import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:injera/api/api_client.dart';
import 'package:injera/api/endpoints.dart';
import 'package:injera/models/user_models.dart';
import 'package:injera/utils/storage_service.dart';
import 'auth_state.dart';
import 'auth_result.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _initialize();
  }

  late final ApiClient _apiClient;
  late final StorageService _storageService;

  Future<void> _initialize() async {
    _apiClient = ApiClient();
    _storageService = await StorageService.create();
  }

  Future<AuthResult> login(String login, String password) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await _apiClient.post(
        AuthEndpoints.login,
        body: {'login': login.trim(), 'password': password},
      );

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
            token: token,
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
      final response = await _apiClient.post(
        AuthEndpoints.register,
        body: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
          'type': type.toString().split('.').last,
        },
      );

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

  Future<AuthResult> verifyOtp(String otp) async {
    if (state.user?.email == null) {
      return AuthResult.failure(
        error: 'User email not found. Please try signing up again.',
      );
    }

    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final response = await _apiClient.post(
        AuthEndpoints.verifyEmail,
        body: {'email': state.user!.email, 'otp': otp.trim()},
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

  Future<AuthResult> resendOtp(String email) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await _apiClient.post(
        AuthEndpoints.resendOtp,
        body: {'email': email.trim()},
      );

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

  Future<AuthResult> forgotPassword(String email) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await _apiClient.post(
        AuthEndpoints.forgotPassword,
        body: {'email': email.trim()},
      );

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

  Future<AuthResult> resendVerification(String email) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await _apiClient.post(
        AuthEndpoints.resendVerification,
        body: {'email': email.trim()},
      );

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
      final response = await _apiClient.post(
        AuthEndpoints.resetPassword,
        body: {
          'email': email.trim(),
          'otp': otp.trim(),
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

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
      final token = _storageService.getToken();
      final userData = _storageService.getUserData();

      if (token != null && userData != null) {
        try {
          final user = User.fromJson(userData);
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

  Future<void> logout() async {
    await _clearAuthData();
    state = AuthState.initial();
  }

  void resetState() {
    state = AuthState.initial();
  }

  // Private helper methods
  Future<void> _saveAuthData(User user, String token) async {
    await _storageService.saveToken(token);
    await _storageService.saveUserData(user.toJson());
    await _storageService.setLoggedIn(true);
  }

  Future<void> _clearAuthData() async {
    await _storageService.clearAuthData();
  }

  String _parseErrorResponse(
    Map<String, dynamic> responseBody,
    int statusCode,
  ) {
    if (responseBody['errors'] != null) {
      final errors = responseBody['errors'];
      if (errors is Map) {
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
