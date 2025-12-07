// screens/profile/components/edit_profile_button.dart
import 'package:flutter/material.dart';
import 'package:injera/theme/app_colors.dart';

class EditProfileButton extends StatelessWidget {
  final bool isDark;

  const EditProfileButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'Edit profile',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
