// screens/profile/components/video_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class VideoGrid extends ConsumerWidget {
  const VideoGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.7,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return _buildVideoThumbnail(index, isDark);
      },
    );
  }

  Widget _buildVideoThumbnail(int index, bool isDark) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: Image.network(
            'https://picsum.photos/200/300?random=$index',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Row(
            children: [
              Icon(Icons.play_arrow, color: AppColors.pureWhite, size: 14),
              const SizedBox(width: 4),
              Text(
                '${(index + 1) * 125}',
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
