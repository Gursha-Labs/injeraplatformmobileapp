import 'package:injera/models/ad_video_model.dart';

enum SearchStatus { initial, loading, loadingMore, success, error }

class SearchState {
  final SearchStatus status;
  final List<AdVideo> videos;
  final String? error;
  final String searchQuery;
  final String selectedCategory;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isSearching;
  final List<String> recentSearches;

  const SearchState({
    this.status = SearchStatus.initial,
    this.videos = const [],
    this.error,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
    this.isSearching = false,
    this.recentSearches = const [],
  });

  bool get isLoading => status == SearchStatus.loading;
  bool get isLoadingMore => status == SearchStatus.loadingMore;
  bool get hasError => status == SearchStatus.error;
  bool get hasVideos => videos.isNotEmpty;
  bool get canLoadMore => hasMore && !isLoadingMore;
  String? get message => error;

  SearchState copyWith({
    SearchStatus? status,
    List<AdVideo>? videos,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isSearching,
    List<String>? recentSearches,
  }) {
    return SearchState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isSearching: isSearching ?? this.isSearching,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}
