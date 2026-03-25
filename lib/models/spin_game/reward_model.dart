// models/spin_game/reward_model.dart
class RewardModel {
  final String id;
  final String name;
  final String type; // 'money', 'point', 'lose', 'trial'
  final double value;
  final int probability;
  final String description;
  final String icon;
  final bool isActive;

  RewardModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.probability,
    required this.description,
    required this.icon,
    required this.isActive,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
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
      isActiveValue = true; // default value
    }

    return RewardModel(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      probability: json['probability'] ?? 0,
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isActive: isActiveValue,
    );
  }
}
