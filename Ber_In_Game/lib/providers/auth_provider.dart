import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user_model.dart';

/// Provider untuk mengelola status autentikasi pengguna,
/// mengintegrasikan Firebase Authentication, Google Sign-In, Facebook Login,
/// serta sinkronisasi profil pengguna ke Firestore collection `users`.
/// 
/// Jika Firebase tidak diinisialisasi (misal dalam tahap lokal dev tanpa google-services.json),
/// provider akan secara otomatis beralih menggunakan Mock User demi mencegah crash.
class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _db;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isMockUser = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Memeriksa ketersediaan Firebase
  bool get isFirebaseAvailable => _auth != null && _db != null;

  AuthProvider() {
    _initFirebase();
  }

  void _initFirebase() {
    try {
      _auth = FirebaseAuth.instance;
      _db = FirebaseFirestore.instance;
      
      // Dengarkan perubahan status autentikasi dari Firebase
      _auth!.authStateChanges().listen(_onAuthStateChanged);
    } catch (e) {
      debugPrint('Firebase Auth/Firestore tidak diinisialisasi: $e');
      _auth = null;
      _db = null;
    }
  }

  /// Callback saat status autentikasi Firebase berubah
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      if (!_isMockUser) {
        _currentUser = null;
        notifyListeners();
      }
    } else {
      _isMockUser = false;
      await _syncUserToFirestore(firebaseUser);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Sinkronisasi data pengguna Firebase Auth ke Firestore
  Future<void> _syncUserToFirestore(User firebaseUser) async {
    if (!isFirebaseAvailable) return;
    try {
      final docRef = _db!.collection('users').doc(firebaseUser.uid);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        // Ambil data user yang ada
        _currentUser = UserModel.fromMap(docSnap.data()!, firebaseUser.uid);
      } else {
        // Buat data user baru
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'Gamer',
          photoUrl: firebaseUser.photoURL ?? 'https://api.dicebear.com/7.x/pixel-art/png?seed=${firebaseUser.uid}',
          bookmarkedArticles: [],
          likedArticles: [],
        );
        await docRef.set(_currentUser!.toMap());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error sync user ke Firestore: $e');
      // Fallback tetap mengisi local user state agar aplikasi tidak macet
      _currentUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Gamer',
        photoUrl: firebaseUser.photoURL ?? 'https://api.dicebear.com/7.x/pixel-art/png?seed=${firebaseUser.uid}',
        bookmarkedArticles: [],
        likedArticles: [],
      );
      notifyListeners();
    }
  }

  /// Login menggunakan Email & Password
  Future<bool> loginWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      if (isFirebaseAvailable) {
        await _auth!.signInWithEmailAndPassword(email: email, password: password);
        return true;
      } else {
        // Fallback Mock User
        _isMockUser = true;
        _currentUser = UserModel(
          uid: 'mock_uid_123',
          email: email,
          displayName: email.split('@')[0],
          photoUrl: 'https://api.dicebear.com/7.x/pixel-art/png?seed=mock',
          bookmarkedArticles: [],
          likedArticles: [],
        );
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _translateAuthError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Pendaftaran User Baru dengan Email & Password
  Future<bool> registerWithEmail(String email, String password, String displayName) async {
    _setLoading(true);
    _clearError();
    try {
      if (isFirebaseAvailable) {
        UserCredential credential = await _auth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (credential.user != null) {
          // Update displayName di Firebase Auth
          await credential.user!.updateDisplayName(displayName);
          
          // Buat data baru di Firestore
          _currentUser = UserModel(
            uid: credential.user!.uid,
            email: email,
            displayName: displayName,
            photoUrl: 'https://api.dicebear.com/7.x/pixel-art/png?seed=$displayName',
            bookmarkedArticles: [],
            likedArticles: [],
          );
          
          await _db!.collection('users').doc(credential.user!.uid).set(_currentUser!.toMap());
          notifyListeners();
        }
        return true;
      } else {
        // Fallback Mock User
        _isMockUser = true;
        _currentUser = UserModel(
          uid: 'mock_uid_123',
          email: email,
          displayName: displayName,
          photoUrl: 'https://api.dicebear.com/7.x/pixel-art/png?seed=$displayName',
          bookmarkedArticles: [],
          likedArticles: [],
        );
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _translateAuthError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Gagal mendaftar: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign In menggunakan akun Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      if (isFirebaseAvailable) {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          _setLoading(false);
          return false;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth!.signInWithCredential(credential);
        return true;
      } else {
        // Fallback Mock User
        _isMockUser = true;
        _currentUser = UserModel(
          uid: 'mock_google_uid_123',
          email: 'googleuser@mock.com',
          displayName: 'Google User',
          photoUrl: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Google',
          bookmarkedArticles: [],
          likedArticles: [],
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Google Sign In gagal: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign In menggunakan akun Facebook
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    _clearError();
    try {
      if (isFirebaseAvailable) {
        final LoginResult result = await FacebookAuth.instance.login();
        if (result.status == LoginStatus.success) {
          final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
          await _auth!.signInWithCredential(credential);
          return true;
        } else {
          _errorMessage = 'Login Facebook dibatalkan atau gagal.';
          return false;
        }
      } else {
        // Fallback Mock User
        _isMockUser = true;
        _currentUser = UserModel(
          uid: 'mock_facebook_uid_123',
          email: 'facebookuser@mock.com',
          displayName: 'Facebook User',
          photoUrl: 'https://api.dicebear.com/7.x/pixel-art/png?seed=Facebook',
          bookmarkedArticles: [],
          likedArticles: [],
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Facebook Sign In gagal: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Tambah/Hapus Bookmark Artikel pada profil user
  Future<void> toggleBookmark(String articleId) async {
    if (_currentUser == null) return;
    
    List<String> updatedBookmarks = List.from(_currentUser!.bookmarkedArticles);
    if (updatedBookmarks.contains(articleId)) {
      updatedBookmarks.remove(articleId);
    } else {
      updatedBookmarks.add(articleId);
    }

    _currentUser = _currentUser!.copyWith(bookmarkedArticles: updatedBookmarks);
    notifyListeners();

    if (isFirebaseAvailable && !_isMockUser) {
      try {
        await _db!.collection('users').doc(_currentUser!.uid).update({
          'bookmarkedArticles': updatedBookmarks,
        });
      } catch (e) {
        debugPrint('Gagal update bookmark di Firestore: $e');
      }
    }
  }

  /// Tambah/Hapus Like Artikel pada profil user
  Future<void> toggleLike(String articleId) async {
    if (_currentUser == null) return;
    
    List<String> updatedLikes = List.from(_currentUser!.likedArticles);
    if (updatedLikes.contains(articleId)) {
      updatedLikes.remove(articleId);
    } else {
      updatedLikes.add(articleId);
    }

    _currentUser = _currentUser!.copyWith(likedArticles: updatedLikes);
    notifyListeners();

    if (isFirebaseAvailable && !_isMockUser) {
      try {
        await _db!.collection('users').doc(_currentUser!.uid).update({
          'likedArticles': updatedLikes,
        });
      } catch (e) {
        debugPrint('Gagal update like di Firestore: $e');
      }
    }
  }

  /// Memperbarui foto profil
  Future<void> updateProfilePicture(String photoPath) async {
    if (_currentUser == null) return;
    
    // Update profil secara lokal
    _currentUser = _currentUser!.copyWith(photoUrl: photoPath);
    notifyListeners();

    // Jika menggunakan Firebase, idealnya diunggah ke Firebase Storage terlebih dahulu.
    // Untuk demo ini, kita asumsikan simpan path lokal/URL.
    if (isFirebaseAvailable && !_isMockUser) {
      try {
        await _db!.collection('users').doc(_currentUser!.uid).update({
          'photoUrl': photoPath,
        });
      } catch (e) {
        debugPrint('Gagal update foto profil di Firestore: $e');
      }
    }
  }

  /// Keluar / Logout dari Akun
  Future<void> logout() async {
    _setLoading(true);
    try {
      _isMockUser = false;
      _currentUser = null;
      if (isFirebaseAvailable) {
        await _googleSignIn.signOut();
        await FacebookAuth.instance.logOut();
        await _auth!.signOut();
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Terjemahan error Firebase Auth ke Bahasa Indonesia
  String _translateAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Pengguna tidak ditemukan. Silakan mendaftar terlebih dahulu.';
      case 'wrong-password':
        return 'Kata sandi salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Gunakan email lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
      default:
        return 'Terjadi kesalahan autentikasi. Kode: $code';
    }
  }
}

