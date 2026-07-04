import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_themes.dart';
import 'providers/auth_provider.dart';
import 'providers/news_provider.dart';
import 'providers/tournament_provider.dart';
import 'views/screens/splash_onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.en-sureInitialized();
  
  // Inisialisasi Lokalisasi Tanggal (Bahasa Indonesia) demi kelancaran parsing DateFormat
  try {
    await initializeDateFormatting('id', null);
  } catch (e) {
    debugPrint('Gagal inisialisasi date formatting id: $e');
  }

  // Inisialisasi Firebase secara opsional
  try {
    // Mencoba menginisialisasi Firebase (bekerja jika google-services.json ada)
    await Firebase.initializeApp();
    debugPrint('Firebase berhasil diinisialisasi.');
  } catch (e) {
    debugPrint('Firebase gagal diinisialisasi (menggunakan fallback Mock): $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
      ],
      child: const EsportNewsApp(),
    ),
  );
}

/// Widget Root Aplikasi Portal Berita Esport Modern.
class EsportNewsApp extends StatelessWidget {
  const EsportNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Berita Esport',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.darkTheme,
      home: const SplashOnboardingScreen(),
    );
  }
}

