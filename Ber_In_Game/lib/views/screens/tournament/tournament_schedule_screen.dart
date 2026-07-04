import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/tournament_provider.dart';
import '../../../models/tournament_model.dart';
import '../../../constants/app_colors.dart';
import '../../widgets/custom_shimmer_loader.dart';
import '../../widgets/live_stream_player_widget.dart';

/// Screen Jadwal Pertandingan & Turnamen Esport.
/// Menampilkan daftar pertandingan yang dibagi berdasarkan status: Semua, LIVE, UPCOMING, dan FINISHED.
/// Dilengkapi dengan simulated media player untuk nonton live stream secara langsung di dalam aplikasi.
class TournamentScheduleScreen extends StatefulWidget {
  const TournamentScheduleScreen({super.key});

  @override
  State<TournamentScheduleScreen> createState() => _TournamentScheduleScreenState();
}

class _TournamentScheduleScreenState extends State<TournamentScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final tournamentProvider = context.watch<TournamentProvider>();
    final matchesList = tournamentProvider.filteredMatches;
    final statusList = ['ALL', 'LIVE', 'UPCOMING', 'FINISHED'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('JADWAL TURNAMEN'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Tab Bar Status Pertandingan (Neon Chips)
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: statusList.length,
                itemBuilder: (context, index) {
                  final status = statusList[index];
                  final isSelected = tournamentProvider.selectedStatus == status;
                  
                  // Label status terjemahan Bahasa Indonesia
                  String label = 'Semua';
                  if (status == 'LIVE') label = 'Sedang Tanding';
                  if (status == 'UPCOMING') label = 'Mendatang';
                  if (status == 'FINISHED') label = 'Selesai';

                  return GestureDetector(
                    onTap: () => tournamentProvider.selectStatus(status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryLight : Colors.white.withValues(alpha: 0.04),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Daftar Pertandingan
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => tournamentProvider.loadMatches(),
                color: AppColors.secondary,
                backgroundColor: AppColors.surface,
                child: tournamentProvider.isLoading
                    ? ListView.builder(
                        itemCount: 4,
                        itemBuilder: (context, index) => CustomShimmerLoader.tournamentCardPlaceholder(),
                      )
                    : matchesList.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada pertandingan di kategori ini.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: matchesList.length,
                            itemBuilder: (context, index) {
                              final match = matchesList[index];
                              return _buildMatchCard(context, match);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun Card Jadwal Match
  Widget _buildMatchCard(BuildContext context, TournamentModel match) {
    final dateFormatted = DateFormat('EEEE, dd MMM yyyy', 'id').format(match.matchTime);
    final timeFormatted = DateFormat('HH:mm').format(match.matchTime);

    // Kustomisasi visual berdasarkan status pertandingan
    Color statusColor = AppColors.textMuted;
    String statusLabel = 'UPCOMING';
    bool showLiveIndicator = false;

    if (match.status.toUpperCase() == 'LIVE') {
      statusColor = AppColors.error;
      statusLabel = 'LIVE MATCH';
      showLiveIndicator = true;
    } else if (match.status.toUpperCase() == 'FINISHED') {
      statusColor = AppColors.textSecondary;
      statusLabel = 'SELESAI';
    } else {
      statusColor = AppColors.secondary;
      statusLabel = 'MENDATANG';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: match.status.toUpperCase() == 'LIVE' 
              ? AppColors.error.withValues(alpha: 0.3) 
              : Colors.white.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: match.status.toUpperCase() == 'LIVE'
            ? [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header Match Card (Turnamen + Status)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: match.game.toLowerCase() == 'mlbb' ? AppColors.secondary : AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${match.game.toUpperCase()} - ${match.tournamentName}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                // Status Badge
                Row(
                  children: [
                    if (showLiveIndicator)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3), duration: 600.ms),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceSecondary),

          // Body Match Card (Tim VS Tim + Logo)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Team A
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.scaffoldBackground,
                        backgroundImage: NetworkImage(match.teamALogo),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.teamA,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // VS Area
                Column(
                  children: [
                    const Text(
                      'VS',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeFormatted,
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),

                // Team B
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.scaffoldBackground,
                        backgroundImage: NetworkImage(match.teamBLogo),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.teamB,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Footer Match Card (Jadwal Tanggal & Tombol Aksi)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormatted,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
                _buildActionButton(context, match),
              ],
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms)
    .slideY(begin: 0.05, end: 0);
  }

  /// Membuat tombol aksi dinamis berdasarkan status match
  Widget _buildActionButton(BuildContext context, TournamentModel match) {
    if (match.status.toUpperCase() == 'LIVE') {
      return ElevatedButton.icon(
        icon: const Icon(Icons.play_arrow, size: 14),
        label: const Text('TONTON'),
        onPressed: () => _openLiveStreamSimulatedPlayer(context, match),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    } else if (match.status.toUpperCase() == 'FINISHED') {
      return OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rekap pertandingan belum diunggah oleh admin.'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: AppColors.textSecondary,
        ),
        child: const Text('REKAP MATCH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
      );
    } else {
      return OutlinedButton.icon(
        icon: const Icon(Icons.notifications_active_outlined, size: 10, color: AppColors.secondary),
        label: const Text('INGATKAN SAYA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pengingat diset untuk match: ${match.teamA} VS ${match.teamB}!'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
  }

  /// Menampilkan simulated player modal streaming langsung bernuansa esport di dalam aplikasi
  void _openLiveStreamSimulatedPlayer(BuildContext context, TournamentModel match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Modal
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'LIVE STREAMING: ${match.teamA} VS ${match.teamB}',
                        style: const TextStyle(fontFamily: 'Orbitron', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // 1. YouTube Live Stream Player
              LiveStreamPlayerWidget(streamUrl: match.streamUrl),
              const SizedBox(height: 24), // Memberikan jarak di bawah video
            ],
          ),
        );
      },
    );
  }
}

