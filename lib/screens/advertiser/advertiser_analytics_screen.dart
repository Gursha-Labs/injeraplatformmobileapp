// lib/screens/advertiser/advertiser_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/theme_provider.dart';
import '../../services/analytics_service.dart';
import '../../models/analytics_model.dart';
import '../../theme/app_colors.dart';

class AdvertiserAnalyticsScreen extends ConsumerStatefulWidget {
  const AdvertiserAnalyticsScreen({super.key});

  @override
  ConsumerState<AdvertiserAnalyticsScreen> createState() =>
      _AdvertiserAnalyticsScreenState();
}

class _AdvertiserAnalyticsScreenState
    extends ConsumerState<AdvertiserAnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  late Future<AdvertiserAnalytics> _analyticsFuture;
  int _selectedDays = 30;
  bool _isLoading = true;
  String? _error;
  AdvertiserAnalytics? _analytics;

  final List<int> _dateRangeOptions = [7, 14, 30, 60, 90];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final analytics = await _analyticsService.getAdvertiserAnalytics(
        days: _selectedDays,
      );
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changeDateRange(int days) {
    setState(() {
      _selectedDays = days;
    });
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: bgColor,
              elevation: 0,
              pinned: true,
              title: Text(
                'Analytics',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              actions: [_buildDateRangeSelector(textColor, secondaryTextColor)],
            ),
            SliverToBoxAdapter(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    )
                  : _error != null
                  ? _buildErrorWidget(secondaryTextColor)
                  : _analytics != null
                  ? _buildContent(
                      _analytics!,
                      textColor,
                      secondaryTextColor,
                      isDark,
                    )
                  : _buildEmptyWidget(secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(Color textColor, Color secondaryTextColor) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: PopupMenuButton<int>(
        icon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderDark),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                'Last $_selectedDays days',
                style: TextStyle(color: textColor, fontSize: 12),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: textColor, size: 16),
            ],
          ),
        ),
        onSelected: (int value) {
          _changeDateRange(value);
        },
        itemBuilder: (context) => _dateRangeOptions.map((days) {
          return PopupMenuItem<int>(
            value: days,
            child: Text('Last $days days'),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorWidget(Color secondaryTextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Failed to load analytics',
              style: TextStyle(color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAnalytics,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(Color secondaryTextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No analytics data available',
              style: TextStyle(color: secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    AdvertiserAnalytics analytics,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildKpiGrid(analytics, textColor, secondaryTextColor),
          const SizedBox(height: 16),
          _buildPerformanceChart(
            analytics,
            textColor,
            secondaryTextColor,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildViewsRevenueChart(
            analytics,
            textColor,
            secondaryTextColor,
            isDark,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildAudienceInsights(
                  textColor,
                  secondaryTextColor,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPlatformDistribution(
                  textColor,
                  secondaryTextColor,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(
    AdvertiserAnalytics analytics,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final kpis = [
      _KpiData(
        _formatNumber(analytics.totalViews),
        'Impressions',
        _formatGrowth(analytics.weeklyGrowth),
        analytics.weeklyGrowth >= 0,
      ),
      _KpiData(
        _formatNumber(analytics.totalComments + analytics.totalOrders),
        'Engagement',
        _formatGrowth(analytics.engagementRate),
        analytics.engagementRate >= 5,
      ),
      _KpiData(
        '${analytics.ctr.toStringAsFixed(2)}%',
        'CTR',
        _formatGrowth(analytics.ctr - 5),
        analytics.ctr >= 5,
      ),
      _KpiData(
        'ETB ${_formatNumber(analytics.totalRevenue.toInt())}',
        'Revenue',
        _formatGrowth(analytics.weeklyGrowth),
        analytics.weeklyGrowth >= 0,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderDark),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      kpi.value,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: kpi.isPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          kpi.isPositive
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 10,
                          color: kpi.isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          kpi.change,
                          style: TextStyle(
                            color: kpi.isPositive ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                kpi.label,
                style: TextStyle(color: secondaryTextColor, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceChart(
    AdvertiserAnalytics analytics,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    if (analytics.series.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: secondaryTextColor),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < analytics.series.length; i++) {
      spots.add(FlSpot(i.toDouble(), analytics.series[i].views.toDouble()));
    }

    // FIXED: Convert num to double explicitly
    final double maxY = spots.isEmpty
        ? 100.0
        : (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1)
              .toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
                'Views Overview',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: ${_formatNumber(analytics.totalViews)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: secondaryTextColor.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: spots.length > 7 ? spots.length / 7 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < analytics.series.length) {
                          final date = DateTime.parse(
                            analytics.series[index].date,
                          );
                          return Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatNumber(value.toInt()),
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFFEF4444),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxY,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewsRevenueChart(
    AdvertiserAnalytics analytics,
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    if (analytics.series.isEmpty) {
      return const SizedBox.shrink();
    }

    final barGroups = <BarChartGroupData>[];
    final startIndex = analytics.series.length > 7
        ? analytics.series.length - 7
        : 0;

    for (int i = startIndex; i < analytics.series.length; i++) {
      final data = analytics.series[i];
      barGroups.add(
        BarChartGroupData(
          x: i - startIndex,
          barRods: [
            BarChartRodData(
              toY: data.views.toDouble(),
              width: 8,
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Performance',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last ${barGroups.length} days views',
            style: TextStyle(color: secondaryTextColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
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
                        final index = value.toInt();
                        if (index >= 0 && index < barGroups.length) {
                          final dataIndex = startIndex + index;
                          if (dataIndex < analytics.series.length) {
                            final date = DateTime.parse(
                              analytics.series[dataIndex].date,
                            );
                            return Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 10,
                              ),
                            );
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceInsights(
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    final audienceData = [
      AudienceData('18-25', 35, const Color(0xFFEF4444)),
      AudienceData('26-35', 45, Colors.grey[600]!),
      AudienceData('36+', 20, Colors.grey[400]!),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audience',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: audienceData.map((data) {
                        return PieChartSectionData(
                          value: data.percentage,
                          color: data.color,
                          radius: 30,
                          title: '${data.percentage.toInt()}%',
                          titleStyle: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: audienceData.map((data) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: data.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data.ageRange,
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${data.percentage.toInt()}%',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformDistribution(
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    final platforms = [
      PlatformData('Mobile', 65, const Color(0xFFEF4444)),
      PlatformData('Desktop', 25, Colors.grey[600]!),
      PlatformData('Tablet', 10, Colors.grey[400]!),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platforms',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: platforms.map((platform) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: platform.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        platform.name,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      '${platform.percentage}%',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(
                        value: platform.percentage / 100,
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(platform.color),
                        borderRadius: BorderRadius.circular(2),
                        minHeight: 4,
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatGrowth(double value) {
    if (value > 0) {
      return '+${value.toStringAsFixed(1)}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }
}

class _KpiData {
  final String value;
  final String label;
  final String change;
  final bool isPositive;

  _KpiData(this.value, this.label, this.change, this.isPositive);
}
