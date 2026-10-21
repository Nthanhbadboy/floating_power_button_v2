package com.floatingbutton.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action
        if (action == Intent.ACTION_BOOT_COMPLETED || action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            Log.i("BootReceiver", "Boot completed or package replaced: restoring keep-alive service.")
            
            // If accessibility is enabled in settings or device admin is active, restart keep-alive service
            val isA11y = PowerAccessibilityService.isAccessibilityEnabledInSettings(context)
            val isAdmin = PowerAccessibilityService.isDeviceAdminActive(context)

            if (isA11y || isAdmin) {
                val serviceIntent = Intent(context, KeepAliveService::class.java).apply {
                    this.action = KeepAliveService.ACTION_START
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.i("BootReceiver", "KeepAliveService restored after reboot.")
            }
        }
    }
}
