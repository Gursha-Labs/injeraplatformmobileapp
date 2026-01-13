import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onClearPressed;
  final List<String> recentSearches;
  final ValueChanged<String> onRecentSearchTap;
  final bool isSearching;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    this.onClearPressed,
    required this.recentSearches,
    required this.onRecentSearchTap,
    this.isSearching = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final FocusNode _focusNode = FocusNode();
  bool _showRecentSearches = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _showRecentSearches =
          _focusNode.hasFocus &&
          widget.controller.text.isEmpty &&
          widget.recentSearches.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back button
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: (value) {
                widget.onSearchChanged(value);
                setState(() {
                  _showRecentSearches =
                      _focusNode.hasFocus &&
                      value.isEmpty &&
                      widget.recentSearches.isNotEmpty;
                });
              },
              onTap: () {
                setState(() {
                  _showRecentSearches =
                      widget.controller.text.isEmpty &&
                      widget.recentSearches.isNotEmpty;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: widget.isSearching
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: Transform.scale(
                          scale: 0.6,
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search videos...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          widget.onSearchChanged('');
                          widget.onClearPressed?.call();
                          _focusNode.unfocus();
                          setState(() {
                            _showRecentSearches = false;
                          });
                        },
                      )
                    : null,
              ),
              cursorColor: Colors.white,
            ),
          ),
        ),
        if (_showRecentSearches)
          Positioned(
            top: kToolbarHeight,
            left: 0,
            right: 0,
            child: _buildRecentSearchesDropdown(),
          ),
      ],
    );
  }

  Widget _buildRecentSearchesDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1C1C1C),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Recent Searches',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: widget.recentSearches.length,
                  itemBuilder: (context, index) {
                    final searchTerm = widget.recentSearches[index];
                    return _buildRecentSearchItem(searchTerm);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String searchTerm) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.history, color: Colors.grey, size: 20),
      title: Text(
        searchTerm,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.clear, color: Colors.grey, size: 16),
        onPressed: () {
          // Implement remove recent search functionality if needed
        },
      ),
      onTap: () {
        widget.controller.text = searchTerm;
        widget.onRecentSearchTap(searchTerm);
        _focusNode.unfocus();
        setState(() {
          _showRecentSearches = false;
        });
      },
    );
  }
}
