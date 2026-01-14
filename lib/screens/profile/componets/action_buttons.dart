import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class ProfileActionButtons extends ConsumerWidget {
  final VoidCallback onEditPressed;
  final VoidCallback onSharePressed;

  const ProfileActionButtons({
    super.key,
    required this.onEditPressed,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onEditPressed,
              icon: Icon(
                Icons.edit_outlined,
                size: 18,
                color: isDark ? AppColors.pureBlack : AppColors.pureWhite,
              ),
              label: Text(
                'Edit Profile',
                style: TextStyle(
                  color: isDark ? AppColors.pureBlack : AppColors.pureWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.pureWhite
                    : AppColors.pureBlack,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onSharePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              foregroundColor: isDark
                  ? AppColors.pureWhite
                  : AppColors.pureBlack,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              elevation: 0,
            ),
            child: Icon(
              Icons.share_outlined,
              size: 20,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
        ],
      ),
    );
  }
}
