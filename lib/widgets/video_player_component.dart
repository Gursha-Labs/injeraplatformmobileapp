// widgets/video_player_component.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/ad_feed_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerComponent extends ConsumerStatefulWidget {
  final dynamic ad;
  final bool shouldPlay;

  const VideoPlayerComponent({
    super.key,
    required this.ad,
    required this.shouldPlay,
  });

  @override
  ConsumerState<VideoPlayerComponent> createState() =>
      _VideoPlayerComponentState();
}

class _VideoPlayerComponentState extends ConsumerState<VideoPlayerComponent> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ad.id != widget.ad.id) {
      _disposeController();
      _initializeController();
    }

    if (widget.shouldPlay && _isInitialized) {
      _controller?.play();
    } else if (!widget.shouldPlay && _isInitialized) {
      _controller?.pause();
    }
  }

  void _initializeController() {
    final controllers = ref.read(adFeedProvider).videoControllers;
    _controller = controllers[widget.ad.id];

    if (_controller != null && !_controller!.value.isInitialized) {
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          if (widget.shouldPlay) {
            _controller!.play();
          }
        }
      });
    } else if (_controller != null && _controller!.value.isInitialized) {
      _isInitialized = true;
      if (widget.shouldPlay) {
        _controller!.play();
      }
    }
  }

  void _toggleControls() {
    setState(() => _showControls = true);
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _disposeController() {
    _controlsTimer?.cancel();
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
        _toggleControls();
        _togglePlayPause();
      },
      onDoubleTap: () {
        // Implement like functionality here
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

          if (_showControls)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),

          if (!_controller!.value.isPlaying && !_showControls)
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
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.8),
              ),
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
}
