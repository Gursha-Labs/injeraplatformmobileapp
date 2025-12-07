// services/upload_service.dart
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/ad_model.dart';

class UploadService {
  final Dio _dio;

  UploadService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://192.168.137.1:8000/api',
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Accept': 'application/json'},
        ),
      );

  Future<AdVideo> uploadAd({
    required String title,
    required String description,
    required File videoFile,
    required String categoryId,
    required String authToken,
    List<String>? tagNames,
    required void Function(double progress) onProgress,
  }) async {
    try {
      // Validate file exists
      if (!await videoFile.exists()) {
        throw Exception('Video file does not exist');
      }

      // Check file size (100MB max)
      final fileSize = await videoFile.length();
      if (fileSize > 100 * 1024 * 1024) {
        throw Exception('Video file too large. Maximum size is 100MB');
      }

      // Create form data
      final formData = FormData.fromMap({
        'title': title.trim(),
        'description': description.trim(),
        'category_id': categoryId,
        'file': await MultipartFile.fromFile(
          videoFile.path,
          filename: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
        ),
      });

      // Add tags if available
      if (tagNames != null && tagNames.isNotEmpty) {
        for (int i = 0; i < tagNames.length; i++) {
          formData.fields.add(MapEntry('tag_names[$i]', tagNames[i]));
        }
      }

      print('Uploading ad with title: $title');
      print('Video path: ${videoFile.path}');
      print('Category ID: $categoryId');

      // Make request
      final response = await _dio.post(
        '/ads/upload',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            onProgress(progress);
            print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
          }
        },
      );

      print('Upload response status: ${response.statusCode}');
      print('Upload response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final adData = response.data['ad'] ?? response.data;
        return AdVideo.fromJson(adData);
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.type}');
      print('Error response: ${e.response?.data}');

      String errorMessage = 'Upload failed. Please try again.';

      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          errorMessage =
              errorData['error']?.toString() ??
              errorData['message']?.toString() ??
              'Server error: ${e.response!.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Upload timed out. The file might be too large.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Upload failed: $e');
    }
  }

  Future<void> cancelUpload() async {
    _dio.close(force: true);
  }
}
