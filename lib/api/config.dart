class ApiConfig {
  static const String baseUrl = 'http://192.168.137.86:8000/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration timeout = Duration(seconds: 30);
}

class ApiEndpoints {
  static const String uploadAd = '/ads/upload';
  static const String adsFeed = '/ads/feed';
  static String adView(String adId) => '/ads/$adId/view';
  static const String userPoints = '/user/points';
  static const String categories = '/categories';
}
