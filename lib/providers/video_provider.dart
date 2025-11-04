// providers/video_provider.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:injera/models/video_models.dart';

final videoProvider = StateNotifierProvider<VideoNotifier, VideoState>((ref) {
  return VideoNotifier();
});

class VideoNotifier extends StateNotifier<VideoState> {
  VideoNotifier() : super(VideoState.initial());

  Future<void> loadVideos() async {
    state = state.copyWith(status: VideoStatus.loading);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      final videos = [
        // Mock data - replace with actual API response
        AdVideo(
          id: '1',
          advertiserId: 'adv1',
          title: 'Sample Ad 1',
          description: 'This is a sample ad video',
          videoUrl: 'https://example.com/video1.mp4',
          categoryId: 'cat1',
          duration: 30,
          viewCount: 1000,
          commentCount: 50,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      state = state.copyWith(status: VideoStatus.loaded, videos: videos);
    } catch (e) {
      state = state.copyWith(status: VideoStatus.error, error: e.toString());
    }
  }

  Future<void> likeVideo(String videoId) async {
    // TODO: Implement like functionality
  }

  Future<void> addToFavorites(String videoId) async {
    // TODO: Implement favorite functionality
  }

  Future<void> recordView(String videoId, int watchedDuration) async {
    // TODO: Implement view recording
  }
}

class VideoState {
  final VideoStatus status;
  final List<AdVideo> videos;
  final List<AdVideo> favoriteVideos;
  final String? error;

  const VideoState({
    required this.status,
    required this.videos,
    required this.favoriteVideos,
    this.error,
  });

  factory VideoState.initial() => const VideoState(
    status: VideoStatus.initial,
    videos: [],
    favoriteVideos: [],
  );

  VideoState copyWith({
    VideoStatus? status,
    List<AdVideo>? videos,
    List<AdVideo>? favoriteVideos,
    String? error,
  }) {
    return VideoState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      favoriteVideos: favoriteVideos ?? this.favoriteVideos,
      error: error ?? this.error,
    );
  }
}

enum VideoStatus { initial, loading, loaded, error }
