import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';
import 'package:injera/theme/app_theme.dart';

class AdvertiserSettingsScreen extends ConsumerStatefulWidget {
  const AdvertiserSettingsScreen({super.key});

  @override
  ConsumerState<AdvertiserSettingsScreen> createState() =>
      _AdvertiserSettingsScreenState();
}

class _AdvertiserSettingsScreenState
    extends ConsumerState<AdvertiserSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _marketingEmails = false;
  bool _autoSaveDrafts = true;
  bool _twoFactorAuth = false;
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'English';
  double _budgetLimit = 5000.0;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD'];
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
  ];

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            Colors.black.withOpacity(0.8),
                            Colors.grey[900]!.withOpacity(0.6),
                          ]
                        : [
                            AppColors.primary.withOpacity(0.1),
                            Colors.white.withOpacity(0.1),
                          ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.settings_suggest_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.save_rounded,
                  color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
                ),
                onPressed: _saveSettings,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile Card
                _buildProfileCard(isDarkMode),
                const SizedBox(height: 24),

                // Appearance Section
                _buildSectionHeader(
                  'Appearance',
                  Icons.palette_rounded,
                  isDarkMode,
                ),
                _buildAppearanceCard(isDarkMode),
                const SizedBox(height: 24),

                // Notifications Section
                _buildSectionHeader(
                  'Notifications',
                  Icons.notifications_rounded,
                  isDarkMode,
                ),
                _buildNotificationsCard(isDarkMode),
                const SizedBox(height: 24),

                // Account Section
                _buildSectionHeader(
                  'Account',
                  Icons.security_rounded,
                  isDarkMode,
                ),
                _buildAccountCard(isDarkMode),
                const SizedBox(height: 24),

                // Preferences Section
                _buildSectionHeader(
                  'Preferences',
                  Icons.tune_rounded,
                  isDarkMode,
                ),
                _buildPreferencesCard(isDarkMode),
                const SizedBox(height: 24),

                // Budget Section
                _buildSectionHeader(
                  'Budget & Billing',
                  Icons.account_balance_wallet_rounded,
                  isDarkMode,
                ),
                _buildBudgetCard(isDarkMode),
                const SizedBox(height: 24),

                // Support Section
                _buildSectionHeader(
                  'Support',
                  Icons.help_center_rounded,
                  isDarkMode,
                ),
                _buildSupportCard(isDarkMode),
                const SizedBox(height: 32),

                // Danger Zone
                _buildDangerZoneCard(isDarkMode),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
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

  Widget _buildProfileCard(bool isDarkMode) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.person_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Advertiser Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Premium Plan • Active',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('12', 'Active Ads', isDarkMode),
              _buildStatItem('4.8', 'Rating', isDarkMode),
              _buildStatItem('98%', 'Success', isDarkMode),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/advertiser/profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDarkMode) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceCard(bool isDarkMode) {
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
      child: Column(
        children: [
          // Dark Mode Toggle
          _buildSettingItem(
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
          const Divider(height: 32),

          // Theme Color
          _buildSettingItem(
            icon: Icons.color_lens_rounded,
            title: 'Theme Color',
            subtitle: 'Choose your primary color',
            trailing: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 2,
                ),
              ),
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              _showColorPicker(isDarkMode);
            },
          ),
          const Divider(height: 32),

          // Font Size
          _buildSettingItem(
            icon: Icons.text_fields_rounded,
            title: 'Font Size',
            subtitle: 'Adjust text size',
            trailing: Text(
              'Medium',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              _showFontSizeDialog(isDarkMode);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(bool isDarkMode) {
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
            icon: Icons.notifications_active_rounded,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            trailing: Switch.adaptive(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            isDarkMode: isDarkMode,
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.email_rounded,
            title: 'Email Notifications',
            subtitle: 'Receive email updates',
            trailing: Switch.adaptive(
              value: _marketingEmails,
              onChanged: (value) {
                setState(() {
                  _marketingEmails = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            isDarkMode: isDarkMode,
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.campaign_rounded,
            title: 'Campaign Alerts',
            subtitle: 'Get notified about campaign performance',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
            isDarkMode: isDarkMode,
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.monetization_on_rounded,
            title: 'Billing Alerts',
            subtitle: 'Notifications about payments and budget',
            trailing: Switch.adaptive(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(bool isDarkMode) {
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
            icon: Icons.lock_rounded,
            title: 'Two-Factor Authentication',
            subtitle: 'Add extra security to your account',
            trailing: Switch.adaptive(
              value: _twoFactorAuth,
              onChanged: (value) {
                setState(() {
                  _twoFactorAuth = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            isDarkMode: isDarkMode,
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.password_rounded,
            title: 'Change Password',
            subtitle: 'Update your password regularly',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              _showChangePasswordDialog(isDarkMode);
            },
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.devices_rounded,
            title: 'Connected Devices',
            subtitle: 'Manage your active sessions',
            trailing: Text(
              '3 active',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              _showDevicesDialog(isDarkMode);
            },
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Settings',
            subtitle: 'Control your data and privacy',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.pushNamed(context, '/advertiser/privacy');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(bool isDarkMode) {
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
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'App language preference',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  iconSize: 20,
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  items: _languages.map((language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(
                        language,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
              ),
            ),
            isDarkMode: isDarkMode,
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.attach_money_rounded,
            title: 'Currency',
            subtitle: 'Default currency for transactions',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  iconSize: 20,
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(
                        currency,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value!;
                    });
                  },
                ),
              ),
            ),
            isDarkMode: isDarkMode,
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.save_alt_rounded,
            title: 'Auto-save Drafts',
            subtitle: 'Automatically save campaign drafts',
            trailing: Switch.adaptive(
              value: _autoSaveDrafts,
              onChanged: (value) {
                setState(() {
                  _autoSaveDrafts = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(bool isDarkMode) {
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
          // Budget Limit Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Budget Limit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '\$${_budgetLimit.toInt()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _budgetLimit,
                min: 100.0,
                max: 20000.0,
                divisions: 199,
                activeColor: AppColors.primary,
                inactiveColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                label: '\$${_budgetLimit.toInt()}',
                onChanged: (value) {
                  setState(() {
                    _budgetLimit = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$100',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    '\$20,000',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.receipt_long_rounded,
            title: 'Billing History',
            subtitle: 'View all your transactions',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              _showBillingHistory(isDarkMode);
            },
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.credit_card_rounded,
            title: 'Payment Methods',
            subtitle: 'Manage your payment options',
            trailing: Text(
              '2 cards',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              _showPaymentMethods(isDarkMode);
            },
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.receipt_rounded,
            title: 'Tax Information',
            subtitle: 'Manage tax documents and settings',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              _showTaxInformation(isDarkMode);
            },
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
            onTap: () {
              Navigator.pushNamed(context, '/help-center');
            },
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
            onTap: () {
              _contactSupport(isDarkMode);
            },
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.feedback_rounded,
            title: 'Send Feedback',
            subtitle: 'Share your thoughts with us',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              _sendFeedback(isDarkMode);
            },
          ),
          const Divider(height: 32),

          _buildSettingItem(
            icon: Icons.description_rounded,
            title: 'Terms & Policies',
            subtitle: 'View our terms and privacy policy',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            isDarkMode: isDarkMode,
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
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

          ElevatedButton.icon(
            onPressed: () {
              _showDeleteAccountDialog(isDarkMode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () {
              _showDeactivateDialog(isDarkMode);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.orange.withOpacity(0.3)),
            ),
            icon: const Icon(Icons.pause_circle_outline_rounded),
            label: const Text(
              'Deactivate Account',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showColorPicker(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Theme Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 20),
              // Add color picker grid here
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text(
            'Font Size',
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add font size options here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text(
            'Change Password',
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add password fields here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDevicesDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text(
            'Connected Devices',
            style: TextStyle(
              color: isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Add device list here
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showBillingHistory(bool isDarkMode) {
    // Implement billing history
  }

  void _showPaymentMethods(bool isDarkMode) {
    // Implement payment methods
  }

  void _showTaxInformation(bool isDarkMode) {
    // Implement tax information
  }

  void _contactSupport(bool isDarkMode) {
    // Implement contact support
  }

  void _sendFeedback(bool isDarkMode) {
    // Implement send feedback
  }

  void _showDeleteAccountDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
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
                // Implement delete account logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
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
                // Implement deactivate logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }
}
