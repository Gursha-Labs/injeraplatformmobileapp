import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
            Colors.black,
          ],
        ),
        border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 26),
        items: [
          _buildNavBarItem(
            icon: Icons.home,
            activeIcon: Icons.home_filled,
            label: 'Home',
            isActive: currentIndex == 0,
          ),
          _buildNavBarItem(
            icon: Icons.sports_esports,
            activeIcon: Icons.sports_esports,
            label: 'Games',
            isActive: currentIndex == 1,
          ),
          _buildNavBarItem(
            icon: Icons.search,
            activeIcon: Icons.search,
            label: 'Search',
            isActive: currentIndex == 2,
          ),
          _buildNavBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            isActive: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: isActive ? 28 : 26,
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
      label: label,
    );
  }
}
