// widgets/smart_video_player.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:injera/providers/ad_feed_provider.dart';

class SmartVideoPlayer extends ConsumerStatefulWidget {
  final AdVideo ad;
  final bool shouldPlay;

  const SmartVideoPlayer({
    super.key,
    required this.ad,
    required this.shouldPlay,
  });

  @override
  ConsumerState<SmartVideoPlayer> createState() => _SmartVideoPlayerState();
}

class _SmartVideoPlayerState extends ConsumerState<SmartVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant SmartVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ad.id != widget.ad.id) {
      _disposeController();
      _initializeController();
    }

    if (widget.shouldPlay && _isInitialized && !_isBuffering) {
      _controller?.play();
    } else if (!widget.shouldPlay && _isInitialized) {
      _controller?.pause();
    }
  }

  void _initializeController() {
    final controllers = ref.read(adFeedProvider).videoControllers;
    _controller = controllers[widget.ad.id];

    if (_controller != null && !_controller!.value.isInitialized) {
      _controller!
          .initialize()
          .then((_) {
            if (mounted) {
              setState(() => _isInitialized = true);
              if (widget.shouldPlay) {
                _controller!.play();
              }
            }
          })
          .catchError((e) {
            if (mounted) {
              setState(() => _isInitialized = false);
            }
          });
    } else if (_controller != null && _controller!.value.isInitialized) {
      _isInitialized = true;
      if (widget.shouldPlay) {
        _controller!.play();
      }
    }
  }

  void _disposeController() {
    if (_controller != null && _isInitialized) {
      _controller!.pause();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return _buildPlaceholder();
    }

    return GestureDetector(
      onTap: () {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
      },
      child: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),

          // Buffering indicator
          if (_controller!.value.isBuffering)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

          // Play button overlay
          if (!_controller!.value.isPlaying && !_controller!.value.isBuffering)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),

          // Video duration overlay
          if (_controller!.value.isInitialized)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDuration(_controller!.value.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
