import 'dart:ui';
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
  static SupportedLanguage currentLanguage = SupportedLanguage.system;

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
        final code = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
        const supported = [
          'vi', 'zh', 'es', 'ja', 'ko', 'fr', 'de', 'ru', 'pt', 'id',
          'ar', 'hi', 'it', 'nl', 'pl', 'cs', 'tl', 'en'
        ];
        return supported.contains(code) ? code : 'en';
    }
  }

  static bool isVietnamese() => effectiveLanguageCode == 'vi';

  // App Title
  static String get appTitle => 'Power & Volume';

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
  static String get statusProtectedTitle {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Hệ thống bảo vệ 24/7';
      case 'zh': return '24/7 全天候受保护';
      case 'es': return 'Protegido 24/7';
      case 'ja': return '24時間保護中';
      case 'ko': return '24/7 보호됨';
      case 'fr': return 'Protégé 24/7';
      case 'de': return '24/7 geschützt';
      case 'ru': return 'Защищено 24/7';
      case 'pt': return 'Protegido 24/7';
      case 'id': return 'Terlindungi 24/7';
      case 'ar': return 'محمي على مدار 24/7';
      case 'hi': return '24/7 सुरक्षित';
      case 'it': return 'Protetto 24/7';
      case 'nl': return '24/7 beschermd';
      case 'pl': return 'Chronione 24/7';
      case 'cs': return 'Chráněno 24/7';
      case 'tl': return 'Protektado 24/7';
      default: return 'Protected 24/7';
    }
  }

  static String statusProtectedSubtitle(String deviceName) {
    switch (effectiveLanguageCode) {
      case 'vi':
        return 'Dịch vụ luôn hoạt động ổn định trên $deviceName, không bị tắt khi vuốt đóng app.';
      case 'zh':
        return '后台服务在 $deviceName 上稳定运行，清理后台任务也不会被关闭。';
      case 'es':
        return 'Los servicios permanecen activos en $deviceName, inmunes al cierre en recientes.';
      case 'ja':
        return '$deviceName でバックグラウンドサービスが常に安定して動作し、終了時も停止しません。';
      case 'ko':
        return '$deviceName 에서 백그라운드 서비스가 안정적으로 작동하며 꺼지지 않습니다.';
      case 'fr':
        return 'Les services restent actifs sur $deviceName, protégés contre l\'arrêt.';
      case 'de':
        return 'Dienste bleiben auf $deviceName aktiv und werden beim Schließen nicht beendet.';
      case 'ru':
        return 'Служба стабильно работает на $deviceName и не закрывается при свайпе.';
      case 'pt':
        return 'Os serviços permanecem ativos no $deviceName, imunes ao encerramento.';
      case 'id':
        return 'Layanan tetap aktif di $deviceName, tidak mati saat aplikasi ditutup.';
      case 'ar':
        return 'الخدمات نشطة دائماً على $deviceName ولا تتوقف عند إغلاق التطبيق.';
      case 'hi':
        return '$deviceName पर सेवाएं सक्रिय रहती हैं और ऐप बंद करने पर भी चालू रहती हैं।';
      case 'it':
        return 'I servizi restano attivi su $deviceName senza terminare alla chiusura.';
      case 'nl':
        return 'Services blijven actief op $deviceName, immuun voor afsluiten.';
      case 'pl':
        return 'Usługi pozostają aktywne na $deviceName po zamknięciu aplikacji.';
      case 'cs':
        return 'Služby zůstávají aktivní na $deviceName i po zavření aplikace.';
      case 'tl':
        return 'Ang mga serbisyo ay nananatiling aktibo sa $deviceName kahit isara ang app.';
      default:
        return 'Services remain active on $deviceName, immune to swipe-to-kill.';
    }
  }

  static String get statusSetupTitle {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Cần thiết lập để hoạt động ổn định';
      case 'zh': return '需要设置以确保稳定运行';
      case 'es': return 'Configuración requerida para estabilidad';
      case 'ja': return '安定動作のための設定が必要です';
      case 'ko': return '안정적인 작동을 위해 설정이 필요합니다';
      case 'fr': return 'Configuration requise pour la stabilité';
      case 'de': return 'Einrichtung erforderlich';
      case 'ru': return 'Требуется настройка для стабильной работы';
      case 'pt': return 'Configuração necessária';
      case 'id': return 'Perlu Pengaturan untuk Stabilitas';
      case 'ar': return 'مطلوب الإعداد لضمان التشغيل المستقر';
      case 'hi': return 'स्थिर संचालन के लिए सेटअप आवश्यक है';
      case 'it': return 'Configurazione richiesta';
      case 'nl': return 'Configuratie vereist';
      case 'pl': return 'Wymagana konfiguracja';
      case 'cs': return 'Nutná konfigurace';
      case 'tl': return 'Kailangan ang setup para sa katatagan';
      default: return 'Setup Required for Reliability';
    }
  }

  static String get statusSetupSubtitle {
    switch (effectiveLanguageCode) {
      case 'vi':
        return 'Chưa đủ quyền để khóa màn hình hoặc chống tắt ngầm. Nhấn nút bên dưới để cấp quyền ngay.';
      case 'zh':
        return '缺少锁屏或后台保护权限。请点击下方按钮快速配置。';
      case 'es':
        return 'Faltan permisos para bloquear pantalla o segundo plano. Toque abajo.';
      case 'ja':
        return '画面ロックまたはバックグラウンド保護の権限が不足しています。下をタップしてください。';
      case 'ko':
        return '화면 잠금 또는 백그라운드 보호 권한이 없습니다. 아래를 누르세요.';
      default:
        return 'Permissions missing for screen lock or kill protection. Tap below to set up now.';
    }
  }

  static String get quickSetupBtn {
    switch (effectiveLanguageCode) {
      case 'vi': return 'KÍCH HOẠT NHANH (1-CHẠM)';
      case 'zh': return '快速设置 (一键)';
      case 'es': return 'CONFIGURACIÓN RÁPIDA';
      case 'ja': return 'クイック設定 (ワンタップ)';
      case 'ko': return '빠른 설정 (원터치)';
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
      default: return 'QUICK SETUP (1-TAP)';
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
      case 'vi': return 'ĐÃ KÍCH HOẠT (0ms)';
      case 'zh': return '已激活 (0ms)';
      case 'es': return 'ACTIVO (0ms)';
      case 'ja': return '有効 (0ms)';
      case 'ko': return '활성화됨 (0ms)';
      case 'fr': return 'ACTIF (0ms)';
      case 'de': return 'AKTIV (0ms)';
      case 'ru': return 'АКТИВНО (0мс)';
      case 'pt': return 'ATIVO (0ms)';
      case 'id': return 'AKTIF (0ms)';
      case 'ar': return 'نشط (0 مللي ثانية)';
      case 'hi': return 'सक्रिय (0ms)';
      case 'it': return 'ATTIVO (0ms)';
      case 'nl': return 'ACTIEF (0ms)';
      case 'pl': return 'AKTYWNY (0ms)';
      case 'cs': return 'AKTIVNÍ (0ms)';
      case 'tl': return 'AKTIBO (0ms)';
      default: return 'ACTIVE (0ms)';
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

  static String get deactivateAdminConfirmTitle {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Hủy kích hoạt Quản trị viên?';
      case 'zh': return '取消激活设备管理器？';
      default: return 'Deactivate Device Administrator?';
    }
  }

  static String get deactivateAdminConfirmDesc {
    switch (effectiveLanguageCode) {
      case 'vi':
        return 'Sau khi hủy, bạn có thể dễ dàng gỡ cài đặt ứng dụng bất cứ lúc nào. Bạn có chắc muốn hủy không?';
      case 'zh':
        return '取消激活后，您可以随时轻松卸载本应用。确定要取消激活吗？';
      default:
        return 'After deactivating, you will be able to easily uninstall the application. Do you wish to proceed?';
    }
  }

  static String get cancelBtn {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Hủy';
      case 'zh': return '取消';
      case 'es': return 'Cancelar';
      case 'ja': return 'キャンセル';
      case 'ko': return '취소';
      default: return 'Cancel';
    }
  }

  static String get confirmBtn {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Xác nhận hủy';
      case 'zh': return '确认取消';
      default: return 'Confirm';
    }
  }

  // Main Action Controls
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

  static String get lockScreenDesc {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Tắt màn hình ngay lập tức (0ms)';
      case 'zh': return '立即关闭屏幕 (0ms)';
      case 'es': return 'Apagar pantalla al instante (0ms)';
      case 'ja': return '瞬時に画面をオフ (0ms)';
      case 'ko': return '즉시 화면 끄기 (0ms)';
      case 'fr': return 'Éteindre l\'écran immédiatement (0ms)';
      case 'de': return 'Bildschirm sofort ausschalten (0ms)';
      case 'ru': return 'Мгновенное выключение экрана (0мс)';
      case 'pt': return 'Desligar a tela instantaneamente (0ms)';
      case 'id': return 'Matikan layar secara instan (0ms)';
      default: return 'Instant screen lock (0ms)';
    }
  }

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

  static String get volumePanelDesc {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Mở thanh chỉnh âm lượng hệ thống';
      case 'zh': return '调出系统音量控制滑块';
      case 'es': return 'Mostrar control deslizante de volumen';
      case 'ja': return 'システム音量スライダーを表示';
      case 'ko': return '시스템 볼륨 조절 슬라이더 열기';
      default: return 'Show system volume slider';
    }
  }

  // Quick Access Section
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
  static String get permissionsHeader {
    switch (effectiveLanguageCode) {
      case 'vi': return 'Quản lý quyền & Chống tắt ngầm';
      case 'zh': return '权限管理与防杀后台';
      case 'es': return 'Permisos y protección en segundo plano';
      default: return 'Permissions & Keep-Alive Settings';
    }
  }

  static String get a11yTitle => isVietnamese() ? 'Dịch vụ trợ năng (Accessibility)' : 'Accessibility Service';
  static String get a11yActive => isVietnamese() ? 'Đang hoạt động (Khóa qua Global Action)' : 'Active (Global Action lock)';
  static String get a11yInactive => isVietnamese() ? 'Chưa bật trong Cài đặt' : 'Disabled in Settings';

  static String get deviceAdminTitle => isVietnamese() ? 'Quản trị viên thiết bị (Device Admin)' : 'Device Administrator';
  static String get deviceAdminActive => isVietnamese() ? 'Đã kích hoạt (Khóa phần cứng 0ms)' : 'Active (Hardware 0ms lock)';
  static String get deviceAdminInactive => isVietnamese() ? 'Chưa kích hoạt (Nên bật để chống bị tắt)' : 'Inactive (Recommended to prevent kill)';

  static String get keepAliveTitle => isVietnamese() ? 'Chạy ngầm liên tục (Keep-Alive)' : 'Keep-Alive Foreground Service';
  static String get keepAliveDesc => isVietnamese()
      ? 'Bảo vệ dịch vụ trợ năng không bị tắt khi vuốt đóng đa nhiệm'
      : 'Protects accessibility service from being killed when swiped away';

  static String get batteryOptTitle => isVietnamese() ? 'Bỏ qua tối ưu hóa pin' : 'Ignore Battery Optimization';
  static String get batteryOptActive => isVietnamese() ? 'Đã cho phép không hạn chế' : 'Unrestricted';
  static String get batteryOptInactive => isVietnamese() ? 'Đang bị tối ưu hóa (Nên tắt)' : 'Optimized by system (Tap to disable)';

  // OEM Guidance Section
  static String get oemGuideHeader => isVietnamese() ? 'Hướng dẫn chi tiết theo dòng máy' : 'Device-Specific Background Guide';
  static String get oemGuideSubtitle => isVietnamese()
      ? 'Đã tự động nhận diện thiết bị của bạn. Bạn cũng có thể chọn hãng máy khác bên dưới:'
      : 'Auto-detected your device. You can also select another manufacturer below:';
  static String get autoDetectedTag => isVietnamese() ? 'Máy của bạn' : 'Your Device';

  static String get oemHuawei => 'Huawei / Honor';
  static String get oemXiaomi => 'Xiaomi / Redmi / POCO';
  static String get oemSamsung => 'Samsung (One UI)';
  static String get oemOppo => 'OPPO / Realme';
  static String get oemVivo => 'Vivo / iQOO';
  static String get oemStock => 'Google / Stock Android';

  static String oemStepTitle(String oem) => isVietnamese() ? 'Các bước thiết lập cho $oem:' : 'Setup steps for $oem:';

  static String getOemInstructions(String oemKey, DeviceInfo? dev) {
    switch (oemKey) {
      case 'huawei':
        return isVietnamese()
            ? '1. Bấm nút bên dưới để mở màn hình Cài đặt Pin Huawei (EMUI).\n'
              '2. Chọn mục: "Khởi chạy ứng dụng" (App launch).\n'
              '3. Tìm app "Power & Volume" -> Tắt "Tự động quản lý" -> BẬT CẢ 3 CÔNG TẮC:\n'
              '   • Tự khởi chạy (Auto-launch)\n'
              '   • Khởi chạy phụ (Secondary launch)\n'
              '   • Chạy dưới nền (Run in background)\n'
              '4. Trong màn hình Đa nhiệm (Recent Apps): Vuốt nhẹ thẻ app xuống để hiện Ổ khóa 🔒.'
            : '1. Tap button below to open Huawei Battery Settings (EMUI).\n'
              '2. Select: "App launch".\n'
              '3. Find "Power & Volume" -> Turn OFF "Manage automatically" -> Turn ON all 3:\n'
              '   • Auto-launch\n'
              '   • Secondary launch\n'
              '   • Run in background\n'
              '4. In Recent Apps overview: Swipe down on app card until Lock icon 🔒 appears.';
      case 'xiaomi':
        return isVietnamese()
            ? '1. Bấm nút bên dưới để mở quản lý Tự khởi chạy (Autostart) của MIUI / HyperOS.\n'
              '2. BẬT công tắc "Tự khởi chạy" (Autostart) cho Power & Volume.\n'
              '3. Vào Cài đặt ứng dụng -> Tiết kiệm pin -> Chọn "Không hạn chế" (No restrictions).\n'
              '4. Trong màn hình Đa nhiệm: Nhấn giữ thẻ app và chọn biểu tượng Ổ khóa 🔒.'
            : '1. Tap button below to open MIUI / HyperOS Autostart management.\n'
              '2. Turn ON "Autostart" for Power & Volume.\n'
              '3. Go to App Info -> Battery Saver -> Choose "No restrictions".\n'
              '4. In Recent Apps: Long-press app card and tap Lock icon 🔒.';
      case 'samsung':
        return isVietnamese()
            ? '1. Bấm nút bên dưới để mở Cài đặt Pin Samsung (One UI).\n'
              '2. Vào "Giới hạn sử dụng dưới nền" -> "Ứng dụng không bao giờ ngủ" (Never sleeping apps).\n'
              '3. Bấm dấu (+) ở góc trên và thêm "Power & Volume" vào danh sách.\n'
              '4. Trong màn hình Đa nhiệm: Nhấn vào biểu tượng app ở đầu thẻ -> Chọn "Khóa ứng dụng này" 🔒.'
            : '1. Tap button below to open Samsung Battery Settings (One UI).\n'
              '2. Go to "Background usage limits" -> "Never sleeping apps".\n'
              '3. Tap (+) icon and add "Power & Volume" to the list.\n'
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
              '2. Mở app iManager -> Quản lý ứng dụng -> Tự khởi chạy -> BẬT cho Power & Volume.\n'
              '3. Vào Cài đặt Pin -> Mức tiêu thụ pin dưới nền cao -> BẬT công tắc cho Power & Volume.\n'
              '4. Trong màn hình Đa nhiệm: Kéo nhẹ thẻ app xuống để khóa 🔒.'
            : '1. Tap button below to open Vivo battery settings (Funtouch OS / OriginOS).\n'
              '2. Open iManager app -> App manager -> Autostart -> Turn ON for Power & Volume.\n'
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
    switch (oemKey) {
      case 'huawei': return isVietnamese() ? 'Mở Cài đặt Pin Huawei (EMUI)' : 'Open Huawei Battery Settings';
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
  static String get supportDeveloperTitle =>
      isVietnamese() ? 'Ủng hộ tác giả (Tùy tâm)' : 'Support Developer (Optional)';

  static String get supportDeveloperSubtitle => isVietnamese()
      ? 'Ứng dụng hoàn toàn miễn phí. Nếu bạn thấy app hữu ích, hãy gửi tặng tác giả 1 ly cà phê qua VietQR hoặc Payoneer!'
      : 'This utility is 100% free. If you find it helpful, feel free to buy the developer a coffee via Payoneer or VietQR!';

  static String get vietQrTab =>
      isVietnamese() ? 'Mã VietQR (Việt Nam)' : 'VietQR (Vietnam)';

  static String get payoneerTab =>
      isVietnamese() ? 'Payoneer (Quốc tế)' : 'Payoneer (International)';

  static const String bankAccountOwner = 'NGUYEN MINH THANH';
  static const String bankAccountNumber = '1020506046';
  static const String bankName = 'Vietcombank (Trụ sở CN Hải Phòng)';
  static const String payoneerEmail = 'alphaplus.thanh82@gmail.com';

  static String get copyAccountBtn =>
      isVietnamese() ? 'Sao chép số tài khoản VCB' : 'Copy Bank Account Number';

  static String get copyEmailBtn =>
      isVietnamese() ? 'Sao chép Email Payoneer' : 'Copy Payoneer Email';

  static String get copiedSuccessToast =>
      isVietnamese() ? 'Đã sao chép vào bộ nhớ tạm!' : 'Copied to clipboard!';

  static String get closeBtn =>
      isVietnamese() ? 'Đóng' : 'Close';

  static String get adBadge => isVietnamese() ? 'Quảng cáo' : 'Ad';

  static String get adBannerText => isVietnamese()
      ? 'Quảng cáo giúp ứng dụng duy trì 100% miễn phí'
      : 'Ads keep this utility 100% free for everyone';

  static String get adBannerSub => isVietnamese()
      ? 'Google AdMob / Petal Ads Banner'
      : 'Google AdMob / Petal Ads Banner';

  static String get payoneerGuide => isVietnamese()
      ? 'Bạn có thể chuyển tiền ủng hộ qua tính năng Pay / Make a Payment của Payoneer đến email trên, hoặc chuyển khoản quốc tế.'
      : 'Send your support via Payoneer internal transfer (Pay to a recipient) using the email above, or via international card.';

  static String get scanQrGuide => isVietnamese()
      ? 'Mở ứng dụng ngân hàng bất kỳ (VCB, VietinBank, Techcombank, MB, VPBank...) và quét mã QR này để ủng hộ.'
      : 'Open your mobile banking app and scan this VietQR code to send direct donation.';
}
