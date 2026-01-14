import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/auth_provider.dart';
import 'package:injera/providers/theme_provider.dart' hide AppTheme;
import 'package:injera/screens/advertiser/advertiser_analytics_screen.dart';
import 'package:injera/screens/advertiser/advertiser_dashboard_screen.dart';
import 'package:injera/screens/advertiser/advertiser_profile_screen.dart';
import 'package:injera/screens/advertiser/advertiser_upload_screen.dart';
import 'package:injera/screens/advertiser/drawerscreens/advertiser_settings_screen.dart';
import 'package:injera/theme/app_theme.dart';
import 'package:injera/theme/app_colors.dart';
import 'advertiser_main_screen.dart';

class AdvertiserWrapper extends ConsumerWidget {
  const AdvertiserWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Injera Advertiser',
      theme: themeState.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const _AdvertiserHomePage(),
      routes: _buildRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/advertiser/dashboard': (context) => const AdvertiserDashboardScreen(),
      '/advertiser/upload': (context) => const AdvertiserUploadScreen(),
      '/advertiser/profile': (context) => const AdvertiserProfileScreen(),
      '/advertiser/analytics': (context) => const AdvertiserAnalyticsScreen(),
      '/advertiser/settings': (context) => const AdvertiserSettingsScreen(),
    };
  }
}

class _AdvertiserHomePage extends ConsumerWidget {
  const _AdvertiserHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDarkMode = themeState.isDarkMode;

    // Color configurations for interchangeability
    final Color drawerBackgroundColor = isDarkMode
        ? Colors.black.withOpacity(0.95) // Black for dark mode
        : Colors.white.withOpacity(0.95); // White for light mode

    final Color drawerSurfaceColor = isDarkMode
        ? Colors.grey[900]!.withOpacity(0.8) // Dark grey for dark mode
        : Colors.grey[100]!.withOpacity(0.8); // Light grey for light mode

    final Color drawerBorderColor = isDarkMode
        ? Colors.grey[800]!.withOpacity(0.5) // Dark border for dark mode
        : Colors.grey[300]!.withOpacity(0.5); // Light border for light mode

    final Color drawerTextPrimaryColor = isDarkMode
        ? Colors
              .white // White text for dark mode
        : Colors.black; // Black text for light mode

    final Color drawerTextSecondaryColor = isDarkMode
        ? Colors.grey[400]! // Light grey text for dark mode
        : Colors.grey[600]!; // Dark grey text for light mode

    // Get initials for avatar
    String getInitials() {
      if (user?.username?.isNotEmpty == true) {
        final parts = user!.username!.split(' ');
        if (parts.length >= 2) {
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        }
        return user.username![0].toUpperCase();
      }
      return 'AD';
    }

    // Get company name
    String getCompanyName() {
      return user?.username ?? 'Advertiser';
    }

    // Get email
    String getEmail() {
      return user?.email ?? 'email@example.com';
    }

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        width: MediaQuery.of(context).size.width * 0.85,
        child: Container(
          decoration: BoxDecoration(
            color: drawerBackgroundColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.2),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: drawerBorderColor, width: 1),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: drawerSurfaceColor,
                      border: Border.all(color: drawerBorderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  getInitials(),
                                  style: const TextStyle(
                                    color: AppColors.pureWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getCompanyName(),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: drawerTextPrimaryColor,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    getEmail(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: drawerTextSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Wallet Balance Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: drawerSurfaceColor,
                            border: Border.all(
                              color: drawerBorderColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDarkMode ? 0.2 : 0.05,
                                ),
                                blurRadius: 15,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Balance',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: drawerTextSecondaryColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '\$12,500',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: drawerTextPrimaryColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withOpacity(0.9),
                                          AppColors.primary,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 6,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'USD',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.pureWhite,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: drawerBorderColor,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Updated just now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: drawerTextSecondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu Items Section
                  Expanded(
                    child: Container(
                      color: drawerBackgroundColor,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        children: [
                          const SizedBox(height: 8),
                          _buildDrawerSection(
                            title: 'MAIN',
                            textColor: drawerTextSecondaryColor,
                          ),
                          _buildDrawerItem(
                            icon: Icons.dashboard_rounded,
                            title: 'Dashboard',
                            backgroundColor: drawerBackgroundColor,
                            surfaceColor: drawerSurfaceColor,
                            textPrimaryColor: drawerTextPrimaryColor,
                            textSecondaryColor: drawerTextSecondaryColor,
                            isSelected: true,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.video_collection_rounded,
                            title: 'Ad Library',
                            backgroundColor: drawerBackgroundColor,
                            surfaceColor: drawerSurfaceColor,
                            textPrimaryColor: drawerTextPrimaryColor,
                            textSecondaryColor: drawerTextSecondaryColor,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.add_circle_rounded,
                            title: 'Create Ad',
                            backgroundColor: drawerBackgroundColor,
                            surfaceColor: drawerSurfaceColor,
                            textPrimaryColor: drawerTextPrimaryColor,
                            textSecondaryColor: drawerTextSecondaryColor,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                '/advertiser/upload',
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDrawerSection(
                            title: 'MANAGEMENT',
                            textColor: drawerTextSecondaryColor,
                          ),
                          _buildDrawerItem(
                            icon: Icons.shopping_bag_rounded,
                            title: 'Orders',
                            backgroundColor: drawerBackgroundColor,
                            surfaceColor: drawerSurfaceColor,
                            textPrimaryColor: drawerTextPrimaryColor,
                            textSecondaryColor: drawerTextSecondaryColor,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),

                          _buildDrawerItem(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'Wallet',
                            backgroundColor: drawerBackgroundColor,
                            surfaceColor: drawerSurfaceColor,
                            textPrimaryColor: drawerTextPrimaryColor,
                            textSecondaryColor: drawerTextSecondaryColor,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDrawerSection(
                            title: 'SUPPORT',
                            textColor: drawerTextSecondaryColor,
                          ),
                          _buildDrawerItem(
                            icon: Icons.help_center_rounded,
                            title: 'Help Center',
                            backgroundColor: drawerBackgroundColor,
                            surfaceColor: drawerSurfaceColor,
                            textPrimaryColor: drawerTextPrimaryColor,
                            textSecondaryColor: drawerTextSecondaryColor,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.description_rounded,
                            title: 'Documentation',
                            backgroundColor: drawerBackgroundColor,
                            surfaceColor: drawerSurfaceColor,
                            textPrimaryColor: drawerTextPrimaryColor,
                            textSecondaryColor: drawerTextSecondaryColor,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Settings Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: drawerBackgroundColor,
                      border: Border(
                        top: BorderSide(color: drawerBorderColor, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDrawerItem(
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          backgroundColor: drawerBackgroundColor,
                          surfaceColor: drawerSurfaceColor,
                          textPrimaryColor: drawerTextPrimaryColor,
                          textSecondaryColor: drawerTextSecondaryColor,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/advertiser/settings',
                            ); // Update this line
                          },
                        ),
                        const SizedBox(height: 4),
                        _buildDrawerItem(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          backgroundColor: drawerBackgroundColor,
                          surfaceColor: drawerSurfaceColor,
                          textPrimaryColor: drawerTextPrimaryColor,
                          textSecondaryColor: drawerTextSecondaryColor,
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(authProvider.notifier).logout();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Injera Platform',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: isDarkMode
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: _buildHamburgerMenuIcon(isDarkMode),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Open Menu',
            );
          },
        ),
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                size: 24,
                color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: const AdvertiserMainScreen(),
    );
  }

  Widget _buildHamburgerMenuIcon(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 2,
            width: 20,
            color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 20,
            color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 20,
            color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection({
    required String title,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? surfaceColor : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : textSecondaryColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? AppColors.primary : textPrimaryColor,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
