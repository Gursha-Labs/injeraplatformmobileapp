// screens/profile/components/profile_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/api/config.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class ProfileHeader extends ConsumerWidget {
  final String? profilePicture;
  final String fullName;
  final String username;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    // REMOVED: bool isDark,
    super.key,
    this.profilePicture,
    required this.fullName,
    required this.username,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildProfilePicture(context, isDark),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: onEditPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            _buildProfileImage(),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.backgroundDark : Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final imageUrl = _getImageUrl();
    print("Profile Image URL: $imageUrl");

    final initials = fullName.isNotEmpty
        ? fullName.substring(0, 1).toUpperCase()
        : 'U';

    // If no valid URL, show initials
    if (imageUrl == null) {
      print("Showing initials instead of image");
      return CircleAvatar(
        radius: 38,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }

    print("Loading image from URL: $imageUrl");
    return CircleAvatar(
      radius: 38,
      backgroundImage: NetworkImage(imageUrl),
      backgroundColor: Colors.transparent,
      onBackgroundImageError: (exception, stackTrace) {
        print("NetworkImage error: $exception");
      },
    );
  }

  String? _getImageUrl() {
    if (profilePicture == null || profilePicture!.isEmpty) {
      print("No profile picture provided");
      return null;
    }

    print("Raw profile picture from backend: '$profilePicture'");

    // CASE 1: Already a full HTTP URL - return as-is
    if (profilePicture!.startsWith('http://') ||
        profilePicture!.startsWith('https://')) {
      print("Already a full URL");
      return profilePicture;
    }

    // CASE 2: Local file path - skip (return null to show initials)
    if (profilePicture!.startsWith('file://') ||
        profilePicture!.startsWith('/storage/') ||
        profilePicture!.startsWith('/data/')) {
      print("Local file path detected - skipping");
      return null;
    }

    // CASE 3: Relative path (like 'profiles/users/xxx.jpg') - construct full URL
    try {
      // Clean the path - remove leading slash if present
      String cleanPath = profilePicture!;
      if (cleanPath.startsWith('/')) {
        cleanPath = cleanPath.substring(1);
      }

      // Construct base URL
      // Assuming your API config has something like: http://192.168.0.115:8000/api
      final baseUrl = ApiConfig.baseUrl.replaceFirst('/api', '');

      // Construct full image URL
      final fullUrl = '$baseUrl/storage/$cleanPath';

      print("Constructed full URL: $fullUrl");

      // Verify it looks like a valid URL
      if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
        print("Invalid URL constructed: $fullUrl");
        return null;
      }

      return fullUrl;
    } catch (e) {
      print("Error constructing URL: $e");
      return null;
    }
  }
}
