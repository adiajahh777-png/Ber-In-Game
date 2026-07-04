import 'package:flutter/material.dart';

/// Model untuk merepresentasikan kategori game esport (misal: MLBB, PUBG Mobile, Valorant).
class GameCategoryModel {
  final String id;
  final String name;
  final String iconKey; // Key untuk merujuk ke Icon FontAwesome atau Aset Gambar
  final Color accentColor; // Warna identitas game tersebut untuk mempercantik UI

  GameCategoryModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.accentColor,
  });

  /// Daftar Kategori Game Esport Default yang siap digunakan.
  static List<GameCategoryModel> get defaultCategories {
    return [
      GameCategoryModel(
        id: 'all',
        name: 'Semua',
        iconKey: 'gamepad',
        accentColor: const Color(0xFF8B5CF6), // Neon Purple
      ),
      GameCategoryModel(
        id: 'mlbb',
        name: 'MLBB',
        iconKey: 'mobile',
        accentColor: const Color(0xFF06B6D4), // Electric Cyan
      ),
      GameCategoryModel(
        id: 'pubg',
        name: 'PUBG',
        iconKey: 'crosshairs',
        accentColor: const Color(0xFFF59E0B), // Amber Orange
      ),
      GameCategoryModel(
        id: 'valorant',
        name: 'Valorant',
        iconKey: 'shield',
        accentColor: const Color(0xFFEF4444), // Crimson Red
      ),
      GameCategoryModel(
        id: 'dota2',
        name: 'Dota 2',
        iconKey: 'fire',
        accentColor: const Color(0xFFE11D48), // Dota Red
      ),
      GameCategoryModel(
        id: 'freefire',
        name: 'Free Fire',
        iconKey: 'skull',
        accentColor: const Color(0xFF10B981), // Green
      ),
    ];
  }
}

