import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/channel_bridge.dart';
import '../core/localization.dart';
import '../screens/home_screen.dart';

/// The notice is shown once per installation, including existing installations
/// upgrading to a version that introduces it.
class PrivacyGate extends StatefulWidget {
  const PrivacyGate({super.key});

  @override
  State<PrivacyGate> createState() => _PrivacyGateState();
}

class _PrivacyGateState extends State<PrivacyGate> {
  bool? _acknowledged;
  bool _saving = false;
  late String _language;

  @override
  void initState() {
    super.initState();
    final language = ui.PlatformDispatcher.instance.locale.languageCode;
    _language = language == 'zh' || language == 'vi' ? language : 'en';
    ChannelBridge.hasAcknowledgedPrivacy().then((value) {
      if (mounted) setState(() => _acknowledged = value);
    });
  }

  String text(String en, String vi, String zh) =>
      _language == 'vi' ? vi : _language == 'zh' ? zh : en;

  @override
  Widget build(BuildContext context) {
    if (_acknowledged == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_acknowledged!) return const HomeScreen();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButton<String>(
                      value: _language,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                        DropdownMenuItem(value: 'zh', child: Text('简体中文')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _language = value;
                            AppStrings.currentLanguage = value == 'zh'
                                ? SupportedLanguage.chinese
                                : value == 'vi'
                                    ? SupportedLanguage.vietnamese
                                    : SupportedLanguage.english;
                          });
                        }
                      },
                    ),
                  ),
                  const Icon(Icons.privacy_tip_outlined, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(text('Privacy policy', 'Chính sách quyền riêng tư', '隐私政策'),
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Text(text(
                    'Please read the privacy policy before using Power & Volume. It explains the permissions and how information is handled. You can open it again from the app at any time.',
                    'Vui lòng đọc chính sách quyền riêng tư trước khi sử dụng Power & Volume. Chính sách giải thích các quyền và cách xử lý thông tin. Bạn có thể mở lại bất cứ lúc nào trong ứng dụng.',
                    '使用 Power & Volume 前，请阅读隐私政策。政策说明了权限用途和信息处理方式。您可以随时在应用中再次查看。',
                  )),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => openPrivacyPolicy(context, language: _language),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(text('Read privacy policy', 'Đọc chính sách quyền riêng tư', '阅读隐私政策')),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _saving ? null : () async {
                      setState(() => _saving = true);
                      final saved = await ChannelBridge.acknowledgePrivacy();
                      if (!context.mounted) return;
                      setState(() {
                        _saving = false;
                        _acknowledged = saved ? true : false;
                      });
                      if (!saved) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text(
                          'Could not save your choice. Please try again.',
                          'Không thể lưu lựa chọn. Vui lòng thử lại.',
                          '无法保存您的选择，请重试。',
                        ))));
                      }
                    },
                    child: Text(text('Continue', 'Tiếp tục', '继续')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> openPrivacyPolicy(BuildContext context, {String? language}) async {
  final opened = await ChannelBridge.openPrivacyPolicy();
  if (!opened && context.mounted) {
    final code = language ?? AppStrings.effectiveLanguageCode;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
      code == 'vi' ? 'Không thể mở trình duyệt. Hãy thử lại.' :
      code == 'zh' ? '无法打开浏览器，请重试。' : 'Could not open a browser. Please try again.',
    )));
  }
}
