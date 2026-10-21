import 'package:flutter/services.dart';

class DeviceInfo {
  final String manufacturer;
  final String brand;
  final String model;
  final int sdkInt;

  DeviceInfo({
    required this.manufacturer,
    required this.brand,
    required this.model,
    required this.sdkInt,
  });

  bool get isHuawei =>
      manufacturer.toUpperCase().contains('HUAWEI') || brand.toUpperCase().contains('HONOR');

  bool get isXiaomi =>
      manufacturer.toUpperCase().contains('XIAOMI') ||
      brand.toUpperCase().contains('REDMI') ||
      brand.toUpperCase().contains('POCO');

  bool get isSamsung => manufacturer.toUpperCase().contains('SAMSUNG');

  bool get isOppoRealme =>
      manufacturer.toUpperCase().contains('OPPO') || brand.toUpperCase().contains('REALME');

  bool get isVivo => manufacturer.toUpperCase().contains('VIVO');

  String get friendlyName {
    if (isHuawei) return 'Huawei ($model)';
    if (isXiaomi) return 'Xiaomi / Redmi ($model)';
    if (isSamsung) return 'Samsung ($model)';
    if (isOppoRealme) return 'Oppo / Realme ($model)';
    if (isVivo) return 'Vivo ($model)';
    return '$brand $model';
  }
}

class ChannelBridge {
  static const MethodChannel _channel = MethodChannel('com.floatingbutton.app/bridge');

  /// Fetches hardware & manufacturer details for smart device-specific UX.
  static Future<DeviceInfo> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic>? result =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('getDeviceInfo');
      if (result != null) {
        return DeviceInfo(
          manufacturer: result['manufacturer']?.toString() ?? '',
          brand: result['brand']?.toString() ?? '',
          model: result['model']?.toString() ?? '',
          sdkInt: (result['sdkInt'] as num?)?.toInt() ?? 28,
        );
      }
    } catch (_) {}
    return DeviceInfo(manufacturer: '', brand: '', model: '', sdkInt: 28);
  }

  /// Checks if Accessibility permission is enabled in Android Settings.
  static Future<bool> checkAccessibilityPermission() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('checkAccessibilityPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the AccessibilityService IPC binder is currently active in memory.
  static Future<bool> isServiceConnected() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isServiceConnected');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens the system Accessibility Settings screen.
  static Future<bool> requestAccessibilityPermission() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('requestAccessibilityPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Checks if Device Administrator is active (100% immune to app close / OEM task killing).
  static Future<bool> checkDeviceAdminActive() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('checkDeviceAdminActive');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests Device Administrator permission.
  static Future<bool> requestDeviceAdmin() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('requestDeviceAdmin');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Deactivates Device Administrator permission (Required for Google Play uninstall policy).
  static Future<bool> deactivateDeviceAdmin() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('deactivateDeviceAdmin');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens manufacturer-specific App Launch / Autostart settings (Huawei, Xiaomi, Samsung, Oppo, Vivo).
  static Future<bool> openManufacturerSettings() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('openManufacturerSettings');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests POST_NOTIFICATIONS (Android 13+). Returns true if notifications
  /// are allowed - required for the keep-alive icon to appear in status bar.
  static Future<bool> requestNotificationPermission() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('requestNotificationPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Starts the silent Foreground Keep-Alive service to protect Accessibility from being force-stopped.
  static Future<bool> startKeepAliveService() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('startKeepAliveService');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Stops the Foreground Keep-Alive service.
  static Future<bool> stopKeepAliveService() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('stopKeepAliveService');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Checks whether the Keep-Alive service is running.
  static Future<bool> isKeepAliveRunning() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isKeepAliveRunning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Checks whether battery optimization is ignored (Unrestricted).
  static Future<bool> checkBatteryOptimization() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('checkBatteryOptimization');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests exemption from battery optimizations.
  static Future<bool> requestBatteryOptimization() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('requestBatteryOptimization');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Invokes screen lock (Accessibility GLOBAL_ACTION_LOCK_SCREEN with Device Admin fallback).
  static Future<bool> performLockScreen() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('performLockScreen');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Invokes AudioManager system volume panel without altering volume level.
  static Future<bool> performVolumeUI() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('performVolumeUI');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the user has supported / removed ads.
  static Future<bool> isAdsRemoved() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isAdsRemoved');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Saves the ad-free / supported status permanently in native SharedPreferences.
  static Future<bool> setAdsRemoved(bool removed) async {
    try {
      final bool? result =
          await _channel.invokeMethod<bool>('setAdsRemoved', {'removed': removed});
      return result ?? true;
    } catch (_) {
      return false;
    }
  }
}
