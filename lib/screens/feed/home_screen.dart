import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/comment_provider.dart';
import 'package:injera/widgets/comment_bottom_sheet.dart';
import 'package:video_player/video_player.dart';
import 'package:injera/models/ad_video_model.dart';
import 'package:injera/providers/ad_feed_provider.dart';
import 'package:injera/providers/points_provider.dart';
import 'package:injera/widgets/points_display_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasJumpedToSavedPage = false; // Prevent multiple jumps

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final feedState = ref.read(adFeedProvider);
    _currentPage = feedState.currentIndex ?? 0;

    // Preload videos around the saved position
    ref.read(adFeedProvider.notifier).preloadAround(_currentPage);

    // Safely jump to saved page AFTER the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasJumpedToSavedPage && feedState.ads.isNotEmpty) {
        _pageController.jumpToPage(_currentPage);
        _hasJumpedToSavedPage = true;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final notifier = ref.read(adFeedProvider.notifier);
    final feedState = ref.read(adFeedProvider);

    if (_currentPage != index && _currentPage < feedState.ads.length) {
      // Pause previous video
      final previousAd = feedState.ads[_currentPage];
      final previousController = notifier.getController(previousAd.id);
      previousController?.pause();
    }

    _currentPage = index;
    notifier.setCurrentIndex(index);
    _playCurrentVideo();
    _loadMoreIfNeeded(index);
    notifier.preloadAround(index);
  }

  void _playCurrentVideo() {
    final notifier = ref.read(adFeedProvider.notifier);
    final feedState = ref.read(adFeedProvider);
    if (_currentPage < feedState.ads.length) {
      final currentAd = feedState.ads[_currentPage];
      final controller = notifier.getController(currentAd.id);
      if (controller != null &&
          controller.value.isInitialized &&
          !controller.value.isPlaying) {
        controller.play();
      }
    }
  }

  void _loadMoreIfNeeded(int index) {
    final notifier = ref.read(adFeedProvider.notifier);
    final feedState = ref.read(adFeedProvider);
    if (index >= feedState.ads.length - 5 &&
        feedState.hasMore &&
        !_isLoadingMore) {
      _isLoadingMore = true;
      notifier.loadMore().then((_) => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(adFeedProvider);
    final pointsState = ref.watch(pointsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildVideoFeed(feedState),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Injera',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const PointsDisplayWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFeed(AdFeedState state) {
    if (state.isLoading && state.ads.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state.error != null && state.ads.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 50),
              const SizedBox(height: 16),
              const Text(
                'Failed to load videos',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ref.read(adFeedProvider.notifier).refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: state.ads.length,
      onPageChanged: _onPageChanged,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final ad = state.ads[index];
        final notifier = ref.read(adFeedProvider.notifier);
        final controller = notifier.getController(ad.id);
        final isCurrent = index == _currentPage;

        return VideoPlayerCard(
          key: ValueKey('${ad.id}_${ad.videoUrl}'),
          ad: ad,
          controller: controller,
          isCurrentVideo: isCurrent,
        );
      },
    );
  }
}

// VideoPlayerCard (unchanged except fixed syntax error in didUpdateWidget)
class VideoPlayerCard extends StatefulWidget {
  final AdVideo ad;
  final VideoPlayerController? controller;
  final bool isCurrentVideo;

  const VideoPlayerCard({
    super.key,
    required this.ad,
    this.controller,
    required this.isCurrentVideo,
  });

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  bool _showControls = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _ensureControllerReady();
  }

  void _ensureControllerReady() {
    if (widget.controller != null && !widget.controller!.value.isInitialized) {
      widget.controller!.initialize().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentVideo && widget.controller != null) {
      if (!widget.controller!.value.isPlaying &&
          widget.controller!.value.isInitialized) {
        widget.controller!.play();
      }
    } else if (!widget.isCurrentVideo &&
        widget.controller != null &&
        widget.controller!.value.isPlaying) {
      widget.controller!.pause();
    }
  }

  void _togglePlayPause() {
    if (widget.controller == null) return;
    if (widget.controller!.value.isPlaying) {
      widget.controller!.pause();
    } else {
      widget.controller!.play();
    }
    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideoReady = widget.controller?.value.isInitialized == true;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isVideoReady && widget.controller != null)
            VideoPlayer(widget.controller!)
          else
            Container(
              color: Colors.black87,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),

          if (_showControls ||
              (widget.controller != null &&
                  !widget.controller!.value.isPlaying))
            Container(
              color: Colors.black26,
              child: Center(
                child: Icon(
                  widget.controller?.value.isPlaying == true
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 64,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),

          // Side actions
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _buildActionButton(
                  Icons.favorite_border,
                  widget.ad.viewCount.toString(),
                ),
                const SizedBox(height: 20),
                // In your VideoPlayerCard's build method, update the comment action button:
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CommentBottomSheet(ad: widget.ad),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.comment_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Consumer(
                        builder: (context, ref, child) {
                          final commentState = ref.watch(
                            commentProvider(widget.ad.id),
                          );
                          return Text(
                            commentState.commentCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionButton(Icons.bookmark_border, 'Save'),
                const SizedBox(height: 20),
                _buildActionButton(Icons.share_outlined, 'Share'),
              ],
            ),
          ),

          // Bottom content
          Positioned(
            left: 16,
            right: 100,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${widget.ad.advertiser.username}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.ad.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.ad.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      children: widget.ad.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${tag.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
