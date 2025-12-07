// screens/profile/components/action_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

import 'edit_profile_button.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(child: EditProfileButton(isDark: isDark)),
          const SizedBox(width: 8),
          _buildFollowButton(isDark),
          const SizedBox(width: 8),
          _buildMessageButton(isDark),
        ],
      ),
    );
  }

  Widget _buildFollowButton(bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFE2C55),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(Icons.person_add, color: AppColors.pureWhite, size: 20),
    );
  }

  Widget _buildMessageButton(bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.chat_bubble_outline,
        color: isDark ? AppColors.iconDark : AppColors.iconLight,
        size: 20,
      ),
    );
  }
}
