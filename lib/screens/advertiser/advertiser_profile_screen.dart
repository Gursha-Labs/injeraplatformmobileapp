// screens/advertiser/advertiser_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/auth/auth_state.dart';
import 'package:injera/providers/auth_provider.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class AdvertiserProfileScreen extends ConsumerStatefulWidget {
  const AdvertiserProfileScreen({super.key});

  @override
  ConsumerState<AdvertiserProfileScreen> createState() =>
      _AdvertiserProfileScreenState();
}

class _AdvertiserProfileScreenState
    extends ConsumerState<AdvertiserProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _showLogoutDialog(BuildContext context) async {
    final isDark = ref.read(themeProvider).isDarkMode;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            'Logout',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: _isLoggingOut
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Text('Logout', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      await ref.read(authProvider.notifier).logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Logged out successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = ref.watch(themeProvider).isDarkMode;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(
              authState,
              surfaceColor,
              textColor,
              secondaryTextColor,
              borderColor,
            ),
            const SizedBox(height: 16),

            // Account Info
            _buildAccountInfo(
              authState,
              surfaceColor,
              textColor,
              secondaryTextColor,
              borderColor,
            ),
            const SizedBox(height: 16),

            // Quick Actions
            _buildQuickActions(
              surfaceColor,
              textColor,
              secondaryTextColor,
              borderColor,
            ),
            const SizedBox(height: 16),

            // Settings Section
            _buildSettingsSection(
              surfaceColor,
              textColor,
              secondaryTextColor,
              borderColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    AuthState authState,
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    final user = authState.user;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: secondaryTextColor,
            child: Icon(Icons.business, size: 40, color: surfaceColor),
          ),
          const SizedBox(height: 16),
          Text(
            user?.username ?? 'Advertiser',
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'email@example.com',
            style: TextStyle(color: secondaryTextColor, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user?.type?.toString().split('.').last.toUpperCase() ??
                  'ADVERTISER',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Campaigns', '12', textColor, secondaryTextColor),
              _buildStatItem('Active', '8', textColor, secondaryTextColor),
              _buildStatItem('Spent', '\$5.2K', textColor, secondaryTextColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: secondaryTextColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildAccountInfo(
    AuthState authState,
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    final user = authState.user;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            'Company Name',
            user?.username ?? 'TechCorp Inc.',
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildInfoItem(
            'Email',
            user?.email ?? 'techcorp@example.com',
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildInfoItem(
            'Phone',
            '+1 (555) 123-4567',
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildInfoItem(
            'Address',
            '123 Business St, New York, NY',
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildInfoItem(
            'Account Type',
            'Business Advertiser',
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildInfoItem(
            'Joined Date',
            'January 15, 2024',
            textColor,
            secondaryTextColor,
            borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildActionItem(
                'Create Campaign',
                Icons.add,
                textColor,
                surfaceColor,
                borderColor,
              ),
              _buildActionItem(
                'Add Funds',
                Icons.attach_money,
                textColor,
                surfaceColor,
                borderColor,
              ),
              _buildActionItem(
                'Support',
                Icons.help,
                textColor,
                surfaceColor,
                borderColor,
              ),
              _buildActionItem(
                'Documents',
                Icons.description,
                textColor,
                surfaceColor,
                borderColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    IconData icon,
    Color textColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings & Billing',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            'Payment Methods',
            Icons.payment,
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildSettingItem(
            'Billing History',
            Icons.receipt,
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildSettingItem(
            'Notifications',
            Icons.notifications,
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildSettingItem(
            'Privacy & Security',
            Icons.security,
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildSettingItem(
            'Help & Support',
            Icons.help_outline,
            textColor,
            secondaryTextColor,
            borderColor,
          ),
          _buildLogoutItem(textColor, secondaryTextColor, borderColor),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: secondaryTextColor,
        ),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Colors.transparent,
      ),
    );
  }

  Widget _buildLogoutItem(
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _isLoggingOut
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Icon(Icons.logout, color: AppColors.primary),
        title: Text(
          _isLoggingOut ? 'Logging out...' : 'Logout',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: _isLoggingOut
            ? null
            : Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
        onTap: _isLoggingOut ? null : () => _showLogoutDialog(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: AppColors.primary.withOpacity(0.1),
      ),
    );
  }
}
