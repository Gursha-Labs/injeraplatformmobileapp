import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injera/api/config.dart';
import 'package:injera/models/user_profile.dart';
import 'package:injera/utils/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio? _dio; // Changed from 'late Dio _dio' to nullable
  final String _baseUrl = ApiConfig.baseUrl;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) async {
          debugPrint('API Error: ${error.message}');
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final token = await _getToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              return handler.resolve(await _dio!.fetch(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> _refreshToken() async {
    await _ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await _dio!.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        await prefs.setString('auth_token', newToken);
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
    return false;
  }

  Future<UserProfile> getUserProfile() async {
    await _ensureInitialized();

    try {
      final response = await _dio!.get('/profile/user');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['profile'] != null) {
          return UserProfile.fromJson(responseData['profile']);
        }
      }

      // If no profile returned, create a default one
      return await _createDefaultProfile();
    } on DioException catch (e) {
      debugPrint('Get profile error: ${e.message}');

      // For any error, return a default profile
      return await _createDefaultProfile();
    }
  }

  Future<UserProfile> _createDefaultProfile() async {
    final storage = await StorageService.getInstance();
    final userData = storage.getUserData();

    final name = userData?['name']?.toString();
    String? firstName;
    String? lastName;

    if (name != null && name.isNotEmpty) {
      final nameParts = name.split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      lastName = nameParts.length > 1 ? nameParts.last : null;
    } else {
      firstName = 'User';
      lastName = null;
    }

    return UserProfile(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      userId: userData?['id']?.toString() ?? 'unknown',
      firstName: firstName,
      lastName: lastName,
      pointsBalance: 0.0,
      moneyBalance: 0.0,
      totalEarned: 0.0,
      paymentMethods: [],
      favoriteCategories: [],
      notificationsEnabled: true,
      emailNotifications: true,
      totalAdsWatched: 0,
      totalGamesPlayed: 0,
      totalComments: 0,
      totalShares: 0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<UserProfile> updateUserProfile(Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      final response = await _dio!.post('/profile/user', data: data);
      if (response.statusCode == 200) {
        return UserProfile.fromJson(response.data['profile']);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      debugPrint('Update profile error: ${e.message}');
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }
        throw Exception('Validation failed');
      }
      rethrow;
    }
  }

  Future<UserProfile> uploadProfilePicture(File imageFile) async {
    await _ensureInitialized();

    try {
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio!.post(
        '/profile/user',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserProfile.fromJson(response.data['profile']);
      }

      throw Exception('Failed to upload profile picture');
    } on DioException catch (e) {
      debugPrint(
        'Upload profile picture error: ${e.response?.data ?? e.message}',
      );
      rethrow;
    }
  }

  Future<bool> deleteProfilePicture() async {
    await _ensureInitialized();

    try {
      final response = await _dio!.delete('/profile/user/picture');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Delete profile picture error: ${e.message}');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _ensureInitialized();

    try {
      await _dio!.post('/auth/logout');
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
    }
  }
}
