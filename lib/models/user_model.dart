/// Model untuk menyimpan data pengguna (User) di Firebase Firestore.
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final List<String> bookmarkedArticles;
  final List<String> likedArticles;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.bookmarkedArticles,
    required this.likedArticles,
  });

  /// Membuat object [UserModel] baru dengan perubahan data tertentu.
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? bookmarkedArticles,
    List<String>? likedArticles,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bookmarkedArticles: bookmarkedArticles ?? this.bookmarkedArticles,
      likedArticles: likedArticles ?? this.likedArticles,
    );
  }

  /// Mengonversi Map data dari Firestore menjadi object [UserModel].
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Gamer',
      photoUrl: map['photoUrl'] ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=$id',
      bookmarkedArticles: List<String>.from(map['bookmarkedArticles'] ?? []),
      likedArticles: List<String>.from(map['likedArticles'] ?? []),
    );
  }

  /// Mengonversi object [UserModel] menjadi Map data untuk disimpan ke Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bookmarkedArticles': bookmarkedArticles,
      'likedArticles': likedArticles,
    };
  }

  /// Factory untuk membuat data Mock pengguna demi kelancaran development tanpa Firebase.
  factory UserModel.mock(String uid, {String? name, String? email}) {
    return UserModel(
      uid: uid,
      email: email ?? 'gamer_$uid@esportportal.com',
      displayName: name ?? 'Pro Gamer $uid',
      photoUrl: 'https://api.dicebear.com/7.x/pixel-art/png?seed=$uid',
      bookmarkedArticles: [],
      likedArticles: [],
    );
  }
}

