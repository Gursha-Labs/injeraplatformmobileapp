import 'package:injera/models/user_models.dart';

class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? message;
  final bool requiresVerification;

  AuthResult._({
    required this.success,
    this.user,
    this.error,
    this.message,
    this.requiresVerification = false,
  });

  factory AuthResult.success({
    User? user,
    String? message,
    bool requiresVerification = false,
  }) {
    return AuthResult._(
      success: true,
      user: user,
      message: message,
      requiresVerification: requiresVerification,
    );
  }

  factory AuthResult.failure({required String error}) {
    return AuthResult._(success: false, error: error);
  }
}
