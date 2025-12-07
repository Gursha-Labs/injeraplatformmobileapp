// models/user_models.dart
// models/user_models.dart
import 'package:json_annotation/json_annotation.dart';

enum UserType { user, advertiser, admin }

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  final UserType type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      type: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] as String),
        orElse: () => UserType.user,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'type': type.toString().split('.').last,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

class UserPreferences {
  final String id;
  final String userId;
  final List<String> interests;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.interests,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'],
      userId: json['user_id'],
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
}

class UserSettings {
  final String id;
  final String userId;
  final AppTheme theme;
  final Privacy privacy;

  UserSettings({
    required this.id,
    required this.userId,
    required this.theme,
    required this.privacy,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'],
      userId: json['user_id'],
      theme: AppTheme.values.firstWhere((e) => e.name == json['theme']),
      privacy: Privacy.values.firstWhere((e) => e.name == json['privacy']),
    );
  }
}

enum AppTheme { light, dark, darkTheme }

enum Privacy { public, private }
