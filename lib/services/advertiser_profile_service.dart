// services/advertiser_profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injera/api/config.dart';

import 'package:injera/models/advertiser_profile.dart';
import 'package:injera/utils/storage_service.dart';

import 'package:injera/utils/debug_util.dart';

class AdvertiserProfileService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ),
  );

  AdvertiserProfileService() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = await StorageService.getInstance();
          final token = storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';

          DebugUtil.logJson('REQUEST_HEADERS', options.headers);
          DebugUtil.logJson('REQUEST_URL', {
            'url': options.uri.toString(),
            'method': options.method,
          });

          handler.next(options);
        },
        onResponse: (response, handler) {
          DebugUtil.logJson('RESPONSE_STATUS', {
            'status': response.statusCode,
            'url': response.realUri.toString(),
          });
          DebugUtil.logJson(
            'RESPONSE_DATA_TYPE',
            response.data.runtimeType.toString(),
          );
          handler.next(response);
        },
        onError: (DioException error, handler) async {
          DebugUtil.logError('DIO_ERROR', error, error.stackTrace);
          if (error.response != null) {
            DebugUtil.logJson('ERROR_RESPONSE_DATA', error.response!.data);
            DebugUtil.logJson(
              'ERROR_RESPONSE_HEADERS',
              error.response!.headers,
            );
          }

          if (error.response?.statusCode == 401) {
            final storage = await StorageService.getInstance();
            await storage.clearAuthData();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<AdvertiserProfile> getProfile() async {
    try {
      DebugUtil.logJson('GET_PROFILE', {'endpoint': '/profile/advertiser'});

      final response = await _dio.get('/profile/advertiser');

      DebugUtil.logJson('GET_PROFILE_RAW_RESPONSE', {
        'status': response.statusCode,
        'data_type': response.data.runtimeType.toString(),
        'data_length': response.data is List
            ? response.data.length
            : 'Not a list',
        'data': response.data,
      });

      if (response.statusCode == 200) {
        // Handle both array and object responses
        dynamic responseData = response.data;

        // If response is a list/array, take the first element
        if (responseData is List) {
          if (responseData.isEmpty) {
            throw Exception('Profile data is empty');
          }
          // Take the first item if it's a list
          responseData = responseData[0];
        }

        // Ensure it's a Map before parsing
        if (responseData is Map<String, dynamic>) {
          return AdvertiserProfile.fromJson(responseData);
        } else {
          throw Exception(
            'Invalid profile data format: ${responseData.runtimeType}',
          );
        }
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      DebugUtil.logError('GET_PROFILE_DIO_ERROR', e, e.stackTrace);

      if (e.response != null) {
        dynamic errorData = e.response!.data;

        // Handle array error responses
        if (errorData is List) {
          final errorMessages = errorData.map((e) => e.toString()).join(', ');
          throw Exception(errorMessages);
        }

        final errorMessage = errorData is Map
            ? errorData['message'] ?? errorData['error'] ?? e.message
            : e.message;
        throw Exception(errorMessage ?? 'Failed to load profile');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      DebugUtil.logError('GET_PROFILE_UNEXPECTED', e, stackTrace);
      throw Exception('Unexpected error: $e');
    }
  }

  // Update in services/advertiser_profile_service.dart
  Future<AdvertiserProfile> updateProfile({
    String? companyName,
    String? businessEmail,
    String? phoneNumber,
    String? website,
    String? description,
    String? country,
    String? city,
    String? address,
    File? logo,
    File? profilePicture,
    File? coverImage,
  }) async {
    try {
      final formData = FormData();

      // Add text fields
      if (companyName != null && companyName.isNotEmpty) {
        formData.fields.add(MapEntry('company_name', companyName));
      }
      if (businessEmail != null && businessEmail.isNotEmpty) {
        formData.fields.add(MapEntry('business_email', businessEmail));
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        formData.fields.add(MapEntry('phone_number', phoneNumber));
      }
      if (website != null && website.isNotEmpty) {
        formData.fields.add(MapEntry('website', website));
      }
      if (description != null && description.isNotEmpty) {
        formData.fields.add(MapEntry('description', description));
      }
      if (country != null && country.isNotEmpty) {
        formData.fields.add(MapEntry('country', country));
      }
      if (city != null && city.isNotEmpty) {
        formData.fields.add(MapEntry('city', city));
      }
      if (address != null && address.isNotEmpty) {
        formData.fields.add(MapEntry('address', address));
      }

      // Add files
      if (logo != null) {
        formData.files.add(
          MapEntry(
            'logo',
            await MultipartFile.fromFile(
              logo.path,
              filename: 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }
      if (profilePicture != null) {
        formData.files.add(
          MapEntry(
            'profile_picture',
            await MultipartFile.fromFile(
              profilePicture.path,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }
      if (coverImage != null) {
        formData.files.add(
          MapEntry(
            'cover_image',
            await MultipartFile.fromFile(
              coverImage.path,
              filename: 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/profile/advertiser',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;

        if (responseData is Map && responseData.containsKey('profile')) {
          return AdvertiserProfile.fromJson(responseData['profile']);
        }

        return AdvertiserProfile.fromJson(responseData);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> deleteProfilePicture() async {
    try {
      DebugUtil.logJson('DELETE_PROFILE_PICTURE', {});

      final response = await _dio.delete('/profile/advertiser/picture');

      DebugUtil.logJson('DELETE_PROFILE_PICTURE_RESPONSE', {
        'status': response.statusCode,
        'data': response.data,
      });

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete profile picture: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      DebugUtil.logError(
        'DELETE_PROFILE_PICTURE_ERROR',
        e,
        e.stackTrace ?? StackTrace.current,
      );

      if (e.response != null) {
        dynamic errorData = e.response!.data;

        if (errorData is List) {
          throw Exception(errorData.join(', '));
        }

        final errorMessage = errorData is Map
            ? errorData['message'] ?? errorData['error'] ?? e.message
            : e.message;
        throw Exception(errorMessage ?? 'Failed to delete profile picture');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      DebugUtil.logError('DELETE_PROFILE_PICTURE_UNEXPECTED', e, stackTrace);
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getPublicProfile(String userId) async {
    try {
      DebugUtil.logJson('GET_PUBLIC_PROFILE', {'userId': userId});

      final response = await _dio.get('/advertiser/public/$userId');

      DebugUtil.logJson('GET_PUBLIC_PROFILE_RESPONSE', {
        'status': response.statusCode,
        'data_type': response.data.runtimeType.toString(),
      });

      if (response.statusCode == 200) {
        dynamic responseData = response.data;

        // Handle array response
        if (responseData is List) {
          if (responseData.isEmpty) {
            return {};
          }
          // Convert first item to Map if it's not already
          if (responseData[0] is Map) {
            return Map<String, dynamic>.from(responseData[0]);
          }
        } else if (responseData is Map) {
          return Map<String, dynamic>.from(responseData);
        }

        return {};
      } else {
        throw Exception(
          'Failed to load public profile: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      DebugUtil.logError('GET_PUBLIC_PROFILE_ERROR', e, e.stackTrace);
      throw Exception(e.message ?? 'Failed to load public profile');
    }
  }

  Future<List<dynamic>> getOwnVideos({int perPage = 10}) async {
    try {
      DebugUtil.logJson('GET_OWN_VIDEOS', {'perPage': perPage});

      final response = await _dio.get(
        '/owen-videos',
        queryParameters: {'per_page': perPage},
      );

      DebugUtil.logJson('GET_OWN_VIDEOS_RESPONSE', {
        'status': response.statusCode,
        'data_type': response.data.runtimeType.toString(),
      });

      if (response.statusCode == 200) {
        dynamic responseData = response.data;

        // Handle different response formats
        if (responseData is List) {
          return responseData;
        } else if (responseData is Map) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return responseData['data'];
          }
          // If it's a map but contains video-like data
          return [responseData];
        }

        return [];
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      DebugUtil.logError('GET_OWN_VIDEOS_ERROR', e, e.stackTrace);
      throw Exception(e.message ?? 'Failed to load videos');
    }
  }

  Future<Map<String, dynamic>> getVideoById(String id) async {
    try {
      DebugUtil.logJson('GET_VIDEO_BY_ID', {'id': id});

      final response = await _dio.get('/advertiser/video/$id');

      DebugUtil.logJson('GET_VIDEO_BY_ID_RESPONSE', {
        'status': response.statusCode,
        'data_type': response.data.runtimeType.toString(),
      });

      if (response.statusCode == 200) {
        dynamic responseData = response.data;

        // Handle array response
        if (responseData is List) {
          if (responseData.isNotEmpty && responseData[0] is Map) {
            return Map<String, dynamic>.from(responseData[0]);
          }
          return {};
        } else if (responseData is Map) {
          return Map<String, dynamic>.from(responseData);
        }

        return {};
      } else {
        throw Exception('Failed to load video: ${response.statusCode}');
      }
    } on DioException catch (e) {
      DebugUtil.logError('GET_VIDEO_BY_ID_ERROR', e, e.stackTrace);
      throw Exception(e.message ?? 'Failed to load video');
    }
  }
}
