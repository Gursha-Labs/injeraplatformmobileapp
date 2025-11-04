// providers/user_data_provider.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:injera/models/monetization_models.dart';

final userDataProvider = StateNotifierProvider<UserDataNotifier, UserDataState>(
  (ref) {
    return UserDataNotifier();
  },
);

class UserDataNotifier extends StateNotifier<UserDataState> {
  UserDataNotifier() : super(UserDataState.initial());

  Future<void> loadUserData(String userId) async {
    state = state.copyWith(status: UserDataStatus.loading);
    try {
      // TODO: Replace with actual API calls
      await Future.delayed(const Duration(seconds: 1));

      final points = UserPoints(
        id: 'points1',
        userId: userId,
        points: 1500,
        updatedAt: DateTime.now(),
      );

      final earnings = [
        UserEarnings(
          id: 'earn1',
          userId: userId,
          amount: 25.50,
          source: EarningsSource.ads,
          createdAt: DateTime.now(),
        ),
      ];

      state = state.copyWith(
        status: UserDataStatus.loaded,
        userPoints: points,
        userEarnings: earnings,
      );
    } catch (e) {
      state = state.copyWith(status: UserDataStatus.error, error: e.toString());
    }
  }
}

class UserDataState {
  final UserDataStatus status;
  final UserPoints? userPoints;
  final List<UserEarnings> userEarnings;
  final String? error;

  const UserDataState({
    required this.status,
    this.userPoints,
    required this.userEarnings,
    this.error,
  });

  factory UserDataState.initial() =>
      const UserDataState(status: UserDataStatus.initial, userEarnings: []);

  UserDataState copyWith({
    UserDataStatus? status,
    UserPoints? userPoints,
    List<UserEarnings>? userEarnings,
    String? error,
  }) {
    return UserDataState(
      status: status ?? this.status,
      userPoints: userPoints ?? this.userPoints,
      userEarnings: userEarnings ?? this.userEarnings,
      error: error ?? this.error,
    );
  }
}

enum UserDataStatus { initial, loading, loaded, error }
