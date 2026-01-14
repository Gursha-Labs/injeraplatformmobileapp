import 'dart:io';
import 'package:flutter/material.dart';
import 'package:injera/api/config.dart';

class ImageUtils {
  static ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      // Return a default placeholder
      return const AssetImage('assets/images/default_profile.png');
    }

    // Network image (starts with http or https)
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    }

    // Local file (starts with file:// or /data/ or /storage/)
    if (imagePath.startsWith('file://') ||
        imagePath.startsWith('/data/') ||
        imagePath.startsWith('/storage/')) {
      try {
        // Remove file:// prefix if present
        final filePath = imagePath.startsWith('file://')
            ? imagePath.substring(7)
            : imagePath;
        return FileImage(File(filePath));
      } catch (e) {
        print('Error loading local image: $e');
        return const AssetImage('assets/images/default_profile.png');
      }
    }

    // Relative path from Laravel storage
    if (imagePath.startsWith('profiles/') || imagePath.contains('storage/')) {
      // Construct full URL
      final baseUrl = ApiConfig.baseUrl.replaceFirst('/api', '');
      final imageUrl = '$baseUrl/storage/$imagePath';
      return NetworkImage(imageUrl);
    }

    // Default fallback
    return const AssetImage('assets/images/default_profile.png');
  }

  static String getProfileImageUrl(String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      return '';
    }

    // If it's already a full URL, return as is
    if (profilePicture.startsWith('http')) {
      return profilePicture;
    }

    // If it's a local file path, return as is
    if (profilePicture.startsWith('file://') ||
        profilePicture.startsWith('/data/') ||
        profilePicture.startsWith('/storage/')) {
      return profilePicture;
    }

    // Assume it's a relative path from Laravel storage
    final baseUrl = ApiConfig.baseUrl.replaceFirst('/api', '');
    return '$baseUrl/storage/$profilePicture';
  }

  static String getAvatarUrl(String initials) {
    // Create a colored avatar using UI Avatars service
    final colors = ['FE2C55', '4A90E2', '50C878', 'FF6B35', '8E44AD'];
    final colorIndex =
        initials.codeUnits.fold(0, (sum, code) => sum + code) % colors.length;
    return 'https://ui-avatars.com/api/?name=$initials&background=${colors[colorIndex]}&color=fff&bold=true&size=256';
  }
}
