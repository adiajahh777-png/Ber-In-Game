import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';

/// Widget Shimmer Loader untuk status pemuatan (loading) artikel berita atau profil.
/// Dibangun menggunakan `flutter_animate` untuk efek shimmer yang halus dan berkelas,
/// sehingga tidak memerlukan pustaka tambahan eksternal di luar pubspec.yaml.
class CustomShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const CustomShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          colors: [
            AppColors.surfaceSecondary,
            AppColors.surfaceSecondary.withValues(alpha: 0.4),
            AppColors.surfaceSecondary,
          ],
          stops: [0.0, 0.5, 1.0],
          angle: 1.5,
        );
  }

  /// Shimmer berbentuk card berita untuk list loading
  static Widget newsCardPlaceholder({EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomShimmerLoader(width: 110, height: 85, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomShimmerLoader(width: 80, height: 16, borderRadius: 4),
                const SizedBox(height: 8),
                CustomShimmerLoader(width: double.infinity, height: 18, borderRadius: 4),
                const SizedBox(height: 6),
                const CustomShimmerLoader(width: 150, height: 14, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shimmer berbentuk list card turnamen
  static Widget tournamentCardPlaceholder({EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomShimmerLoader(
        width: double.infinity,
        height: 120,
        borderRadius: 16,
      ),
    );
  }
}

