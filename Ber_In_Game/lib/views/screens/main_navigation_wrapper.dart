import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'home/home_screen.dart';
import 'bookmark/bookmark_screen.dart';
import 'profile/profile_screen.dart';

/// Shell / Wrapper navigasi utama aplikasi yang memegang BottomNavigationBar.
/// Mendukung perpindahan screen antara: Home, Tournament, Bookmark, dan Profile.
/// Desain navigation bar dimodifikasi dengan gaya floating glassmorphic semi-transparan.
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BookmarkScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              activeIcon: Icon(Icons.home_filled, color: AppColors.secondary),
              label: 'BERANDA',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark, color: AppColors.secondary),
              label: 'DISIMPAN',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppColors.secondary),
              label: 'PROFIL',
            ),
          ],
        ),
      ),
    );
  }
}

