package com.floatingbutton.app

import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import com.huawei.hms.ads.AdListener
import com.huawei.hms.ads.AdParam
import com.huawei.hms.ads.BannerAdSize
import com.huawei.hms.ads.HwAds
import com.huawei.hms.ads.banner.BannerView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** A platform view is created only after the explicit, revocable ad choice. */
class PetalBannerFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val container = FrameLayout(context)
        val allowed = context.getSharedPreferences("prefs_power_button", Context.MODE_PRIVATE)
            .getBoolean("petal_ads_consent_v1", false)
        var banner: BannerView? = null
        if (allowed) {
            try {
                HwAds.init(context.applicationContext)
                // 1 = ALLOW_NON_PERSONALIZED. Never request personalized ads here.
                HwAds.setRequestOptions(HwAds.getRequestOptions().toBuilder()
                    .setNonPersonalizedAd(1).build())
                val test = (args as? Map<*, *>)?.get("test") == true
                banner = BannerView(context).apply {
                    adId = if (test) "testw6vs28auh3" else "i3kcblwkv6"
                    bannerAdSize = BannerAdSize.BANNER_SIZE_320_50
                    setBannerRefresh(60)
                    adListener = object : AdListener() {
                        override fun onAdFailed(errorCode: Int) {
                            Log.w("PetalBanner", "Banner unavailable: $errorCode")
                        }
                    }
                }
                container.addView(banner)
                banner.loadAd(AdParam.Builder().build())
            } catch (e: Exception) {
                Log.w("PetalBanner", "Unable to initialize banner", e)
                banner?.destroy()
                banner = null
            }
        }
        return object : PlatformView {
            override fun getView(): View = container
            override fun dispose() { banner?.destroy() }
        }
    }
}
