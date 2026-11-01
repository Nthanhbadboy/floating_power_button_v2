import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_power_button/core/localization.dart';
import 'package:floating_power_button/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.floatingbutton.app/bridge');
  final calls = <String>[];
  var running = false;
  var notificationGranted = true;

  setUp(() {
    AppStrings.currentLanguage = SupportedLanguage.english;
    calls.clear();
    running = false;
    notificationGranted = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'getDeviceInfo': return <String, dynamic>{};
        case 'isKeepAliveRunning': return running;
        case 'requestNotificationPermission': return notificationGranted;
        case 'startKeepAliveService': running = true; return true;
        case 'stopKeepAliveService': running = false; return true;
        default: return false;
      }
    });
  });
  tearDown(() {
    AppStrings.currentLanguage = SupportedLanguage.system;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('service only starts after explicit confirmation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(Switch), 300);
    tester.widget<Switch>(find.byType(Switch)).onChanged!(true);
    await tester.pumpAndSettle();
    expect(find.text('Enable quick controls?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, isNot(contains('startKeepAliveService')));

    tester.widget<Switch>(find.byType(Switch)).onChanged!(true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(calls, contains('startKeepAliveService'));
    expect(running, isTrue);
  });
  testWidgets('denying notifications does not start foreground service', (tester) async {
    notificationGranted = false;
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(Switch), 300);
    tester.widget<Switch>(find.byType(Switch)).onChanged!(true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable'));
    await tester.pumpAndSettle();
    expect(calls, isNot(contains('startKeepAliveService')));
    expect(running, isFalse);
  });

}
