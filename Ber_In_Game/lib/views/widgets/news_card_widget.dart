import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/article_model.dart';
import '../../constants/app_colors.dart';
import 'custom_shimmer_loader.dart';

/// Widget Card Berita Esport yang mendukung format horizontal dan vertikal.
/// Menggunakan `cached_network_image` dengan placeholder shimmer dan
/// format tanggal menggunakan pustaka `intl`. Dilengkapi dengan animasi masuk (fade-in, slide-up).
class NewsCardWidget extends StatelessWidget {
  final ArticleModel article;
  final bool isHorizontal;
  final VoidCallback onTap;

  const NewsCardWidget({
    super.key,
    required this.article,
    this.isHorizontal = true,
    required this.onTap,
  });

  /// Mengambil warna aksen berdasarkan kategori game untuk tag/badge berita
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mlbb':
        return const Color(0xFF06B6D4); // Cyan
      case 'pubg':
        return const Color(0xFFF59E0B); // Amber
      case 'valorant':
        return const Color(0xFFEF4444); // Red
      case 'dota 2':
      case 'dota2':
        return const Color(0xFFE11D48); // Dark Red
      default:
        return AppColors.primary; // Violet
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatted = DateFormat('dd MMM yyyy, HH:mm', 'id').format(article.publishedAt);
    
    if (isHorizontal) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Kategori & Views Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(article.gameCategory).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getCategoryColor(article.gameCategory).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      article.gameCategory.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(article.gameCategory),
                      ),
                    ),
                  ),
                  // Tayangan (views) dan Likes
                  Row(
                    children: [
                      const Icon(Icons.favorite_border, size: 12, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(
                        '${article.likesCount}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.remove_red_eye_outlined, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${article.viewsCount}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Judul Berita
              Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              // Excerpt (Cuplikan Berita)
              Text(
                article.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              // Author & Waktu Publish
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    article.author,
                    style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    timeFormatted,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
      )
      .animate()
      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
      .slideY(begin: 0.1, end: 0.0, duration: 400.ms, curve: Curves.easeOut);
    } else {
      // Tampilan Vertikal (untuk berita trending / breaking news di carousel/card utama)
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(article.gameCategory).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _getCategoryColor(article.gameCategory).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        article.gameCategory.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(article.gameCategory),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border, size: 12, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          '${article.likesCount}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.remove_red_eye_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${article.viewsCount}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    article.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      article.author,
                      style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeFormatted.split(',')[0], // Tampilkan tanggal saja untuk vertikal card
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
      )
      .animate()
      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
      .slideX(begin: 0.1, end: 0.0, duration: 400.ms, curve: Curves.easeOut);
    }
  }
}

