import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:huawei_ads/huawei_ads.dart';

/// Petal Ads (Huawei Ads Kit) configuration.
///
/// Values come from Petal Ads Console (Publisher Service):
///  * App ID      : 119378375   (informational - the SDK identifies the app by
///                               its package name `com.floatingbutton.app`)
///  * Banner slot : i3kcblwkv6  (Ad unit ID = "ad slot id" in the SDK)
class AdConfig {
  AdConfig._();

  static const String appId = '119378375';

  /// Real banner ad unit created in Petal Ads Console.
  static const String _productionBannerId = String.fromEnvironment(
    'PETAL_BANNER_ID',
    defaultValue: 'i3kcblwkv6',
  );

  /// Huawei's official TEST banner slot - always returns a sample ad.
  static const String testBannerId = 'testw6vs28auh3';

  /// Force the test slot even in release (verify wiring before the real ad
  /// unit is released/approved):  --dart-define=PETAL_USE_TEST_ADS=true
  static const bool _forceTest = bool.fromEnvironment('PETAL_USE_TEST_ADS');

  /// Debug builds always use the test slot so you never click your own real
  /// ads (which can get a Petal Ads account suspended).
  static String get bannerSlotId =>
      (kDebugMode || _forceTest) ? testBannerId : _productionBannerId;

  static bool get isSupported => !kIsWeb && Platform.isAndroid;
}

/// Initialises the Petal Ads SDK once.
class AdService {
  AdService._();

  static bool _initialised = false;

  static Future<void> init() async {
    if (_initialised || !AdConfig.isSupported) return;
    _initialised = true;
    try {
      await HwAds.init();
    } catch (e) {
      debugPrint('Petal Ads init failed: $e');
      _initialised = false;
    }
  }
}
