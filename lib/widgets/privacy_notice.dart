import 'package:flutter/material.dart';
import '../core/channel_bridge.dart';
import '../core/localization.dart';
import '../core/ads_strings.dart';
import '../core/privacy_translations.dart';
import '../screens/home_screen.dart';

/// First-run notice for new installations and upgrades from older versions.
class PrivacyGate extends StatefulWidget {
  const PrivacyGate({super.key});

  @override
  State<PrivacyGate> createState() => _PrivacyGateState();
}

class _PrivacyGateState extends State<PrivacyGate> {
  bool? _acknowledged;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final savedLanguage = await ChannelBridge.getSelectedLanguage();
    final acknowledged = await ChannelBridge.hasAcknowledgedPrivacy();
    if (!mounted) return;
    AppStrings.currentLanguage = AppStrings.languageFromName(savedLanguage);
    setState(() => _acknowledged = acknowledged);
  }

  @override
  Widget build(BuildContext context) {
    if (_acknowledged == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_acknowledged!) return const HomeScreen();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Dialog(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButton<SupportedLanguage>(
                      value: AppStrings.currentLanguage,
                      isExpanded: true,
                      items: AppStrings.languageNames.entries.map((entry) =>
                          DropdownMenuItem(value: entry.key,
                              child: Text(entry.value, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => AppStrings.currentLanguage = value);
                          ChannelBridge.setSelectedLanguage(value.name);
                        }
                      },
                    ),
                  ),
                  const Icon(Icons.privacy_tip_outlined, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(AppStrings.critical(0), style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Text(AppStrings.critical(1)),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => openPrivacyPolicy(context),
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: Text(AppStrings.critical(2)),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _saving ? null : () async {
                      setState(() => _saving = true);
                      final saved = await ChannelBridge.acknowledgePrivacy();
                      if (!context.mounted) return;
                      setState(() {
                        _saving = false;
                        _acknowledged = saved;
                      });
                      if (!saved) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(AppStrings.extra(7)),
                        ));
                      }
                    },
                    child: Text(AppStrings.critical(3)),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}

Future<void> openPrivacyPolicy(BuildContext context, {String? language}) async {
  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const PrivacyPolicyScreen(),
  ));
}

/// Available offline in all 18 supported languages.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late String _policyLanguage;

  @override
  void initState() {
    super.initState();
    _policyLanguage = AppStrings.effectiveLanguageCode;
  }

  static const _english = '''App name: Power&volume
Developer: NGUYEN MINH THANH
Contact: alphaplusthanh82@gmail.com
Updated: 1 November 2026

Purpose and information
Power&volume locks the screen and opens the system volume controls. The app has no account or sign-in. It reads the device manufacturer and model locally to suggest settings, and saves the language, privacy notice acknowledgement and quick-control preference on your device. The app itself does not transmit these settings to the developer.

Permissions
Accessibility is optional and used to lock the screen only when you request it; this app does not read screen contents or typed text. Device administrator is an optional alternative for screen locking and can be disabled in the app. Notifications and the foreground service are optional: after you enable quick controls, a persistent notification provides lock and volume buttons. The service may restart after a reboot or update while enabled. Battery settings are optional and controlled by you in Android settings.

Other services and your choices
If you open the online policy or use an external banking service to support the developer, that external service handles information under its own policy. The app does not process donations itself. Android and your device manufacturer may process information under their own policies. You can change settings or remove app data through Android settings; disabling Device Administrator may be required before uninstalling.

Questions or changes
Contact NGUYEN MINH THANH at the email above. The current online policy is linked below.''';

  static const _vietnamese = '''Tên ứng dụng: Power&volume
Nhà phát triển: NGUYEN MINH THANH
Liên hệ: alphaplusthanh82@gmail.com
Cập nhật: 01/11/2026

Mục đích và thông tin
Power&volume khóa màn hình và mở điều khiển âm lượng hệ thống. Ứng dụng không có tài khoản hoặc đăng nhập. Ứng dụng đọc hãng và mẫu máy tại thiết bị để gợi ý cài đặt; lựa chọn ngôn ngữ, xác nhận đã xem thông báo quyền riêng tư và tùy chọn điều khiển nhanh được lưu trên thiết bị. Ứng dụng không gửi các cài đặt này cho nhà phát triển.

Quyền truy cập
Trợ năng là tùy chọn và chỉ dùng để khóa màn hình khi bạn yêu cầu; ứng dụng không đọc nội dung màn hình hoặc văn bản đã nhập. Quản trị viên thiết bị là cách khóa màn hình tùy chọn khác và có thể tắt trong app. Thông báo và dịch vụ tiền cảnh là tùy chọn: sau khi bạn bật điều khiển nhanh, thông báo liên tục hiển thị nút khóa và âm lượng. Dịch vụ có thể khởi động lại sau khi máy khởi động hoặc app cập nhật nếu bạn vẫn bật. Cài đặt pin là tùy chọn do bạn điều chỉnh trong Android.

Dịch vụ khác và lựa chọn của bạn
Nếu bạn mở chính sách trực tuyến hoặc sử dụng dịch vụ ngân hàng bên ngoài để ủng hộ tác giả, dịch vụ đó xử lý thông tin theo chính sách riêng. App không tự xử lý khoản ủng hộ. Android và nhà sản xuất thiết bị có thể xử lý thông tin theo chính sách của họ. Bạn có thể thay đổi cài đặt hoặc xóa dữ liệu ứng dụng trong Android; có thể cần tắt Quản trị viên thiết bị trước khi gỡ app.

Liên hệ và thay đổi
Liên hệ NGUYEN MINH THANH qua email trên. Liên kết chính sách trực tuyến được cung cấp bên dưới.''';

  static const _chinese = '''应用名称：Power&volume
开发者：NGUYEN MINH THANH
联系邮箱：alphaplusthanh82@gmail.com
更新日期：2026年11月1日

用途和信息
Power&volume 用于锁定屏幕和打开系统音量控制。本应用没有账户或登录功能。本应用在设备上读取设备制造商和型号，用于提供设置建议；语言选择、隐私提示确认和快捷控制偏好保存在设备上。本应用不会将这些设置发送给开发者。

权限用途
无障碍服务为可选项，仅在您请求时用于锁屏；本应用不读取屏幕内容或输入的文字。设备管理员是可选的另一种锁屏方式，可在应用内关闭。通知和前台服务均为可选项：当您启用快捷控制后，常驻通知将提供锁屏和音量按钮。若保持启用，设备重启或应用更新后服务可能再次启动。电池设置为可选项，由您在 Android 设置中控制。

其他服务和您的选择
如果您打开在线政策，或使用外部银行服务支持开发者，这些外部服务将按照其自身政策处理信息。本应用不直接处理捐赠。Android 和设备制造商可能根据各自政策处理信息。您可在 Android 设置中修改设置或清除应用数据；卸载前可能需要先关闭设备管理员。

联系与更新
如有问题，请通过以上邮箱联系 NGUYEN MINH THANH。最新在线政策链接如下。''';

  @override
  Widget build(BuildContext context) {
    final content = _policyLanguage == 'zh' ? _chinese :
        _policyLanguage == 'vi' ? _vietnamese :
        _policyLanguage == 'en' ? _english :
        'Power&volume\nNGUYEN MINH THANH\nalphaplusthanh82@gmail.com\n2026-11-01\n\n${privacyTranslations[_policyLanguage]!}';
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.critical(0))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(AppStrings.critical(12)),
          DropdownButton<String>(
            value: _policyLanguage,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              DropdownMenuItem(value: 'zh', child: Text('简体中文')),
              DropdownMenuItem(value: 'es', child: Text('Español')),
              DropdownMenuItem(value: 'ja', child: Text('日本語')),
              DropdownMenuItem(value: 'ko', child: Text('한국어')),
              DropdownMenuItem(value: 'fr', child: Text('Français')),
              DropdownMenuItem(value: 'de', child: Text('Deutsch')),
              DropdownMenuItem(value: 'ru', child: Text('Русский')),
              DropdownMenuItem(value: 'pt', child: Text('Português')),
              DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
              DropdownMenuItem(value: 'ar', child: Text('العربية')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
              DropdownMenuItem(value: 'it', child: Text('Italiano')),
              DropdownMenuItem(value: 'nl', child: Text('Nederlands')),
              DropdownMenuItem(value: 'pl', child: Text('Polski')),
              DropdownMenuItem(value: 'cs', child: Text('Čeština')),
              DropdownMenuItem(value: 'tl', child: Text('Tagalog')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _policyLanguage = value);
            },
          ),
          Directionality(
            textDirection: _policyLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: SelectableText('$content\n\n${adsStrings[_policyLanguage]![1]}\n\nhttps://consumer.huawei.com/en/privacy/privacy-policy/', style: const TextStyle(fontSize: 15, height: 1.5)),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              final opened = await ChannelBridge.openPrivacyPolicy();
              if (!opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppStrings.extra(8)),
                ));
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('https://power-volume-privacy.vercel.app/privacy-policy.html'),
          ),
        ],
      ),
    );
  }
}
