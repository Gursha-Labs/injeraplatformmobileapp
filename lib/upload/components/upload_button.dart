// upload/components/upload_button.dart
import 'package:flutter/material.dart';
import 'package:injera/theme/app_colors.dart';

class UploadButton extends StatelessWidget {
  final bool isDark;
  final bool hasVideo;
  final bool hasTitle;
  final bool hasCategory;
  final VoidCallback onUpload;

  const UploadButton({
    super.key,
    required this.isDark,
    required this.hasVideo,
    required this.hasTitle,
    required this.hasCategory,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onUpload,
              icon: Icon(
                Icons.cloud_upload,
                size: 18,
                color: AppColors.pureWhite,
              ),
              label: Text(
                'PUBLISH AD',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pureWhite,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE2C55),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (hasVideo) _buildCheckIcon(),
          if (hasTitle) const SizedBox(width: 8),
          if (hasTitle) _buildCheckIcon(),
          if (hasCategory) const SizedBox(width: 8),
          if (hasCategory) _buildCheckIcon(),
        ],
      ),
    );
  }

  Widget _buildCheckIcon() {
    return Icon(Icons.check_circle, color: const Color(0xFFFE2C55), size: 20);
  }
}
