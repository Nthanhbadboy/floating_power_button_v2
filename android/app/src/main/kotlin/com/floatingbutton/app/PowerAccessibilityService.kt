package com.floatingbutton.app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityManager

class PowerAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "PowerAccessibility"

        @Volatile
        var instance: PowerAccessibilityService? = null
            private set

        /**
         * Checks whether the service instance is currently bound and active in memory.
         */
        fun isServiceConnected(): Boolean {
            return instance != null
        }

        /**
         * Checks whether the user has granted Accessibility permission in Android Settings.
         */
        fun isAccessibilityEnabledInSettings(context: Context): Boolean {
            // Method 1: AccessibilityManager API
            try {
                val am = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as? AccessibilityManager
                if (am != null) {
                    val enabledServices = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
                    for (info in enabledServices) {
                        val pkg = info.resolveInfo?.serviceInfo?.packageName
                        val name = info.resolveInfo?.serviceInfo?.name
                        if (pkg == context.packageName && name?.contains("PowerAccessibilityService") == true) {
                            return true
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "AccessibilityManager query error", e)
            }

            // Method 2: Settings.Secure query
            try {
                val enabledServices = Settings.Secure.getString(
                    context.contentResolver,
                    Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                )
                if (!enabledServices.isNullOrEmpty()) {
                    val colonSplitter = TextUtils.SimpleStringSplitter(':')
                    colonSplitter.setString(enabledServices)
                    while (colonSplitter.hasNext()) {
                        val component = colonSplitter.next()
                        if (component.contains(context.packageName, ignoreCase = true) &&
                            component.contains("PowerAccessibilityService", ignoreCase = true)
                        ) {
                            return true
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "Settings.Secure query error", e)
            }

            return false
        }

        /**
         * Checks whether Device Administrator is active.
         */
        fun isDeviceAdminActive(context: Context): Boolean {
            return try {
                val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as? DevicePolicyManager
                val adminComponent = ComponentName(context, PowerDeviceAdminReceiver::class.java)
                dpm?.isAdminActive(adminComponent) == true
            } catch (e: Exception) {
                false
            }
        }

        /**
         * Deactivates Device Administrator so user can easily uninstall the app (Google Play compliance).
         */
        fun deactivateDeviceAdmin(context: Context): Boolean {
            return try {
                val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as? DevicePolicyManager
                val adminComponent = ComponentName(context, PowerDeviceAdminReceiver::class.java)
                dpm?.removeActiveAdmin(adminComponent)
                Log.i(TAG, "Device Administrator successfully deactivated.")
                true
            } catch (e: Exception) {
                Log.e(TAG, "Failed to deactivate Device Administrator", e)
                false
            }
        }

        /**
         * Synchronous lock screen (used by Quick Settings LockTileService).
         */
        fun lockScreen(context: Context): Boolean {
            // 1. Device Administrator (Instant lock, 0 delay)
            if (isDeviceAdminActive(context)) {
                try {
                    val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as? DevicePolicyManager
                    dpm?.lockNow()
                    return true
                } catch (e: Exception) {
                    Log.e(TAG, "Device Admin lockNow failed", e)
                }
            }

            // 2. Bound Accessibility Service (GLOBAL_ACTION_LOCK_SCREEN)
            instance?.let { service ->
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    val ok = service.performGlobalAction(GLOBAL_ACTION_LOCK_SCREEN)
                    if (ok) return true
                }
            }

            return false
        }

        /**
         * Asynchronous lock screen (used by Flutter MethodChannel):
         * - If Device Admin is active -> locks immediately in 0ms.
         * - If AccessibilityService is bound -> locks immediately in 0ms.
         * - If instance == null but permission is granted in Settings -> waits non-blockingly
         *   via Handler.postDelayed on Main Looper (up to 800ms) without freezing UI.
         */
        fun lockScreenAsync(context: Context, callback: (Boolean) -> Unit) {
            // Check Device Admin first (0ms)
            if (isDeviceAdminActive(context)) {
                try {
                    val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as? DevicePolicyManager
                    dpm?.lockNow()
                    Log.i(TAG, "Screen locked instantly via Device Administrator.")
                    callback(true)
                    return
                } catch (e: Exception) {
                    Log.e(TAG, "Device Admin lockNow failed", e)
                }
            }

            // Check if Accessibility is already bound (0ms)
            instance?.let { service ->
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    val ok = service.performGlobalAction(GLOBAL_ACTION_LOCK_SCREEN)
                    Log.i(TAG, "Screen locked via bound AccessibilityService: $ok")
                    if (ok) {
                        callback(true)
                        return
                    }
                }
            }

            // If accessibility is enabled in settings, wait up to 800ms non-blockingly
            if (isAccessibilityEnabledInSettings(context)) {
                val handler = Handler(Looper.getMainLooper())
                val startTime = System.currentTimeMillis()
                val timeoutMs = 800L

                val checkRunnable = object : Runnable {
                    override fun run() {
                        instance?.let { service ->
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                val ok = service.performGlobalAction(GLOBAL_ACTION_LOCK_SCREEN)
                                Log.i(TAG, "Screen locked via AccessibilityService after async binder wait: $ok")
                                if (ok) {
                                    callback(true)
                                    return
                                }
                            }
                        }

                        if (System.currentTimeMillis() - startTime < timeoutMs) {
                            handler.postDelayed(this, 40)
                        } else {
                            Log.w(TAG, "AccessibilityService binder wait timed out after ${timeoutMs}ms.")
                            callback(false)
                        }
                    }
                }
                handler.postDelayed(checkRunnable, 40)
            } else {
                callback(false)
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        try {
            val info = serviceInfo ?: AccessibilityServiceInfo()
            info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            info.flags = AccessibilityServiceInfo.DEFAULT
            serviceInfo = info
        } catch (e: Exception) {
            Log.w(TAG, "Error configuring serviceInfo", e)
        }
        Log.i(TAG, "PowerAccessibilityService successfully bound and connected.")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Keeps binder warm
    }

    override fun onInterrupt() {
        Log.w(TAG, "PowerAccessibilityService interrupted.")
    }

    override fun onDestroy() {
        super.onDestroy()
        if (instance == this) {
            instance = null
        }
        Log.i(TAG, "PowerAccessibilityService destroyed.")
    }
}
