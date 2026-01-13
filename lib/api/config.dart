class ApiConfig {
  static const String baseUrl = 'http://192.168.0.109:8000/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration timeout = Duration(seconds: 30);

  static const String userProfile = '/profile/user';
  static const String deleteProfilePicture = '/profile/user/picture';
  static const String updatePoints = '/user/points';

  static String getProfilePictureUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http')) {
      return path;
    }
    return '${baseUrl.replaceFirst('/api', '')}/storage/$path';
  }
}

class ApiEndpoints {
  static const String uploadAd = '/ads/upload';
  static const String adsFeed = '/ads/feed';
  static String adView(String adId) => '/ads/$adId/view';
  static const String userPoints = '/user/points';
  static const String categories = '/categories';
}
