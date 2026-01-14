// widgets/video_card_widget.dart
import 'package:flutter/material.dart';
import 'package:injera/api/config.dart';
import 'package:injera/models/advertiser_models.dart';

class VideoCardWidget extends StatelessWidget {
  final AdvertiserVideo video;
  final VoidCallback onTap;
  final bool isDark;

  const VideoCardWidget({
    super.key,
    required this.video,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final cardColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final borderColor = isDark ? Colors.grey[800] : Colors.grey[300];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.black,
                    child:
                        video.thumbnailUrl != null &&
                            video.thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            ApiConfig.getStorageUrl(video.thumbnailUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam_outlined,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(
                                Icons.videocam_outlined,
                                color: Colors.grey,
                                size: 48,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            'PLAY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.remove_red_eye_outlined,
                        '${video.views}',
                        secondaryColor!,
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        Icons.favorite_outline,
                        '${video.likes}',
                        secondaryColor,
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        Icons.share_outlined,
                        '${video.shares}',
                        secondaryColor,
                      ),
                      const Spacer(),
                      Text(
                        video.createdAt.toString(),
                        style: TextStyle(color: secondaryColor, fontSize: 11),
                      ),
                    ],
                  ),

                  // Comments
                  if (video.commentsCount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: secondaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${video.commentsCount} comments',
                          style: TextStyle(color: secondaryColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
