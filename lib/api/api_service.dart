import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injera/api/config.dart';
import 'package:injera/models/advertiser_models.dart';
import 'package:injera/models/user_profile.dart';
import 'package:injera/utils/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio? _dio;
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
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        // Add this to handle different status codes
        validateStatus: (status) {
          return status! < 500; // Accept status codes less than 500
        },
      ),
    );

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get fresh token for each request
          final token = await _getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('Request: ${options.method} ${options.path}');
          debugPrint('Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('Response status: ${response.statusCode}');
          debugPrint('Response data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('API Error: ${error.message}');
          debugPrint('Error status: ${error.response?.statusCode}');
          debugPrint('Error data: ${error.response?.data}');

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
    final token = prefs.getString('auth_token');
    debugPrint('Current token from storage: ${token?.substring(0, 20)}...');
    return token;
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

  Future<AdvertiserProfile> getAdvertiserProfile() async {
    await _ensureInitialized();

    try {
      final response = await _dio!.get('/advertiser/profile');
      debugPrint('Profile Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return AdvertiserProfile.fromJson(response.data);
      } else if (response.statusCode == 404) {
        // Handle 404 by returning default profile
        debugPrint('Profile endpoint returned 404, using default profile');
        return AdvertiserProfile(
          userId: 'unknown',
          username: 'Advertiser',
          email: '',
          totalAdsUploaded: 0,
          totalAdViews: 0,
          totalSpent: '0.00',
          subscriptionActive: false,
          isActive: true,
        );
      } else {
        throw Exception(
          'Failed to load advertiser profile: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Get advertiser profile error: ${e.message}');

      // Handle 404 error
      if (e.response?.statusCode == 404) {
        return AdvertiserProfile(
          userId: 'unknown',
          username: 'Advertiser',
          email: '',
          totalAdsUploaded: 0,
          totalAdViews: 0,
          totalSpent: '0.00',
          subscriptionActive: false,
          isActive: true,
        );
      }

      rethrow;
    }
  }

  Future<List<AdvertiserVideo>> getAdvertiserVideos({
    int page = 1,
    int perPage = 10,
  }) async {
    await _ensureInitialized();

    try {
      final response = await _dio!.get(
        ApiConfig.advertiserVideos,
        queryParameters: {'page': page, 'per_page': perPage},
      );

      debugPrint('Videos Response: ${response.statusCode}');
      debugPrint('Videos Data: ${response.data}');

      if (response.statusCode == 200) {
        // Check different possible response structures
        if (response.data is List) {
          // If response is directly a list
          return (response.data as List)
              .map((json) => AdvertiserVideo.fromJson(json))
              .toList();
        } else if (response.data['data'] != null) {
          // If response has 'data' key (pagination)
          final data = response.data['data'] as List?;
          if (data != null) {
            return data.map((json) => AdvertiserVideo.fromJson(json)).toList();
          }
        } else if (response.data is Map<String, dynamic>) {
          // Try to parse the map directly
          return [AdvertiserVideo.fromJson(response.data)];
        }
        return [];
      } else if (response.statusCode == 500) {
        debugPrint('Server error 500, returning empty list');
        return [];
      } else {
        debugPrint('Unexpected status code: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      debugPrint('Get advertiser videos error: ${e.message}');
      debugPrint('Error status: ${e.response?.statusCode}');
      debugPrint('Error data: ${e.response?.data}');

      // Return empty list on error
      return [];
    }
  }

  // Get single video by ID
  Future<AdvertiserVideo> getVideoById(String id) async {
    await _ensureInitialized();

    try {
      final response = await _dio!.get(ApiConfig.advertiserVideoById(id));
      debugPrint('Video by ID Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return AdvertiserVideo.fromJson(response.data);
      } else if (response.statusCode == 404) {
        throw Exception('Video not found');
      } else {
        throw Exception('Failed to load video: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Get video by ID error: ${e.message}');
      rethrow;
    }
  }

  // Add a method to test API connectivity and authentication
  Future<void> testApiConnection() async {
    await _ensureInitialized();

    try {
      // Test basic API connectivity
      final response = await _dio!.get('/');
      debugPrint('API Root Status: ${response.statusCode}');

      // Test auth token
      final token = await _getToken();
      debugPrint('Auth Token exists: ${token != null && token.isNotEmpty}');
      if (token != null) {
        debugPrint('Token length: ${token.length}');
        debugPrint(
          'Token first 20 chars: ${token.substring(0, min(20, token.length))}...',
        );
      }
    } catch (e) {
      debugPrint('API Connection test failed: $e');
    }
  }

  // Helper function
  int min(int a, int b) => a < b ? a : b;

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

      return await _createDefaultProfile();
    } on DioException catch (e) {
      debugPrint('Get profile error: ${e.message}');
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
