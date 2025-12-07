// upload/components/upload_progress.dart
import 'package:flutter/material.dart';
import 'package:injera/providers/upload_provider.dart';
import 'package:injera/theme/app_colors.dart';

class UploadProgress extends StatelessWidget {
  final UploadState state;
  final bool isDark;

  const UploadProgress({super.key, required this.state, required this.isDark});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploading...',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(state.uploadProgress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFFFE2C55),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.uploadProgress,
            backgroundColor: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFE2C55)),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(icon: Icons.schedule, text: 'Estimated: 30s'),
              _buildInfoItem(icon: Icons.data_usage, text: 'Compressing...'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
