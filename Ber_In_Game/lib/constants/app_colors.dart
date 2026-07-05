import 'package:flutter/material.dart';

/// Konstanta warna yang digunakan di seluruh aplikasi Portal Berita Esport.
/// Mengusung tema gelap (Dark Theme) dengan aksen Neon (Violet & Cyan) khas dunia gaming.
class AppColors {
  // Latar belakang utama (Deep Obsidian / Black)
  static const Color background = Color(0xFF121212);
  static const Color scaffoldBackground = Color(0xFF0A0A0A);
  
  // Warna Card / Kontainer (Elevated surfaces)
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceSecondary = Color(0xFF252528);
  
  // Aksen utama (Neon Violet / Purple)
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA78BFA);
  
  // Aksen sekunder (Electric Cyan)
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF22D3EE);
  
  // Warna Teks
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  
  // Warna Status / Fungsional
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color error = Color(0xFFEF4444);   // Coral Red
  static const Color warning = Color(0xFFF59E0B); // Amber Yellow
  static const Color info = Color(0xFF3B82F6);    // Royal Blue
  
  // Gradients untuk nuansa Cyberpunk/Esport
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1E1E24), Color(0xFF121212)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [primary, Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [secondary, Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

