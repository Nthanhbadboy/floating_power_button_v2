import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/localization.dart';

/// Pinned Bottom Ad Banner Widget
/// Represents a permanent, production-grade bottom ad container (Google AdMob / Petal Ads banner).
/// It runs independently and does not have any bypass/cancel buttons, ensuring continuous ad impressions.
class BottomAdBanner extends StatelessWidget {
  const BottomAdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // Standard Ad Tag Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade400, width: 0.8),
                ),
                child: Text(
                  AppStrings.adBadge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Ad Content Banner Text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.adBannerText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      AppStrings.adBannerSub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Small info icon
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal Sheet for Direct Donations / Creator Support (Separated from Ads)
/// Smartly presents VietQR for Vietnamese users and Payoneer for International users.
class SupportDialog extends StatefulWidget {
  final bool initialIsVietnamese;

  const SupportDialog({
    super.key,
    required this.initialIsVietnamese,
  });

  static Future<void> show(BuildContext context) {
    final isVi = AppStrings.isVietnamese();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SupportDialog(
        initialIsVietnamese: isVi,
      ),
    );
  }

  @override
  State<SupportDialog> createState() => _SupportDialogState();
}

class _SupportDialogState extends State<SupportDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default to VietQR (index 0) if Vietnamese, otherwise Payoneer (index 1)
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIsVietnamese ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String successMsg) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMsg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag bar handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Heart Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.supportDeveloperTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.supportDeveloperSubtitle,
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Smart Tab Selector: VietQR vs Payoneer
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade700,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner, size: 18),
                          const SizedBox(width: 6),
                          Text(AppStrings.vietQrTab),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.public, size: 18),
                          const SizedBox(width: 6),
                          Text(AppStrings.payoneerTab),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVietQrTab(),
                    _buildPayoneerTab(),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Bottom Button: "Đóng / Hoàn tất"
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    AppStrings.closeBtn,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Vietnamese VietQR View (Vietcombank 1020506046)
  Widget _buildVietQrTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // VietQR Display Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Bundled Offline VietQR Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/vietqr_vcb.png',
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) {
                      return Image.network(
                        'https://img.vietqr.io/image/VCB-1020506046-compact2.png?accountName=NGUYEN%20MINH%20THANH&addInfo=Ung%20ho%20tac%20gia',
                        height: 250,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.scanQrGuide,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Account Details Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildInfoRow('Chủ tài khoản', AppStrings.bankAccountOwner),
                const Divider(height: 12),
                _buildInfoRow('Số tài khoản', AppStrings.bankAccountNumber, isHighlight: true),
                const Divider(height: 12),
                _buildInfoRow('Ngân hàng', AppStrings.bankName),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Copy Account Number Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006837),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.copy, size: 16),
              label: Text(
                '${AppStrings.copyAccountBtn} (${AppStrings.bankAccountNumber})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              onPressed: () => _copyToClipboard(
                AppStrings.bankAccountNumber,
                '${AppStrings.copiedSuccessToast} (VCB: ${AppStrings.bankAccountNumber})',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. International Payoneer View
  Widget _buildPayoneerTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFCCBC)),
            ),
            child: Column(
              children: [
                // Payoneer Badge / Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4800),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payment, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Payoneer Global Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payoneer Registered Email
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Payoneer Account Email',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      const SelectableText(
                        AppStrings.payoneerEmail,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD84315),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Copy Email Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text(
                      AppStrings.copyEmailBtn,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () => _copyToClipboard(
                      AppStrings.payoneerEmail,
                      '${AppStrings.copiedSuccessToast} (${AppStrings.payoneerEmail})',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Guidance Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF455A64), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.payoneerGuide,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 15 : 12.5,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? const Color(0xFF006837) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
