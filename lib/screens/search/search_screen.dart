import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/search/search_notifier.dart';
import 'package:injera/providers/search/search_state.dart';
import 'package:injera/providers/search_provider.dart';
import 'package:injera/screens/search/componets/search_app_bar.dart';
import 'package:injera/screens/search/componets/search_content.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(searchProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: SearchAppBar(
        controller: _searchController,
        onSearchChanged: (value) {
          searchNotifier.updateSearchQuery(value);
        },
        onClearPressed: () {
          searchNotifier.clearSearch();
        },
        recentSearches: searchState.recentSearches,
        onRecentSearchTap: (query) {
          _searchController.text = query;
          searchNotifier.updateSearchQuery(query);
        },
        isSearching: searchState.status == SearchStatus.loading,
      ),
      body: SearchContent(
        searchState: searchState,
        onLoadMore: () => searchNotifier.loadMore(),
        onRecentSearchTap: (query) {
          _searchController.text = query;
          searchNotifier.updateSearchQuery(query);
        },
      ),
    );
  }
}
