import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:injera/models/ad_video_model.dart';
import 'package:injera/providers/ad_feed_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final VideoPlayerController controller;
  final bool isCurrentPage;
  final AdVideo ad;
  final VoidCallback onProgressUpdate;

  const VideoPlayerWidget({
    super.key,
    required this.controller,
    required this.isCurrentPage,
    required this.ad,
    required this.onProgressUpdate,
  });

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  bool _isMuted = true;
  bool _showControls = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage) {
        widget.controller.play();
        _startControlsTimer();
      } else {
        widget.controller.pause();
        _controlsTimer?.cancel();
        _showControls = false;
      }
    }
  }

  void _initializeVideo() {
    widget.controller.addListener(_videoListener);

    if (widget.isCurrentPage) {
      widget.controller.play();
      _startControlsTimer();
    }
  }

  void _videoListener() {
    if (widget.controller.value.isPlaying && widget.isCurrentPage) {
      _onProgress();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onProgress() {
    widget.onProgressUpdate();
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _showControls = true;
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.isCurrentPage) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    _startControlsTimer();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      widget.controller.setVolume(_isMuted ? 0 : 1);
    });
    _startControlsTimer();
  }

  void _seekForward() {
    final currentPosition = widget.controller.value.position;
    final duration = widget.controller.value.duration;

    if (duration != Duration.zero) {
      final newPosition = currentPosition + const Duration(seconds: 10);
      if (newPosition < duration) {
        widget.controller.seekTo(newPosition);
      }
    }
    _startControlsTimer();
  }

  void _seekBackward() {
    final currentPosition = widget.controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);

    if (newPosition > Duration.zero) {
      widget.controller.seekTo(newPosition);
    }
    _startControlsTimer();
  }

  void _onTap() {
    setState(() {
      _showControls = true;
    });
    _startControlsTimer();
  }

  void _onDoubleTap(bool isRightSide) {
    if (isRightSide) {
      _seekForward();
    } else {
      _seekBackward();
    }

    // Show quick seek indicator
    _showQuickSeekFeedback(isRightSide);
    _startControlsTimer();
  }

  void _showQuickSeekFeedback(bool isForward) {
    // You can show a custom animation here
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onDoubleTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isRightSide = details.localPosition.dx > screenWidth / 2;
        _onDoubleTap(isRightSide);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video
          VideoPlayer(widget.controller),

          // Loading indicator
          if (!widget.controller.value.isInitialized)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Controls overlay
          if (_showControls && widget.controller.value.isInitialized)
            _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Play/Pause button
          IconButton(
            onPressed: _togglePlayPause,
            icon: Icon(
              widget.controller.value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: Colors.white.withOpacity(0.8),
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side controls
                Row(
                  children: [
                    IconButton(
                      onPressed: _seekBackward,
                      icon: const Icon(Icons.replay_10, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: _toggleMute,
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Right side controls
                IconButton(
                  onPressed: _seekForward,
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
