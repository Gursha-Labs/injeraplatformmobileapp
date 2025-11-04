// providers/auth_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injera/models/user_models.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login':
              email, // Changed from 'email' to 'login' to accept both email and username
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the response contains a user and token (successful login)
        if (data['user'] != null && data['token'] != null) {
          final user = User.fromJson(data['user']);

          // Save login state and token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userData', json.encode(user.toJson()));
          await prefs.setString('token', data['token']); // Save the token

          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            message: data['message'] ?? 'Login successful',
          );
        }
        // If there's no user/token but requires verification
        else if (data['requires_verification'] == true) {
          state = state.copyWith(
            status: AuthStatus.verificationRequired,
            user: User.fromJson(data['user']),
            message: data['message'],
          );
        }
        // If the response structure is unexpected
        else {
          throw Exception('Unexpected response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  void resetState() {
    state = AuthState.initial();
  }

  Future<void> signup(
    String email,
    String username,
    String password,
    UserType type,
  ) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'type': type.toString().split('.').last, // Convert enum to string
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print(data);
        final user = User.fromJson(data['user']);

        state = state.copyWith(
          status: AuthStatus.verificationRequired,
          user: user,
          message: data['message'],
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      print('Verifying OTP: $otp for email: ${state.user?.email}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/verify-email'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': state.user?.email, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final user = User.fromJson(data['user']);

          // Save login state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userData', json.encode(user.toJson()));

          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            error: null,
            message: data['message'] ?? 'Email verified successfully',
          );
        } catch (e) {
          throw Exception('Failed to parse server response');
        }
      } else {
        // Handle different error status codes
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Verification failed with status ${response.statusCode}';
          throw Exception(errorMessage);
        } catch (e) {
          // If JSON parsing fails, use the response body or status code
          if (response.body.isNotEmpty) {
            throw Exception('Verification failed: ${response.body}');
          } else {
            throw Exception(
              'Verification failed with status ${response.statusCode}',
            );
          }
        }
      }
    } on TimeoutException catch (e) {
      state = state.copyWith(
        status: AuthStatus.verificationRequired,
        error: 'Request timeout. Please check your connection and try again.',
      );
    } on http.ClientException catch (e) {
      state = state.copyWith(
        status: AuthStatus.verificationRequired,
        error: 'Network error: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.verificationRequired,
        error: e.toString(),
      );
    }
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userData = prefs.getString('userData');
    final token = prefs.getString('token');

    if (isLoggedIn && userData != null && token != null) {
      try {
        final user = User.fromJson(json.decode(userData));
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } catch (e) {
        await prefs.remove('isLoggedIn');
        await prefs.remove('userData');
        await prefs.remove('token');
        state = AuthState.initial();
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userData');
    state = AuthState.initial();
  }
}

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
