// screens/profile/components/tab_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class TabSelector extends ConsumerStatefulWidget {
  const TabSelector({super.key});

  @override
  ConsumerState<TabSelector> createState() => _TabSelectorState();
}

class _TabSelectorState extends ConsumerState<TabSelector> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(Icons.grid_on, 0, isDark),
          _buildTabItem(Icons.favorite_border, 1, isDark),
          _buildTabItem(Icons.lock_outline, 2, isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight)
                : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            size: 24,
          ),
        ),
      ),
    );
  }
}
