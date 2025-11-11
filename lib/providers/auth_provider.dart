import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injera/models/user_models.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  static const String baseUrl = 'http://10.18.95.28:8000/api';
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<AuthResult> login(String login, String password) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'login': login.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      print(
        'Login Response - Status: ${response.statusCode}, Body: ${response.body}',
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['user'] != null && responseBody['token'] != null) {
          final user = User.fromJson(responseBody['user']);
          final token = responseBody['token'];

          await _saveAuthData(user, token);

          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            message: 'Login successful',
            error: null,
          );

          return AuthResult.success(user: user);
        } else {
          return AuthResult.failure(
            error: 'Invalid response format from server',
          );
        }
      } else {
        final errorMessage = _parseErrorResponse(
          responseBody,
          response.statusCode,
        );
        return AuthResult.failure(error: errorMessage);
      }
    } on TimeoutException {
      final error =
          'Connection timeout. Please check your internet connection.';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    } on http.ClientException catch (e) {
      final error = 'Network error: ${e.message}';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    } catch (e) {
      final error = 'An unexpected error occurred. Please try again.';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    }
  }

  // Enhanced signup method
  Future<AuthResult> signup({
    required String email,
    required String username,
    required String password,
    required UserType type,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username.trim(),
              'email': email.trim(),
              'password': password,
              'type': type.toString().split('.').last,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['user'] != null) {
          final user = User.fromJson(responseBody['user']);

          state = state.copyWith(
            status: AuthStatus.verificationRequired,
            user: user,
            message:
                responseBody['message'] ??
                'Registration successful! Please check your email for verification.',
            error: null,
          );

          return AuthResult.success(user: user, requiresVerification: true);
        } else {
          return AuthResult.failure(
            error: 'Registration failed: Invalid response format',
          );
        }
      } else {
        final errorMessage = _parseErrorResponse(
          responseBody,
          response.statusCode,
        );
        return AuthResult.failure(error: errorMessage);
      }
    } on TimeoutException {
      final error =
          'Connection timeout. Please check your internet connection.';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    } catch (e) {
      final error = 'Registration failed: ${e.toString()}';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    }
  }

  // Enhanced OTP verification
  Future<AuthResult> verifyOtp(String otp) async {
    if (state.user?.email == null) {
      return AuthResult.failure(
        error: 'User email not found. Please try signing up again.',
      );
    }

    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/verify-email'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': state.user!.email, 'otp': otp.trim()}),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['user'] != null && responseBody['token'] != null) {
          final user = User.fromJson(responseBody['user']);
          final token = responseBody['token'];

          await _saveAuthData(user, token);

          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            message: 'Email verified successfully!',
            error: null,
          );

          return AuthResult.success(user: user);
        } else {
          return AuthResult.failure(
            error: 'Verification failed: Invalid response format',
          );
        }
      } else {
        final errorMessage = _parseErrorResponse(
          responseBody,
          response.statusCode,
        );
        return AuthResult.failure(error: errorMessage);
      }
    } on TimeoutException {
      final error =
          'Connection timeout. Please check your internet connection.';
      state = state.copyWith(
        status: AuthStatus.verificationRequired,
        error: error,
      );
      return AuthResult.failure(error: error);
    } catch (e) {
      final error = 'Verification failed: ${e.toString()}';
      state = state.copyWith(
        status: AuthStatus.verificationRequired,
        error: error,
      );
      return AuthResult.failure(error: error);
    }
  }

  // Add this method to your AuthNotifier class
  Future<AuthResult> resendOtp(String email) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/resend-otp',
            ), // You'll need to create this endpoint
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email.trim()}),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        state = state.copyWith(
          status: AuthStatus.verificationRequired,
          message: 'OTP sent successfully!',
          error: null,
        );
        return AuthResult.success(message: 'OTP sent successfully');
      } else {
        final errorMessage = _parseErrorResponse(
          responseBody,
          response.statusCode,
        );
        state = state.copyWith(
          status: AuthStatus.verificationRequired,
          error: errorMessage,
        );
        return AuthResult.failure(error: errorMessage);
      }
    } on TimeoutException {
      final error =
          'Connection timeout. Please check your internet connection.';
      state = state.copyWith(
        status: AuthStatus.verificationRequired,
        error: error,
      );
      return AuthResult.failure(error: error);
    } catch (e) {
      final error = 'Failed to resend OTP: ${e.toString()}';
      state = state.copyWith(
        status: AuthStatus.verificationRequired,
        error: error,
      );
      return AuthResult.failure(error: error);
    }
  }

  // Enhanced forgot password
  Future<AuthResult> forgotPassword(String email) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email.trim()}),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          message:
              responseBody['message'] ??
              'Password reset OTP sent to your email.',
          error: null,
        );
        return AuthResult.success(message: 'OTP sent successfully');
      } else {
        final errorMessage = _parseErrorResponse(
          responseBody,
          response.statusCode,
        );
        return AuthResult.failure(error: errorMessage);
      }
    } on TimeoutException {
      final error =
          'Connection timeout. Please check your internet connection.';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    } catch (e) {
      final error = 'Failed to send OTP: ${e.toString()}';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    }
  }

  // Add this method to your AuthNotifier class
  Future<AuthResult> resendVerification(String email) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/resend-verification'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email.trim()}),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        state = state.copyWith(
          status: AuthStatus.verificationRequired,
          message: 'New OTP sent successfully!',
          error: null,
        );
        return AuthResult.success(message: 'New OTP sent successfully');
      } else {
        final errorMessage = _parseErrorResponse(
          responseBody,
          response.statusCode,
        );
        state = state.copyWith(
          status: AuthStatus.verificationRequired,
          error: errorMessage,
        );
        return AuthResult.failure(error: errorMessage);
      }
    } on TimeoutException {
      final error =
          'Connection timeout. Please check your internet connection.';
      state = state.copyWith(
        status: AuthStatus.verificationRequired,
        error: error,
      );
      return AuthResult.failure(error: error);
    } catch (e) {
      final error = 'Failed to resend OTP: ${e.toString()}';
      state = state.copyWith(
        status: AuthStatus.verificationRequired,
        error: error,
      );
      return AuthResult.failure(error: error);
    }
  }

  // Enhanced reset password
  Future<AuthResult> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email.trim(),
              'otp': otp.trim(),
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          message:
              responseBody['message'] ??
              'Password reset successfully. Please login with your new password.',
          error: null,
        );
        return AuthResult.success(message: 'Password reset successfully');
      } else {
        final errorMessage = _parseErrorResponse(
          responseBody,
          response.statusCode,
        );
        return AuthResult.failure(error: errorMessage);
      }
    } on TimeoutException {
      final error =
          'Connection timeout. Please check your internet connection.';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    } catch (e) {
      final error = 'Password reset failed: ${e.toString()}';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userDataKey);

      if (token != null && userData != null) {
        try {
          final user = User.fromJson(json.decode(userData));
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            error: null,
          );
        } catch (e) {
          await _clearAuthData();
          state = AuthState.initial();
        }
      } else {
        state = AuthState.initial();
      }
    } catch (e) {
      await _clearAuthData();
      state = AuthState.initial();
    }
  }

  // Logout
  Future<void> logout() async {
    await _clearAuthData();
    state = AuthState.initial();
  }

  // Reset state
  void resetState() {
    state = AuthState.initial();
  }

  // Private methods
  Future<void> _saveAuthData(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userDataKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_isLoggedInKey);
  }

  String _parseErrorResponse(
    Map<String, dynamic> responseBody,
    int statusCode,
  ) {
    if (responseBody['errors'] != null) {
      final errors = responseBody['errors'];
      if (errors is Map) {
        // Collect all error messages
        final errorMessages = <String>[];
        errors.forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.map((e) => e.toString()));
          } else {
            errorMessages.add(value.toString());
          }
        });

        if (errorMessages.isNotEmpty) {
          return errorMessages.join(', ');
        }
      }
    }

    return responseBody['message']?.toString() ??
        responseBody['error']?.toString() ??
        'Request failed with status code $statusCode';
  }
}

// Enhanced Auth State
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final String? message;

  const AuthState({required this.status, this.user, this.error, this.message});

  factory AuthState.initial() =>
      const AuthState(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    String? message,
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

enum AuthStatus {
  unauthenticated,
  loading,
  authenticated,
  verificationRequired,
}

// Result class for better error handling
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
