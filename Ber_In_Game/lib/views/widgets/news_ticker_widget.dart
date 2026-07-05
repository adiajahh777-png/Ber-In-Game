import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class NewsTickerWidget extends StatefulWidget {
  final List<String> newsHeadlines;

  const NewsTickerWidget({super.key, required this.newsHeadlines});

  @override
  State<NewsTickerWidget> createState() => _NewsTickerWidgetState();
}

class _NewsTickerWidgetState extends State<NewsTickerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Durasi putaran teks, semakin besar semakin lambat
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 40));
    _controller.addListener(() {
      if (_scrollController.hasClients) {
        double maxExtent = _scrollController.position.maxScrollExtent;
        if (maxExtent > 0) {
          double currentOffset = maxExtent * _controller.value;
          _scrollController.jumpTo(currentOffset);
        }
      }
    });
    
    // Tunda sebentar sebelum animasi dimulai agar layout selesai ter-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.newsHeadlines.isEmpty) return const SizedBox.shrink();

    // Menggabungkan headline menjadi satu string panjang dengan separator
    String combinedText = widget.newsHeadlines.join('   ///   ');
    // Duplikasi teks berkali-kali untuk memastikan efek loop terlihat natural dan mulus
    combinedText = '   ///   $combinedText   ///   $combinedText   ///   $combinedText   ///   $combinedText   ///   $combinedText';

    return Container(
      width: double.infinity,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // Badge "LIVE"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.error],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'LIVE',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // Marquee Text
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 1,
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                    combinedText,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 11,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
