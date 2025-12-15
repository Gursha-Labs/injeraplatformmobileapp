import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injera/api/config.dart';
import '../models/ad_model.dart';

class UploadState {
  final bool isLoading;
  final String? error;
  final AdVideo? uploadedAd;
  final double uploadProgress;
  final File? selectedVideo;
  final String? selectedVideoName;

  const UploadState({
    this.isLoading = false,
    this.error,
    this.uploadedAd,
    this.uploadProgress = 0,
    this.selectedVideo,
    this.selectedVideoName,
  });

  UploadState copyWith({
    bool? isLoading,
    String? error,
    AdVideo? uploadedAd,
    double? uploadProgress,
    File? selectedVideo,
    String? selectedVideoName,
  }) {
    return UploadState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      uploadedAd: uploadedAd ?? this.uploadedAd,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      selectedVideo: selectedVideo ?? this.selectedVideo,
      selectedVideoName: selectedVideoName ?? this.selectedVideoName,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  final Dio _dio;
  final ImagePicker _picker;

  UploadNotifier()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {'Accept': 'application/json'},
        ),
      ),
      _picker = ImagePicker(),
      super(const UploadState());

  Future<void> pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        final fileSize = await file.length();
        if (fileSize > 100 * 1024 * 1024) {
          throw Exception('Video file too large. Max 100MB.');
        }

        state = state.copyWith(
          selectedVideo: file,
          selectedVideoName: _getFileName(pickedFile.name),
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick video: ${e.toString()}');
    }
  }

  String _getFileName(String path) {
    final name = path.split('/').last;
    return name.length > 30 ? '${name.substring(0, 27)}...' : name;
  }

  Future<void> uploadAd({
    required String title,
    required String description,
    required String categoryId,
    required String authToken,
    List<String>? tags,
  }) async {
    if (state.selectedVideo == null) {
      state = state.copyWith(error: 'Please select a video first');
      return;
    }

    if (title.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a title');
      return;
    }

    if (categoryId.isEmpty) {
      state = state.copyWith(error: 'Please select a category');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, uploadProgress: 0);

    try {
      // Prepare multipart file
      final multipartFile = await MultipartFile.fromFile(
        state.selectedVideo!.path,
        filename: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      // Prepare form data
      final formData = FormData.fromMap({
        'title': title.trim(),
        'description': description.trim(),
        'category_id': categoryId,
        'file': multipartFile,
      });

      if (tags != null && tags.isNotEmpty) {
        for (int i = 0; i < tags.length; i++) {
          formData.fields.add(MapEntry('tag_names[$i]', tags[i]));
        }
      }

      final response = await _dio.post(
        ApiEndpoints.uploadAd,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
        onSendProgress: (sent, total) {
          if (total > 0) {
            state = state.copyWith(uploadProgress: sent / total);
          }
        },
      );

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        final adData = response.data['ad'];

        // Create a properly formatted JSON for your AdVideo model
        final formattedJson = {
          'id': adData['id'],
          'title': adData['title'],
          'video_url': adData['video_url'],
          'advertiser_id': adData['advertiser_id'],
          'category_id': adData['category_id'],
          'view_count': 0, // API doesn't return this, so use default
          'comment_count': 0, // API doesn't return this, so use default
          'duration': adData['duration'],
          'created_at': adData['created_at'],
          'advertiser': {
            'id': adData['advertiser_id'],
            'username': 'You', // Default since API doesn't provide
            'profile_picture': null,
          },
          'category': adData['category'],
          'tags': adData['tags'],
          'comments': [], // API doesn't return comments, so use empty list
        };

        final uploadedAd = AdVideo.fromJson(formattedJson);

        state = state.copyWith(
          isLoading: false,
          uploadedAd: uploadedAd,
          uploadProgress: 1.0,
        );
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Upload failed. Please try again.';

      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'].toString();
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'].toString();
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Network error. Please check your connection.';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        uploadProgress: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: ${e.toString()}',
        uploadProgress: 0,
      );
    }
  }

  void clearVideo() {
    state = state.copyWith(selectedVideo: null, selectedVideoName: null);
  }

  void reset() {
    state = const UploadState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final uploadProvider = StateNotifierProvider<UploadNotifier, UploadState>(
  (ref) => UploadNotifier(),
);
