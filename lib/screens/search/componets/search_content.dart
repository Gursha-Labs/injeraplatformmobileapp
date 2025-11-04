// lib/components/search/search_content.dart
import 'package:flutter/material.dart';
import 'search_grid_item.dart';

class SearchContent extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;

  const SearchContent({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) {
      return _buildDiscoverSection();
    } else {
      return _buildSearchResults();
    }
  }

  Widget _buildDiscoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Discover',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 0.7,
            ),
            itemCount: 20, // Mock data count
            itemBuilder: (context, index) {
              return SearchGridItem(
                title: 'Trending #${index + 1}',
                videoCount: (index + 1) * 1000,
                thumbnailUrl: _getMockThumbnailUrl(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.7,
      ),
      itemCount: 12, // Mock search results
      itemBuilder: (context, index) {
        return SearchGridItem(
          title: 'Result ${index + 1}',
          videoCount: (index + 1) * 500,
          thumbnailUrl: _getMockThumbnailUrl(index),
          isSearchResult: true,
        );
      },
    );
  }

  String _getMockThumbnailUrl(int index) {
    // This would be replaced with actual image URLs from your API
    return 'https://picsum.photos/400/600?random=$index';
  }
}
