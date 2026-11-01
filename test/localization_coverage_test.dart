import 'package:flutter_test/flutter_test.dart';
import 'package:floating_power_button/core/common_strings.dart';
import 'package:floating_power_button/core/critical_strings.dart';
import 'package:floating_power_button/core/localization.dart';
import 'package:floating_power_button/core/support_strings.dart';
import 'package:floating_power_button/core/privacy_translations.dart';
import 'package:floating_power_button/core/extra_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('privacy and permission catalogs cover all advertised languages', () {
    for (final language in SupportedLanguage.values) {
      if (language == SupportedLanguage.system) continue;
      AppStrings.currentLanguage = language;
      final code = AppStrings.effectiveLanguageCode;
      expect(criticalStrings[code], hasLength(13), reason: code);
      expect(commonStrings[code], hasLength(16), reason: code);
      expect(supportStrings[code], hasLength(13), reason: code);
      expect(extraStrings[code], hasLength(9), reason: code);
      if (!['en', 'vi', 'zh'].contains(code)) {
        expect(privacyTranslations[code], isNotEmpty, reason: code);
      }
      expect(criticalStrings[code]!.every((s) => s.isNotEmpty), isTrue);
      expect(commonStrings[code]!.every((s) => s.isNotEmpty), isTrue);
    }
    AppStrings.currentLanguage = SupportedLanguage.system;
  });

  test('unknown saved language falls back safely to system', () {
    expect(AppStrings.languageFromName('not-a-language'), SupportedLanguage.system);
    expect(AppStrings.languageFromName('chinese'), SupportedLanguage.chinese);
  });
}
