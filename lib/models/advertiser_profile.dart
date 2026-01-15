// models/advertiser_profile.dart
import 'package:flutter/foundation.dart';
import 'package:injera/utils/debug_util.dart';

class AdvertiserProfile {
  final String userId; // Changed from int to String for UUID
  final String username;
  final String email;
  final String type;
  final DateTime? emailVerifiedAt;
  final DateTime userCreatedAt;
  final DateTime userUpdatedAt;

  final String? advertiserProfileId; // Changed from int? to String?
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
  final Map<String, dynamic>? socialMediaLinks;
  final int totalAdsUploaded;
  final int totalAdViews;
  final String totalSpent;
  final String? subscriptionPlan;
  final bool subscriptionActive;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool isActive;
  final DateTime? lastActiveAt;
  final DateTime? advertiserCreatedAt;
  final DateTime? advertiserUpdatedAt;

  AdvertiserProfile({
    required this.userId,
    required this.username,
    required this.email,
    required this.type,
    this.emailVerifiedAt,
    required this.userCreatedAt,
    required this.userUpdatedAt,
    this.advertiserProfileId,
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
    this.socialMediaLinks,
    required this.totalAdsUploaded,
    required this.totalAdViews,
    required this.totalSpent,
    this.subscriptionPlan,
    required this.subscriptionActive,
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.isActive,
    this.lastActiveAt,
    this.advertiserCreatedAt,
    this.advertiserUpdatedAt,
  });

  // models/advertiser_profile.dart - Update the fromJson method with better debugging
  factory AdvertiserProfile.fromJson(Map<String, dynamic> json) {
    DebugUtil.logJson('PARSING_PROFILE_JSON', json);

    try {
      // Helper function to safely parse dates
      DateTime? safeParseDate(dynamic dateValue) {
        if (dateValue == null) return null;
        try {
          if (dateValue is String) {
            return DateTime.parse(dateValue);
          }
          return null;
        } catch (e) {
          DebugUtil.logError('DATE_PARSE_ERROR', e, StackTrace.current);
          return null;
        }
      }

      // Helper function to safely get string
      String safeString(dynamic value) {
        if (value == null) return '';
        return value.toString();
      }

      // Helper function to safely get int
      int safeInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        if (value is double) return value.toInt();
        if (value is num) return value.toInt();
        return 0;
      }

      // Helper function to safely get bool
      bool safeBool(dynamic value) {
        if (value == null) return false;
        if (value is bool) return value;
        if (value is int) return value != 0;
        if (value is String) {
          final lower = value.toLowerCase();
          return lower == 'true' || lower == '1' || lower == 'yes';
        }
        return false;
      }

      // Helper function to safely get double/string for money
      String safeMoney(dynamic value) {
        if (value == null) return '0.00';
        if (value is String) return value;
        if (value is int) return value.toStringAsFixed(2);
        if (value is double) return value.toStringAsFixed(2);
        if (value is num) return value.toStringAsFixed(2);
        return '0.00';
      }

      // Parse social media links - handle empty array
      Map<String, dynamic>? safeSocialLinks(dynamic value) {
        if (value == null) return null;
        if (value is Map<String, dynamic>) return value;
        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
        if (value is List) {
          // If it's an empty array, return empty map
          return {};
        }
        return null;
      }

      final userId = safeString(json['user_id']);
      final username = safeString(json['username']);
      final email = safeString(json['email']);
      final type = safeString(json['type']);

      DebugUtil.logJson('PARSED_BASIC_INFO', {
        'userId': userId,
        'username': username,
        'email': email,
        'type': type,
      });

      final profile = AdvertiserProfile(
        userId: userId,
        username: username,
        email: email,
        type: type,
        emailVerifiedAt: safeParseDate(json['email_verified_at']),
        userCreatedAt: safeParseDate(json['user_created_at']) ?? DateTime.now(),
        userUpdatedAt: safeParseDate(json['user_updated_at']) ?? DateTime.now(),
        advertiserProfileId: safeString(json['advertiser_profile_id']),
        companyName: json['company_name'] != null
            ? safeString(json['company_name'])
            : null,
        businessEmail: json['business_email'] != null
            ? safeString(json['business_email'])
            : null,
        phoneNumber: json['phone_number'] != null
            ? safeString(json['phone_number'])
            : null,
        website: json['website'] != null ? safeString(json['website']) : null,
        logo: json['logo'] != null ? safeString(json['logo']) : null,
        profilePicture: json['profile_picture'] != null
            ? safeString(json['profile_picture'])
            : null,
        coverImage: json['cover_image'] != null
            ? safeString(json['cover_image'])
            : null,
        description: json['description'] != null
            ? safeString(json['description'])
            : null,
        country: json['country'] != null ? safeString(json['country']) : null,
        city: json['city'] != null ? safeString(json['city']) : null,
        address: json['address'] != null ? safeString(json['address']) : null,
        socialMediaLinks: safeSocialLinks(json['social_media_links']),
        totalAdsUploaded: safeInt(json['total_ads_uploaded']),
        totalAdViews: safeInt(json['total_ad_views']),
        totalSpent: safeMoney(json['total_spent']),
        subscriptionPlan: json['subscription_plan'] != null
            ? safeString(json['subscription_plan'])
            : null,
        subscriptionActive: safeBool(json['subscription_active']),
        notificationsEnabled: safeBool(json['notifications_enabled']),
        emailNotifications: safeBool(json['email_notifications']),
        isActive: safeBool(json['is_active']),
        lastActiveAt: safeParseDate(json['last_active_at']),
        advertiserCreatedAt: safeParseDate(json['advertiser_created_at']),
        advertiserUpdatedAt: safeParseDate(json['advertiser_updated_at']),
      );

      DebugUtil.logJson('CREATED_PROFILE_OBJECT', {
        'userId': profile.userId,
        'username': profile.username,
        'companyName': profile.companyName,
        'totalAds': profile.totalAdsUploaded,
      });

      return profile;
    } catch (e, stackTrace) {
      DebugUtil.logError('ADVERTISER_PROFILE_PARSE_ERROR', e, stackTrace);
      DebugUtil.logJson('ADVERTISER_PROFILE_RAW_JSON', json);

      // Return a default profile with basic info
      return AdvertiserProfile(
        userId: json['user_id']?.toString() ?? '',
        username: json['username']?.toString() ?? 'User',
        email: json['email']?.toString() ?? '',
        type: json['type']?.toString() ?? 'advertiser',
        userCreatedAt: DateTime.now(),
        userUpdatedAt: DateTime.now(),
        totalAdsUploaded: 0,
        totalAdViews: 0,
        totalSpent: '0.00',
        subscriptionActive: false,
        notificationsEnabled: false,
        emailNotifications: false,
        isActive: false,
      );
    }
  }
  AdvertiserProfile copyWith({
    String? userId,
    String? username,
    String? email,
    String? type,
    DateTime? emailVerifiedAt,
    DateTime? userCreatedAt,
    DateTime? userUpdatedAt,
    String? advertiserProfileId,
    String? companyName,
    String? businessEmail,
    String? phoneNumber,
    String? website,
    String? logo,
    String? profilePicture,
    String? coverImage,
    String? description,
    String? country,
    String? city,
    String? address,
    Map<String, dynamic>? socialMediaLinks,
    int? totalAdsUploaded,
    int? totalAdViews,
    String? totalSpent,
    String? subscriptionPlan,
    bool? subscriptionActive,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? isActive,
    DateTime? lastActiveAt,
    DateTime? advertiserCreatedAt,
    DateTime? advertiserUpdatedAt,
  }) {
    return AdvertiserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      type: type ?? this.type,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      userCreatedAt: userCreatedAt ?? this.userCreatedAt,
      userUpdatedAt: userUpdatedAt ?? this.userUpdatedAt,
      advertiserProfileId: advertiserProfileId ?? this.advertiserProfileId,
      companyName: companyName ?? this.companyName,
      businessEmail: businessEmail ?? this.businessEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      logo: logo ?? this.logo,
      profilePicture: profilePicture ?? this.profilePicture,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      totalAdsUploaded: totalAdsUploaded ?? this.totalAdsUploaded,
      totalAdViews: totalAdViews ?? this.totalAdViews,
      totalSpent: totalSpent ?? this.totalSpent,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      isActive: isActive ?? this.isActive,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      advertiserCreatedAt: advertiserCreatedAt ?? this.advertiserCreatedAt,
      advertiserUpdatedAt: advertiserUpdatedAt ?? this.advertiserUpdatedAt,
    );
  }
}
