import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/article_model.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../constants/app_colors.dart';
import '../../widgets/custom_shimmer_loader.dart';

/// Screen Detail Artikel Berita Esport.
/// Dilengkapi dengan:
/// 1. Parallax/Collapsing Header Image (SliverAppBar + FlexibleSpaceBar).
/// 2. Integrasi Bookmark dengan AuthProvider.
/// 3. Statistik Views & tombol bagikan berita.
/// 4. Isi berita yang diformat dengan layout majalah digital.
/// 5. Seksi Komentar real-time (membaca dan menambah komentar baru).
class ArticleDetailScreen extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoadingComments = false;

  Color _getCategoryColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('mobile')) return const Color(0xFF00E5FF);
    if (lower.contains('mmo')) return const Color(0xFFB388FF);
    if (lower.contains('shooter') || lower.contains('fps')) return const Color(0xFFFF1744);
    if (lower.contains('moba')) return const Color(0xFFFFD600);
    return AppColors.primaryLight;
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('mobile')) return Icons.smartphone;
    if (lower.contains('mmo')) return Icons.public;
    if (lower.contains('shooter') || lower.contains('fps')) return Icons.track_changes;
    if (lower.contains('moba')) return Icons.sports_esports;
    return Icons.gamepad;
  }

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoadingComments = true;
    });
    
    final commentsList = await context.read<NewsProvider>().getComments(widget.article.id);
    
    if (mounted) {
      setState(() {
        _comments = commentsList;
        _isLoadingComments = false;
      });
    }
  }

  void _postComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final newsProvider = context.read<NewsProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu untuk berkomentar.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = authProvider.currentUser!;
    bool success = await newsProvider.addComment(
      widget.article.id,
      user.uid,
      user.displayName,
      user.photoUrl,
      commentText,
    );

    if (success && mounted) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      _fetchComments(); // Reload komentar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar berhasil dikirim!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isBookmarked = authProvider.currentUser?.bookmarkedArticles.contains(widget.article.id) ?? false;
    final isLiked = authProvider.currentUser?.likedArticles.contains(widget.article.id) ?? false;
    final timeFormatted = DateFormat('dd MMMM yyyy, HH:mm', 'id').format(widget.article.publishedAt);

    return Scaffold(
      body: Stack(
        children: [
          // Konten utama dengan CustomScrollView untuk collapsing effect
          CustomScrollView(
            slivers: [
              // 1. Collapsing Parallax Header Image
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.background,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  // Tombol Like
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? AppColors.error : Colors.white,
                        size: 20,
                      ),
                      onPressed: () async {
                        if (!authProvider.isAuthenticated) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login untuk menyukai berita.')));
                          return;
                        }
                        await authProvider.toggleLike(widget.article.id);
                        if (!mounted) return;
                        await context.read<NewsProvider>().toggleLikeArticle(widget.article.id, !isLiked);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isLiked 
                                  ? 'Batal menyukai berita.' 
                                  : 'Berita disukai!',
                            ),
                            duration: const Duration(milliseconds: 1500),
                          ),
                        );
                      },
                    ),
                  ),
                  // Tombol Bookmark
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? AppColors.secondary : Colors.white,
                        size: 20,
                      ),
                      onPressed: () async {
                        await authProvider.toggleBookmark(widget.article.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBookmarked 
                                  ? 'Berita dihapus dari Bookmark.' 
                                  : 'Berita disimpan ke Bookmark!',
                            ),
                            duration: const Duration(milliseconds: 1500),
                          ),
                        );
                      },
                    ),
                  ),
                  // Tombol Share
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                      onPressed: () {
                        // Demo copy link
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tautan berita disalin ke papan klip!'),
                            backgroundColor: AppColors.secondary,
                            duration: Duration(milliseconds: 1500),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Latar belakang gradien menarik sesuai kategori game
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(widget.article.gameCategory).withValues(alpha: 0.8),
                              AppColors.background,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // Ikon raksasa transparan sebagai elemen dekorasi
                      Positioned(
                        right: -40,
                        bottom: -40,
                        child: Icon(
                          _getCategoryIcon(widget.article.gameCategory),
                          size: 240,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      // Overlay Gradient Gelap di bagian bawah agar menyatu dengan body
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, AppColors.scaffoldBackground],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Konten Artikel
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Game Badge & View stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            widget.article.gameCategory.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.article.viewsCount} kali dibaca',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Judul Artikel
                    Text(
                      widget.article.title,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.4,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Info Penulis & Tanggal
                    Row(
                      children: [
                        const Icon(Icons.edit, size: 12, color: AppColors.primaryLight),
                        const SizedBox(width: 6),
                        Text(
                          'Oleh: ${widget.article.author}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          timeFormatted,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: AppColors.surfaceSecondary, thickness: 1.5),
                    
                    // Isi Berita
                    Text(
                      widget.article.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 24),
                    // Sumber & Link Asli
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.public, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sumber Asli: ${widget.article.sourceName}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final Uri url = Uri.parse(widget.article.sourceUrl);
                                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Tidak dapat membuka link: ${widget.article.sourceUrl}')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.open_in_new, size: 14),
                              label: const Text('BACA ARTIKEL SELENGKAPNYA'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Section Judul Komentar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DISKUSI GAMER',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${_comments.length} Komentar',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // List Komentar
                    _isLoadingComments
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: CircularProgressIndicator(color: AppColors.secondary),
                            ),
                          )
                        : _comments.isEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 32.0),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Belum ada komentar. Jadilah yang pertama berkomentar!',
                                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _comments.length,
                                itemBuilder: (context, index) {
                                  final comment = _comments[index];
                                  final commentTime = DateFormat('dd MMM, HH:mm', 'id').format(comment.timestamp);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Foto Profil Komentator
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage: NetworkImage(comment.userPhoto),
                                        ),
                                        const SizedBox(width: 12),
                                        // Isi Komentar
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    comment.userName,
                                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryLight),
                                                  ),
                                                  Text(
                                                    commentTime,
                                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                comment.commentText,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    const SizedBox(height: 100), // Memberi ruang ekstra untuk keyboard/input komentar
                  ]),
                ),
              ),
            ],
          ),

          // 3. Floating Input Box untuk Komentar di bagian bawah layar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    top: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.6),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Field input komentar
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar esport Anda...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: AppColors.scaffoldBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.secondary, width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Kirim
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 16),
                      onPressed: _postComment,
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

