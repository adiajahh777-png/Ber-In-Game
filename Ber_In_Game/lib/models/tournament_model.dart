import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk menyimpan jadwal turnamen/pertandingan esport (Match & Tournament).
class TournamentModel {
  final String id;
  final String tournamentName;
  final String game;
  final String teamA;
  final String teamB;
  final String teamALogo;
  final String teamBLogo;
  final DateTime matchTime;
  final String status; // UPCOMING, LIVE, FINISHED
  final String streamUrl;

  TournamentModel({
    required this.id,
    required this.tournamentName,
    required this.game,
    required this.teamA,
    required this.teamB,
    required this.teamALogo,
    required this.teamBLogo,
    required this.matchTime,
    required this.status,
    required this.streamUrl,
  });

  /// Mengonversi Map dari Firestore menjadi object [TournamentModel].
  factory TournamentModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedTime;
    var rawTime = map['matchTime'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      parsedTime = DateTime.parse(rawTime);
    } else if (rawTime is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
    } else {
      parsedTime = DateTime.now();
    }

    return TournamentModel(
      id: id,
      tournamentName: map['tournamentName'] ?? 'Esport Championship',
      game: map['game'] ?? 'General',
      teamA: map['teamA'] ?? 'Team Alpha',
      teamB: map['teamB'] ?? 'Team Beta',
      teamALogo: map['teamALogo'] ?? 'https://api.dicebear.com/7.x/identicon/png?seed=TeamA',
      teamBLogo: map['teamBLogo'] ?? 'https://api.dicebear.com/7.x/identicon/png?seed=TeamB',
      matchTime: parsedTime,
      status: map['status'] ?? 'UPCOMING',
      streamUrl: map['streamUrl'] ?? '',
    );
  }

  /// Mengonversi object [TournamentModel] menjadi Map untuk Firestore.
  Map<String, dynamic> toMap() {
    return {
      'tournamentName': tournamentName,
      'game': game,
      'teamA': teamA,
      'teamB': teamB,
      'teamALogo': teamALogo,
      'teamBLogo': teamBLogo,
      'matchTime': Timestamp.fromDate(matchTime),
      'status': status,
      'streamUrl': streamUrl,
    };
  }
}

