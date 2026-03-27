// models/spin_game/game_variables.dart
class GameVariables {
  final double betPoint;
  final double minBet;
  final double maxBet;
  final bool isActive;

  GameVariables({
    required this.betPoint,
    required this.minBet,
    required this.maxBet,
    required this.isActive,
  });

  factory GameVariables.fromJson(Map<String, dynamic> json) {
    // Handle is_active that might come as int (0/1) or bool
    bool isActiveValue;
    if (json['is_active'] is bool) {
      isActiveValue = json['is_active'];
    } else if (json['is_active'] is int) {
      isActiveValue = json['is_active'] == 1;
    } else if (json['is_active'] is String) {
      isActiveValue =
          json['is_active'].toLowerCase() == 'true' || json['is_active'] == '1';
    } else {
      isActiveValue = true;
    }

    return GameVariables(
      betPoint: (json['bet_point'] ?? 1.0).toDouble(),
      minBet: (json['min_bet'] ?? 0.5).toDouble(),
      maxBet: (json['max_bet'] ?? 100.0).toDouble(),
      isActive: isActiveValue,
    );
  }
}
