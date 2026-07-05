import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/article_model.dart';

/// Provider untuk mengelola status berita esport, kategori game, serta interaksi komentar.
/// Menghubungkan langsung dengan Firestore collection `articles` jika Firebase tersedia.
/// Jika Firebase tidak tersedia, memuat Mock Data berita esport Indonesia yang sangat detail.
class NewsProvider with ChangeNotifier {
  FirebaseFirestore? _db;

  List<ArticleModel> _articles = [];
  final Map<String, List<CommentModel>> _commentsMap = {}; // Local memory untuk komentar per ID artikel
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isTranslated = false;

  List<ArticleModel> get articles => _articles;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isTranslated => _isTranslated;

  /// Memeriksa ketersediaan Firebase
  bool get isFirebaseAvailable => _db != null;

  void toggleTranslation() {
    _isTranslated = !_isTranslated;
    loadArticles();
  }

  Future<String> _translateText(String text) async {
    if (text.isEmpty) return text;
    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=id&dt=t&q=${Uri.encodeComponent(text)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<dynamic> segments = data[0];
        String translated = '';
        for (var segment in segments) {
          translated += segment[0];
        }
        return translated;
      }
    } catch (e) {
      debugPrint('Translate error: $e');
    }
    return text;
  }

  NewsProvider() {
    _initFirebase();
    loadArticles();
  }

  void _initFirebase() {
    try {
      _db = FirebaseFirestore.instance;
    } catch (_) {
      _db = null;
    }
  }

  /// Memilih kategori game untuk menyaring berita
  void selectCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  /// Mengubah kata kunci pencarian berita
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Mengambil daftar artikel tersaring berdasarkan kategori dan query pencarian
  List<ArticleModel> get filteredArticles {
    return _articles.where((article) {
      final matchesCategory = _selectedCategory == 'all' || 
          article.gameCategory.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          article.content.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Mengambil artikel trending/popular
  List<ArticleModel> get trendingArticles {
    return _articles.where((article) => article.isTrending).toList();
  }

  /// Mengambil breaking news (misal 3 artikel terbaru paling penting)
  List<ArticleModel> get breakingNews {
    final trending = trendingArticles;
    if (trending.isNotEmpty) return trending.take(3).toList();
    return _articles.take(3).toList();
  }

  /// Memuat artikel berita dari RSS Feed (atau fallback ke Firestore/Mock Data)
  Future<void> loadArticles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiArticles = await fetchArticlesFromApi();
      if (apiArticles.isNotEmpty) {
        _articles = apiArticles;
      } else {
        await _loadFallbackArticles();
      }
    } catch (e) {
      debugPrint('Gagal memuat berita dari RSS: $e. Menggunakan fallback.');
      await _loadFallbackArticles();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFallbackArticles() async {
    if (isFirebaseAvailable) {
      try {
        final querySnap = await _db!
            .collection('articles')
            .orderBy('publishedAt', descending: true)
            .get();

        if (querySnap.docs.isNotEmpty) {
          _articles = querySnap.docs
              .map((doc) => ArticleModel.fromMap(doc.data(), doc.id))
              .toList();
          return;
        }
      } catch (e) {
        debugPrint('Error fallback Firestore: $e');
      }
    }
    _loadMockArticles();
  }

  /// Menambah jumlah tayang (views) artikel sewaktu dibuka
  Future<void> incrementViews(String articleId) async {
    // Cari index artikel lokal dan update viewsCount secara langsung agar responsif di UI
    final index = _articles.indexWhere((art) => art.id == articleId);
    if (index != -1) {
      final updatedArticle = _articles[index].copyWith(
        viewsCount: _articles[index].viewsCount + 1,
      );
      _articles[index] = updatedArticle;
      notifyListeners();
    }

    if (isFirebaseAvailable) {
      try {
        await _db!.collection('articles').doc(articleId).update({
          'viewsCount': FieldValue.increment(1),
        });
      } catch (e) {
        debugPrint('Gagal increment views di Firestore: $e');
      }
    }
  }

  /// Menambah/mengurangi jumlah likes pada artikel
  Future<void> toggleLikeArticle(String articleId, bool isLiked) async {
    final index = _articles.indexWhere((art) => art.id == articleId);
    if (index != -1) {
      final updatedArticle = _articles[index].copyWith(
        likesCount: _articles[index].likesCount + (isLiked ? 1 : -1),
      );
      _articles[index] = updatedArticle;
      notifyListeners();
    }

    if (isFirebaseAvailable) {
      try {
        await _db!.collection('articles').doc(articleId).update({
          'likesCount': FieldValue.increment(isLiked ? 1 : -1),
        });
      } catch (e) {
        debugPrint('Gagal update likes di Firestore: $e');
      }
    }
  }

  /// Memuat komentar untuk suatu artikel
  Future<List<CommentModel>> getComments(String articleId) async {
    if (isFirebaseAvailable) {
      try {
        final snap = await _db!
            .collection('articles')
            .doc(articleId)
            .collection('comments')
            .orderBy('timestamp', descending: true)
            .get();

        final commentsList = snap.docs
            .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
            .toList();
            
        _commentsMap[articleId] = commentsList;
        return commentsList;
      } catch (e) {
        debugPrint('Gagal fetch comments dari Firestore: $e');
        return _commentsMap[articleId] ?? [];
      }
    } else {
      // Ambil dari local mock memori
      if (!_commentsMap.containsKey(articleId)) {
        _commentsMap[articleId] = _generateMockComments(articleId);
      }
      return _commentsMap[articleId] ?? [];
    }
  }

  /// Menambah komentar baru ke artikel
  Future<bool> addComment(String articleId, String userId, String userName, String userPhoto, String text) async {
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      commentText: text,
      timestamp: DateTime.now(),
    );

    // Update lokal memori komentar
    if (_commentsMap.containsKey(articleId)) {
      _commentsMap[articleId]!.insert(0, newComment);
    } else {
      _commentsMap[articleId] = [newComment];
    }
    notifyListeners();

    if (isFirebaseAvailable) {
      try {
        await _db!
            .collection('articles')
            .doc(articleId)
            .collection('comments')
            .add(newComment.toMap());
        return true;
      } catch (e) {
        debugPrint('Gagal tambah komentar ke Firestore: $e');
        return false;
      }
    }
    return true;
  }

  /// Memuat dataset mock berita esport lokal
  void _loadMockArticles() {
    _articles = _generateMockArticles();
  }

  /// Generator Mock Articles yang sangat detail
  List<ArticleModel> _generateMockArticles() {
    return [
      ArticleModel(
        id: 'art_1',
        title: 'RRQ Hoshi Umumkan Roster Terbaru untuk MPL Indonesia Season 17!',
        content: 'Tim esport legendaris Indonesia, RRQ Hoshi, secara resmi mengumumkan jajaran roster terbaru mereka untuk menyambut turnamen kasta tertinggi Mobile Legends: Bang Bang, yaitu MPL Indonesia Season 17. Pengumuman ini dirilis melalui media sosial resmi tim pada malam hari kemarin.\n\nYang mengejutkan para penggemar (Kingdom) adalah kembalinya pemain veteran legendaris di posisi Gold Laner, didampingi oleh bakat muda berbakat asal Filipina yang baru saja ditransfer. Keputusan ini dinilai strategis oleh analis esport untuk merebut kembali tahta juara yang sempat hilang pada musim sebelumnya.\n\n"Kami telah melakukan evaluasi besar-besaran dan percaya bahwa kombinasi mental veteran serta agresivitas pemain muda ini adalah ramuan terbaik untuk Season 17," ujar sang pelatih kepala dalam konferensi pers virtual.\n\nMari kita nantikan aksi perdana mereka di minggu pertama MPL ID Season 17 nanti!',
        imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800&auto=format&fit=crop',
        gameCategory: 'MLBB',
        author: 'Fajar Esport',
        viewsCount: 1420,
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isTrending: true,
      ),
      ArticleModel(
        id: 'art_2',
        title: 'Bigetron Red Aliens Juara PMPL SEA Autumn Champion setelah Epic Comeback!',
        content: 'Pertandingan sengit grand final PMPL SEA Autumn Champion baru saja usai dengan kemenangan dramatis dari tim kebanggaan Indonesia, Bigetron Red Aliens. Bermain di hadapan ribuan penonton online, tim berlogo alien merah ini berhasil meraih gelar juara setelah melakukan aksi epic comeback luar biasa pada hari terakhir.\n\nSempat tertinggal di posisi kelima klasemen pada hari kedua, BTR bangkit dengan mengamankan 3 kali WWCD (Winner Winner Chicken Dinner) berturut-turut pada 3 map terakhir di hari ketiga. Kombinasi permainan taktis dari IGL serta tembakan akurat para Rusher andalan sukses membungkam dominasi tim-tim kuat asal Thailand dan Malaysia.\n\nDengan kemenangan bersejarah ini, Bigetron Red Aliens berhak membawa pulang hadiah utama sebesar \$50,000 USD sekaligus mengamankan tiket menuju PMGC (PUBG Mobile Global Championship) akhir tahun nanti.',
        imageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=800&auto=format&fit=crop',
        gameCategory: 'PUBG',
        author: 'Rian Wijaya',
        viewsCount: 980,
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        isTrending: true,
      ),
      ArticleModel(
        id: 'art_3',
        title: 'Valorant Champions Tour 2026: Paper Rex Lolos ke Grand Final!',
        content: 'Tim kebanggaan Asia Tenggara, Paper Rex (PRX), kembali mengukir sejarah emas di kancah internasional Valorant Champions Tour (VCT) 2026 yang digelar di Seoul, Korea Selatan. PRX memastikan diri melangkah ke babak Grand Final setelah menundukkan raksasa Eropa dalam laga Best of 5 (Bo5) yang sangat menegangkan.\n\nPermainan agresif "W-Gaming" yang menjadi ciri khas PRX sukses membuat musuh kocar-kacir di map Sunset dan Lotus. Meskipun sempat kecolongan di map Breeze akibat strategi counter musuh, koordinasi apik di ronde overtime map penentu Haven akhirnya mengunci kemenangan 3-1 bagi Paper Rex.\n\n"Kami hanya bermain lepas, menikmati game, dan saling percaya satu sama lain. Terima kasih atas dukungan luar biasa dari fans di Indonesia dan seluruh Asia Tenggara," ucap salah satu pemain PRX dalam sesi wawancara pasca-tanding.',
        imageUrl: 'https://images.unsplash.com/photo-1552820728-8b83bb6b773f?q=80&w=800&auto=format&fit=crop',
        gameCategory: 'Valorant',
        author: 'Andi Pratama',
        viewsCount: 2150,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        isTrending: true,
      ),
      ArticleModel(
        id: 'art_4',
        title: 'Update Patch Dota 2 Versi 7.36: Penyesuaian Meta Besar-Besaran!',
        content: 'Valve baru saja meluncurkan update patch terbaru untuk Dota 2, yakni versi 7.36. Update kali ini membawa perubahan yang sangat masif, terutama pengenalan sistem mekanik baru berupa "Innate Abilities" dan "Hero Facets" yang secara total merombak cara memainkan setiap hero di medan pertempuran.\n\nKini, setiap hero memiliki kemampuan pasif bawaan sejak level 1 tanpa perlu mengalokasikan poin skill. Ditambah dengan Facets, pemain dapat memilih salah satu dari dua gaya bermain hero sebelum permainan dimulai, memberikan fleksibilitas taktis yang belum pernah ada sebelumnya.\n\nBeberapa hero populer seperti Pudge dan Shadow Fiend mendapatkan nerf pada damage dasar mereka, sementara hero-hero offlane lawas mendapatkan buff pertahanan yang cukup signifikan. Patch ini diprediksi akan mengubah meta permainan secara radikal menjelang kualifikasi The International tahun ini.',
        imageUrl: 'https://images.unsplash.com/photo-1538481199705-c710c4e965fc?q=80&w=800&auto=format&fit=crop',
        gameCategory: 'Dota 2',
        author: 'Budi Santoso',
        viewsCount: 540,
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        isTrending: false,
      ),
      ArticleModel(
        id: 'art_5',
        title: 'EVOS Glory Juarai ESL Snapdragon Pro Series Setelah Tundukkan Falcon AP.Bren!',
        content: 'Kabar membanggakan datang dari scene MLBB internasional, di mana EVOS Glory berhasil keluar sebagai kampiun turnamen ESL Snapdragon Pro Series Challenge Season. Gelar bergengsi ini diraih setelah perjuangan luar biasa mengalahkan juara dunia M5, Falcon AP.Bren, dengan skor telak 4-2 di babak grand final.\n\nStrategi draft pick yang cerdas dari staf kepelatihan EVOS Glory berhasil meredam kekuatan hero-hero andalan AP.Bren. Permainan disiplin sang Roamer EVOS yang menggunakan hero Minotaur menjadi kunci pengamanan objektif lord krusial di game ke-6.\n\nKemenangan ini membuktikan bahwa tim Indonesia masih sangat kompetitif di level tertinggi global dan menjadi modal berharga bagi EVOS Glory sebelum bertanding di ajang MSC mendatang.',
        imageUrl: 'https://images.unsplash.com/photo-1560253023-3ec5d502959f?q=80&w=800&auto=format&fit=crop',
        gameCategory: 'MLBB',
        author: 'Fajar Esport',
        viewsCount: 1780,
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        isTrending: false,
      ),
    ];
  }

  /// Generator Mock Comments berdasarkan ID Artikel
  List<CommentModel> _generateMockComments(String articleId) {
    // Komentar bot dinonaktifkan sesuai permintaan pengguna
    return [];
  }

  /// Mengambil berita real-time tentang game dan update dari API MMOBomb
  Future<List<ArticleModel>> fetchArticlesFromApi() async {
    final List<ArticleModel> parsedArticles = [];
    try {
      final response = await http.get(Uri.parse('https://www.mmobomb.com/api1/latestnews'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        int index = 1;
        int maxItems = _isTranslated ? 10 : 30; // Batasi item jika diterjemahkan agar tidak lambat
        
        for (final item in data) {
          if (index > maxItems) break;

          // Bersihkan tag HTML dari konten agar bersih
          String rawContent = item['article_content'] ?? '';
          String cleanContent = rawContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          if (cleanContent.length > 500) {
            cleanContent = cleanContent.replaceAll(RegExp(r'\s+'), ' ');
          }

          // Map kategori game sederhana dari judul
          String gameCategory = 'PC Game';
          final lowerTitle = (item['title'] ?? '').toLowerCase();
          if (lowerTitle.contains('mobile') || lowerTitle.contains('android')) {
            gameCategory = 'Mobile';
          } else if (lowerTitle.contains('mmo') || lowerTitle.contains('rpg')) {
            gameCategory = 'MMORPG';
          } else if (lowerTitle.contains('shooter') || lowerTitle.contains('fps')) {
            gameCategory = 'Shooter';
          }

          String title = item['title'] ?? 'Berita Game Terbaru';
          String content = cleanContent.isNotEmpty ? cleanContent : (item['short_description'] ?? 'Silakan baca selengkapnya di sumber berita.');

          if (_isTranslated) {
            title = await _translateText(title);
            content = await _translateText(content);
          }

          parsedArticles.add(
            ArticleModel(
              id: item['id']?.toString() ?? 'api_$index',
              title: title,
              content: content,
              imageUrl: item['main_image'] ?? item['thumbnail'] ?? 'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&q=80&w=800',
              gameCategory: gameCategory,
              author: 'MMOBomb',
              viewsCount: 150 + (index * 42) % 300,
              // Buat tanggal publikasi terkesan baru karena API MMOBomb latestnews tidak menyertakan field date
              publishedAt: DateTime.now().subtract(Duration(hours: index * 2)),
              isTrending: index <= 3, // 3 teratas jadikan trending
              sourceName: 'MMOBomb',
              sourceUrl: item['article_url'] ?? 'https://www.mmobomb.com',
            ),
          );
          index++;
        }
      }
    } catch (e) {
      debugPrint('Error parse API feed: $e');
    }
    return parsedArticles;
  }
}

