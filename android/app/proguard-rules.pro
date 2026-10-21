# Minimal R8 / ProGuard rules for floating_power_button v2 (release minimal-size).
# Flutter wrapper already applies tree-shaking; these rules only protect
# reflection / manifest-referenced entry points from over-shrinking.

# Flutter embedding (required by official Flutter template when minify enabled).
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# AccessibilityService + Quick Settings Tiles are instantiated by the OS
# via AndroidManifest.xml, not by direct Java references - never strip them.
-keep public class com.floatingbutton.app.PowerAccessibilityService extends android.accessibilityservice.AccessibilityService { *; }
-keep public class com.floatingbutton.app.LockTileService extends android.service.quicksettings.TileService { *; }
-keep public class com.floatingbutton.app.VolumeTileService extends android.service.quicksettings.TileService { *; }
-keep public class com.floatingbutton.app.MainActivity extends io.flutter.embedding.android.FlutterActivity { *; }
-keep class com.floatingbutton.app.VolumeController { *; }
-keep class com.floatingbutton.app.PowerDeviceAdminReceiver extends android.app.admin.DeviceAdminReceiver { *; }
-keep class com.floatingbutton.app.KeepAliveService extends android.app.Service { *; }
-keep class com.floatingbutton.app.BootCompletedReceiver extends android.content.BroadcastReceiver { *; }

# androidx / kotlin coroutines used by services.
-keep class androidx.core.** { *; }
-dontwarn androidx.**
-dontwarn kotlinx.coroutines.**
