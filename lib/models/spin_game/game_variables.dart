// models/spin_game/game_variables.dart
class GameVariables {
  final double betPoint;
  final bool isActive;

  GameVariables({required this.betPoint, required this.isActive});

  factory GameVariables.fromJson(Map<String, dynamic> json) {
    // The bet amount is stored in the 'value' field, not 'point'
    // 'point' field contains the type name ("earn_point" or "bet_point")
    double betPointValue = 1.0;

    // Parse the 'value' field which contains the actual bet amount
    if (json['value'] != null) {
      if (json['value'] is String) {
        betPointValue = double.tryParse(json['value']) ?? 1.0;
      } else if (json['value'] is num) {
        betPointValue = (json['value'] as num).toDouble();
      }
    }

    // Handle is_active (though your variables table doesn't have this field)
    bool isActiveValue = true;
    if (json['is_active'] != null) {
      if (json['is_active'] is bool) {
        isActiveValue = json['is_active'];
      } else if (json['is_active'] is int) {
        isActiveValue = json['is_active'] == 1;
      } else if (json['is_active'] is String) {
        isActiveValue =
            json['is_active'].toLowerCase() == 'true' ||
            json['is_active'] == '1';
      }
    }

    return GameVariables(betPoint: betPointValue, isActive: isActiveValue);
  }
}
