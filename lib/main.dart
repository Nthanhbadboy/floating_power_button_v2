import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'widgets/privacy_notice.dart';
import 'core/localization.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PowerVolumeApp());
}

class PowerVolumeApp extends StatelessWidget {
  const PowerVolumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SupportedLanguage>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, language, _) => MaterialApp(
        title: 'Power&volume',
        debugShowCheckedModeBanner: false,
        locale: Locale(AppStrings.effectiveLanguageCode == 'tl'
            ? 'fil' : AppStrings.effectiveLanguageCode),
        supportedLocales: const [
          Locale('en'), Locale('vi'), Locale('zh'), Locale('es'), Locale('ja'),
          Locale('ko'), Locale('fr'), Locale('de'), Locale('ru'), Locale('pt'),
          Locale('id'), Locale('ar'), Locale('hi'), Locale('it'), Locale('nl'),
          Locale('pl'), Locale('cs'), Locale('fil'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        ),
        home: const PrivacyGate(),
      ),
    );
  }
}
