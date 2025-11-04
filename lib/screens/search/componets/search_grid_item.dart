// lib/components/search/search_grid_item.dart
import 'package:flutter/material.dart';

class SearchGridItem extends StatelessWidget {
  final String title;
  final int videoCount;
  final String thumbnailUrl;
  final bool isSearchResult;

  const SearchGridItem({
    super.key,
    required this.title,
    required this.videoCount,
    required this.thumbnailUrl,
    this.isSearchResult = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Thumbnail
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(thumbnailUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatCount(videoCount)} videos',
                style: TextStyle(color: Colors.grey[300], fontSize: 12),
              ),
            ],
          ),
        ),

        // Play icon for search results
        if (isSearchResult)
          const Positioned(
            top: 8,
            right: 8,
            child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
          ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
