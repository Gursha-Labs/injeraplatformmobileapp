// models/advertiser_models.dart
class AdvertiserVideo {
  final String id;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int views;
  final int likes;
  final int shares;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdvertiserVideo({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.views,
    required this.likes,
    required this.shares,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdvertiserVideo.fromJson(Map<String, dynamic> json) {
    return AdvertiserVideo(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      videoUrl: json['video_url']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString(),
      views: json['views'] is int ? json['views'] : 0,
      likes: json['likes'] is int ? json['likes'] : 0,
      shares: json['shares'] is int ? json['shares'] : 0,
      commentsCount: json['comments_count'] is int ? json['comments_count'] : 0,
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toString(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toString(),
      ),
    );
  }
}

class AdvertiserProfile {
  final String userId;
  final String username;
  final String email;
  final String? companyName;
  final String? businessEmail;
  final String? phoneNumber;
  final String? website;
  final String? logo;
  final String? profilePicture;
  final String? coverImage;
  final String? description;
  final String? country;
  final String? city;
  final String? address;
  final int totalAdsUploaded;
  final int totalAdViews;
  final String totalSpent;
  final bool subscriptionActive;
  final bool isActive;
  final DateTime? lastActiveAt;

  AdvertiserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.companyName,
    this.businessEmail,
    this.phoneNumber,
    this.website,
    this.logo,
    this.profilePicture,
    this.coverImage,
    this.description,
    this.country,
    this.city,
    this.address,
    required this.totalAdsUploaded,
    required this.totalAdViews,
    required this.totalSpent,
    required this.subscriptionActive,
    required this.isActive,
    this.lastActiveAt,
  });

  factory AdvertiserProfile.fromJson(Map<String, dynamic> json) {
    return AdvertiserProfile(
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      companyName: json['company_name']?.toString(),
      businessEmail: json['business_email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      website: json['website']?.toString(),
      logo: json['logo']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      coverImage: json['cover_image']?.toString(),
      description: json['description']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      totalAdsUploaded: json['total_ads_uploaded'] is int
          ? json['total_ads_uploaded']
          : 0,
      totalAdViews: json['total_ad_views'] is int ? json['total_ad_views'] : 0,
      totalSpent: json['total_spent']?.toString() ?? '0.00',
      subscriptionActive: json['subscription_active'] == true,
      isActive: json['is_active'] == true,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'].toString())
          : null,
    );
  }
}
