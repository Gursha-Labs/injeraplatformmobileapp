// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:injera/screens/search/componets/search_app_bar.dart';
import 'package:injera/screens/search/componets/search_categories.dart';
import 'package:injera/screens/search/componets/search_content.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: SearchAppBar(
        controller: _searchController,
        onSearchChanged: (value) {
          // Handle search query changes
          setState(() {});
        },
      ),
      body: Column(
        children: [
          SearchCategories(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          Expanded(
            child: SearchContent(
              searchQuery: _searchController.text,
              selectedCategory: _selectedCategory,
            ),
          ),
        ],
      ),
    );
  }
}
