// upload/components/upload_success.dart
import 'package:flutter/material.dart';
import 'package:injera/models/ad_model.dart';
import 'package:injera/theme/app_colors.dart';

class UploadSuccess extends StatelessWidget {
  final AdVideo ad;
  final bool isDark;
  final VoidCallback onNewAd;
  final VoidCallback onDashboard;

  const UploadSuccess({
    super.key,
    required this.ad,
    required this.isDark,
    required this.onNewAd,
    required this.onDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSuccessIcon(),
            const SizedBox(height: 24),
            _buildSuccessText(),
            const SizedBox(height: 16),
            _buildAdStats(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFE2C55), Color(0xFFFF6B9D)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFE2C55).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.check, size: 36, color: AppColors.pureWhite),
    );
  }

  Widget _buildSuccessText() {
    return Column(
      children: [
        Text(
          'Published!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ad is now live on Injera',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildAdStats() {
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
          _buildStatColumn('ID', ad.id.substring(0, 8)),
          _buildStatusColumn(),
          _buildStatColumn('Created', 'Now'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusColumn() {
    return Column(
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green, width: 0.5),
          ),
          child: Text(
            'Live',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onNewAd,
            icon: const Icon(Icons.add, size: 16, color: AppColors.pureWhite),
            label: const Text(
              'New Ad',
              style: TextStyle(fontSize: 13, color: AppColors.pureWhite),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.pureBlack,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDashboard,
            icon: Icon(
              Icons.dashboard,
              size: 16,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            label: Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
