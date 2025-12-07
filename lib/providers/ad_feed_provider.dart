// providers/ad_feed_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdVideo {
  final String id;
  final String title;
  final String videoUrl;
  final String advertiserId;
  final String categoryId;
  final int viewCount;
  final int commentCount;
  final int? duration;
  final DateTime createdAt;
  final Map<String, dynamic> advertiser;
  final Map<String, dynamic> category;
  final List<dynamic> tags;
  final List<dynamic> comments;

  AdVideo({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.advertiserId,
    required this.categoryId,
    required this.viewCount,
    required this.commentCount,
    this.duration,
    required this.createdAt,
    required this.advertiser,
    required this.category,
    required this.tags,
    required this.comments,
  });

  factory AdVideo.fromJson(Map<String, dynamic> json) {
    // Handle profile picture with escaped quotes
    String? profilePic;
    if (json['advertiser'].containsKey('"profile_picture"')) {
      profilePic = json['advertiser']['"profile_picture"'];
    }

    final advertiserData = {
      'id': json['advertiser']['id'],
      'username': json['advertiser']['username'],
      'profile_picture': profilePic,
    };

    return AdVideo(
      id: json['id'],
      title: json['title'],
      videoUrl: json['video_url'],
      advertiserId: json['advertiser_id'],
      categoryId: json['category_id'],
      viewCount: json['view_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      duration: json['duration'],
      createdAt: DateTime.parse(json['created_at']),
      advertiser: advertiserData,
      category: json['category'],
      tags: json['tags'] ?? [],
      comments: json['comments'] ?? [],
    );
  }
}

class AdFeedState {
  final List<AdVideo> ads;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final String? errorMessage;
  final bool hasMore;
  final String? nextCursor;
  final Map<String, VideoPlayerController?> videoControllers;
  final Map<String, bool> videoInitialized;

  const AdFeedState({
    this.ads = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.hasMore = true,
    this.nextCursor,
    this.videoControllers = const {},
    this.videoInitialized = const {},
  });

  AdFeedState copyWith({
    List<AdVideo>? ads,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    String? errorMessage,
    bool? hasMore,
    String? nextCursor,
    Map<String, VideoPlayerController?>? videoControllers,
    Map<String, bool>? videoInitialized,
  }) {
    return AdFeedState(
      ads: ads ?? this.ads,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      videoControllers: videoControllers ?? this.videoControllers,
      videoInitialized: videoInitialized ?? this.videoInitialized,
    );
  }
}

class AdFeedNotifier extends StateNotifier<AdFeedState> {
  static const String _baseUrl = 'http://192.168.137.1:8000/api';
  Timer? _preloadTimer;
  int _currentIndex = 0;
  final Set<String> _pendingViewTrackings = {};

  AdFeedNotifier() : super(const AdFeedState());

  Future<Map<String, dynamic>> _fetchAdsFeed({String? cursor}) async {
    try {
      final queryParams = cursor != null ? '?cursor=$cursor' : '';
      final url = Uri.parse('$_baseUrl/ads/feed$queryParams');

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load ads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> loadInitialAds() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      final response = await _fetchAdsFeed();

      final ads = (response['data'] as List)
          .map((json) => AdVideo.fromJson(json))
          .toList();

      // Initialize video controllers for first 3 videos
      final initialAds = ads.take(3).toList();
      for (final ad in initialAds) {
        unawaited(_initializeVideoController(ad));
      }

      state = state.copyWith(
        ads: ads,
        hasMore: response['has_more'] ?? false,
        nextCursor: response['next_cursor'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadMoreAds() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.nextCursor == null ||
        state.ads.isEmpty)
      return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _fetchAdsFeed(cursor: state.nextCursor);

      if (response['data'].isEmpty) {
        state = state.copyWith(hasMore: false, isLoadingMore: false);
        return;
      }

      final newAds = (response['data'] as List)
          .map((json) => AdVideo.fromJson(json))
          .toList();

      // Filter out duplicates
      final existingIds = state.ads.map((a) => a.id).toSet();
      final filteredNewAds = newAds
          .where((ad) => !existingIds.contains(ad.id))
          .toList();

      // Pre-initialize next 2 videos
      final adsToInitialize = filteredNewAds.take(2).toList();
      for (final ad in adsToInitialize) {
        unawaited(_initializeVideoController(ad));
      }

      state = state.copyWith(
        ads: [...state.ads, ...filteredNewAds],
        hasMore: response['has_more'] ?? false,
        nextCursor: response['next_cursor'],
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _initializeVideoController(AdVideo ad) async {
    if (state.videoControllers.containsKey(ad.id) ||
        state.videoInitialized[ad.id] == true) {
      return;
    }

    try {
      final controller = VideoPlayerController.network(
        ad.videoUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await controller.initialize();

      state = state.copyWith(
        videoControllers: {...state.videoControllers, ad.id: controller},
        videoInitialized: {...state.videoInitialized, ad.id: true},
      );
    } catch (e) {
      print('Failed to initialize video: ${ad.videoUrl} - $e');
      state = state.copyWith(
        videoInitialized: {...state.videoInitialized, ad.id: false},
      );
    }
  }

  void preloadVideosSmartly(int currentIndex) {
    _currentIndex = currentIndex;

    _preloadTimer?.cancel();

    _preloadTimer = Timer(const Duration(milliseconds: 300), () {
      final startIndex = currentIndex + 1;
      final endIndex = currentIndex + 3;

      for (int i = startIndex; i <= endIndex; i++) {
        if (i < state.ads.length) {
          final ad = state.ads[i];
          if (state.videoInitialized[ad.id] != true) {
            unawaited(_initializeVideoController(ad));
          }
        }
      }
    });
  }

  void playVideo(String videoId) {
    // Pause all other videos
    for (final entry in state.videoControllers.entries) {
      if (entry.key != videoId && entry.value?.value.isPlaying == true) {
        entry.value?.pause();
      }
    }

    // Play current video
    final controller = state.videoControllers[videoId];
    if (controller != null && !controller.value.isPlaying) {
      controller.play();
    }
  }

  void pauseVideo(String videoId) {
    final controller = state.videoControllers[videoId];
    controller?.pause();
  }

  void cleanupControllers(int currentIndex) {
    final controllersToRemove = <String>[];

    for (final entry in state.videoControllers.entries) {
      final index = state.ads.indexWhere((ad) => ad.id == entry.key);
      if (index != -1 && (currentIndex - index).abs() > 3) {
        entry.value?.dispose();
        controllersToRemove.add(entry.key);
      }
    }

    if (controllersToRemove.isNotEmpty) {
      final newControllers = Map<String, VideoPlayerController?>.from(
        state.videoControllers,
      );
      final newInitialized = Map<String, bool>.from(state.videoInitialized);

      for (final id in controllersToRemove) {
        newControllers.remove(id);
        newInitialized.remove(id);
      }

      state = state.copyWith(
        videoControllers: newControllers,
        videoInitialized: newInitialized,
      );
    }
  }

  void refreshFeed() {
    // Dispose all controllers
    for (final controller in state.videoControllers.values) {
      controller?.dispose();
    }

    state = const AdFeedState();
    loadInitialAds();
  }

  @override
  void dispose() {
    _preloadTimer?.cancel();
    for (final controller in state.videoControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }
}

final adFeedProvider = StateNotifierProvider<AdFeedNotifier, AdFeedState>(
  (ref) => AdFeedNotifier(),
);
