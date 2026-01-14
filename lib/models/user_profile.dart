import 'dart:convert';

class UserProfile {
  final String id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? profilePicture;
  final String? bio;
  final String? country;
  final String? city;
  final String? address;
  final double pointsBalance;
  final double moneyBalance;
  final double totalEarned;
  final List<String>? paymentMethods;
  final List<String>? favoriteCategories;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final int totalAdsWatched;
  final int totalGamesPlayed;
  final int totalComments;
  final int totalShares;
  final bool isActive;
  final DateTime? lastActiveAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.profilePicture,
    this.bio,
    this.country,
    this.city,
    this.address,
    required this.pointsBalance,
    required this.moneyBalance,
    required this.totalEarned,
    this.paymentMethods,
    this.favoriteCategories,
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.totalAdsWatched,
    required this.totalGamesPlayed,
    required this.totalComments,
    required this.totalShares,
    required this.isActive,
    this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Helper function to parse numbers safely
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.tryParse(value) ?? 0.0;
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.tryParse(value) ?? 0;
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    bool parseBool(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return true;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return null;
      }
    }

    return UserProfile(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      dateOfBirth: parseDate(json['date_of_birth']),
      gender: json['gender']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      bio: json['bio']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      pointsBalance: parseDouble(json['points_balance']),
      moneyBalance: parseDouble(json['money_balance']),
      totalEarned: parseDouble(json['total_earned']),
      paymentMethods: json['payment_methods'] != null
          ? List<String>.from(json['payment_methods'] ?? [])
          : [],
      favoriteCategories: json['favorite_categories'] != null
          ? List<String>.from(json['favorite_categories'] ?? [])
          : [],
      notificationsEnabled: parseBool(json['notifications_enabled']),
      emailNotifications: parseBool(json['email_notifications']),
      totalAdsWatched: parseInt(json['total_ads_watched']),
      totalGamesPlayed: parseInt(json['total_games_played']),
      totalComments: parseInt(json['total_comments']),
      totalShares: parseInt(json['total_shares']),
      isActive: parseBool(json['is_active']),
      lastActiveAt: parseDate(json['last_active_at']),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bio': bio,
      'country': country,
      'city': city,
      'address': address,
    };
  }

  String get fullName {
    final parts = [firstName, lastName].where((n) => n != null && n.isNotEmpty);
    return parts.join(' ');
  }

  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    return firstName ?? 'User';
  }

  String get initials {
    final first = firstName?.isNotEmpty == true
        ? firstName![0].toUpperCase()
        : '';
    final last = lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    return (first + last).isEmpty ? 'U' : first + last;
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? profilePicture,
    String? bio,
    String? country,
    String? city,
    String? address,
    double? pointsBalance,
    double? moneyBalance,
    double? totalEarned,
    List<String>? paymentMethods,
    List<String>? favoriteCategories,
    bool? notificationsEnabled,
    bool? emailNotifications,
    int? totalAdsWatched,
    int? totalGamesPlayed,
    int? totalComments,
    int? totalShares,
    bool? isActive,
    DateTime? lastActiveAt,
  }) {
    return UserProfile(
      id: id,
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      moneyBalance: moneyBalance ?? this.moneyBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      totalAdsWatched: totalAdsWatched ?? this.totalAdsWatched,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalComments: totalComments ?? this.totalComments,
      totalShares: totalShares ?? this.totalShares,
      isActive: isActive ?? this.isActive,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
