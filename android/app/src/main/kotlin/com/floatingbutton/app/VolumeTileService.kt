package com.floatingbutton.app

import android.os.Build
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.N)
class VolumeTileService : TileService() {

    override fun onClick() {
        super.onClick()
        VolumeController.showVolumeUI(this)
    }
}
