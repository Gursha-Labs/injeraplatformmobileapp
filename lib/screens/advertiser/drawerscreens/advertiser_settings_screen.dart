import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';
import 'package:injera/screens/legal/terms_of_service_screen.dart';
import 'package:injera/screens/legal/privacy_policy_screen.dart';
import 'package:injera/screens/legal/security_policy_screen.dart';
import 'package:injera/screens/legal/copyright_policy_screen.dart';
import 'package:injera/screens/legal/gambling_policy_screen.dart';

class AdvertiserSettingsScreen extends ConsumerStatefulWidget {
  const AdvertiserSettingsScreen({super.key});

  @override
  ConsumerState<AdvertiserSettingsScreen> createState() =>
      _AdvertiserSettingsScreenState();
}

class _AdvertiserSettingsScreenState
    extends ConsumerState<AdvertiserSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Dark Mode Section
            _buildSectionHeader(
              'Appearance',
              Icons.palette_rounded,
              isDarkMode,
            ),
            _buildDarkModeCard(isDarkMode),
            const SizedBox(height: 24),

            // Legal Section
            _buildSectionHeader(
              'Legal & Policies',
              Icons.gavel_rounded,
              isDarkMode,
            ),
            _buildLegalCard(isDarkMode),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader(
              'Support',
              Icons.help_center_rounded,
              isDarkMode,
            ),
            _buildSupportCard(isDarkMode),
            const SizedBox(height: 24),

            // Danger Zone
            _buildDangerZoneCard(isDarkMode),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeCard(bool isDarkMode) {
    final themeState = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode ? Colors.grey[900]!.withOpacity(0.5) : Colors.white,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[800]!.withOpacity(0.5)
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: _buildSettingItem(
        icon: Icons.dark_mode_rounded,
        title: 'Dark Mode',
        subtitle: 'Switch between light and dark themes',
        trailing: Switch.adaptive(
          value: themeState.isDarkMode,
          onChanged: (value) {
            ref.read(themeProvider.notifier).toggleTheme();
          },
          activeColor: AppColors.primary,
        ),
        isDarkMode: isDarkMode,
      ),
    );
  }

  Widget _buildLegalCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode ? Colors.grey[900]!.withOpacity(0.5) : Colors.white,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[800]!.withOpacity(0.5)
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.description_rounded,
            title: 'Terms of Service',
            subtitle: 'Read our terms and conditions',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () => _showTermsOfService(isDarkMode),
          ),
          const Divider(height: 32),
          _buildSettingItem(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () => _showPrivacyPolicy(isDarkMode),
          ),
          const Divider(height: 32),
          _buildSettingItem(
            icon: Icons.security_rounded,
            title: 'Security Policy',
            subtitle: 'Our security commitments',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () => _showSecurityPolicy(isDarkMode),
          ),
          const Divider(height: 32),
          _buildSettingItem(
            icon: Icons.copyright_rounded,
            title: 'Copyright Policy',
            subtitle: 'Based on Proclamation No. 872/2014',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () => _showCopyrightPolicy(isDarkMode),
          ),
          const Divider(height: 32),
          _buildSettingItem(
            icon: Icons.sports_score_rounded,
            title: 'Gambling Policy',
            subtitle: 'Sports Betting Directive No. 856/2014',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () => _showGamblingPolicy(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode ? Colors.grey[900]!.withOpacity(0.5) : Colors.white,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[800]!.withOpacity(0.5)
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.help_center_rounded,
            title: 'Help Center',
            subtitle: 'Find answers to common questions',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () => _showHelpCenter(isDarkMode),
          ),
          const Divider(height: 32),
          _buildSettingItem(
            icon: Icons.support_agent_rounded,
            title: 'Contact Support',
            subtitle: 'Get help from our support team',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () => _contactSupport(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.red.withOpacity(isDarkMode ? 0.1 : 0.05),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'These actions are irreversible. Please proceed with caution.',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteAccountDialog(isDarkMode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text(
                    'Delete Account',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeactivateDialog(isDarkMode),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                  ),
                  icon: const Icon(Icons.pause_circle_outline_rounded),
                  label: const Text(
                    'Deactivate',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsOfService(bool isDarkMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TermsOfServiceScreen(isDarkMode: isDarkMode),
      ),
    );
  }

  void _showPrivacyPolicy(bool isDarkMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivacyPolicyScreen(isDarkMode: isDarkMode),
      ),
    );
  }

  void _showSecurityPolicy(bool isDarkMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecurityPolicyScreen(isDarkMode: isDarkMode),
      ),
    );
  }

  void _showCopyrightPolicy(bool isDarkMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CopyrightPolicyScreen(isDarkMode: isDarkMode),
      ),
    );
  }

  void _showGamblingPolicy(bool isDarkMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamblingPolicyScreen(isDarkMode: isDarkMode),
      ),
    );
  }

  void _showHelpCenter(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Help Center',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.article_rounded, color: AppColors.primary),
                title: Text(
                  'FAQs',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(
                  Icons.video_library_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Video Tutorials',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.forum_rounded, color: AppColors.primary),
                title: Text(
                  'Community Forum',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _contactSupport(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.email_rounded, color: AppColors.primary),
                title: Text(
                  'Email Support',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: const Text('support@injera.com'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.chat_rounded, color: AppColors.primary),
                title: Text(
                  'Live Chat',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: const Text('Available 24/7'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.phone_rounded, color: AppColors.primary),
                title: Text(
                  'Phone Support',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: const Text('+251-XXX-XXXX'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Account',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  void _showDeactivateDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Deactivate Account',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Your account will be temporarily deactivated. You can reactivate it anytime by logging back in.',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deactivated'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }
}