// lib/models/analytics_model.dart
import 'package:flutter/material.dart';

class AdvertiserAnalytics {
  final String scope;
  final String advertiserId;
  final int totalAds;
  final int totalViews;
  final int totalComments;
  final int totalOrders;
  final double totalRevenue;
  final List<AnalyticsSeries> series;

  AdvertiserAnalytics({
    required this.scope,
    required this.advertiserId,
    required this.totalAds,
    required this.totalViews,
    required this.totalComments,
    required this.totalOrders,
    required this.totalRevenue,
    required this.series,
  });

  factory AdvertiserAnalytics.fromJson(Map<String, dynamic> json) {
    final List<AnalyticsSeries> seriesList = [];

    if (json['series'] != null && json['series'] is List) {
      for (var item in json['series']) {
        seriesList.add(AnalyticsSeries.fromJson(item));
      }
    }

    return AdvertiserAnalytics(
      scope: json['scope'] ?? 'advertiser',
      advertiserId: json['advertiser_id']?.toString() ?? '',
      totalAds: json['total_ads'] ?? 0,
      totalViews: json['total_views'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      series: seriesList,
    );
  }

  double get engagementRate {
    if (totalViews == 0) return 0;
    final engagement = totalComments + totalOrders;
    return (engagement / totalViews) * 100;
  }

  double get ctr {
    if (totalViews == 0) return 0;
    return (totalOrders / totalViews) * 100;
  }

  int get todayViews {
    if (series.isEmpty) return 0;
    return series.last.views;
  }

  double get weeklyGrowth {
    if (series.length < 14) return 0;
    final lastWeek = series.sublist(series.length - 7);
    final previousWeek = series.sublist(series.length - 14, series.length - 7);

    final lastWeekTotal = lastWeek.fold<int>(
      0,
      (sum, item) => sum + item.views,
    );
    final previousWeekTotal = previousWeek.fold<int>(
      0,
      (sum, item) => sum + item.views,
    );

    if (previousWeekTotal == 0) return 0;
    return ((lastWeekTotal - previousWeekTotal) / previousWeekTotal) * 100;
  }
}

class AnalyticsSeries {
  final String date;
  final int views;
  final int comments;
  final int orders;
  final double revenue;

  AnalyticsSeries({
    required this.date,
    required this.views,
    required this.comments,
    required this.orders,
    required this.revenue,
  });

  factory AnalyticsSeries.fromJson(Map<String, dynamic> json) {
    return AnalyticsSeries(
      date: json['date'] ?? '',
      views: json['views'] ?? 0,
      comments: json['comments'] ?? 0,
      orders: json['orders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class PlatformData {
  final String name;
  final int percentage;
  final Color color;

  PlatformData(this.name, this.percentage, this.color);
}

class AudienceData {
  final String ageRange;
  final double percentage;
  final Color color;

  AudienceData(this.ageRange, this.percentage, this.color);
}
