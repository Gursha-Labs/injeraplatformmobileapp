import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:video_player/video_player.dart';
import 'package:injera/api/ad_service.dart';
import 'package:injera/models/ad_video_model.dart';
import 'package:injera/providers/points_provider.dart';

final adFeedProvider = StateNotifierProvider<AdFeedNotifier, AdFeedState>((
  ref,
) {
  return AdFeedNotifier(ref);
});

class AdFeedNotifier extends StateNotifier<AdFeedState> {
  final Ref _ref;
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _hasInitialized = false;
  final Set<String> _rewardedVideos = {};
  final Map<String, VideoPlayerController> _controllers = {};
  final Set<String> _trackedViews = {};

  AdFeedNotifier(this._ref) : super(AdFeedState.initial()) {
    _loadInitialFeed();
  }

  Future<void> _loadInitialFeed() async {
    if (_hasInitialized) return;
    state = state.copyWith(isLoading: true);
    try {
      final response = await AdService.fetchAdsFeed();
      _nextCursor = response.nextCursor;
      _hasInitialized = true;
      state = state.copyWith(
        ads: response.data,
        hasMore: response.hasMore,
        isLoading: false,
        error: null,
        currentIndex: state.currentIndex ?? 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !state.hasMore || _nextCursor == null) return;
    _isLoadingMore = true;
    try {
      final response = await AdService.fetchAdsFeed(cursor: _nextCursor);
      _nextCursor = response.nextCursor;
      final newAds = [...state.ads, ...response.data];
      state = state.copyWith(ads: newAds, hasMore: response.hasMore);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> trackVideoCompletion(AdVideo ad) async {
    if (_rewardedVideos.contains(ad.id)) return;
    try {
      final response = await AdService.trackVideoView(adId: ad.id);
      if (response.rewarded) {
        _rewardedVideos.add(ad.id);
        _ref.read(pointsProvider.notifier).updatePoints(response.totalPoints);
      }
    } catch (e) {
      // Silent fail for tracking
    }
  }

  void refresh() {
    _hasInitialized = false;
    _nextCursor = null;
    _rewardedVideos.clear();
    _trackedViews.clear();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    state = AdFeedState.initial();
    _loadInitialFeed();
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
    _cleanupDistantControllers();
  }

  VideoPlayerController? getController(String id) {
    if (_controllers.containsKey(id)) {
      return _controllers[id];
    }

    final index = state.ads.indexWhere((a) => a.id == id);
    if (index == -1) return null;
    final ad = state.ads[index];

    final controller = VideoPlayerController.network(ad.videoUrl);
    _controllers[id] = controller;

    controller.initialize().then((_) {
      controller.setLooping(true);
      controller.setVolume(1.0);

      controller.addListener(() {
        if (_trackedViews.contains(id)) return;
        final duration = controller.value.duration.inSeconds;
        if (duration == 0) return;
        final percentage =
            (controller.value.position.inSeconds / duration * 100).round();
        if (percentage >= 95) {
          final currentIdx = state.currentIndex ?? -1;
          final thisIdx = state.ads.indexWhere((a) => a.id == id);
          if (thisIdx == currentIdx) {
            _trackedViews.add(id);
            trackVideoCompletion(ad);
          }
        }
      });
    });

    return controller;
  }

  void preloadAround(int index) {
    final start = (index - 2).clamp(0, state.ads.length);
    final end = (index + 6).clamp(0, state.ads.length);
    for (int i = start; i < end; i++) {
      getController(state.ads[i].id);
    }
  }

  void _cleanupDistantControllers() {
    final toRemove = <String>[];
    for (final id in _controllers.keys) {
      final index = state.ads.indexWhere((a) => a.id == id);
      if (index == -1 || (index - (state.currentIndex ?? 0)).abs() > 5) {
        _controllers[id]?.dispose();
        toRemove.add(id);
      }
    }
    for (final id in toRemove) {
      _controllers.remove(id);
      _trackedViews.remove(id);
    }
  }
}

class AdFeedState {
  final List<AdVideo> ads;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final int? currentIndex;

  const AdFeedState({
    required this.ads,
    required this.hasMore,
    required this.isLoading,
    this.error,
    this.currentIndex,
  });

  factory AdFeedState.initial() => const AdFeedState(
    ads: [],
    hasMore: true,
    isLoading: false,
    error: null,
    currentIndex: null,
  );

  AdFeedState copyWith({
    List<AdVideo>? ads,
    bool? hasMore,
    bool? isLoading,
    String? error,
    int? currentIndex,
  }) {
    return AdFeedState(
      ads: ads ?? this.ads,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
