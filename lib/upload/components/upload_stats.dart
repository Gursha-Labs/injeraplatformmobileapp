// upload/components/upload_stats.dart
import 'package:flutter/material.dart';
import 'package:injera/theme/app_colors.dart';

class UploadStats extends StatelessWidget {
  final bool isDark;

  const UploadStats({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.visibility,
            value: '10-15k',
            label: 'Estimated Views',
          ),
          _buildStatItem(
            icon: Icons.attach_money,
            value: '\$50-100',
            label: 'Potential Revenue',
          ),
          _buildStatItem(
            icon: Icons.people,
            value: '5-7%',
            label: 'Engagement Rate',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFE2C55)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
