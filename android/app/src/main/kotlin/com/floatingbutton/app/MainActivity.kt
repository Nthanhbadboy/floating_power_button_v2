package com.floatingbutton.app

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.floatingbutton.app/bridge"
    private var pendingNotifResult: MethodChannel.Result? = null

    companion object {
        const val ACTION_QUICK_LOCK = "com.floatingbutton.app.ACTION_QUICK_LOCK"
        const val ACTION_QUICK_VOLUME = "com.floatingbutton.app.ACTION_QUICK_VOLUME"
        private const val REQ_POST_NOTIFICATIONS = 1001
    }

    override fun onResume() {
        super.onResume()
        handleShortcuts(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleShortcuts(intent)
    }

    private fun handleShortcuts(intent: Intent?) {
        if (intent == null) return
        when (intent.action) {
            ACTION_QUICK_LOCK -> {
                PowerAccessibilityService.lockScreen(this)
                finish()
            }
            ACTION_QUICK_VOLUME -> {
                VolumeController.showVolumeUI(this)
                finish()
            }
        }
        // Consume the shortcut action so onResume does not re-trigger it.
        setIntent(Intent(this, MainActivity::class.java).setAction(Intent.ACTION_MAIN))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    val info = mapOf(
                        "manufacturer" to Build.MANUFACTURER,
                        "brand" to Build.BRAND,
                        "model" to Build.MODEL,
                        "sdkInt" to Build.VERSION.SDK_INT
                    )
                    result.success(info)
                }

                "checkAccessibilityPermission" -> {
                    val enabled = PowerAccessibilityService.isAccessibilityEnabledInSettings(this)
                    result.success(enabled)
                }

                "isServiceConnected" -> {
                    val connected = PowerAccessibilityService.isServiceConnected()
                    result.success(connected)
                }

                "requestAccessibilityPermission" -> {
                    try {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INTENT_ERROR", "Cannot open Accessibility Settings", e.message)
                    }
                }

                "checkDeviceAdminActive" -> {
                    val active = PowerAccessibilityService.isDeviceAdminActive(this)
                    result.success(active)
                }

                "requestDeviceAdmin" -> {
                    try {
                        val component = ComponentName(this, PowerDeviceAdminReceiver::class.java)
                        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, component)
                            putExtra(
                                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                                "Enable Device Administrator to lock the screen reliably across app-close on Huawei/Xiaomi/Samsung."
                            )
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ADMIN_ERROR", "Cannot request Device Administrator", e.message)
                    }
                }

                "deactivateDeviceAdmin" -> {
                    val success = PowerAccessibilityService.deactivateDeviceAdmin(this)
                    result.success(success)
                }

                "startKeepAliveService" -> {
                    try {
                        val prefs = getSharedPreferences("prefs_power_button", Context.MODE_PRIVATE)
                        prefs.edit().putBoolean("keep_alive_enabled", true).apply()
                        val intent = Intent(this, KeepAliveService::class.java).apply {
                            action = KeepAliveService.ACTION_START
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", "Cannot start keep-alive service", e.message)
                    }
                }

                "stopKeepAliveService" -> {
                    try {
                        val prefs = getSharedPreferences("prefs_power_button", Context.MODE_PRIVATE)
                        prefs.edit().putBoolean("keep_alive_enabled", false).apply()
                        val intent = Intent(this, KeepAliveService::class.java).apply {
                            action = KeepAliveService.ACTION_STOP
                        }
                        startService(intent)
                        stopService(Intent(this, KeepAliveService::class.java))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", "Cannot stop keep-alive service", e.message)
                    }
                }

                "isKeepAliveRunning" -> {
                    val prefs = getSharedPreferences("prefs_power_button", Context.MODE_PRIVATE)
                    val isPrefEnabled = prefs.getBoolean("keep_alive_enabled", true)
                    val isRunning = KeepAliveService.isRunning || isServiceRunning(KeepAliveService::class.java)
                    result.success(isPrefEnabled && isRunning)
                }

                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                        result.success(true)
                    } else if (checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) ==
                        PackageManager.PERMISSION_GRANTED
                    ) {
                        result.success(true)
                    } else {
                        pendingNotifResult = result
                        requestPermissions(
                            arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                            REQ_POST_NOTIFICATIONS
                        )
                    }
                }

                "openManufacturerSettings" -> {
                    val opened = openManufacturerSpecificSettings()
                    result.success(opened)
                }

                "checkBatteryOptimization" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val pm = getSystemService(Context.POWER_SERVICE) as? PowerManager
                        val isIgnoring = pm?.isIgnoringBatteryOptimizations(packageName) ?: false
                        result.success(isIgnoring)
                    } else {
                        result.success(true)
                    }
                }

                "requestBatteryOptimization" -> {
                    // Fully compliant with Google Play: uses standard system settings screen
                    // without requesting the restricted REQUEST_IGNORE_BATTERY_OPTIMIZATIONS permission
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.parse("package:$packageName")
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }

                "performLockScreen" -> {
                    PowerAccessibilityService.lockScreenAsync(this) { success ->
                        result.success(success)
                    }
                }

                "performVolumeUI" -> {
                    val success = VolumeController.showVolumeUI(this)
                    result.success(success)
                }

                "isAdsRemoved" -> {
                    val prefs = getSharedPreferences("prefs_power_button", Context.MODE_PRIVATE)
                    result.success(prefs.getBoolean("ads_removed", false))
                }

                "setAdsRemoved" -> {
                    val removed = call.argument<Boolean>("removed") ?: true
                    val prefs = getSharedPreferences("prefs_power_button", Context.MODE_PRIVATE)
                    prefs.edit().putBoolean("ads_removed", removed).apply()
                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openManufacturerSpecificSettings(): Boolean {
        val manufacturer = Build.MANUFACTURER.uppercase()
        val intents = mutableListOf<Intent>()

        if (manufacturer.contains("HUAWEI") || manufacturer.contains("HONOR")) {
            // Priority 1: Huawei App Launch / Startup Normal App List (EMUI 9.1, 10, 11 on Mate 20X)
            intents.add(Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")))
            // Priority 2: Huawei App Control
            intents.add(Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity")))
            // Priority 3: Huawei Boot Start
            intents.add(Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.bootstart.BootStartActivity")))
            // Priority 4: Huawei Battery Screen (where "App launch" is clearly visible in EMUI)
            intents.add(Intent(Intent.ACTION_POWER_USAGE_SUMMARY))
            // Priority 5: Huawei Optimize Process (Protected Apps)
            intents.add(Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity")))
            // Priority 6: Direct Application Details Settings (opens app info -> Battery -> App launch)
            intents.add(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(Uri.parse("package:$packageName")))
        } else if (manufacturer.contains("XIAOMI") || manufacturer.contains("REDMI") || manufacturer.contains("POCO")) {
            intents.add(Intent().setComponent(ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")))
            intents.add(Intent().setComponent(ComponentName("com.miui.powerkeeper", "com.miui.powerkeeper.ui.HiddenAppsConfigActivity")))
        } else if (manufacturer.contains("OPPO") || manufacturer.contains("REALME")) {
            intents.add(Intent().setComponent(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")))
        } else if (manufacturer.contains("VIVO")) {
            intents.add(Intent().setComponent(ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity")))
            intents.add(Intent().setComponent(ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")))
        } else if (manufacturer.contains("SAMSUNG")) {
            intents.add(Intent().setComponent(ComponentName("com.samsung.android.lool", "com.samsung.android.sm.battery.ui.BatteryActivity")))
        }

        // Standard Android fallback paths
        intents.add(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
        intents.add(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(Uri.parse("package:$packageName")))

        for (intent in intents) {
            try {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
                return true
            } catch (_: Exception) {}
        }
        return false
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQ_POST_NOTIFICATIONS) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingNotifResult?.success(granted)
            pendingNotifResult = null
        }
    }

    private fun isServiceRunning(serviceClass: Class<*>): Boolean {        return try {
            val manager = getSystemService(Context.ACTIVITY_SERVICE) as? android.app.ActivityManager
            if (manager != null) {
                @Suppress("DEPRECATION")
                for (service in manager.getRunningServices(Int.MAX_VALUE)) {
                    if (serviceClass.name == service.service.className) {
                        return true
                    }
                }
            }
            false
        } catch (_: Exception) {
            false
        }
    }
}
