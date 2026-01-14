import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class ProfileBioSection extends ConsumerWidget {
  final String bio;
  final String? country;
  final String? city;
  final String? address;

  const ProfileBioSection({
    super.key,
    required this.bio,
    this.country,
    this.city,
    this.address,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
              const SizedBox(width: 8),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.6,
            ),
          ),
          if (country != null || city != null || address != null) ...[
            const SizedBox(height: 16),
            Divider(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              height: 1,
            ),
            const SizedBox(height: 16),
            if (country != null && country!.isNotEmpty)
              _buildLocationItem(
                icon: Icons.location_on_outlined,
                text: country!,
                isDark: isDark,
              ),
            if (city != null && city!.isNotEmpty)
              _buildLocationItem(
                icon: Icons.location_city_outlined,
                text: city!,
                isDark: isDark,
              ),
            if (address != null && address!.isNotEmpty)
              _buildLocationItem(
                icon: Icons.home_outlined,
                text: address!,
                isDark: isDark,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
