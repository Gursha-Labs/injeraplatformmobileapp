// widgets/video_controls_component.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';


class VideoControlsComponent extends ConsumerWidget {
  final dynamic ad;

  const VideoControlsComponent({super.key, required this.ad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white70 : Colors.black87;
    final bgColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.white.withOpacity(0.3);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          _buildUserInfo(context, isDark, textColor, bgColor),

          const Spacer(),

          // Right side buttons
          Align(
            alignment: Alignment.bottomRight,
            child: _buildSideButtons(context, iconColor, bgColor),
          ),

          // Bottom info
          _buildBottomInfo(context, textColor, iconColor),
        ],
      ),
    );
  }

  Widget _buildUserInfo(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color bgColor,
  ) {
    final username = ad.advertiser['username'] ?? 'User';
    final profilePic = ad.advertiser['profile_picture'];
    final category = ad.category['name'] ?? 'Category';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isDark ? Colors.white24 : Colors.black12,
            child: profilePic != null && profilePic != 'profile_picture'
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      profilePic,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    username[0].toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@$username',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Sponsored • $category',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideButtons(
    BuildContext context,
    Color iconColor,
    Color bgColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(Icons.favorite_border, '0', iconColor, bgColor),
        const SizedBox(height: 16),
        _buildIconButton(
          Icons.comment_outlined,
          ad.commentCount.toString(),
          iconColor,
          bgColor,
        ),
        const SizedBox(height: 16),
        _buildIconButton(Icons.share_outlined, '0', iconColor, bgColor),
        const SizedBox(height: 16),
        _buildIconButton(
          Icons.visibility_outlined,
          ad.viewCount.toString(),
          iconColor,
          bgColor,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(Icons.more_vert, color: iconColor, size: 20),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon,
    String count,
    Color iconColor,
    Color bgColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            color: iconColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(
    BuildContext context,
    Color textColor,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ad.title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (ad.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            children: ad.tags.map<Widget>((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '#${tag['name']}',
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
