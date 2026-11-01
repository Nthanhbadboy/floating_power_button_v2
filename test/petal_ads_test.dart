import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_power_button/core/ads_strings.dart';
import 'package:floating_power_button/core/localization.dart';
import 'package:floating_power_button/screens/home_screen.dart';
import 'package:floating_power_button/widgets/petal_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const bridge = MethodChannel('com.floatingbutton.app/bridge');
  bool? choice;
  var saveSucceeds = true;
  final calls = <String>[];

  setUp(() {
    choice = null;
    saveSucceeds = true;
    calls.clear();
    AppStrings.currentLanguage = SupportedLanguage.english;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(bridge, (call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'getPetalAdsChoice': return choice;
        case 'setPetalAdsChoice':
          if (saveSucceeds) choice = call.arguments['allowed'] as bool;
          return saveSucceeds;
        case 'getDeviceInfo': return <String, dynamic>{};
        default: return false;
      }
    });
  });

  tearDown(() {
    AppStrings.currentLanguage = SupportedLanguage.system;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(bridge, null);
  });

  test('ad disclosure covers all supported languages', () {
    for (final language in SupportedLanguage.values) {
      if (language == SupportedLanguage.system) continue;
      AppStrings.currentLanguage = language;
      final strings = adsStrings[AppStrings.effectiveLanguageCode];
      expect(strings, hasLength(5));
      expect(strings!.every((s) => s.isNotEmpty), isTrue);
      expect(strings[1], contains('Petal Ads'));
    }
  });

  testWidgets('ad choice is separate and refusal is persisted without a native view', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Advertising choice'), findsOneWidget);
    expect(find.byType(AndroidView), findsNothing);
    await tester.tap(find.text('No ads'));
    await tester.pumpAndSettle();
    expect(choice, isFalse);
    expect(find.byType(AndroidView), findsNothing);
    expect(tester.widget<PetalBanner>(find.byType(PetalBanner)).allowed, isFalse);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Advertising choice'), findsNothing);
    expect(find.byType(AndroidView), findsNothing);
  });

  testWidgets('failed consent save never enables advertising', (tester) async {
    saveSucceeds = false;
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow ads'));
    await tester.pumpAndSettle();
    expect(calls, contains('setPetalAdsChoice'));
    expect(find.byType(AndroidView), findsNothing);
    expect(tester.widget<PetalBanner>(find.byType(PetalBanner)).allowed, isFalse);
  });
}
