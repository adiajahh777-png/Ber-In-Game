import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/game_category_model.dart';
import '../../../constants/app_colors.dart';
import '../../widgets/game_badge_widget.dart';
import '../../widgets/news_card_widget.dart';
import '../../widgets/custom_shimmer_loader.dart';
import 'article_detail_screen.dart';

/// Screen Beranda Utama Portal Berita Esport.
/// Terdiri dari:
/// 1. Header Profil & Tombol Pencarian.
/// 2. Breaking/Trending News Carousel (Horizontal scroll).
/// 3. Filter Kategori Game (MLBB, PUBG, dll).
/// 4. List Berita Terbaru (Latest News).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<NewsProvider>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final newsProvider = context.watch<NewsProvider>();
    final categories = GameCategoryModel.defaultCategories;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => newsProvider.loadArticles(),
          color: AppColors.secondary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. App Bar Area (Custom Header)
              SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'HELLO, ',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                authProvider.currentUser?.displayName.toUpperCase() ?? 'GAMER',
                                style: const TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 12,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ESPORT PORTAL',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 22, // Diperbesar
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Foto Profil mini
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surface,
                        backgroundImage: NetworkImage(
                          authProvider.currentUser?.photoUrl ?? 
                          'https://api.dicebear.com/7.x/pixel-art/png?seed=gamer',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Search Bar Area
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white, fontFamily: 'Orbitron', fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Cari berita esport terbaru...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Orbitron'),
                            prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.textMuted),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Carousel Breaking News (Hanya muncul jika tidak sedang mencari berita)
              if (newsProvider.searchQuery.isEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BREAKING NEWS',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: AppColors.error.withValues(alpha: 0.5), blurRadius: 10),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                          ),
                          child: const Text(
                            'HOT',
                            style: TextStyle(fontSize: 8, color: AppColors.error, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 260,
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    child: newsProvider.isLoading
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 16),
                            itemCount: 3,
                            itemBuilder: (context, index) => const CustomShimmerLoader(
                              width: 280,
                              height: 250,
                              borderRadius: 20,
                              margin: EdgeInsets.only(right: 16),
                            ),
                          )
                        : newsProvider.breakingNews.isEmpty
                            ? const Center(child: Text('Tidak ada berita trending saat ini.'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(left: 16),
                                itemCount: newsProvider.breakingNews.length,
                                itemBuilder: (context, index) {
                                  final article = newsProvider.breakingNews[index];
                                  return NewsCardWidget(
                                    article: article,
                                    isHorizontal: false,
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
                ),
              ],

              // 4. Header Hasil Pencarian
              if (newsProvider.searchQuery.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'HASIL PENCARIAN',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: AppColors.secondary.withValues(alpha: 0.5), blurRadius: 10),
                        ],
                      ),
                    ),
                  ),
                ),

              // 5. List Berita Terbaru (Latest News)
              newsProvider.isLoading
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => CustomShimmerLoader.newsCardPlaceholder(),
                        childCount: 5,
                      ),
                    )
                  : newsProvider.filteredArticles.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 48.0),
                            child: Center(
                              child: Text(
                                'Tidak ada berita yang cocok.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final article = newsProvider.filteredArticles[index];
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
                            childCount: newsProvider.filteredArticles.length,
                          ),
                        ),
              
              // Bottom Spacer
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

