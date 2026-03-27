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
    return SpinResponse(
      segmentIndex: json['segment_index'] ?? 0,
      rewardId: json['reward_id'].toString(),
      rewardName: json['reward_name'],
      rewardType: json['reward_type'],
      rewardValue: (json['reward_value'] as num).toDouble(),
      isWinner: json['is_winner'],
      winAmount: (json['win_amount'] as num).toDouble(),
      userPoints: json['user_points'],
      message: json['message'],
    );
  }
}
