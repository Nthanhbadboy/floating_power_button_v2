package com.floatingbutton.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class KeepAliveService : Service() {

    companion object {
        const val CHANNEL_ID = "keep_alive_service_channel_v2"
        const val LEGACY_CHANNEL_ID = "keep_alive_service_channel"
        const val NOTIFICATION_ID = 2002

        const val ACTION_START = "com.floatingbutton.app.ACTION_START_KEEP_ALIVE"
        const val ACTION_STOP = "com.floatingbutton.app.ACTION_STOP_KEEP_ALIVE"

        var isRunning: Boolean = false
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val enabled = getSharedPreferences("prefs_power_button", Context.MODE_PRIVATE)
            .getBoolean("keep_alive_explicitly_enabled_v2", false)
        if (!enabled || intent?.action == ACTION_STOP) {
            isRunning = false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                @Suppress("DEPRECATION")
                stopForeground(true)
            }
            stopSelf()
            return START_NOT_STICKY
        }

        // Must always ensure foreground notification is attached on every start command
        createNotificationChannel()
        startAsForeground()
        isRunning = true
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            // Drop the legacy MIN-importance channel: MIN never shows a status-bar
            // icon and the old channel config survives app updates otherwise.
            manager?.deleteNotificationChannel(LEGACY_CHANNEL_ID)
            val channel = NotificationChannel(
                CHANNEL_ID,
                getString(R.string.quick_controls_channel),
                // LOW (not MIN): shows the status-bar icon without sound/vibration.
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.quick_controls_channel_description)
                setShowBadge(false)
            }
            manager?.createNotificationChannel(channel)
        }
    }

    private fun activityPendingIntent(requestCode: Int, action: String): PendingIntent {
        val intent = Intent(this, MainActivity::class.java).apply {
            this.action = action
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        return PendingIntent.getActivity(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    private fun startAsForeground() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.quick_controls_title))
            .setContentText(getString(R.string.quick_controls_description))
            .setSmallIcon(R.drawable.ic_lock)
            .setContentIntent(pendingIntent)
            .addAction(
                R.drawable.ic_lock,
                getString(R.string.quick_controls_lock),
                activityPendingIntent(1, MainActivity.ACTION_QUICK_LOCK)
            )
            .addAction(
                R.drawable.ic_volume,
                getString(R.string.quick_controls_volume),
                activityPendingIntent(2, MainActivity.ACTION_QUICK_VOLUME)
            )
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        isRunning = false
        super.onDestroy()
    }
}
