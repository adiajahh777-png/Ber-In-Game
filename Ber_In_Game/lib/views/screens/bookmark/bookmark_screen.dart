import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../constants/app_colors.dart';
import '../../widgets/news_card_widget.dart';
import '../home/article_detail_screen.dart';

/// Screen Bookmark / Berita yang Disimpan.
/// Menampilkan artikel berita esport yang ditandai (bookmarked) oleh user yang sedang masuk.
/// Jika belum ada berita yang disimpan, menampilkan halaman status kosong bertema gamer.
class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final newsProvider = context.watch<NewsProvider>();
    
    // Cari artikel yang ID-nya tercatat di bookmarks user
    final bookmarkedArticleIds = authProvider.currentUser?.bookmarkedArticles ?? [];
    final bookmarkedArticles = newsProvider.articles.where((article) {
      return bookmarkedArticleIds.contains(article.id);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BERITA DISIMPAN'),
      ),
      body: SafeArea(
        child: bookmarkedArticles.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ikon Bookmark Cyberpunk
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
                        ),
                        child: Icon(
                          Icons.bookmark_outline,
                          size: 48,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      )
                          .animate()
                          .scale(duration: 400.ms, curve: Curves.easeOutBack)
                          .then()
                          .shake(duration: 600.ms, hz: 2),
                      const SizedBox(height: 24),
                      const Text(
                        'BELUM ADA BERITA DISIMPAN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Jelajahi portal berita dan tandai artikel favorit Anda untuk dibaca kembali kapan saja.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: bookmarkedArticles.length,
                itemBuilder: (context, index) {
                  final article = bookmarkedArticles[index];
                  return NewsCardWidget(
                    article: article,
                    isHorizontal: true,
                    onTap: () {
                      newsProvider.incrementViews(article.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailScreen(article: article),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

