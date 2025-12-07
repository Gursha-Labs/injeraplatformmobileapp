import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class MainBottomNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const MainBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        currentIndex: currentIndex,
        onTap: onTabTapped,
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Games',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
