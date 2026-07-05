import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tournament_model.dart';

/// Provider untuk mengelola status jadwal pertandingan dan turnamen esport.
/// Menghubungkan langsung dengan Firestore collection `tournaments` jika Firebase tersedia.
/// Menyediakan mock data match esport berkelas jika Firebase tidak diinisialisasi.
class TournamentProvider with ChangeNotifier {
  FirebaseFirestore? _db;

  List<TournamentModel> _matches = [];
  bool _isLoading = false;
  String _selectedStatus = 'ALL'; // ALL, LIVE, UPCOMING, FINISHED

  List<TournamentModel> get matches => _matches;
  bool get isLoading => _isLoading;
  String get selectedStatus => _selectedStatus;

  /// Memeriksa ketersediaan Firebase
  bool get isFirebaseAvailable => _db != null;

  TournamentProvider() {
    _initFirebase();
    loadMatches();
  }

  void _initFirebase() {
    try {
      _db = FirebaseFirestore.instance;
    } catch (_) {
      _db = null;
    }
  }

  /// Memilih filter status pertandingan (ALL, LIVE, UPCOMING, FINISHED)
  void selectStatus(String status) {
    _selectedStatus = status.toUpperCase();
    notifyListeners();
  }

  /// Mengambil daftar match tersaring berdasarkan status terpilih
  List<TournamentModel> get filteredMatches {
    if (_selectedStatus == 'ALL') {
      // Urutkan LIVE pertama, lalu UPCOMING, lalu FINISHED
      final live = _matches.where((m) => m.status.toUpperCase() == 'LIVE').toList();
      final upcoming = _matches.where((m) => m.status.toUpperCase() == 'UPCOMING').toList();
      final finished = _matches.where((m) => m.status.toUpperCase() == 'FINISHED').toList();
      return [...live, ...upcoming, ...finished];
    }
    return _matches.where((match) => match.status.toUpperCase() == _selectedStatus).toList();
  }

  /// Memuat jadwal pertandingan dari Firestore atau Mock Data
  Future<void> loadMatches() async {
    _isLoading = true;
    notifyListeners();

    if (isFirebaseAvailable) {
      try {
        final querySnap = await _db!
            .collection('tournaments')
            .orderBy('matchTime', descending: false)
            .get();

        if (querySnap.docs.isNotEmpty) {
          _matches = querySnap.docs
              .map((doc) => TournamentModel.fromMap(doc.data(), doc.id))
              .toList();
        } else {
          // Seeding mock match data pertama kali ke Firestore
          await _seedMockMatches();
        }
      } catch (e) {
        debugPrint('Error load matches dari Firestore: $e. Memuat Mock Data.');
        _loadMockMatches();
      }
    } else {
      _loadMockMatches();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Mengambil match yang saat ini sedang berlangsung (LIVE)
  List<TournamentModel> get liveMatches {
    return _matches.where((m) => m.status.toUpperCase() == 'LIVE').toList();
  }

  void _loadMockMatches() {
    _matches = _generateMockMatches();
  }

  /// Menanam data awal ke Firestore demi demo yang lengkap
  Future<void> _seedMockMatches() async {
    if (!isFirebaseAvailable) return;
    try {
      final mockData = _generateMockMatches();
      for (var match in mockData) {
        await _db!.collection('tournaments').doc(match.id).set(match.toMap());
      }
      // Reload ulang
      final querySnap = await _db!
          .collection('tournaments')
          .orderBy('matchTime', descending: false)
          .get();
      _matches = querySnap.docs
          .map((doc) => TournamentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error seeding mock tournaments ke Firestore: $e');
    }
  }

  /// Generator Mock Matches/Tournaments yang sangat variatif dan premium
  List<TournamentModel> _generateMockMatches() {
    final now = DateTime.now();
    return [
      TournamentModel(
        id: 'match_1',
        tournamentName: 'MPL Indonesia Season 17',
        game: 'MLBB',
        teamA: 'RRQ Hoshi',
        teamB: 'ONIC Esport',
        teamALogo: 'https://s2.googleusercontent.com/s2/favicons?domain=teamrrq.com&sz=128',
        teamBLogo: 'https://s2.googleusercontent.com/s2/favicons?domain=onicesports.com&sz=128',
        matchTime: now.add(const Duration(minutes: 10)), // Akan tanding segera
        status: 'LIVE',
        streamUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Link streaming youtube demo
      ),
      TournamentModel(
        id: 'match_2',
        tournamentName: 'VCT Pacific League 2026',
        game: 'Valorant',
        teamA: 'Paper Rex',
        teamB: 'DRX',
        teamALogo: 'https://s2.googleusercontent.com/s2/favicons?domain=pprx.team&sz=128',
        teamBLogo: 'https://s2.googleusercontent.com/s2/favicons?domain=drx.gg&sz=128',
        matchTime: now.add(const Duration(hours: 4)),
        status: 'UPCOMING',
        streamUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      ),
      TournamentModel(
        id: 'match_3',
        tournamentName: 'PMGC League Stage 2026',
        game: 'PUBG',
        teamA: 'Bigetron RA',
        teamB: 'Faze Clan',
        teamALogo: 'https://s2.googleusercontent.com/s2/favicons?domain=bigetron.gg&sz=128',
        teamBLogo: 'https://s2.googleusercontent.com/s2/favicons?domain=fazeclan.com&sz=128',
        matchTime: now.add(const Duration(days: 1)),
        status: 'UPCOMING',
        streamUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      ),
      TournamentModel(
        id: 'match_4',
        tournamentName: 'ESL Snapdragon Challenge',
        game: 'MLBB',
        teamA: 'EVOS Glory',
        teamB: 'Falcon AP.Bren',
        teamALogo: 'https://s2.googleusercontent.com/s2/favicons?domain=evos.gg&sz=128',
        teamBLogo: 'https://s2.googleusercontent.com/s2/favicons?domain=brenesports.com&sz=128',
        matchTime: now.subtract(const Duration(hours: 3)),
        status: 'FINISHED',
        streamUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      ),
      TournamentModel(
        id: 'match_5',
        tournamentName: 'The International 2026 Qualifier',
        game: 'Dota 2',
        teamA: 'Tundra Esports',
        teamB: 'Team Liquid',
        teamALogo: 'https://s2.googleusercontent.com/s2/favicons?domain=tundraesports.com&sz=128',
        teamBLogo: 'https://s2.googleusercontent.com/s2/favicons?domain=teamliquid.com&sz=128',
        matchTime: now.subtract(const Duration(days: 1)),
        status: 'FINISHED',
        streamUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      ),
    ];
  }
}

