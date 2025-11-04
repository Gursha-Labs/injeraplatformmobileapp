// models/monetization_models.dart
class UserPoints {
  final String id;
  final String userId;
  final int points;
  final DateTime updatedAt;

  UserPoints({
    required this.id,
    required this.userId,
    required this.points,
    required this.updatedAt,
  });

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      id: json['id'],
      userId: json['user_id'],
      points: json['points'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class UserEarnings {
  final String id;
  final String userId;
  final double amount;
  final EarningsSource source;
  final DateTime createdAt;

  UserEarnings({
    required this.id,
    required this.userId,
    required this.amount,
    required this.source,
    required this.createdAt,
  });

  factory UserEarnings.fromJson(Map<String, dynamic> json) {
    return UserEarnings(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      source: EarningsSource.values.firstWhere((e) => e.name == json['source']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

enum EarningsSource { ads, games, bonus }
