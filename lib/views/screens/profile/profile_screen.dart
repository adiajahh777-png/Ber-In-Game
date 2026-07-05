import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/news_provider.dart';
import '../../../constants/app_colors.dart';
import '../splash_onboarding_screen.dart';

/// Screen Profil Gamer.
/// Menampilkan informasi detail akun user, statistik aktivitas (bookmark & komentar),
/// riwayat komentar yang ditulis oleh user tersebut di berbagai artikel, dan tombol logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(AuthProvider authProvider) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await authProvider.updateProfilePicture(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  /// Membuat dialog konfirmasi keluar dari akun
  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.primary, width: 1),
          ),
          title: const Text(
            'KELUAR PORTAL',
            style: TextStyle(fontFamily: 'Orbitron', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari Portal Berita Esport ini?',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              child: const Text('BATAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            ElevatedButton(
              child: const Text('KELUAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); // Tutup dialog
                await authProvider.logout();
                if (context.mounted) {
                  // Kembali ke screen splash/onboarding dan hapus stack sebelumnya
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashOnboardingScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final newsProvider = context.watch<NewsProvider>();
    final user = authProvider.currentUser;

    // Hitung jumlah bookmark dan likes
    final totalBookmarks = user?.bookmarkedArticles.length ?? 0;
    final totalLikes = user?.likedArticles.length ?? 0;

    // Comments disabled per user request

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFIL GAMER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
            onPressed: () => _showLogoutDialog(context, authProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('Gagal memuat profil. Silakan masuk kembali.'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Header Banner & Avatar Stack
                    Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // Banner Background
                        Container(
                          height: 140,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 50),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.surfaceSecondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=800&auto=format&fit=crop'),
                              fit: BoxFit.cover,
                              opacity: 0.3,
                            ),
                          ),
                        ),
                        // Avatar dengan Glow & Tombol Edit
                        Positioned(
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => _pickImage(authProvider),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppColors.surfaceSecondary,
                                    backgroundImage: kIsWeb
                                        ? NetworkImage(user.photoUrl) as ImageProvider
                                        : (user.photoUrl.startsWith('http')
                                            ? NetworkImage(user.photoUrl) as ImageProvider
                                            : FileImage(File(user.photoUrl))),
                                  ),
                                ),
                                // Badge Edit
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.surface, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 16),
                    
                    // 2. Info Nama & Email
                    Text(
                      user.displayName.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pengaturan Bahasa (Translate)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                      ),
                      child: SwitchListTile(
                        title: const Text('Terjemahkan Berita ke Indonesia', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: const Text('Otomatis menerjemahkan berita berbahasa Inggris.', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        value: newsProvider.isTranslated,
                        activeThumbColor: AppColors.secondary,
                        onChanged: (val) {
                          newsProvider.toggleTranslation();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Kartu Statistik Aktivitas (Bookmark & Likes)
                    Row(
                      children: [
                        // Stat Bookmark
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.bookmark, color: AppColors.secondary, size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  '$totalBookmarks',
                                  style: const TextStyle(fontFamily: 'Orbitron', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                const Text('BERITA DISIMPAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Stat Likes
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.favorite, color: AppColors.error, size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  '$totalLikes',
                                  style: const TextStyle(fontFamily: 'Orbitron', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                const Text('BERITA DISUKAI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 24),

                    // 4. Informasi & Dukungan (Wajib untuk Google Play News Policy)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                            title: const Text('Kebijakan Privasi', style: TextStyle(fontSize: 12, color: Colors.white)),
                            trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                            onTap: () async {
                              final url = Uri.parse('https://adiajahh777-png.github.io/Website-Saya/privacy.html');
                              if (!await launchUrl(url)) {
                                debugPrint('Could not launch $url');
                              }
                            },
                          ),
                          const Divider(height: 1, color: AppColors.surfaceSecondary),
                          ListTile(
                            leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                            title: const Text('Syarat & Ketentuan', style: TextStyle(fontSize: 12, color: Colors.white)),
                            trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                            onTap: () async {
                              final url = Uri.parse('https://adiajahh777-png.github.io/Website-Saya/terms.html');
                              if (!await launchUrl(url)) {
                                debugPrint('Could not launch $url');
                              }
                            },
                          ),
                          const Divider(height: 1, color: AppColors.surfaceSecondary),
                          ListTile(
                            leading: const Icon(Icons.mail_outline, color: AppColors.primary),
                            title: const Text('Hubungi Kami', style: TextStyle(fontSize: 12, color: Colors.white)),
                            trailing: const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                            onTap: () async {
                              // Menggunakan halaman kontak website agar pasti bisa diakses dari browser/platform manapun
                              final url = Uri.parse('https://adiajahh777-png.github.io/Website-Saya/contact.html');
                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                debugPrint('Could not launch $url');
                              }
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

