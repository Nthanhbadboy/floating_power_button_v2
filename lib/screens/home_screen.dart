import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../core/channel_bridge.dart';
import '../core/localization.dart';
import '../widgets/disclosure_dialog.dart';
import '../widgets/monetization_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // Last-built context of the OEM guide section (refreshed on every build).
  // Used as a key-free scroll anchor; guarded by attached-checks.
  BuildContext? _oemSectionContext;
  final ScrollController _scrollController = ScrollController();

  bool _isAccessibilityEnabled = false;
  bool _isServiceConnected = false;
  bool _isDeviceAdminActive = false;
  bool _isKeepAliveRunning = false;
  bool _isBatteryOptimizationIgnored = false;
  bool _isLoading = true;
  bool _isLocking = false;
  DeviceInfo? _deviceInfo;
  String _selectedOem = 'huawei';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshState();
    }
  }

  Future<void> _refreshState() async {
    final devInfo = await ChannelBridge.getDeviceInfo();
    final enabled = await ChannelBridge.checkAccessibilityPermission();
    final connected = await ChannelBridge.isServiceConnected();
    final adminActive = await ChannelBridge.checkDeviceAdminActive();
    final keepAlive = await ChannelBridge.isKeepAliveRunning();
    final batteryIgnored = await ChannelBridge.checkBatteryOptimization();

    String defaultOem = 'stock';
    if (devInfo.isHuawei) {
      defaultOem = 'huawei';
    } else if (devInfo.isXiaomi) {
      defaultOem = 'xiaomi';
    } else if (devInfo.isSamsung) {
      defaultOem = 'samsung';
    } else if (devInfo.isOppoRealme) {
      defaultOem = 'oppo';
    } else if (devInfo.isVivo) {
      defaultOem = 'vivo';
    }

    if (mounted) {
      setState(() {
        _deviceInfo = devInfo;
        _selectedOem = defaultOem;
        _isAccessibilityEnabled = enabled;
        _isServiceConnected = connected;
        _isDeviceAdminActive = adminActive;
        _isKeepAliveRunning = keepAlive;
        _isBatteryOptimizationIgnored = batteryIgnored;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleKeepAlive(bool enable) async {
    if (!enable) {
      await ChannelBridge.stopKeepAliveService();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        final running = await ChannelBridge.isKeepAliveRunning();
        setState(() {
          _isKeepAliveRunning = running;
        });
      }
      return;
    }
    // Android 13+ suppresses ALL notifications (including the foreground-service
    // icon) until POST_NOTIFICATIONS is granted - request it BEFORE starting.
    final notifOk = await ChannelBridge.requestNotificationPermission();
    await ChannelBridge.startKeepAliveService();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      final running = await ChannelBridge.isKeepAliveRunning();
      setState(() {
        _isKeepAliveRunning = running;
      });
      if (!notifOk) {
        final isVi = AppStrings.isVietnamese();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVi
                  ? 'Đã bật keep-alive. Hãy cho phép Thông báo để thấy nút điều khiển nhanh trên thanh trạng thái.'
                  : 'Keep-alive is on. Allow Notifications to see quick controls in the status bar.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _scrollToOemGuide() {
    // Key-free scroll: the section GlobalKey proved unreliable at runtime
    // (detached context), so anchor on the last-built section context instead,
    // with maxScrollExtent as the guaranteed-motion fallback.
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    double? target;
    final ctx = _oemSectionContext;
    if (ctx != null) {
      final box = ctx.findRenderObject();
      if (box is RenderBox && box.attached) {
        try {
          final scrollable = Scrollable.maybeOf(ctx);
          final viewportBox = scrollable?.context.findRenderObject();
          if (viewportBox is RenderBox) {
            final dy = box.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
            if (dy.isFinite) target = pos.pixels + dy - 12.0;
          }
        } catch (_) {}
      }
    }
    target ??= pos.maxScrollExtent;
    pos.animateTo(
      target.clamp(pos.minScrollExtent, pos.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _executeLockScreen() async {
    if (_isLocking) return;
    _isLocking = true;
    HapticFeedback.heavyImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    try {
      final success = await ChannelBridge.performLockScreen();
      if (!success && mounted) {
        final isAcc = await ChannelBridge.checkAccessibilityPermission();
        final isAdmin = await ChannelBridge.checkDeviceAdminActive();

        if (!isAcc && !isAdmin) {
          _showSetupRequiredSheet();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.isVietnamese()
                    ? 'Vui lòng kích hoạt Device Administrator hoặc Accessibility để khóa màn hình.'
                    : 'Please activate Device Administrator or Accessibility to lock screen.',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _isLocking = false;
            });
          }
        });
      } else {
        _isLocking = false;
      }
    }
  }

  Future<void> _executeVolumeUI() async {
    HapticFeedback.mediumImpact();
    await ChannelBridge.performVolumeUI();
  }

  void _showSetupRequiredSheet() {
    final vi = AppStrings.isVietnamese();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF1E88E5), size: 28),
                const SizedBox(width: 12),
                Text(
                  vi ? 'Kích hoạt quyền khóa máy' : 'Enable Screen Lock Permission',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              vi
                  ? 'Để tắt màn hình 0ms và không bao giờ bị hệ thống tắt khi đóng app, vui lòng bật 1 trong 2 quyền dưới đây:'
                  : 'To enable 0ms screen lock and prevent OS from killing it, activate one of the options below:',
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF00C853), width: 1.5),
              ),
              tileColor: const Color(0xFFE8F5E9),
              leading: const Icon(Icons.verified_user, color: Color(0xFF00C853)),
              title: Text(
                vi ? 'Cách 1 (Khuyên dùng): Quản trị viên thiết bị' : 'Option 1 (Recommended): Device Admin',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                vi
                    ? 'Khóa tức thì 0ms, không đơ giật, không bao giờ bị hỏi lại quyền.'
                    : 'Instant 0ms lock, zero lag, never revoked by task killers.',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                ChannelBridge.requestDeviceAdmin();
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              tileColor: Colors.grey.shade50,
              leading: const Icon(Icons.accessibility_new, color: Color(0xFF1E88E5)),
              title: Text(
                vi ? 'Cách 2: Dịch vụ Trợ năng (Accessibility)' : 'Option 2: Accessibility Service',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                vi ? 'Dùng tính năng Global Action Lock Screen.' : 'Uses Global Action Lock Screen.',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                AccessibilityDisclosureDialog.show(
                  context,
                  onAccept: () => ChannelBridge.requestAccessibilityPermission(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeactivateAdminDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.deactivateAdminConfirmTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          AppStrings.deactivateAdminConfirmDesc,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancelBtn),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ChannelBridge.deactivateDeviceAdmin();
              _refreshState();
            },
            child: Text(AppStrings.confirmBtn),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final hasLockPermission = _isDeviceAdminActive || _isAccessibilityEnabled;
    final isFullyConfigured = hasLockPermission;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.power_settings_new, color: Color(0xFF1E88E5), size: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                AppStrings.appTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Compact Multi-Language Switcher (Never overlaps title)
          PopupMenuButton<SupportedLanguage>(
            tooltip: 'Language / Ngôn ngữ / 语言',
            padding: EdgeInsets.zero,
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey.shade50,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.currentLanguage == SupportedLanguage.system
                        ? '🌐 ${AppStrings.effectiveLanguageCode.toUpperCase()}'
                        : AppStrings.effectiveLanguageCode.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            onSelected: (lang) {
              setState(() {
                AppStrings.currentLanguage = lang;
              });
            },
            itemBuilder: (context) => AppStrings.languageNames.entries.map((entry) {
              final isCurrent = AppStrings.currentLanguage == entry.key;
              return PopupMenuItem<SupportedLanguage>(
                value: entry.key,
                child: Row(
                  children: [
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? const Color(0xFF1E88E5) : Colors.black87,
                      ),
                    ),
                    if (isCurrent) ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 16, color: Color(0xFF1E88E5)),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.all(6),
            icon: const Icon(
              Icons.volunteer_activism_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            tooltip: AppStrings.supportDeveloperTitle,
            onPressed: () => SupportDialog.show(context),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.all(6),
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh',
            onPressed: _refreshState,
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: const BottomAdBanner(),
      body: RefreshIndicator(
        onRefresh: _refreshState,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            // 1. PROMINENT STATUS & DIAGNOSTICS BANNER (PLACED AT THE VERY TOP)
            _buildTopDiagnosticsBanner(isFullyConfigured),
            const SizedBox(height: 16),

            // 2. DEVICE-SPECIFIC BACKGROUND GUIDE SUMMARY (JUMPS DIRECTLY TO DETAILED GUIDE)
            _buildDeviceGuideSummaryCard(),
            const SizedBox(height: 16),

            // 3. MAIN ACTION BUTTONS: LOCK SCREEN & VOLUME PANEL (EQUAL HEIGHT)
            _buildMainActionControls(),
            const SizedBox(height: 20),

            // 4. PERMISSIONS & BACKGROUND PROTECTION OVERVIEW (ACCESSIBILITY, ADMIN, KEEP-ALIVE, BATTERY)
            _buildPermissionsOverview(),
            const SizedBox(height: 20),

            // 5. FULL OEM BACKGROUND PROTECTION GUIDANCE (HUAWEI, XIAOMI, SAMSUNG, OPPO, VIVO, ETC.)
            _buildOemGuidanceSection(),
            const SizedBox(height: 20),

            // 6. CREATOR SUPPORT / DONATION CARD (VIETQR VCB 1020506046 & PAYONEER)
            _buildSupportSection(),
          ],
        ),
      ),
    );
  }

  /// 1. Top Diagnostics Banner: Always visible immediately at the top
  Widget _buildTopDiagnosticsBanner(bool isFullyConfigured) {
    final devName = _deviceInfo?.friendlyName ?? 'Android';
    final isWarning = !isFullyConfigured;

    return Container(
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF8E1) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning ? const Color(0xFFFFB300) : const Color(0xFF81C784),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isWarning ? Colors.amber : Colors.green).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isWarning ? const Color(0xFFFF8F00) : const Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isWarning ? Icons.warning_amber_rounded : Icons.verified_user,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWarning ? AppStrings.statusSetupTitle : AppStrings.statusProtectedTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isWarning ? const Color(0xFFE65100) : const Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppStrings.deviceDetected}: $devName',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isWarning ? const Color(0xFFBF360C) : const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isWarning ? AppStrings.statusSetupSubtitle : AppStrings.statusProtectedSubtitle(devName),
            style: TextStyle(
              fontSize: 13,
              color: isWarning ? Colors.black87 : const Color(0xFF2E7D32),
              height: 1.35,
            ),
          ),
          if (isWarning) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.build_circle, size: 18),
                label: Text(
                  AppStrings.quickSetupBtn,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: _showSetupRequiredSheet,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 2. Device-Specific Background Protection Summary Card: Jumps directly to OEM guidance
  Widget _buildDeviceGuideSummaryCard() {
    final dev = _deviceInfo;
    final devName = dev?.friendlyName ?? 'Huawei Mate 20X';
    final vi = AppStrings.isVietnamese();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF90CAF9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.settings_suggest, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vi ? 'Hướng dẫn chạy ngầm dòng máy này' : 'Device-Specific Background Guide',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      devName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vi ? 'Chống tắt ngầm' : 'Anti-Kill',
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            vi
                ? 'Thiết lập Khởi chạy ứng dụng (App launch), Không giới hạn pin và Khóa đa nhiệm để app không bao giờ bị hệ thống đóng.'
                : 'Configure App Launch, Unrestricted Battery, and Lock in Recents to prevent the OS from killing background services.',
            style: const TextStyle(fontSize: 12.5, height: 1.4, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
              icon: const Icon(Icons.arrow_downward_rounded, size: 16),
              label: Text(
                vi ? 'Xem hướng dẫn chi tiết dòng máy này ↓' : 'View Step-by-Step Instructions ↓',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: _scrollToOemGuide,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Main Action Controls: Huge tactile Lock Screen & Volume UI buttons (Guaranteed Equal Size)
  Widget _buildMainActionControls() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LOCK SCREEN BUTTON
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _executeLockScreen,
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFC62828)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.power_settings_new, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.lockScreenBtn,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 32,
                        child: Center(
                          child: Text(
                            AppStrings.lockScreenDesc,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // VOLUME PANEL BUTTON
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _executeVolumeUI,
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.volumePanelBtn,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 32,
                        child: Center(
                          child: Text(
                            AppStrings.volumePanelDesc,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Permissions & Keep-Alive Overview
  Widget _buildPermissionsOverview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: Color(0xFF1E88E5), size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.permissionsHeader,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Accessibility Service Item
          _buildPermissionTile(
            icon: Icons.accessibility_new,
            iconColor: Colors.blue,
            title: AppStrings.a11yTitle,
            subtitle: _isAccessibilityEnabled ? AppStrings.a11yActive : AppStrings.a11yInactive,
            isActive: _isAccessibilityEnabled,
            onTap: () {
              AccessibilityDisclosureDialog.show(
                context,
                onAccept: () => ChannelBridge.requestAccessibilityPermission(),
              );
            },
          ),
          const Divider(height: 16),

          // Device Admin Item
          _buildPermissionTile(
            icon: Icons.security,
            iconColor: Colors.teal,
            title: AppStrings.deviceAdminTitle,
            subtitle: _isDeviceAdminActive
                ? '${AppStrings.deviceAdminActive} (${AppStrings.isVietnamese() ? 'Chạm để hủy' : 'Tap to deactivate'})'
                : AppStrings.deviceAdminInactive,
            isActive: _isDeviceAdminActive,
            onTap: () {
              if (_isDeviceAdminActive) {
                _showDeactivateAdminDialog();
              } else {
                ChannelBridge.requestDeviceAdmin();
              }
            },
          ),
          const Divider(height: 16),

          // Keep-Alive Service Item (Switch)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt, color: Colors.orange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.keepAliveTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.keepAliveDesc,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isKeepAliveRunning,
                activeColor: const Color(0xFF1E88E5),
                onChanged: (val) => _toggleKeepAlive(val),
              ),
            ],
          ),
          const Divider(height: 16),

          // Battery Optimization Item
          _buildPermissionTile(
            icon: Icons.battery_charging_full,
            iconColor: Colors.green,
            title: AppStrings.batteryOptTitle,
            subtitle: _isBatteryOptimizationIgnored
                ? AppStrings.batteryOptActive
                : AppStrings.batteryOptInactive,
            isActive: _isBatteryOptimizationIgnored,
            onTap: () => ChannelBridge.requestBatteryOptimization(),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? const Color(0xFF2E7D32) : Colors.red.shade700,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isActive ? Icons.check_circle : Icons.arrow_forward_ios,
              color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade400,
              size: isActive ? 20 : 14,
            ),
          ],
        ),
      ),
    );
  }

  /// 6. Full OEM Device Guidance Section
  Widget _buildOemGuidanceSection() {
    final dev = _deviceInfo;
    String detectedOemKey = 'stock';
    if (dev != null) {
      if (dev.isHuawei) detectedOemKey = 'huawei';
      else if (dev.isXiaomi) detectedOemKey = 'xiaomi';
      else if (dev.isSamsung) detectedOemKey = 'samsung';
      else if (dev.isOppoRealme) detectedOemKey = 'oppo';
      else if (dev.isVivo) detectedOemKey = 'vivo';
    }

    final oemList = [
      {'key': 'huawei', 'label': AppStrings.oemHuawei},
      {'key': 'xiaomi', 'label': AppStrings.oemXiaomi},
      {'key': 'samsung', 'label': AppStrings.oemSamsung},
      {'key': 'oppo', 'label': AppStrings.oemOppo},
      {'key': 'vivo', 'label': AppStrings.oemVivo},
      {'key': 'stock', 'label': AppStrings.oemStock},
    ];

    return Builder(
      builder: (sectionCtx) {
        // Refresh the key-free scroll anchor on every build.
        _oemSectionContext = sectionCtx;
        return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android, color: Color(0xFF1E88E5), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.oemGuideHeader,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.oemGuideSubtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          // OEM Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: oemList.map((item) {
                final key = item['key']!;
                final label = item['label']!;
                final isSelected = _selectedOem == key;
                final isDetected = detectedOemKey == key;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label),
                        if (isDetected) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white24 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppStrings.autoDetectedTag,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1E88E5),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedOem = key;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Instruction Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.oemStepTitle(
                    oemList.firstWhere((e) => e['key'] == _selectedOem)['label']!,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.getOemInstructions(_selectedOem, dev),
                  style: const TextStyle(fontSize: 12.5, height: 1.5, color: Colors.black87),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF263238),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(
                      AppStrings.getOemButtonLabel(_selectedOem),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => ChannelBridge.openManufacturerSettings(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    });
  }

  /// 7. Creator Support Section (Independent from Ads)
  Widget _buildSupportSection() {
    final vi = AppStrings.isVietnamese();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_cafe, color: Colors.amber.shade800, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.supportDeveloperTitle,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.supportDeveloperSubtitle,
            style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.favorite, size: 16),
              label: Text(
                vi ? 'Mở thông tin ủng hộ (VietQR / Payoneer)' : 'Support Developer (Payoneer / VietQR)',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              onPressed: () => SupportDialog.show(context),
            ),
          ),
        ],
      ),
    );
  }
}
