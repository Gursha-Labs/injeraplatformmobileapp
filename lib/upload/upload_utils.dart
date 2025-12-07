// upload/upload_utils.dart
import 'package:shared_preferences/shared_preferences.dart';

class UploadUtils {
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static List<String>? parseTags(String tagsText) {
    if (tagsText.trim().isEmpty) return null;

    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  static bool validateForm({
    required String title,
    required String? categoryId,
    required bool hasVideo,
  }) {
    return title.trim().isNotEmpty &&
        categoryId != null &&
        categoryId.isNotEmpty &&
        hasVideo;
  }
}
