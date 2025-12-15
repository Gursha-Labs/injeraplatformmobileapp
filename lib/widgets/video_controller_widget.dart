import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:injera/models/ad_video_model.dart';

class VideoControllerWidget extends StatelessWidget {
  final VideoPlayerController videoController;
  final AdVideo ad;

  const VideoControllerWidget({
    super.key,
    required this.videoController,
    required this.ad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Advertiser Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: ad.advertiser.profilePicture.isNotEmpty
                        ? NetworkImage(ad.advertiser.profilePicture)
                        : null,
                    child: ad.advertiser.profilePicture.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.advertiser.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ad.category.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Views Count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ad.viewCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // Bottom Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                ad.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Tags
              Wrap(
                spacing: 8,
                children: ad.tags
                    .take(3)
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#${tag.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              // Video Controls
              _buildVideoControls(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Row(
      children: [
        // Play/Pause Button
        IconButton(
          onPressed: () {
            if (videoController.value.isPlaying) {
              videoController.pause();
            } else {
              videoController.play();
            }
          },
          icon: Icon(
            videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        // Progress Bar
        Expanded(
          child: VideoProgressIndicator(
            videoController,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.white24,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 16),
        // Volume Control
        IconButton(
          onPressed: () {
            // Toggle mute/unmute
            videoController.setVolume(
              videoController.value.volume == 0 ? 1.0 : 0.0,
            );
          },
          icon: Icon(
            videoController.value.volume == 0
                ? Icons.volume_off
                : Icons.volume_up,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }
}
