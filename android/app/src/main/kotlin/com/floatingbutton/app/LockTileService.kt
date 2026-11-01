package com.floatingbutton.app

import android.os.Build
import android.service.quicksettings.TileService
import android.widget.Toast
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.N)
class LockTileService : TileService() {

    override fun onClick() {
        super.onClick()
        val success = PowerAccessibilityService.lockScreen(this)
        if (!success) {
            Toast.makeText(
                this,
                AppLocale.text(this, R.string.tile_missing_permission),
                Toast.LENGTH_LONG
            ).show()
        }
    }
}
