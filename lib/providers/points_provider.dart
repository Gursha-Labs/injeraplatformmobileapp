import 'package:flutter_riverpod/legacy.dart';
import 'package:injera/api/ad_service.dart';

final pointsProvider = StateNotifierProvider<PointsNotifier, PointsState>((
  ref,
) {
  return PointsNotifier();
});

class PointsNotifier extends StateNotifier<PointsState> {
  PointsNotifier() : super(PointsState.initial()) {
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      final response = await AdService.getUserPoints();
      state = PointsState(points: response.points);
    } catch (e) {
      // Keep current points
    }
  }

  void updatePoints(int totalPoints) {
    state = PointsState(points: totalPoints);
  }

  void refreshPoints() {
    _loadPoints();
  }
}

class PointsState {
  final int points;
  const PointsState({required this.points});
  factory PointsState.initial() => const PointsState(points: 0);
}
