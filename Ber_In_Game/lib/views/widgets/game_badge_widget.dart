import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/game_category_model.dart';
import '../../constants/app_colors.dart';

/// Widget Badge Kategori Game Esport yang menampilkan ikon FontAwesome,
/// warna identitas game (misal: merah untuk Valorant, cyan untuk MLBB),
/// serta status aktif/pilihan user dengan micro-animations.
class GameBadgeWidget extends StatelessWidget {
  final GameCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const GameBadgeWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  /// Mengonversi key string dari model menjadi IconData FontAwesome
  FaIconData _getIconData(String key) {
    switch (key.toLowerCase()) {
      case 'gamepad':
        return FontAwesomeIcons.gamepad;
      case 'mobile':
        return FontAwesomeIcons.mobileScreen;
      case 'crosshairs':
        return FontAwesomeIcons.crosshairs;
      case 'shield':
        return FontAwesomeIcons.shieldHalved;
      case 'fire':
        return FontAwesomeIcons.fire;
      case 'skull':
        return FontAwesomeIcons.skull;
      default:
        return FontAwesomeIcons.gamepad;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = isSelected ? category.accentColor : Colors.white.withValues(alpha: 0.05);
    final Color contentColor = isSelected ? Colors.white : AppColors.textSecondary;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(30), // Lebih membulat (pill)
          border: Border.all(
            color: isSelected 
                ? category.accentColor.withValues(alpha: 0.8) 
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category.accentColor.withValues(alpha: 0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: category.accentColor.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: -5,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    _getIconData(category.iconKey),
                    size: 14,
                    color: contentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    .animate(target: isSelected ? 1 : 0)
    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.08, 1.08), duration: 200.ms, curve: Curves.easeOutBack);
  }
}

