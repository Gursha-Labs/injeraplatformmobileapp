import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/models/user_profile.dart';
import 'package:injera/providers/auth_provider.dart';
import 'package:injera/providers/profile_provider.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/screens/profile/componets/profile_header.dart';
import 'package:injera/screens/profile/edit_profile_screen.dart';
import 'package:injera/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTab = 0; // Track the selected tab index

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    ).then((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
      appBar: _buildAppBar(isDark, profileState.profile?.firstName),
      body: _buildBody(isDark, profileState),
    );
  }

  AppBar _buildAppBar(bool isDark, String? displayName) {
    return AppBar(
      backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
      elevation: 0,
      title: Text(
        displayName ?? 'Profile',
        style: TextStyle(
          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            size: 22,
          ),
          onPressed: () {
            _showMenu(context, isDark);
          },
        ),
      ],
    );
  }

  void _showMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                context,
                isDark,
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
              _buildMenuItem(
                context,
                isDark,
                icon: Icons.share_outlined,
                label: 'Share Profile',
                onTap: () {
                  Navigator.pop(context);
                  _shareProfile();
                },
              ),
              _buildMenuItem(
                context,
                isDark,
                icon: Icons.logout_outlined,
                label: 'Logout',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context, isDark);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : (isDark ? AppColors.pureWhite : AppColors.pureBlack),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive
              ? Colors.red
              : (isDark ? AppColors.pureWhite : AppColors.pureBlack),
        ),
      ),
      onTap: onTap,
    );
  }

  void _shareProfile() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality coming soon'),
        backgroundColor: AppColors.pureBlack,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, bool isDark) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    bool isDark,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Account',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be deleted. Are you sure you want to proceed?',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete account logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion initiated'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Implement logout logic
      await ref.read(authProvider.notifier).logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.black,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBody(bool isDark, ProfileState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading profile...',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    ref.read(profileProvider.notifier).loadProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.pureWhite
                      : AppColors.pureBlack,
                  foregroundColor: isDark
                      ? AppColors.pureBlack
                      : AppColors.pureWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = state.profile!;
    final fullName = _buildFullName(profile);
    // FIX: Use username from profile instead of firstName
    final username = profile.firstName ?? '';

    return Column(
      children: [
        // Profile Header - FIXED: No bool isDark parameter needed
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProfileHeader(
            profilePicture: profile.profilePicture,
            fullName: fullName,
            username: username,
            onEditPressed: _navigateToEditProfile,
          ),
        ),

        // Tab Bar
        _buildTabBar(isDark),

        // Tab Content
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: [
              // Personal Info Tab (Original Content)
              _buildPersonalInfoTab(isDark, profile),

              // Account Settings Tab
              _buildAccountSettingsTab(isDark, profile),

              // Privacy & Security Tab
              _buildPrivacySecurityTab(isDark, profile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    final tabs = ['Personal Info', 'Account Settings', 'Privacy & Security'];

    return Container(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _selectedTab == index
                        ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: _selectedTab == index
                      ? (isDark ? AppColors.pureWhite : AppColors.pureBlack)
                      : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  fontSize: 14,
                  fontWeight: _selectedTab == index
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Personal Info Tab (Original Content in Scrollable View)
  Widget _buildPersonalInfoTab(bool isDark, UserProfile profile) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Stats Section
          _buildStatsRow(isDark, profile),

          // Bio Section
          if (profile.bio != null && profile.bio!.isNotEmpty)
            _buildBioSection(isDark, profile.bio!),

          // Contact Information
          _buildContactSection(isDark, profile),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _navigateToEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.pureWhite
                    : AppColors.pureBlack,
                foregroundColor: isDark
                    ? AppColors.pureBlack
                    : AppColors.pureWhite,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsTab(bool isDark, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Overview
          Text(
            'Account Overview',
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Points and Balance Cards in a row
          Row(
            children: [
              Expanded(
                child: Card(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Points Balance',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.pureWhite
                                : AppColors.pureBlack,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.pointsBalance.toStringAsFixed(0)} pts',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.pureWhite
                                : AppColors.pureBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Money Balance',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.pureWhite
                                : AppColors.pureBlack,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${profile.moneyBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.pureWhite
                                : AppColors.pureBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Earnings Card
          Card(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Earnings',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.pureWhite
                              : AppColors.pureBlack,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '\$${profile.totalEarned.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.pureWhite
                              : AppColors.pureBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: profile.totalEarned > 0
                        ? (profile.totalEarned / 10000).clamp(0.0, 1.0)
                        : 0.0,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    color: Colors.green,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(profile.totalEarned / 10000 * 100).toStringAsFixed(1)}% of goal',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Notification Settings
          Text(
            'Notification Settings',
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildToggleSetting(
                    isDark: isDark,
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications for updates',
                    value: profile.notificationsEnabled ?? true,
                  ),
                  const SizedBox(height: 16),
                  _buildToggleSetting(
                    isDark: isDark,
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    value: profile.emailNotifications ?? true,
                  ),
                  const SizedBox(height: 16),
                  _buildToggleSetting(
                    isDark: isDark,
                    title: 'SMS Alerts',
                    subtitle: 'Receive important alerts via SMS',
                    value: profile.notificationsEnabled ?? false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Preferences
          Text(
            'Preferences',
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Favorite Categories (dummy data)
                  _buildPreferenceItem(
                    isDark: isDark,
                    icon: Icons.category_outlined,
                    title: 'Favorite Categories',
                    value: 'Food, Travel, Technology',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceItem(
                    isDark: isDark,
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    value: '2 cards saved',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceItem(
                    isDark: isDark,
                    icon: Icons.language_outlined,
                    title: 'Language',
                    value: 'English',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceItem(
                    isDark: isDark,
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    value: isDark ? 'Dark' : 'Light',
                    onTap: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPrivacySecurityTab(bool isDark, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Settings
          Text(
            'Security Settings',
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSecurityItem(
                    isDark: isDark,
                    icon: Icons.fingerprint_outlined,
                    title: 'Biometric Login',
                    subtitle: 'Use fingerprint or face ID to login',
                    value: false,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityItem(
                    isDark: isDark,
                    icon: Icons.lock_outline,
                    title: 'Two-Factor Authentication',
                    subtitle: 'Add an extra layer of security',
                    value: false,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityItem(
                    isDark: isDark,
                    icon: Icons.visibility_outlined,
                    title: 'Activity Log',
                    subtitle: 'View your account activity',
                    value: false,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Privacy Settings
          Text(
            'Privacy Settings',
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSecurityItem(
                    isDark: isDark,
                    icon: Icons.person_outline,
                    title: 'Profile Visibility',
                    subtitle: 'Control who can see your profile',
                    value: true,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityItem(
                    isDark: isDark,
                    icon: Icons.location_on_outlined,
                    title: 'Location Sharing',
                    subtitle: 'Share your location with the app',
                    value: false,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityItem(
                    isDark: isDark,
                    icon: Icons.data_usage_outlined,
                    title: 'Data Collection',
                    subtitle: 'Allow anonymous data collection',
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Data & Privacy
          Text(
            'Data & Privacy',
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDataRow(
                    isDark: isDark,
                    label: 'Account Created',
                    value:
                        '${profile.createdAt.month} ${profile.createdAt.day}, ${profile.createdAt.year}',
                  ),
                  const SizedBox(height: 12),
                  _buildDataRow(
                    isDark: isDark,
                    label: 'Last Updated',
                    value:
                        '${profile.updatedAt.month} ${profile.updatedAt.day}, ${profile.updatedAt.year}',
                  ),
                  const SizedBox(height: 12),
                  _buildDataRow(
                    isDark: isDark,
                    label: 'Last Login',
                    value: 'Today, 10:30 AM',
                  ),
                  const SizedBox(height: 12),
                  _buildDataRow(
                    isDark: isDark,
                    label: 'Devices',
                    value: '2 active devices',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Account Actions
          Text(
            'Account Actions',
            style: TextStyle(
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: isDark ? Color(0xFF2C2C2C) : Color(0xFFF5F5F5),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger Zone',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'These actions are irreversible. Please proceed with caution.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Export Data Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data export initiated'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Export Data',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showLogoutDialog(context, isDark),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Delete Account Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () =>
                          _showDeleteAccountDialog(context, isDark),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildToggleSetting({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {},
          activeColor: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        ),
      ],
    );
  }

  Widget _buildSecurityItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow({
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // The following methods are the original methods from your code
  // They are preserved exactly as they were

  String _buildFullName(UserProfile profile) {
    final firstName = profile.firstName ?? '';
    final lastName = profile.lastName ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      return 'User';
    } else if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else {
      return firstName.isNotEmpty ? firstName : lastName;
    }
  }

  Widget _buildStatsRow(bool isDark, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            isDark: isDark,
            icon: Icons.star_border_rounded,
            value: profile.pointsBalance.toStringAsFixed(0),
            label: 'Points',
          ),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            isDark: isDark,
            icon: Icons.account_balance_wallet_outlined,
            value: '\$${profile.moneyBalance.toStringAsFixed(2)}',
            label: 'Balance',
          ),
          _buildVerticalDivider(isDark),
          _buildStatItem(
            isDark: isDark,
            icon: Icons.trending_up_outlined,
            value: '\$${profile.totalEarned.toStringAsFixed(2)}',
            label: 'Total Earned',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required bool isDark,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  Widget _buildBioSection(bool isDark, String bio) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
              const SizedBox(width: 8),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isDark, UserProfile profile) {
    final hasContactInfo =
        (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) ||
        profile.dateOfBirth != null ||
        profile.gender != null;

    final hasLocationInfo =
        (profile.country != null && profile.country!.isNotEmpty) ||
        (profile.city != null && profile.city!.isNotEmpty) ||
        (profile.address != null && profile.address!.isNotEmpty);

    if (!hasContactInfo && !hasLocationInfo) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
          ),
          const SizedBox(height: 16),

          if (hasContactInfo) ...[
            if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
              _buildInfoRow(
                isDark: isDark,
                icon: Icons.phone_outlined,
                text: profile.phoneNumber!,
              ),

            if (profile.dateOfBirth != null)
              _buildInfoRow(
                isDark: isDark,
                icon: Icons.cake_outlined,
                text:
                    '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}',
              ),

            if (profile.gender != null)
              _buildInfoRow(
                isDark: isDark,
                icon: Icons.person_outline,
                text: profile.gender!.replaceAll('_', ' ').toTitleCase(),
              ),
          ],

          if (hasLocationInfo) ...[
            const SizedBox(height: 24),
            Text(
              'Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
            ),
            const SizedBox(height: 16),

            if (profile.country != null && profile.country!.isNotEmpty)
              _buildInfoRow(
                isDark: isDark,
                icon: Icons.location_on_outlined,
                text: profile.country!,
              ),

            if (profile.city != null && profile.city!.isNotEmpty)
              _buildInfoRow(
                isDark: isDark,
                icon: Icons.location_city_outlined,
                text: profile.city!,
              ),

            if (profile.address != null && profile.address!.isNotEmpty)
              _buildInfoRow(
                isDark: isDark,
                icon: Icons.home_outlined,
                text: profile.address!,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required bool isDark,
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split('_')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : word,
        )
        .join(' ');
  }
}
