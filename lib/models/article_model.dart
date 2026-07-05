import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk merepresentasikan Komentar pada Artikel Esport.
/// Disimpan sebagai sub-collection `comments` di bawah dokumen artikel tertentu.
class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final String commentText;
  final DateTime timestamp;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.commentText,
    required this.timestamp,
  });

  /// Mengonversi Map dari Firestore menjadi object [CommentModel].
  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedTime;
    var rawTime = map['timestamp'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      parsedTime = DateTime.parse(rawTime);
    } else if (rawTime is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
    } else {
      parsedTime = DateTime.now();
    }

    return CommentModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonim',
      userPhoto: map['userPhoto'] ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=anon',
      commentText: map['commentText'] ?? '',
      timestamp: parsedTime,
    );
  }

  /// Mengonversi object [CommentModel] menjadi Map untuk Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'commentText': commentText,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

/// Model untuk merepresentasikan artikel/berita esport di Firestore.
class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String gameCategory;
  final String author;
  final int viewsCount;
  final int likesCount;
  final DateTime publishedAt;
  final bool isTrending;
  final String sourceName;
  final String sourceUrl;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.gameCategory,
    required this.author,
    required this.viewsCount,
    this.likesCount = 0,
    required this.publishedAt,
    required this.isTrending,
    this.sourceName = 'Sumber Asli',
    this.sourceUrl = 'https://beritainternasionalgamers.com',
  });

  /// Membuat object [ArticleModel] baru dengan data terubah.
  ArticleModel copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    String? gameCategory,
    String? author,
    int? viewsCount,
    int? likesCount,
    DateTime? publishedAt,
    bool? isTrending,
    String? sourceName,
    String? sourceUrl,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      gameCategory: gameCategory ?? this.gameCategory,
      author: author ?? this.author,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      publishedAt: publishedAt ?? this.publishedAt,
      isTrending: isTrending ?? this.isTrending,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }

  /// Mengonversi Map data dari Firestore menjadi object [ArticleModel].
  factory ArticleModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedTime;
    var rawTime = map['publishedAt'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      parsedTime = DateTime.parse(rawTime);
    } else if (rawTime is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
    } else {
      parsedTime = DateTime.now();
    }

    return ArticleModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      gameCategory: map['gameCategory'] ?? 'Umum',
      author: map['author'] ?? 'Anonim',
      viewsCount: map['viewsCount'] ?? 0,
      likesCount: map['likesCount'] ?? 0,
      publishedAt: parsedTime,
      isTrending: map['isTrending'] ?? false,
      sourceName: map['sourceName'] ?? 'Sumber Asli',
      sourceUrl: map['sourceUrl'] ?? 'https://beritainternasionalgamers.com',
    );
  }

  /// Mengonversi object [ArticleModel] menjadi Map untuk Firestore.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'gameCategory': gameCategory,
      'author': author,
      'viewsCount': viewsCount,
      'likesCount': likesCount,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'isTrending': isTrending,
      'sourceName': sourceName,
      'sourceUrl': sourceUrl,
    };
  }
}
