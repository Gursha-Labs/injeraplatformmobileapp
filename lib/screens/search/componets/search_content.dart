import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/models/ad_video_model.dart' as vid;

import 'package:injera/providers/search/search_state.dart';
import 'search_grid_item.dart';

class SearchContent extends StatefulWidget {
  final SearchState searchState;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onRecentSearchTap;

  const SearchContent({
    super.key,
    required this.searchState,
    required this.onLoadMore,
    required this.onRecentSearchTap,
  });

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.searchState;

    if (state.searchQuery.isEmpty) {
      return _buildDiscoverSection();
    }

    if (state.isLoading && !state.isLoadingMore) {
      return _buildLoading();
    }

    if (state.hasError) {
      return _buildError(state.error!);
    }

    if (!state.hasVideos) {
      return _buildEmptyResults();
    }

    return _buildSearchResults(state);
  }

  Widget _buildDiscoverSection() {
    final recentSearches = widget.searchState.recentSearches;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (recentSearches.isNotEmpty) _buildRecentSearches(recentSearches),

          // Discover Section
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

          // Discover Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 0.7,
            ),
            itemCount: 20, // Mock discover items
            itemBuilder: (context, index) {
              return SearchGridItem(video: _createMockVideo(index));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(List<String> searches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.map((search) {
              return GestureDetector(
                onTap: () => widget.onRecentSearchTap(search),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        search,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(color: Colors.grey, height: 32, thickness: 0.5),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.onLoadMore(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: Colors.grey, size: 64),
          const SizedBox(height: 16),
          Text(
            widget.searchState.message ?? 'No results found',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search term',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            state.canLoadMore) {
          widget.onLoadMore();
        }
        return false;
      },
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: state.videos.length + (state.canLoadMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.videos.length) {
                  return _buildLoadingMore();
                }
                return SearchGridItem(
                  video: state.videos[index],
                  isSearchResult: true,
                );
              },
            ),
          ),
          if (state.isLoadingMore) _buildLoadMoreIndicator(),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  // Fixed mock video creation to match your AdVideo model
  vid.AdVideo _createMockVideo(int index) {
    return vid.AdVideo(
      id: index.toString(),
      advertiserId: index.toString(),
      title: 'Trending Video #${index + 1}',
      videoUrl: 'https://picsum.photos/400/600?random=$index',
      categoryId: index.toString(),
      viewCount: (index + 1) * 1000,
      commentCount: index * 50,
      duration: 60,
      createdAt: DateTime.now(),
      advertiser: vid.Advertiser(
        id: index.toString(),
        username: 'Advertiser $index',
        profilePicture: 'https://picsum.photos/200?random=$index',
      ),
      category: vid.Category(id: index.toString(), name: 'Category $index'),
      tags: [
        vid.Tag(id: index.toString(), name: 'tag$index'),
        vid.Tag(id: '${index}_2', name: 'trending'),
      ],
    );
  }
}
