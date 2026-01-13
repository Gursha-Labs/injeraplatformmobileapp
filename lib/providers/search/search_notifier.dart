import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:injera/api/search_service.dart';
import 'package:injera/providers/search/search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;
  Timer? _debounceTimer;

  SearchNotifier()
    : _searchService = SearchService(),
      super(const SearchState());

  // In SearchNotifier class
  Future<void> initialize() async {
    await _loadRecentSearches();
  }

  // Clear search
  void clearSearch() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    state = state.copyWith(
      status: SearchStatus.initial,
      videos: [],
      searchQuery: '',
      error: null,
      currentPage: 1,
      hasMore: false,
    );
  }

  // Update search query with debounce
  void updateSearchQuery(String query) async {
    // Cancel previous timer
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    // Update query immediately
    state = state.copyWith(searchQuery: query, isSearching: query.isNotEmpty);

    // If query is empty, clear results
    if (query.isEmpty) {
      state = state.copyWith(
        status: SearchStatus.initial,
        videos: [],
        error: null,
        currentPage: 1,
        hasMore: false,
      );
      await _loadRecentSearches();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  // Update category
  void updateCategory(String category) {
    if (state.selectedCategory != category) {
      state = state.copyWith(
        selectedCategory: category,
        videos: [],
        currentPage: 1,
        hasMore: false,
        status: SearchStatus.initial,
      );

      // If there's a search query, search with new category
      if (state.searchQuery.isNotEmpty) {
        _performSearch(state.searchQuery);
      }
    }
  }

  // Perform search
  Future<void> _performSearch(String query) async {
    try {
      state = state.copyWith(status: SearchStatus.loading, error: null);

      final response = await _searchService.searchVideos(
        query: query,
        page: state.currentPage,
      );

      state = state.copyWith(
        status: SearchStatus.success,
        videos: response.videos,
        currentPage: response.currentPage,
        totalPages: response.lastPage,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(status: SearchStatus.error, error: e.toString());
    }
  }

  // Load more results
  Future<void> loadMore() async {
    if (!state.canLoadMore || state.searchQuery.isEmpty) return;

    try {
      state = state.copyWith(status: SearchStatus.loadingMore);

      final nextPage = state.currentPage + 1;
      final response = await _searchService.searchVideos(
        query: state.searchQuery,
        page: nextPage,
      );

      final allVideos = [...state.videos, ...response.videos];

      state = state.copyWith(
        status: SearchStatus.success,
        videos: allVideos,
        currentPage: response.currentPage,
        totalPages: response.lastPage,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(status: SearchStatus.error, error: e.toString());
    }
  }

  // Refresh search
  Future<void> refresh() async {
    if (state.searchQuery.isEmpty) {
      await _loadRecentSearches();
      return;
    }

    state = state.copyWith(
      status: SearchStatus.loading,
      currentPage: 1,
      videos: [],
      hasMore: false,
    );

    await _performSearch(state.searchQuery);
  }

  // Load recent searches
  Future<void> _loadRecentSearches() async {
    try {
      final recentSearches = await _searchService.getRecentSearches();
      state = state.copyWith(recentSearches: recentSearches);
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
