// models/spin_game/spin_response.dart
class SpinResponse {
  final int segmentIndex;
  final String rewardId;
  final String rewardName;
  final String rewardType;
  final double rewardValue;
  final bool isWinner;
  final double winAmount;
  final int userPoints;
  final String message;

  SpinResponse({
    required this.segmentIndex,
    required this.rewardId,
    required this.rewardName,
    required this.rewardType,
    required this.rewardValue,
    required this.isWinner,
    required this.winAmount,
    required this.userPoints,
    required this.message,
  });

  factory SpinResponse.fromJson(Map<String, dynamic> json) {
    // Handle all fields with proper null safety
    return SpinResponse(
      segmentIndex: _parseInt(json['segment_index']) ?? 0,
      rewardId: _parseString(json['reward_id']) ?? '',
      rewardName: _parseString(json['reward_name']) ?? '',
      rewardType: _parseString(json['reward_type']) ?? 'lose',
      rewardValue: _parseDouble(json['reward_value']) ?? 0.0,
      isWinner: _parseBool(json['is_winner']) ?? false,
      winAmount: _parseDouble(json['win_amount']) ?? 0.0,
      userPoints: _parseInt(json['user_points']) ?? 0,
      message: _parseString(json['message']) ?? '',
    );
  }

  // Helper methods for safe parsing
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
  }
}
