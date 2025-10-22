// screens/profile/components/video_grid.dart
import 'package:flutter/material.dart';

class VideoGrid extends StatelessWidget {
  const VideoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.7,
      ),
      itemCount: 15, // Replace with actual video count
      itemBuilder: (context, index) {
        return _buildVideoThumbnail(index);
      },
    );
  }

  Widget _buildVideoThumbnail(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.grey[800],
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
              const Icon(Icons.play_arrow, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                '${(index + 1) * 125}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
