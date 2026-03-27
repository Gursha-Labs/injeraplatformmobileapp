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
    // Handle value that might be string or number
    double valueValue = 0;
    if (json['value'] != null) {
      if (json['value'] is String) {
        valueValue = double.tryParse(json['value']) ?? 0;
      } else if (json['value'] is num) {
        valueValue = (json['value'] as num).toDouble();
      }
    }

    // Handle probability that might be string or number
    int probabilityValue = 0;
    if (json['probability'] != null) {
      if (json['probability'] is String) {
        probabilityValue = int.tryParse(json['probability']) ?? 0;
      } else if (json['probability'] is num) {
        probabilityValue = (json['probability'] as num).toInt();
      }
    }

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

    return RewardModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? 'lose',
      value: valueValue,
      probability: probabilityValue,
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isActive: isActiveValue,
    );
  }
}
