import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:floating_power_button/core/channel_bridge.dart';
import 'package:floating_power_button/core/localization.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.floatingbutton.app/bridge');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'getDeviceInfo':
          return {
            'manufacturer': 'HUAWEI',
            'brand': 'HUAWEI',
            'model': 'Mate 20X',
            'sdkInt': 29,
          };
        case 'checkAccessibilityPermission':
          return true;
        case 'isServiceConnected':
          return true;
        case 'checkDeviceAdminActive':
          return true;
        case 'requestDeviceAdmin':
          return true;
        case 'deactivateDeviceAdmin':
          return true;
        case 'isKeepAliveRunning':
          return true;
        case 'openManufacturerSettings':
          return true;
        case 'startKeepAliveService':
          return true;
        case 'stopKeepAliveService':
          return true;
        case 'checkBatteryOptimization':
          return true;
        case 'requestBatteryOptimization':
          return true;
        case 'performLockScreen':
          return true;
        case 'performVolumeUI':
          return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Power & Volume Channel Bridge Tests', () {
    test('getDeviceInfo returns accurate manufacturer and model', () async {
      final dev = await ChannelBridge.getDeviceInfo();
      expect(dev.manufacturer, equals('HUAWEI'));
      expect(dev.isHuawei, isTrue);
      expect(dev.friendlyName, contains('Mate 20X'));
    });

    test('checkAccessibilityPermission calls channel and returns true', () async {
      final result = await ChannelBridge.checkAccessibilityPermission();
      expect(result, isTrue);
      expect(log.any((call) => call.method == 'checkAccessibilityPermission'), isTrue);
    });

    test('checkDeviceAdminActive and deactivateDeviceAdmin call channel', () async {
      final active = await ChannelBridge.checkDeviceAdminActive();
      expect(active, isTrue);
      final deactivated = await ChannelBridge.deactivateDeviceAdmin();
      expect(deactivated, isTrue);
      expect(log.any((call) => call.method == 'deactivateDeviceAdmin'), isTrue);
    });

    test('openManufacturerSettings invokes channel', () async {
      final result = await ChannelBridge.openManufacturerSettings();
      expect(result, isTrue);
      expect(log.any((call) => call.method == 'openManufacturerSettings'), isTrue);
    });

    test('performLockScreen invokes native action without delay', () async {
      final result = await ChannelBridge.performLockScreen();
      expect(result, isTrue);
      expect(log.any((call) => call.method == 'performLockScreen'), isTrue);
    });

    test('performVolumeUI invokes native action', () async {
      final result = await ChannelBridge.performVolumeUI();
      expect(result, isTrue);
      expect(log.any((call) => call.method == 'performVolumeUI'), isTrue);
    });
  });

  group('Localization and Multi-OEM Guides Tests', () {
    test('AppStrings supports system default and manual switching', () {
      AppStrings.currentLanguage = SupportedLanguage.vietnamese;
      expect(AppStrings.isVietnamese(), isTrue);
      expect(AppStrings.lockScreenBtn, equals('KHÓA MÀN HÌNH'));

      AppStrings.currentLanguage = SupportedLanguage.english;
      expect(AppStrings.isVietnamese(), isFalse);
      expect(AppStrings.lockScreenBtn, equals('LOCK SCREEN'));

      AppStrings.currentLanguage = SupportedLanguage.chinese;
      expect(AppStrings.lockScreenBtn, equals('立即锁屏'));

      AppStrings.currentLanguage = SupportedLanguage.spanish;
      expect(AppStrings.lockScreenBtn, equals('BLOQUEAR PANTALLA'));
    });

    test('OEM guides return instructions and deep-links for all manufacturers', () {
      final dev = DeviceInfo(manufacturer: 'HUAWEI', brand: 'HUAWEI', model: 'Mate 20X', sdkInt: 29);
      for (final oem in ['huawei', 'xiaomi', 'samsung', 'oppo', 'vivo', 'stock']) {
        final guideVi = AppStrings.getOemInstructions(oem, dev);
        expect(guideVi.isNotEmpty, isTrue);
        final labelVi = AppStrings.getOemButtonLabel(oem);
        expect(labelVi.isNotEmpty, isTrue);
      }
    });
  });
}
