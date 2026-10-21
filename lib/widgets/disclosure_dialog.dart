import 'package:flutter/material.dart';
import '../core/localization.dart';

class AccessibilityDisclosureDialog extends StatelessWidget {
  final VoidCallback onAccept;

  const AccessibilityDisclosureDialog({
    super.key,
    required this.onAccept,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onAccept}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AccessibilityDisclosureDialog(onAccept: onAccept),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vi = AppStrings.isVietnamese();
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.accessibility_new, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              vi ? 'Minh bạch Dịch vụ Trợ năng' : 'Accessibility Service Disclosure',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vi ? 'Mục đích sử dụng duy nhất:' : 'Sole Purpose of Use:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              vi
                  ? 'Ứng dụng này sử dụng Android AccessibilityService API nghiêm ngặt cho đúng 1 hành động hệ thống:\n\n'
                    '• GLOBAL_ACTION_LOCK_SCREEN: Khóa màn hình ngay lập tức khi bạn bấm nút Khóa màn hình hoặc dùng ô Cài đặt nhanh Quick Settings.\n\n'
                    'Cam kết quyền riêng tư tuyệt đối:\n'
                    '• KHÔNG đọc hay theo dõi nội dung hiển thị trên màn hình.\n'
                    '• KHÔNG thu thập hoặc gửi bất kỳ thông tin cá nhân hay thao tác bàn phím nào.\n'
                    '• Dịch vụ chỉ thực hiện khi người dùng chủ động bấm nút.\n\n'
                    'Cách bật: Bấm "Đồng ý & Mở Cài đặt", tìm "Power & Volume" trong mục Ứng dụng đã cài đặt / Dịch vụ đã cài đặt và BẬT công tắc.'
                  : 'This application uses the Android AccessibilityService API strictly for one single system action:\n\n'
                    '• GLOBAL_ACTION_LOCK_SCREEN: Locks the screen immediately when you tap the Lock button or use the Quick Settings Tile.\n\n'
                    'Privacy & Policy Guarantees:\n'
                    '• NO inspection or reading of on-screen content.\n'
                    '• NO collection or transmission of personal data or keystrokes.\n'
                    '• The service only executes upon an explicit user tap.\n\n'
                    'To enable: Tap "Agree & Open Settings", locate "Power & Volume" under Installed Services, and switch it ON.',
              style: const TextStyle(fontSize: 13, height: 1.45, color: Colors.black54),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(vi ? 'Hủy' : 'Cancel', style: const TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onAccept();
          },
          child: Text(vi ? 'Đồng ý & Mở Cài đặt' : 'Agree & Open Settings'),
        ),
      ],
    );
  }
}
