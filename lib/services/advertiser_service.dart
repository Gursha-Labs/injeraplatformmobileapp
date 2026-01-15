// services/advertiser_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injera/api/api_service.dart';
import 'package:injera/api/config.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AdvertiserService {
  static final AdvertiserService _instance = AdvertiserService._internal();
  factory AdvertiserService() => _instance;
  AdvertiserService._internal();

  final ApiService _apiService = ApiService();
  late Dio _dio;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      await _apiService.init();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      // Add interceptor for token refresh
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await _getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
        ),
      );

      _initialized = true;
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get advertiser profile
  Future<Map<String, dynamic>> getAdvertiserProfile() async {
    await init();

    try {
      final response = await _dio.get('/advertiser/profile');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load advertiser profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied: User is not an advertiser');
      }
      throw Exception('Error fetching profile: ${e.message}');
    }
  }

  // Update advertiser profile
  Future<Map<String, dynamic>> updateAdvertiserProfile(
    Map<String, dynamic> data,
  ) async {
    await init();

    try {
      final response = await _dio.put('/advertiser/profile', data: data);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          throw Exception('Validation error: ${jsonEncode(errors)}');
        }
      }
      throw Exception('Error updating profile: ${e.message}');
    }
  }

  // Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(
    String fieldName, // 'logo', 'profile_picture', or 'cover_image'
    String filePath,
  ) async {
    await init();

    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/advertiser/profile/upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to upload image');
      }
    } on DioException catch (e) {
      throw Exception('Error uploading image: ${e.message}');
    }
  }

  // Get owned videos - Updated for your AdVideo model
  Future<Map<String, dynamic>> getOwnedVideos({
    int page = 1,
    int perPage = 10,
  }) async {
    await init();

    try {
      final response = await _dio.get(
        '/owen-videos',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load videos');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied: User is not an advertiser');
      }
      throw Exception('Error fetching videos: ${e.message}');
    }
  }

  // Get video by ID - Updated for your AdVideo model
  Future<Map<String, dynamic>> getVideoById(String videoId) async {
    await init();

    try {
      final response = await _dio.get('/advertiser/video/$videoId');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load video details');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching video: ${e.message}');
    }
  }

  // Delete profile picture
  Future<bool> deleteProfilePicture() async {
    await init();

    try {
      final response = await _dio.delete('/advertiser/profile/picture');

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Error deleting profile picture: ${e.message}');
    }
  }

  // Get public profile
  Future<Map<String, dynamic>> getPublicProfile(String userId) async {
    await init();

    try {
      final response = await _dio.get('/advertiser/public-profile/$userId');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load public profile');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching public profile: ${e.message}');
    }
  }
}
