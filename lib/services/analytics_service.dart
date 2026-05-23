// lib/services/analytics_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injera/api/api_service.dart';
import 'package:injera/models/analytics_model.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  ApiService? _apiService;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _apiService = ApiService();
      await _apiService!.init();
      _isInitialized = true;
    }
  }

  Future<AdvertiserAnalytics> getAdvertiserAnalytics({int days = 30}) async {
    await _ensureInitialized();
    debugPrint('=== GETTING ADVERTISER ANALYTICS ===');

    try {
      final response = await _apiService!.dio.get(
        '/analytics/adertiser-analysis',
        queryParameters: {'days': days},
      );

      debugPrint('Analytics Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final analytics = AdvertiserAnalytics.fromJson(data);
        debugPrint(
          'Analytics loaded: ${analytics.totalViews} views, ${analytics.totalRevenue} revenue',
        );
        return analytics;
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DIO Error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception('Failed to load analytics: $e');
    }
  }
}
