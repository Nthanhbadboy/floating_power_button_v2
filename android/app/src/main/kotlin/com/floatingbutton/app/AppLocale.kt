package com.floatingbutton.app

import android.content.Context
import android.content.res.Configuration
import java.util.Locale

/** Applies the in-app language choice to notifications and native messages. */
object AppLocale {
    private val codes = mapOf(
        "vietnamese" to "vi", "english" to "en", "chinese" to "zh-CN",
        "spanish" to "es", "japanese" to "ja", "korean" to "ko",
        "french" to "fr", "german" to "de", "russian" to "ru",
        "portuguese" to "pt", "indonesian" to "id", "arabic" to "ar",
        "hindi" to "hi", "italian" to "it", "dutch" to "nl",
        "polish" to "pl", "czech" to "cs", "tagalog" to "fil"
    )

    fun text(context: Context, id: Int): String {
        val name = context.getSharedPreferences("prefs_power_button", Context.MODE_PRIVATE)
            .getString("selected_language", "system") ?: "system"
        val code = codes[name] ?: return context.getString(id)
        val configuration = Configuration(context.resources.configuration)
        configuration.setLocale(Locale.forLanguageTag(code))
        return context.createConfigurationContext(configuration).getString(id)
    }
}
