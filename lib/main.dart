import 'package:flutter/material.dart';
import 'widgets/privacy_notice.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PowerVolumeApp());
}

class PowerVolumeApp extends StatelessWidget {
  const PowerVolumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power & Volume',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const PrivacyGate(),
    );
  }
}
