// config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://94f8-197-156-75-53.ngrok-free.app/api';
  //static const String baseUrl'https://hypergolic-erma-violably.ngrok-free.dev/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration timeout = Duration(seconds: 30);

  // Existing endpoints
  static const String userProfile = '/profile/user';
  static const String deleteProfilePicture = '/profile/user/picture';
  static const String updatePoints = '/user/points';

  // New advertiser endpoints
  static const String advertiserProfile = '/advertiser/profile';
  static const String advertiserVideos = '/owen-videos';
  static String advertiserVideoById(String id) => '/advertiser/video/$id';

  static const String spinWheel = '/spin-wheel/spin';
  static const String rewards = '/reward';
  static String rewardById(String id) => '/reward/$id';
  static const String gameVariables = '/variables';

  static const String subscriptions = '/subscriptions';
  static String subscriptionById(String id) => '/subscriptions/$id';

  // User subscription endpoints - NOTE: uses dash, not slash
  static const String userSubscriptions = '/user-subscriptions';
  static String userSubscriptionById(String id) => '/user-subscriptions/$id';
  static const String subscribe = '/user-subscriptions';
  static const String cancelSubscription = '/user-subscriptions/cancel';
  // Add this to your ApiConfig class
  static const String advertiserAnalytics = '/analytics/adertiser-analysis';

  // Helper method for URLs
  static String getStorageUrl(String? path) {
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
