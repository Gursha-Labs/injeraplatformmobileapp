// screens/advertiser/advertiser_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';

class AdvertiserDashboardScreen extends ConsumerWidget {
  const AdvertiserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: bgColor,
            elevation: 0,
            pinned: true,

            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light,
                      color: textColor,
                      size: 20,
                    ),
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStats(
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
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
                  'Advertiser Pro',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildMiniStat('12', 'Campaigns', textColor, secondaryTextColor),
              const SizedBox(height: 8),
              _buildMiniStat('8', 'Active', textColor, secondaryTextColor),
            ],
          ),
        ],
      ),
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
