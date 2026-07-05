import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../constants/app_colors.dart';

/// Widget Pemutar Live Stream YouTube Premium.
/// Mendukung konversi link dinamis, pemutaran streaming langsung, kontrol media,
/// penanganan lifecycle controller (dispose), dan fallback UI jika link tidak valid.
class LiveStreamPlayerWidget extends StatefulWidget {
  final String streamUrl;

  const LiveStreamPlayerWidget({
    super.key,
    required this.streamUrl,
  });

  @override
  State<LiveStreamPlayerWidget> createState() => _LiveStreamPlayerWidgetState();
}

class _LiveStreamPlayerWidgetState extends State<LiveStreamPlayerWidget> {
  YoutubePlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.streamUrl);
      if (videoId == null || videoId.isEmpty) {
        setState(() {
          _hasError = true;
        });
        return;
      }

      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: true, // WAJIB true di Web agar browser mengizinkan autoplay
          isLive: false, // Jika video bukan benar-benar live 24/7, isLive=true akan membuatnya error/macet
          disableDragSeek: false,
          enableCaption: false,
        ),
      );
    } catch (e) {
      debugPrint('Error menginisialisasi YouTube Player: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _controller == null) {
      return Container(
        height: 220,
        width: double.infinity,
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam_off_outlined, color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 12),
            const Text(
              'LIVE STREAM TIDAK TERSEDIA',
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.streamUrl.isEmpty ? 'Tautan siaran langsung belum disiapkan.' : widget.streamUrl,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.secondary,
        liveUIColor: AppColors.error,
        topActions: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller!.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        onReady: () {
          // Listener untuk memperbarui UI saat data metadata terisi
          if (mounted) setState(() {});
        },
      ),
      builder: (context, player) {
        return Container(
          width: double.infinity,
          height: 220,
          color: Colors.black,
          child: player,
        );
      },
    );
  }
}
