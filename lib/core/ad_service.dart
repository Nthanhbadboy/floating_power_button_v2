import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Central place for AdMob configuration + SDK start-up.
///
/// IDs default to Google's official TEST IDs so the banner always fills while
/// developing. For production pass your own ad unit id at build time:
///
///   ADMOB_BANNER_ID=ca-app-pub-XXXX/YYYY ADMOB_APP_ID=ca-app-pub-XXXX~ZZZZ \
///     ./build_release.sh
///
/// (or `--dart-define=ADMOB_BANNER_ID=...` + `ADMOB_APP_ID=...` in
/// android/gradle.properties).
class AdConfig {
  AdConfig._();

  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/9214589741';

  static const String bannerUnitId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: _testBannerAndroid,
  );

  static bool get isSupported => !kIsWeb && Platform.isAndroid;
}

/// Starts the Google Mobile Ads SDK once (after UMP consent) and tells the UI
/// when ad requests may be made.
class AdService {
  AdService._();

  /// `true` once the SDK is initialised and consent allows requesting ads.
  static final ValueNotifier<bool> ready = ValueNotifier<bool>(false);

  static bool _started = false;

  static Future<void> init() async {
    if (_started || !AdConfig.isSupported) return;
    _started = true;

    try {
      // 1. Consent (EEA / UK / etc.). Shows the Google form only if required.
      final consentDone = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((FormError? e) {
              if (e != null) debugPrint('UMP form error: ${e.message}');
            });
          } catch (e) {
            debugPrint('UMP form exception: $e');
          }
          if (!consentDone.isCompleted) consentDone.complete();
        },
        (FormError error) {
          debugPrint('UMP update error: ${error.message}');
          if (!consentDone.isCompleted) consentDone.complete();
        },
      );
      await consentDone.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {},
      );

      // 2. Only start the SDK if we are allowed to request ads. If UMP could
      //    not be reached (offline) canRequestAds reflects the last known state.
      final canRequest = await ConsentInformation.instance.canRequestAds();
      if (!canRequest) {
        _started = false; // allow a later retry (e.g. app resumed online)
        return;
      }

      await MobileAds.instance.initialize();
      ready.value = true;
    } catch (e) {
      debugPrint('AdService.init failed: $e');
      _started = false;
    }
  }
}
