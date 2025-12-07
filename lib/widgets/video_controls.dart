import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_model.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class VideoControls extends ConsumerWidget {
  final AdVideo ad;

  const VideoControls({super.key, required this.ad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildUserInfo(isDark), _buildActionButtons(isDark)],
      ),
    );
  }

  Widget _buildUserInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isDark
                  ? AppColors.pureWhite
                  : AppColors.pureBlack,
              backgroundImage: NetworkImage(
                (ad.advertiser.profilePicture ?? '').startsWith('http')
                    ? ad.advertiser.profilePicture!
                    : 'https://tse4.mm.bing.net/th/id/OIP.5r9ik2lpDk0Tev7J45Su_wHaD4?w=1200&h=628&rs=1&pid=ImgDetMain&o=7&rm=3z',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${ad.advertiser.username}',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ad.category.name,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          ad.title,
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        children: [
          _buildActionButton(Icons.favorite_border, '${ad.viewCount}', isDark),
          const SizedBox(height: 20),
          _buildActionButton(
            Icons.chat_bubble_outline,
            '${ad.commentCount}',
            isDark,
          ),
          const SizedBox(height: 20),
          _buildActionButton(Icons.bookmark_border, 'Save', isDark),
          const SizedBox(height: 20),
          _buildActionButton(Icons.share, 'Share', isDark),
          const SizedBox(height: 20),
          _buildActionButton(Icons.more_vert, '', isDark),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String text, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.white.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.iconDark : AppColors.iconLight,
            size: 28,
          ),
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
