// screens/advertiser/advertiser_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:injera/api/api_service.dart';
import 'package:injera/api/config.dart';
import 'package:injera/providers/auth_provider.dart';
import 'package:injera/screens/advertiser/deposit_screen.dart';
import 'package:injera/screens/advertiser/video_card_widget.dart';
import 'package:injera/screens/advertiser/video_player_widget.dart';

import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';
import 'package:injera/providers/auth/auth_state.dart';
import '../../models/advertiser_models.dart';
import '../../services/payment_service.dart'; // Add this import

class AdvertiserDashboardScreen extends ConsumerStatefulWidget {
  const AdvertiserDashboardScreen({super.key});

  @override
  ConsumerState<AdvertiserDashboardScreen> createState() =>
      _AdvertiserDashboardScreenState();
}

class _AdvertiserDashboardScreenState
    extends ConsumerState<AdvertiserDashboardScreen> {
  final ApiService _apiService = ApiService();
  final PaymentService _paymentService =
      PaymentService(); // Add payment service
  late Future<AdvertiserProfile> _profileFuture;

  AdvertiserProfile? _profile;
  List<AdvertiserVideo> _videos = [];
  double _walletBalance = 0.0; // Add wallet balance
  int _currentPage = 1;
  AuthState? get _authState => ref.read(authProvider);

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
    _loadWalletBalance();
  }

  Future<AdvertiserProfile> _loadProfile() async {
    try {
      final profile = await _apiService.getAdvertiserProfile();
      setState(() => _profile = profile);
      return profile;
    } catch (e) {
      return AdvertiserProfile(
        userId: 'unknown',
        username: _authState?.user?.username ?? 'Advertiser',
        email: '',
        totalAdsUploaded: 0,
        totalAdViews: 0,
        totalSpent: '0.00',
        subscriptionActive: false,
        isActive: true,
      );
    }
  }

  // Load wallet balance
  Future<void> _loadWalletBalance() async {
    final balance = await _paymentService.getWalletBalance();
    setState(() {
      _walletBalance = balance;
    });
  }

  // Navigate to deposit screen
  Future<void> _navigateToDeposit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DepositScreen(),
        settings: const RouteSettings(name: '/deposit'),
      ),
    );

    // Refresh wallet balance after returning from deposit screen
    if (result == true) {
      await _loadWalletBalance();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_loadProfile(), _loadWalletBalance()]);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: bgColor,
              elevation: 0,
              pinned: true,
              title: Text(
                'Advertiser Dashboard',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                // Wallet balance button
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _navigateToDeposit,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_walletBalance.toStringAsFixed(2)} ETB',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Theme toggle
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: textColor,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Wallet Card (NEW)
                    _buildWalletCard(
                      surfaceColor,
                      textColor,
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 16),

                    // Welcome & Stats Combined
                    _buildWelcomeStats(
                      surfaceColor,
                      textColor,
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 16),

                    // Performance & Campaigns Side by Side
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildPerformanceChart(
                            surfaceColor,
                            textColor,
                            secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildCampaignList(
                            surfaceColor,
                            textColor,
                            secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Stats Grid
                    _buildQuickStatsGrid(textColor, secondaryTextColor),

                    const SizedBox(height: 16),

                    // Videos Section
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button with Menu
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // New: Wallet Card Widget
  Widget _buildWalletCard(
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToDeposit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wallet Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_walletBalance.toStringAsFixed(2)} ETB',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: AppColors.primary, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Add Money',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Earn 5% bonus on deposits > 500 ETB',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New: Floating Action Button with Menu
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _showFloatingMenu();
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Quick Actions'),
    );
  }

  // Show floating menu with options
  void _showFloatingMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Add Money to Wallet'),
                subtitle: const Text('Deposit funds using Chapa'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToDeposit();
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.video_call, color: Colors.blue),
                ),
                title: const Text('Upload New Video'),
                subtitle: const Text('Create new ad campaign'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to video upload screen
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Coming soon!')));
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.history, color: Colors.green),
                ),
                title: const Text('Transaction History'),
                subtitle: const Text('View all deposits and withdrawals'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to transaction history
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Coming soon!')));
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeStats(
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return FutureBuilder<AdvertiserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  image: profile?.profilePicture != null
                      ? DecorationImage(
                          image: NetworkImage(
                            ApiConfig.getStorageUrl(profile!.profilePicture),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profile?.profilePicture == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile?.companyName ??
                          _authState?.user!.username ??
                          'Advertiser',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (profile?.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile!.description!,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  _buildMiniStat(
                    '${profile?.totalAdsUploaded ?? 0}',
                    'Videos',
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(height: 8),
                  _buildMiniStat(
                    '${profile?.totalAdViews ?? 0}',
                    'Views',
                    textColor,
                    secondaryTextColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(
    String value,
    String label,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: secondaryTextColor, fontSize: 10)),
      ],
    );
  }

  Widget _buildPerformanceChart(
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '7 days',
                  style: TextStyle(color: secondaryTextColor, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(
                          days[value.toInt()],
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 8,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: List.generate(7, (index) {
                  final values = [12, 18, 8, 22, 16, 25, 20];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[index].toDouble(),
                        width: 6,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignList(
    Color surfaceColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final campaigns = [
      _Campaign('Summer Sale', 'Active', 85),
      _Campaign('Product Launch', 'Active', 72),
      _Campaign('Brand Boost', 'Completed', 94),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaigns',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: campaigns.map((campaign) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            value: campaign.progress / 100,
                            strokeWidth: 3,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation(
                              _getProgressColor(campaign.progress),
                            ),
                          ),
                        ),
                        Text(
                          '${campaign.progress}%',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            campaign.status,
                            style: TextStyle(
                              color: _getStatusColor(campaign.status),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(Color textColor, Color secondaryTextColor) {
    final stats = [
      _StatData('124.5K', 'Impressions', Icons.visibility, '+12.4%'),
      _StatData('8.2K', 'Engagement', Icons.favorite, '+8.1%'),
      _StatData('6.58%', 'CTR', Icons.trending_up, '+2.3%'),
      _StatData('\$5,248', 'Revenue', Icons.attach_money, '+15.2%'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderDark),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(stat.icon, color: AppColors.primary, size: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      stat.change,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stat.value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stat.label,
                style: TextStyle(color: secondaryTextColor, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Color _getProgressColor(int progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.blue;
    return Colors.orange;
  }
}

class _Campaign {
  final String name;
  final String status;
  final int progress;

  _Campaign(this.name, this.status, this.progress);
}

class _StatData {
  final String value;
  final String label;
  final IconData icon;
  final String change;

  _StatData(this.value, this.label, this.icon, this.change);
}
