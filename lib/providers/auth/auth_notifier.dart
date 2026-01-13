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
    // 1. Reset state to loading, clearing previous errors immediately
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
      message: null,
    );

    try {
      final response = await _apiClient.post(
        AuthEndpoints.login,
        body: {'login': login.trim(), 'password': password},
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print(
        'Login Response - Status: ${response.statusCode}, Body: ${response.body}',
      );

      try {
        final responseBody = json.decode(response.body);

        if (response.statusCode == 200) {
          // 3. Success Path
          if (responseBody['user'] != null && responseBody['token'] != null) {
            final user = User.fromJson(responseBody['user']);
            final token = responseBody['token'];

            await _saveAuthData(user, token);

            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              message: 'Login successful',
              error: null, // clear any residual errors
              token: token,
            );

            return AuthResult.success(user: user);
          } else {
            final error = 'Invalid response format: Missing user or token.';
            state = state.copyWith(
              status: AuthStatus.unauthenticated,
              error: error,
            );
            return AuthResult.failure(error: error);
          }
        } else {
          // 4. Failure Path (400, 401, 422, etc.)
          // We parse the error string and update state.error so the UI can display the red box.
          final errorMessage = _parseErrorResponse(
            responseBody,
            response.statusCode,
          );
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            error: errorMessage,
          );
          return AuthResult.failure(error: errorMessage);
        }
      } on FormatException catch (e) {
        print('JSON parsing error: $e');
        final error = 'Server returned invalid response format.';
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: error,
        );
        return AuthResult.failure(error: error);
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
      print('Unexpected login error: $e');
      final error = 'An unexpected error occurred. Please try again.';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    }
  }

  String _parseErrorResponse(dynamic responseBody, int statusCode) {
    try {
      // 1. Priority: Laravel "errors" object (Validation errors)
      // Example: {"errors": {"email": ["The email has already been taken."]}}
      if (responseBody is Map && responseBody['errors'] is Map) {
        final errors = responseBody['errors'] as Map<String, dynamic>;

        // Extract first error message found
        for (final key in errors.keys) {
          if (errors[key] is List && (errors[key] as List).isNotEmpty) {
            return (errors[key] as List).first.toString();
          } else if (errors[key] is String) {
            return errors[key] as String;
          }
        }
      }

      // 2. Priority: Direct "message" field
      // Example: {"message": "Invalid credentials"}
      if (responseBody is Map && responseBody['message'] is String) {
        if (responseBody['message'].toString().isNotEmpty) {
          return responseBody['message'];
        }
      }

      // 3. Priority: "error" field
      // Example: {"error": "Unauthorized"}
      if (responseBody is Map && responseBody['error'] is String) {
        if (responseBody['error'].toString().isNotEmpty) {
          return responseBody['error'];
        }
      }

      // 4. Fallback based on status code (User Friendly translations)
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Incorrect email or password.';
        case 403:
          return 'Access denied. Please contact support.';
        case 404:
          return 'Account not found.';
        case 422:
          return 'Validation error. Please check your input.';
        case 429:
          return 'Too many login attempts. Please try again later.';
        case 500:
          return 'Internal server error. Please try again later.';
        case 503:
          return 'Service unavailable. Please try again later.';
        default:
          return 'Login failed. Please try again.';
      }
    } catch (e) {
      print('Error parsing error response: $e');
      return 'Login failed. Please try again.';
    }
  }

  void clearError() {
    state = state.copyWith(
      error: null,
      // Optionally keep other state values
      status: state.status,
      user: state.user,
      message: state.message,
    );
  }

  void clearMessage() {
    state = state.copyWith(
      message: null,
      status: state.status,
      user: state.user,
      error: state.error,
    );
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
      print('Making signup request to: ${AuthEndpoints.register}');

      final response = await _apiClient
          .post(
            AuthEndpoints.register,
            body: {
              'username': username.trim(),
              'email': email.trim(),
              'password': password,
              'type': type.toString().split('.').last,
            },
          )
          .timeout(const Duration(seconds: 30)); // Add timeout here too

      print('Response received - Status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      // Parse response body
      dynamic responseBody;
      try {
        responseBody = json.decode(response.body);
        print('Parsed response body: $responseBody');
      } catch (e) {
        print('Failed to parse JSON: $e');
        print('Raw body: ${response.body}');
        responseBody = response.body;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody is Map && responseBody['user'] != null) {
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
          final error = 'Registration failed: Invalid response format';
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            error: error,
          );
          return AuthResult.failure(error: error);
        }
      } else {
        // Server returned an error (422, 400, etc.)
        print('Server returned error status: ${response.statusCode}');
        final errorMessage = _parseErrorResponse(
          responseBody,
          response.statusCode,
        );

        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: errorMessage,
        );

        return AuthResult.failure(error: errorMessage);
      }
    } on TimeoutException {
      print('Signup timeout');
      final error =
          'Connection timeout. Please check your internet connection.';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    } on http.ClientException catch (e) {
      print('ClientException in signup: $e');
      print('Exception type: ${e.runtimeType}');
      print('Exception message: ${e.message}');

      // Check if this is actually a network error or a server error
      if (e.message.contains('Failed to fetch') ||
          e.message.contains('XMLHttpRequest')) {
        // This is likely a CORS or network connectivity issue
        final error =
            'Cannot connect to server. Please check:\n'
            '1. Your internet connection\n'
            '2. If the server is running\n'
            '3. CORS configuration on the server';
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: error,
        );
        return AuthResult.failure(error: error);
      } else {
        // Some other client exception
        final error = 'Network error: ${e.message}';
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: error,
        );
        return AuthResult.failure(error: error);
      }
    } on FormatException catch (e) {
      print('JSON parsing error: $e');
      final error = 'Server returned invalid response format';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: error);
      return AuthResult.failure(error: error);
    } catch (e) {
      print('Unexpected signup error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: ${e.toString()}');

      final error = 'An unexpected error occurred. Please try again.';
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
}
