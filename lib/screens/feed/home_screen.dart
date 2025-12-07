// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/ad_feed_provider.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/widgets/video_controls_component.dart';
import 'package:injera/widgets/video_player_component.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adFeedProvider.notifier).loadInitialAds();
    });
  }

  void _onPageChanged(int index) {
    if (!_isScrolling) {
      _currentIndex = index;

      final state = ref.read(adFeedProvider);
      if (index < state.ads.length) {
        final currentAd = state.ads[index];
        ref.read(adFeedProvider.notifier).playVideo(currentAd.id);
      }

      ref.read(adFeedProvider.notifier).preloadVideosSmartly(index);
      _loadMoreIfNeeded(index);
      ref.read(adFeedProvider.notifier).cleanupControllers(index);
    }
  }

  void _loadMoreIfNeeded(int index) {
    final state = ref.read(adFeedProvider);
    final threshold = 2;

    if (index >= state.ads.length - threshold &&
        state.hasMore &&
        !state.isLoadingMore &&
        state.nextCursor != null) {
      ref.read(adFeedProvider.notifier).loadMoreAds();
    }
  }

  void _onScrollStart() {
    _isScrolling = true;
    final state = ref.read(adFeedProvider);
    if (_currentIndex < state.ads.length) {
      final currentAd = state.ads[_currentIndex];
      ref.read(adFeedProvider.notifier).pauseVideo(currentAd.id);
    }
  }

  void _onScrollEnd() {
    _isScrolling = false;
  }

  Widget _buildTopBar(bool isDark) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FEED',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.grey, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Failed to load videos',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(adFeedProvider.notifier).loadInitialAds(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildPageView(AdFeedState state, bool isDark) {
    if (state.isLoading && state.ads.isEmpty) {
      return _buildLoadingIndicator();
    }

    if (state.hasError && state.ads.isEmpty) {
      return _buildErrorWidget();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _onScrollStart();
        } else if (notification is ScrollEndNotification) {
          _onScrollEnd();
        }
        return false;
      },
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: state.ads.length + (state.hasMore ? 1 : 0),
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          if (index >= state.ads.length) {
            return _buildLoadMoreIndicator(isDark);
          }

          final ad = state.ads[index];
          final shouldPlay = index == _currentIndex && !_isScrolling;

          return Stack(
            children: [
              VideoPlayerComponent(ad: ad, shouldPlay: shouldPlay),
              VideoControlsComponent(ad: ad),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adFeedProvider);
    final isDark = ref.watch(themeProvider).isDarkMode;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [_buildPageView(state, isDark), _buildTopBar(isDark)],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
