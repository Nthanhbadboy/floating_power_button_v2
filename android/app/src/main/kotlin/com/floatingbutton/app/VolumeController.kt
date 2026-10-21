package com.floatingbutton.app

import android.content.Context
import android.media.AudioManager
import android.util.Log

object VolumeController {
    private const val TAG = "VolumeController"

    /**
     * Opens the native Android system volume interface without modifying volume.
     * Uses AudioManager.ADJUST_SAME with AudioManager.FLAG_SHOW_UI.
     */
    fun showVolumeUI(context: Context): Boolean {
        return try {
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
            if (audioManager == null) {
                Log.e(TAG, "AudioManager not available on this device.")
                return false
            }
            audioManager.adjustStreamVolume(
                AudioManager.STREAM_MUSIC,
                AudioManager.ADJUST_SAME,
                AudioManager.FLAG_SHOW_UI
            )
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to invoke native system volume UI", e)
            false
        }
    }
}
