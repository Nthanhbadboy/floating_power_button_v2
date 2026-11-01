import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'critical_strings.dart';
import 'common_strings.dart';
import 'support_strings.dart';
import 'extra_strings.dart';
import 'channel_bridge.dart';

enum SupportedLanguage {
  system,
  vietnamese,
  english,
  chinese,
  spanish,
  japanese,
  korean,
  french,
  german,
  russian,
  portuguese,
  indonesian,
  arabic,
  hindi,
  italian,
  dutch,
  polish,
  czech,
  tagalog,
}

class AppStrings {
  static final ValueNotifier<SupportedLanguage> languageNotifier =
      ValueNotifier<SupportedLanguage>(SupportedLanguage.system);

  static SupportedLanguage get currentLanguage => languageNotifier.value;
  static set currentLanguage(SupportedLanguage value) => languageNotifier.value = value;

  static SupportedLanguage languageFromName(String? name) =>
      SupportedLanguage.values.firstWhere((language) => language.name == name,
          orElse: () => SupportedLanguage.system);

  static String critical(int index) =>
      (criticalStrings[effectiveLanguageCode] ?? criticalStrings['en']!)[index];
  static String common(int index) =>
      (commonStrings[effectiveLanguageCode] ?? commonStrings['en']!)[index];
  static String support(int index) =>
      (supportStrings[effectiveLanguageCode] ?? supportStrings['en']!)[index];
  static String extra(int index) =>
      (extraStrings[effectiveLanguageCode] ?? extraStrings['en']!)[index];

  static String get effectiveLanguageCode {
    switch (currentLanguage) {
      case SupportedLanguage.vietnamese: return 'vi';
      case SupportedLanguage.english: return 'en';
      case SupportedLanguage.chinese: return 'zh';
      case SupportedLanguage.spanish: return 'es';
      case SupportedLanguage.japanese: return 'ja';
      case SupportedLanguage.korean: return 'ko';
      case SupportedLanguage.french: return 'fr';
      case SupportedLanguage.german: return 'de';
      case SupportedLanguage.russian: return 'ru';
      case SupportedLanguage.portuguese: return 'pt';
      case SupportedLanguage.indonesian: return 'id';
      case SupportedLanguage.arabic: return 'ar';
      case SupportedLanguage.hindi: return 'hi';
      case SupportedLanguage.italian: return 'it';
      case SupportedLanguage.dutch: return 'nl';
      case SupportedLanguage.polish: return 'pl';
      case SupportedLanguage.czech: return 'cs';
      case SupportedLanguage.tagalog: return 'tl';
      case SupportedLanguage.system:
        final deviceCode = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
        final code = deviceCode == 'fil' ? 'tl' : deviceCode;
        const supported = [
          'vi', 'zh', 'es', 'ja', 'ko', 'fr', 'de', 'ru', 'pt', 'id',
          'ar', 'hi', 'it', 'nl', 'pl', 'cs', 'tl', 'en'
        ];
        return supported.contains(code) ? code : 'en';
    }
  }

  static bool isVietnamese() => effectiveLanguageCode == 'vi';

  // App Title
  static String get appTitle => 'Power&volume';

  // Device Tag
  static String get deviceDetected {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Thiết bị';
      case 'zh': return '设备';
      case 'es': return 'Dispositivo';
      case 'ja': return 'デバイス';
      case 'ko': return '기기';
      case 'fr': return 'Appareil';
      case 'de': return 'Gerät';
      case 'ru': return 'Устройство';
      case 'pt': return 'Dispositivo';
      case 'id': return 'Perangkat';
      case 'ar': return 'الجهاز';
      case 'hi': return 'उपकरण';
      case 'it': return 'Dispositivo';
      case 'nl': return 'Apparaat';
      case 'pl': return 'Urządzenie';
      case 'cs': return 'Zařízení';
      case 'tl': return 'Aparato';
      default: return 'Device';
    }
  }

  // Diagnostics Banner
  static String get statusProtectedTitle => common(0);
  static String statusProtectedSubtitle(String deviceName) => common(2);
  static String get statusSetupTitle => common(1);
  static String get statusSetupSubtitle => common(3);

  static String get quickSetupBtn {
    switch (effectiveLanguageCode) {
      case 'vi': return 'KÍCH HOẠT NHANH';
      case 'zh': return '快速设置';
      case 'es': return 'CONFIGURACIÓN RÁPIDA';
      case 'ja': return 'クイック設定';
      case 'ko': return '빠른 설정';
      case 'fr': return 'CONFIGURATION RAPIDE';
      case 'de': return 'SCHNELLEINRICHTUNG';
      case 'ru': return 'БЫСТРАЯ НАСТРОЙКА';
      case 'pt': return 'CONFIGURAÇÃO RÁPIDA';
      case 'id': return 'PENGATURAN CEPAT';
      case 'ar': return 'إعداد سريع';
      case 'hi': return 'त्वरित सेटअप';
      case 'it': return 'CONFIGURAZIONE RAPIDA';
      case 'nl': return 'SNELLE INSTELLING';
      case 'pl': return 'SZYBKA KONFIGURACJA';
      case 'cs': return 'RYCHLÉ NASTAVENÍ';
      case 'tl': return 'MABILIS NA SETUP';
      default: return 'QUICK SETUP';
    }
  }

  // Device Admin Hero Card
  static String get deviceAdminHeroTitle {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Khuyên dùng: Bật Quản trị viên thiết bị';
      case 'zh': return '强烈推荐：激活设备管理器';
      case 'es': return 'Recomendado: Activar Administrador';
      case 'ja': return '推奨：デバイス管理者を有効にする';
      case 'ko': return '권장: 기기 관리자 활성화';
      case 'fr': return 'Recommandé : Activer l\'administrateur';
      case 'de': return 'Empfohlen: Geräteadministrator aktivieren';
      case 'ru': return 'Рекомендуется: Включить администратора';
      case 'pt': return 'Recomendado: Ativar Administrador';
      case 'id': return 'Disarankan: Aktifkan Administrator';
      case 'ar': return 'موصى به: تفعيل مسؤول الجهاز';
      case 'hi': return 'अनुशंसित: डिवाइस व्यवस्थापक सक्षम करें';
      case 'it': return 'Consigliato: Attiva amministratore';
      case 'nl': return 'Aanbevolen: Apparaatbeheerder inschakelen';
      case 'pl': return 'Zalecane: Włącz administratora urządzenia';
      case 'cs': return 'Doporučeno: Povolit správce zařízení';
      case 'tl': return 'Inirerekomenda: I-on ang Administrator';
      default: return 'Recommended: Enable Device Admin';
    }
  }

  static String get deviceAdminHeroDesc {
    switch (effectiveLanguageCode) {
      case 'vi':
        return 'Khóa máy tức thì trong 0ms, không lag, miễn nhiễm 100% với trình dọn pin của hệ thống khi đóng app.';
      case 'zh':
        return '0ms 瞬间锁屏，绝不卡顿，100% 免疫系统后台清理。';
      case 'es':
        return 'Bloqueo instantáneo en 0ms, sin retraso, 100% inmune a limpiadores de batería.';
      case 'ja':
        return '0msで瞬時に画面ロック。遅延ゼロ、タスクキラーにも100%影響されません。';
      case 'ko':
        return '0ms 즉각 화면 잠금, 렉 없음, 배터리 청소 기능에 100% 면역.';
      default:
        return 'Instant 0ms screen lock, zero lag, 100% immune to background task killers.';
    }
  }

  static String get activateAdminBtn {
    switch (effectiveLanguageCode) {
      case 'vi': return 'BẬT QUẢN TRỊ VIÊN';
      case 'zh': return '激活设备管理器';
      case 'es': return 'ACTIVAR ADMINISTRADOR';
      case 'ja': return '管理者を有効化';
      case 'ko': return '기기 관리자 활성화';
      case 'fr': return 'ACTIVER L\'ADMINISTRATEUR';
      case 'de': return 'ADMINISTRATOR AKTIVIEREN';
      case 'ru': return 'ВКЛЮЧИТЬ АДМИНИСТРАТОРА';
      case 'pt': return 'ATIVAR ADMINISTRADOR';
      case 'id': return 'AKTIFKAN ADMINISTRATOR';
      case 'ar': return 'تفعيل المسؤول';
      case 'hi': return 'व्यवस्थापक चालू करें';
      case 'it': return 'ATTIVA AMMINISTRATORE';
      case 'nl': return 'BEHEERDER INSCHAKELEN';
      case 'pl': return 'WŁĄCZ ADMINISTRATORA';
      case 'cs': return 'AKTIVOVAT SPRÁVCE';
      case 'tl': return 'I-ON ANG ADMINISTRATOR';
      default: return 'ENABLE DEVICE ADMIN';
    }
  }

  static String get adminActivatedBadge {
    switch (effectiveLanguageCode) {
      case 'vi': return 'ĐÃ KÍCH HOẠT';
      case 'zh': return '已激活';
      case 'es': return 'ACTIVO';
      case 'ja': return '有効';
      case 'ko': return '활성화됨';
      case 'fr': return 'ACTIF';
      case 'de': return 'AKTIV';
      case 'ru': return 'АКТИВНО';
      case 'pt': return 'ATIVO';
      case 'id': return 'AKTIF';
      case 'ar': return 'نشط (0 مللي ثانية)';
      case 'hi': return 'सक्रिय';
      case 'it': return 'ATTIVO';
      case 'nl': return 'ACTIEF';
      case 'pl': return 'AKTYWNY';
      case 'cs': return 'AKTIVNÍ';
      case 'tl': return 'AKTIBO';
      default: return 'ACTIVE';
    }
  }

  static String get deactivateAdminBtn {
    switch (effectiveLanguageCode) {
      case 'vi': return 'HỦY QUẢN TRỊ VIÊN (ĐỂ GỠ APP)';
      case 'zh': return '取消激活设备管理器 (方便卸载)';
      case 'es': return 'DESACTIVAR ADMINISTRADOR';
      case 'ja': return 'デバイス管理者を無効化 (アンインストール用)';
      case 'ko': return '기기 관리자 비활성화 (삭제용)';
      case 'fr': return 'DÉSACTIVER L\'ADMINISTRATEUR';
      case 'de': return 'ADMINISTRATOR DEAKTIVIEREN';
      case 'ru': return 'ОТКЛЮЧИТЬ АДМИНИСТРАТОРА';
      case 'pt': return 'DESATIVAR ADMINISTRADOR';
      case 'id': return 'NONAKTIFKAN ADMINISTRATOR';
      default: return 'DEACTIVATE DEVICE ADMIN';
    }
  }

  static String get deactivateAdminConfirmTitle => extra(0);
  static String get deactivateAdminConfirmDesc => extra(1);
  static String get cancelBtn => critical(6);
  static String get confirmBtn => extra(2);

  static String get lockScreenBtn {
    switch (effectiveLanguageCode) {
      case 'vi': return 'KHÓA MÀN HÌNH';
      case 'zh': return '立即锁屏';
      case 'es': return 'BLOQUEAR PANTALLA';
      case 'ja': return '画面ロック';
      case 'ko': return '화면 잠금';
      case 'fr': return 'VERROUILLER L\'ÉCRAN';
      case 'de': return 'BILDSCHIRM SPERREN';
      case 'ru': return 'БЛОКИРОВКА ЭКРАНА';
      case 'pt': return 'BLOQUEAR TELA';
      case 'id': return 'KUNCI LAYAR';
      case 'ar': return 'قفل الشاشة';
      case 'hi': return 'स्क्रीन लॉक';
      case 'it': return 'BLOCCA SCHERMO';
      case 'nl': return 'SCHERM VERGRENDELEN';
      case 'pl': return 'ZABLOKUJ EKRAN';
      case 'cs': return 'ZAMKNOUT OBRAZOVKU';
      case 'tl': return 'I-LOCK ANG SCREEN';
      default: return 'LOCK SCREEN';
    }
  }

  static String get lockScreenDesc => extra(3);

  static String get volumePanelBtn {
    switch (effectiveLanguageCode) {
      case 'vi': return 'BẢNG ÂM LƯỢNG';
      case 'zh': return '系统音量面板';
      case 'es': return 'PANEL DE VOLUMEN';
      case 'ja': return '音量パネル';
      case 'ko': return '볼륨 패널';
      case 'fr': return 'PANNEAU DE VOLUME';
      case 'de': return 'LAUTSTÄRKEPANEL';
      case 'ru': return 'ПАНЕЛЬ ГРОМКОСТИ';
      case 'pt': return 'PAINEL DE VOLUME';
      case 'id': return 'PANEL VOLUME';
      case 'ar': return 'لوحة الصوت';
      case 'hi': return 'वॉल्यूम पैनल';
      case 'it': return 'PANNELLO VOLUME';
      case 'nl': return 'VOLUMEPANEEL';
      case 'pl': return 'PANEL GŁOŚNOŚCI';
      case 'cs': return 'PANEL HLASITOSTI';
      case 'tl': return 'PANEL NG VOLUME';
      default: return 'VOLUME PANEL';
    }
  }

  static String get volumePanelDesc => extra(4);

  static String get quickAccessTitle {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Tiện ích không cần mở ứng dụng';
      case 'zh': return '无需打开应用的快捷方式';
      case 'es': return 'Acceso rápido (sin abrir la app)';
      case 'ja': return 'アプリを開かずに使える機能';
      case 'ko': return '앱을 열지 않고 빠른 접근';
      default: return 'Quick Access (No App Needed)';
    }
  }

  static String get quickSettingsTileTitle {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Ô Cài đặt nhanh (Quick Settings Tile)';
      case 'zh': return '顶部快捷设置磁贴 (Quick Settings)';
      case 'es': return 'Mosaico de Ajustes Rápidos';
      default: return 'Quick Settings Tile';
    }
  }

  static String get quickSettingsTileDesc {
    switch (effectiveLanguageCode) {
      case 'vi':
        return 'Vuốt thanh thông báo từ trên xuống -> Sửa -> Kéo ô "Khóa màn hình" hoặc "Âm lượng" ra để dùng mọi lúc.';
      case 'zh':
        return '从屏幕顶部下拉通知栏 -> 点击编辑 -> 将「锁屏」或「音量」磁贴拖入上方即可随时使用。';
      default:
        return 'Swipe down notification shade -> Edit -> Drag "Lock Screen" or "Volume" tile to top for 1-tap access.';
    }
  }

  static String get homeShortcutTitle {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Phím tắt Màn hình chính';
      case 'zh': return '桌面快捷图标 (Shortcuts)';
      default: return 'Home Screen Shortcut';
    }
  }

  static String get homeShortcutDesc {
    switch (effectiveLanguageCode) {
      case 'vi':
        return 'Nhấn giữ biểu tượng ứng dụng trên màn hình chính để kéo phím tắt Khóa màn hình / Âm lượng ra ngoài.';
      default:
        return 'Long-press the app icon on your home screen to drag 1-tap Lock Screen or Volume shortcuts.';
    }
  }

  // Permissions Header
  static String get permissionsHeader => common(13);

  static String get a11yTitle => critical(8);
  static String get a11yActive => common(5);
  static String get a11yInactive => common(6);
  static String get deviceAdminTitle => common(4);
  static String get deviceAdminActive => common(5);
  static String get deviceAdminInactive => common(6);
  static String get keepAliveTitle => common(10);
  static String get keepAliveDesc => critical(5);
  static String get batteryOptTitle => common(7);
  static String get batteryOptActive => common(8);
  static String get batteryOptInactive => common(9);

  // OEM Guidance Section
  static String get oemGuideHeader => common(11);
  static String get oemGuideSubtitle => common(14);
  static String get autoDetectedTag => common(12);

  static String get oemHuawei => 'Huawei / Honor';
  static String get oemXiaomi => 'Xiaomi / Redmi / POCO';
  static String get oemSamsung => 'Samsung (One UI)';
  static String get oemOppo => 'OPPO / Realme';
  static String get oemVivo => 'Vivo / iQOO';
  static String get oemStock => 'Google / Stock Android';

  static String oemStepTitle(String oem) => '${common(11)}: $oem';

  static String getOemInstructions(String oemKey, DeviceInfo? dev) {
    if (effectiveLanguageCode != 'vi' && effectiveLanguageCode != 'en' &&
        !(effectiveLanguageCode == 'zh' && oemKey == 'huawei')) {
      return common(14);
    }
    switch (oemKey) {
      case 'huawei':
        if (effectiveLanguageCode == 'zh') {
          return '1. 打开下方电池设置，找到“应用启动管理”。\n'
              '2. 找到 Power&volume，关闭“自动管理”，按需允许自动启动、关联启动和后台活动。\n'
              '3. 在最近任务中，若系统支持，可锁定应用卡片。\n'
              '不同版本的名称和选项可能有所不同。';
        }
        return isVietnamese()
            ? '1. Bấm nút bên dưới để mở màn hình Cài đặt Pin Huawei (EMUI).\n'
              '2. Chọn mục: "Khởi chạy ứng dụng" (App launch).\n'
              '3. Tìm app "Power&volume" -> Tắt "Tự động quản lý" -> BẬT CẢ 3 CÔNG TẮC:\n'
              '   • Tự khởi chạy (Auto-launch)\n'
              '   • Khởi chạy phụ (Secondary launch)\n'
              '   • Chạy dưới nền (Run in background)\n'
              '4. Trong màn hình Đa nhiệm (Recent Apps): Vuốt nhẹ thẻ app xuống để hiện Ổ khóa 🔒.'
            : '1. Tap button below to open Huawei Battery Settings (EMUI).\n'
              '2. Select: "App launch".\n'
              '3. Find "Power&volume" -> Turn OFF "Manage automatically" -> Turn ON all 3:\n'
              '   • Auto-launch\n'
              '   • Secondary launch\n'
              '   • Run in background\n'
              '4. In Recent Apps overview: Swipe down on app card until Lock icon 🔒 appears.';
      case 'xiaomi':
        return isVietnamese()
            ? '1. Bấm nút bên dưới để mở quản lý Tự khởi chạy (Autostart) của MIUI / HyperOS.\n'
              '2. BẬT công tắc "Tự khởi chạy" (Autostart) cho Power&volume.\n'
              '3. Vào Cài đặt ứng dụng -> Tiết kiệm pin -> Chọn "Không hạn chế" (No restrictions).\n'
              '4. Trong màn hình Đa nhiệm: Nhấn giữ thẻ app và chọn biểu tượng Ổ khóa 🔒.'
            : '1. Tap button below to open MIUI / HyperOS Autostart management.\n'
              '2. Turn ON "Autostart" for Power&volume.\n'
              '3. Go to App Info -> Battery Saver -> Choose "No restrictions".\n'
              '4. In Recent Apps: Long-press app card and tap Lock icon 🔒.';
      case 'samsung':
        return isVietnamese()
            ? '1. Bấm nút bên dưới để mở Cài đặt Pin Samsung (One UI).\n'
              '2. Vào "Giới hạn sử dụng dưới nền" -> "Ứng dụng không bao giờ ngủ" (Never sleeping apps).\n'
              '3. Bấm dấu (+) ở góc trên và thêm "Power&volume" vào danh sách.\n'
              '4. Trong màn hình Đa nhiệm: Nhấn vào biểu tượng app ở đầu thẻ -> Chọn "Khóa ứng dụng này" 🔒.'
            : '1. Tap button below to open Samsung Battery Settings (One UI).\n'
              '2. Go to "Background usage limits" -> "Never sleeping apps".\n'
              '3. Tap (+) icon and add "Power&volume" to the list.\n'
              '4. In Recent Apps: Tap app icon on card header -> Select "Lock this app" 🔒.';
      case 'oppo':
        return isVietnamese()
            ? '1. Bấm nút bên dưới để mở Quản lý khởi động ColorOS / Realme UI.\n'
              '2. BẬT "Cho phép tự khởi chạy" (Allow auto-launch) và "Khởi chạy liên kết".\n'
              '3. Vào Thông tin ứng dụng -> Sử dụng pin -> BẬT "Cho phép hoạt động dưới nền".\n'
              '4. Trong màn hình Đa nhiệm: Bấm vào dấu 3 chấm góc thẻ app -> Chọn "Khóa" 🔒.'
            : '1. Tap button below to open ColorOS / Realme UI Startup Manager.\n'
              '2. Turn ON "Allow auto-launch" and "Associate startup".\n'
              '3. Go to App Info -> Battery usage -> Turn ON "Allow background activity".\n'
              '4. In Recent Apps: Tap 3 dots on card header -> Select "Lock" 🔒.';
      case 'vivo':
        return isVietnamese()
            ? '1. Bấm nút bên dưới để mở cài đặt pin Vivo (Funtouch OS / OriginOS).\n'
              '2. Mở app iManager -> Quản lý ứng dụng -> Tự khởi chạy -> BẬT cho Power&volume.\n'
              '3. Vào Cài đặt Pin -> Mức tiêu thụ pin dưới nền cao -> BẬT công tắc cho Power&volume.\n'
              '4. Trong màn hình Đa nhiệm: Kéo nhẹ thẻ app xuống để khóa 🔒.'
            : '1. Tap button below to open Vivo battery settings (Funtouch OS / OriginOS).\n'
              '2. Open iManager app -> App manager -> Autostart -> Turn ON for Power&volume.\n'
              '3. Go to Battery Settings -> High background power consumption -> Turn ON.\n'
              '4. In Recent Apps: Pull down app card to lock with 🔒.';
      default:
        return isVietnamese()
            ? '1. Bấm nút bên dưới để mở Cài đặt pin của hệ thống.\n'
              '2. Vào Thông tin ứng dụng -> Sử dụng pin của ứng dụng (App battery usage).\n'
              '3. Chọn chế độ: "Không hạn chế" (Unrestricted).\n'
              '4. Nếu máy có tính năng khóa đa nhiệm, nhấn giữ app và chọn biểu tượng Ổ khóa 🔒.'
            : '1. Tap button below to open System Battery Optimization settings.\n'
              '2. Go to App Info -> App battery usage.\n'
              '3. Select: "Unrestricted".\n'
              '4. If supported, lock the app in Recent Apps overview with the 🔒 icon.';
    }
  }

  static String getOemButtonLabel(String oemKey) {
    if (effectiveLanguageCode != 'vi' && effectiveLanguageCode != 'en') {
      return common(15);
    }
    switch (oemKey) {
      case 'huawei': return isVietnamese() ? 'Mở Cài đặt Pin Huawei (EMUI)' : effectiveLanguageCode == 'zh' ? '打开华为电池设置' : 'Open Huawei Battery Settings';
      case 'xiaomi': return isVietnamese() ? 'Mở Quản lý Tự khởi chạy MIUI' : 'Open MIUI Autostart Settings';
      case 'samsung': return isVietnamese() ? 'Mở Cài đặt Pin Samsung (One UI)' : 'Open Samsung Battery Settings';
      case 'oppo': return isVietnamese() ? 'Mở Cài đặt ColorOS' : 'Open ColorOS Manager';
      case 'vivo': return isVietnamese() ? 'Mở Cài đặt Pin Vivo' : 'Open Vivo Battery Settings';
      default: return isVietnamese() ? 'Mở Cài đặt Tối ưu pin' : 'Open Battery Optimization';
    }
  }

  // Language names for selector menu
  static final Map<SupportedLanguage, String> languageNames = {
    SupportedLanguage.system: '🌐 Auto (System / Hệ thống)',
    SupportedLanguage.vietnamese: '🇻🇳 Tiếng Việt',
    SupportedLanguage.english: '🇬🇧 English',
    SupportedLanguage.chinese: '🇨🇳 简体中文',
    SupportedLanguage.spanish: '🇪🇸 Español',
    SupportedLanguage.japanese: '🇯🇵 日本語',
    SupportedLanguage.korean: '🇰🇷 한국어',
    SupportedLanguage.french: '🇫🇷 Français',
    SupportedLanguage.german: '🇩🇪 Deutsch',
    SupportedLanguage.russian: '🇷🇺 Русский',
    SupportedLanguage.portuguese: '🇧🇷 Português',
    SupportedLanguage.indonesian: '🇮🇩 Bahasa Indonesia',
    SupportedLanguage.arabic: '🇸🇦 العربية',
    SupportedLanguage.hindi: '🇮🇳 हिन्दी',
    SupportedLanguage.italian: '🇮🇹 Italiano',
    SupportedLanguage.dutch: '🇳🇱 Nederlands',
    SupportedLanguage.polish: '🇵🇱 Polski',
    SupportedLanguage.czech: '🇨🇿 Čeština',
    SupportedLanguage.tagalog: '🇵🇭 Tagalog',
  };

  // --- Donation & Ad Monetization Strings ---
  static String get supportDeveloperTitle => support(0);
  static String get supportDeveloperSubtitle => support(1);
  static String get vietQrTab => support(2);
  static String get payoneerTab => support(3);

  static const String bankAccountOwner = 'NGUYEN MINH THANH';
  static const String bankAccountNumber = '1020506046';
  static const String bankName = 'Vietcombank (Trụ sở CN Hải Phòng)';
  static const String payoneerEmail = 'alphaplus.thanh82@gmail.com';

  static String get copyAccountBtn => support(4);
  static String get copyEmailBtn => support(5);
  static String get copiedSuccessToast => support(6);
  static String get closeBtn => support(7);

  static String get adBadge => isVietnamese() ? 'Quảng cáo' : 'Ad';

  static String get adBannerText => isVietnamese()
      ? 'Quảng cáo giúp ứng dụng duy trì 100% miễn phí'
      : 'Ads keep this utility 100% free for everyone';

  static String get adBannerSub => isVietnamese()
      ? 'Google AdMob / Petal Ads Banner'
      : 'Google AdMob / Petal Ads Banner';

  static String get payoneerGuide => support(9);
  static String get scanQrGuide => support(8);
}
