import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/screens/advertiser/advertiser_dashboard_screen.dart';

import 'package:injera/screens/advertiser/advertiser_profile_screen.dart';
import 'package:injera/screens/advertiser/advertiser_analytics_screen.dart';
import 'package:injera/screens/advertiser/advertiser_upload_screen.dart';
import 'package:injera/theme/app_colors.dart';
import 'package:injera/providers/theme_provider.dart';

class AdvertiserMainScreen extends ConsumerStatefulWidget {
  const AdvertiserMainScreen({super.key});

  @override
  ConsumerState<AdvertiserMainScreen> createState() =>
      _AdvertiserMainScreenState();
}

class _AdvertiserMainScreenState extends ConsumerState<AdvertiserMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _advertiserScreens = [
    const AdvertiserDashboardScreen(),
    const AdvertiserUploadScreen(),
    const AdvertiserAnalyticsScreen(),
    const AdvertiserProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _advertiserScreens[_currentIndex],
      bottomNavigationBar: _buildAdvertiserBottomNavBar(),
    );
  }

  Widget _buildAdvertiserBottomNavBar() {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        selectedItemColor: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
        unselectedItemColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
