// screens/profile/components/tab_selector.dart
import 'package:flutter/material.dart';

class TabSelector extends StatefulWidget {
  const TabSelector({super.key});

  @override
  State<TabSelector> createState() => _TabSelectorState();
}

class _TabSelectorState extends State<TabSelector> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(Icons.grid_on, 0),
          _buildTabItem(Icons.favorite_border, 1),
          _buildTabItem(Icons.lock_outline, 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 24,
          ),
        ),
      ),
    );
  }
}
