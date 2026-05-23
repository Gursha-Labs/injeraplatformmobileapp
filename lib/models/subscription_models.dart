// lib/models/subscription_models.dart
class Subscription {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final String currency;
  final int durationDays;
  final int videoUploadLimit;
  final int? maxVideoDurationSeconds;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.videoUploadLimit,
    this.maxVideoDurationSeconds,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    // Helper function to parse price safely (can be String or double)
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Subscription(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      price: parsePrice(json['price']),
      currency: json['currency']?.toString() ?? 'USD',
      durationDays: json['duration_days'] ?? 0,
      videoUploadLimit: json['video_upload_limit'] ?? 0,
      maxVideoDurationSeconds: json['max_video_duration_seconds'],
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  String get formattedPrice => '$currency ${price.toStringAsFixed(2)}';

  String get durationText {
    if (durationDays >= 365) {
      final years = durationDays ~/ 365;
      return years == 1 ? '$years Year' : '$years Years';
    } else if (durationDays >= 30) {
      final months = durationDays ~/ 30;
      return months == 1 ? '$months Month' : '$months Months';
    } else {
      return durationDays == 1 ? '$durationDays Day' : '$durationDays Days';
    }
  }

  String get videoUploadLimitText {
    if (videoUploadLimit == 0) return 'Unlimited';
    return videoUploadLimit == 1
        ? '$videoUploadLimit Video'
        : '$videoUploadLimit Videos';
  }

  String get videoDurationText {
    if (maxVideoDurationSeconds == null) return 'Unlimited';
    final minutes = maxVideoDurationSeconds! ~/ 60;
    final seconds = maxVideoDurationSeconds! % 60;
    if (minutes == 0) return '${seconds}s';
    if (seconds == 0) return '${minutes}min';
    return '${minutes}min ${seconds}s';
  }
}

class SubscriptionResponse {
  final bool success;
  final List<Subscription> data;
  final String message;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  SubscriptionResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    final List<Subscription> dataList = [];

    try {
      if (json['success'] == true && json['data'] != null) {
        final dataObj = json['data'];

        if (dataObj is Map<String, dynamic> && dataObj['data'] is List) {
          final items = dataObj['data'] as List;
          for (var item in items) {
            try {
              dataList.add(Subscription.fromJson(item));
            } catch (e) {
              print('Error parsing subscription: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error in SubscriptionResponse: $e');
    }

    return SubscriptionResponse(
      success: dataList.isNotEmpty,
      data: dataList,
      message: json['message'] ?? '',
      currentPage: 1,
      lastPage: 1,
      perPage: dataList.length,
      total: dataList.length,
    );
  }
}

class UserSubscription {
  final String id;
  final String userId;
  final String subscriptionId;
  final Subscription subscription;
  final DateTime startsAt;
  final DateTime expiresAt;
  final String status;
  final double amountPaid;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.subscription,
    required this.startsAt,
    required this.expiresAt,
    required this.status,
    required this.amountPaid,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    // Helper function to parse amount safely
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Parse subscription data
    Subscription subscriptionData;
    if (json['subscription'] != null &&
        json['subscription'] is Map<String, dynamic>) {
      subscriptionData = Subscription.fromJson(json['subscription']);
    } else {
      subscriptionData = Subscription(
        id: '0',
        name: 'Free',
        slug: 'free',
        description: 'Free plan',
        price: 0,
        currency: 'USD',
        durationDays: 0,
        videoUploadLimit: 0,
        maxVideoDurationSeconds: null,
        isActive: true,
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return UserSubscription(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      subscriptionId: json['subscription_id']?.toString() ?? '',
      subscription: subscriptionData,
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'])
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : DateTime.now(),
      status: json['status']?.toString() ?? 'inactive',
      amountPaid: parseAmount(json['amount_paid']),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (expiresAt.isBefore(now)) return 0;
    return expiresAt.difference(now).inDays;
  }

  String get daysRemainingText {
    final days = daysRemaining;
    if (days == 0) return 'Expired';
    if (days == 1) return '1 day remaining';
    return '$days days remaining';
  }

  bool get isActivePlan =>
      status.toLowerCase() == 'active' && daysRemaining > 0;
}

class SubscriptionPurchaseResult {
  final bool success;
  final UserSubscription? subscription;
  final String message;

  SubscriptionPurchaseResult({
    required this.success,
    this.subscription,
    required this.message,
  });

  factory SubscriptionPurchaseResult.fromJson(Map<String, dynamic> json) {
    return SubscriptionPurchaseResult(
      success: json['success'] ?? true,
      subscription: null,
      message: json['message'] ?? '',
    );
  }
}
