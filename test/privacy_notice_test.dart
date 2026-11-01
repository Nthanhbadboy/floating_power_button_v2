import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_power_button/widgets/privacy_notice.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.floatingbutton.app/bridge');
  var acknowledged = false;
  var openCount = 0;

  setUp(() {
    acknowledged = false;
    openCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'hasAcknowledgedPrivacy': return acknowledged;
        case 'acknowledgePrivacy': acknowledged = true; return true;
        case 'openPrivacyPolicy': openCount++; return true;
        case 'getDeviceInfo': return <String, dynamic>{};
        default: return false;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('first launch offers policy and records acknowledgement', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyGate()));
    await tester.pumpAndSettle();
    expect(find.text('Privacy policy'), findsOneWidget);
    await tester.tap(find.text('Read privacy policy'));
    await tester.pump();
    expect(openCount, 1);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(acknowledged, isTrue);
    expect(find.text('Read privacy policy'), findsNothing);
  });

  testWidgets('notice can be read in Chinese', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyGate()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('简体中文').last);
    await tester.pumpAndSettle();
    expect(find.text('阅读隐私政策'), findsOneWidget);
  });

  testWidgets('acknowledged notice is not repeated', (tester) async {
    acknowledged = true;
    await tester.pumpWidget(const MaterialApp(home: PrivacyGate()));
    await tester.pumpAndSettle();
    expect(find.text('Read privacy policy'), findsNothing);
  });
}
