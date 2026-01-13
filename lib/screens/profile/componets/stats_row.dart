import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class ProfileStatsRow extends ConsumerWidget {
  final double points;
  final double money;
  final double totalEarned;

  const ProfileStatsRow({
    super.key,
    required this.points,
    required this.money,
    required this.totalEarned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            isDark: isDark,
            icon: Icons.star_border_rounded,
            value: points.toStringAsFixed(0),
            label: 'Points',
          ),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            isDark: isDark,
            icon: Icons.account_balance_wallet_outlined,
            value: '\$${money.toStringAsFixed(2)}',
            label: 'Balance',
          ),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            isDark: isDark,
            icon: Icons.trending_up_outlined,
            value: '\$${totalEarned.toStringAsFixed(2)}',
            label: 'Total Earned',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required bool isDark,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}
