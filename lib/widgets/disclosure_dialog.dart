import 'package:flutter/material.dart';
import '../core/localization.dart';

class AccessibilityDisclosureDialog extends StatelessWidget {
  final VoidCallback onAccept;
  const AccessibilityDisclosureDialog({super.key, required this.onAccept});

  static Future<void> show(BuildContext context, {required VoidCallback onAccept}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AccessibilityDisclosureDialog(onAccept: onAccept),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(AppStrings.critical(8)),
    content: SingleChildScrollView(child: Text(AppStrings.critical(9))),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.critical(6))),
      FilledButton(
        onPressed: () {
          Navigator.of(context).pop();
          onAccept();
        },
        child: Text(AppStrings.critical(10)),
      ),
    ],
  );
}
