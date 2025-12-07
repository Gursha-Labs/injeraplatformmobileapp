import 'package:injera/models/user_models.dart';

enum AuthStatus {
  unauthenticated,
  loading,
  authenticated,
  verificationRequired,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? message;
  final String? token;

  const AuthState({
    required this.status,
    this.user,
    this.error,
    this.message,
    this.token,
  });

  factory AuthState.initial() =>
      const AuthState(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? message,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get requiresVerification => status == AuthStatus.verificationRequired;
}
