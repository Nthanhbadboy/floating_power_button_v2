package com.floatingbutton.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationManagerCompat

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action
        if (action == Intent.ACTION_BOOT_COMPLETED || action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            // An Accessibility or Device Admin grant is not consent to run a
            // foreground service. Only restore a service explicitly enabled by the user.
            val enabled = context.getSharedPreferences("prefs_power_button", Context.MODE_PRIVATE)
                .getBoolean("keep_alive_explicitly_enabled_v2", false)
            if (!enabled || !NotificationManagerCompat.from(context).areNotificationsEnabled()) return

            val serviceIntent = Intent(context, KeepAliveService::class.java).apply {
                this.action = KeepAliveService.ACTION_START
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            } catch (e: Exception) {
                // Android/OEM restrictions may prohibit starting a foreground service
                // from a broadcast; the user can start it again in the app.
                Log.w("BootReceiver", "Could not restore quick controls", e)
            }
        }
    }
}
