// lib/services/subscription_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injera/api/api_service.dart';
import 'package:injera/api/config.dart';
import 'package:injera/models/subscription_models.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  ApiService? _apiService;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      debugPrint('=== INITIALIZING SUBSCRIPTION SERVICE ===');
      _apiService = ApiService();
      await _apiService!.init();
      _isInitialized = true;
      debugPrint('=== SUBSCRIPTION SERVICE INITIALIZED ===');
    }
  }

  // Get all subscriptions (plans)
  Future<SubscriptionResponse> getSubscriptions() async {
    await _ensureInitialized();
    debugPrint('=== GETTING SUBSCRIPTIONS ===');

    try {
      final response = await _apiService!.dio.get(ApiConfig.subscriptions);

      debugPrint('Subscriptions API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Your API returns: {success: true, data: {current_page: 1, data: [...]}}
        if (data is Map<String, dynamic>) {
          final isSuccess = data['success'] ?? false;
          
          if (isSuccess && data['data'] != null) {
            final dataObj = data['data'];
            
            // Handle nested data array
            if (dataObj is Map<String, dynamic> && dataObj['data'] is List) {
              final List<Subscription> subscriptions = [];
              final items = dataObj['data'] as List;
              
              for (var item in items) {
                try {
                  subscriptions.add(Subscription.fromJson(item));
                } catch (e) {
                  debugPrint('Error parsing subscription: $e');
                }
              }
              
              debugPrint('Found ${subscriptions.length} subscriptions');
              
              return SubscriptionResponse(
                success: true,
                data: subscriptions,
                message: data['message'] ?? 'Success',
                currentPage: dataObj['current_page'] ?? 1,
                lastPage: dataObj['last_page'] ?? 1,
                perPage: dataObj['per_page'] ?? 10,
                total: dataObj['total'] ?? 0,
              );
            }
          }
        }
      }

      return SubscriptionResponse(
        success: false,
        data: [],
        message: 'Failed to fetch subscriptions',
        currentPage: 1,
        lastPage: 1,
        perPage: 0,
        total: 0,
      );
    } on DioException catch (e) {
      debugPrint('DIO ERROR fetching subscriptions: ${e.message}');
      return SubscriptionResponse(
        success: false,
        data: [],
        message: 'Network error: ${e.message}',
        currentPage: 1,
        lastPage: 1,
        perPage: 0,
        total: 0,
      );
    } catch (e) {
      debugPrint('UNKNOWN ERROR fetching subscriptions: $e');
      return SubscriptionResponse(
        success: false,
        data: [],
        message: 'Unknown error: $e',
        currentPage: 1,
        lastPage: 1,
        perPage: 0,
        total: 0,
      );
    }
  }

  // Get user's active subscription
  Future<UserSubscription?> getUserSubscription() async {
    await _ensureInitialized();
    debugPrint('=== GETTING USER SUBSCRIPTION ===');

    try {
      final response = await _apiService!.dio.get(ApiConfig.userSubscriptions);

      debugPrint('User Subscription Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Your API returns a direct array: [{...}]
        if (data is List && data.isNotEmpty) {
          debugPrint('Found user subscription');
          return UserSubscription.fromJson(data[0]);
        }
        
        // Handle if it's a single object
        if (data is Map<String, dynamic>) {
          return UserSubscription.fromJson(data);
        }
      }
      debugPrint('No active subscription found');
      return null;
    } on DioException catch (e) {
      debugPrint('Error fetching user subscription: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error parsing user subscription: $e');
      return null;
    }
  }

  // Subscribe to a plan
  Future<SubscriptionPurchaseResult?> subscribeToPlan(String subscriptionId) async {
    await _ensureInitialized();
    debugPrint('=== SUBSCRIBING TO PLAN: $subscriptionId ===');

    try {
      final response = await _apiService!.dio.post(
        ApiConfig.userSubscriptions,
        data: {'subscription_id': subscriptionId},
      );

      debugPrint('Subscribe Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SubscriptionPurchaseResult(
          success: true,
          subscription: null,
          message: 'Subscription successful',
        );
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Error subscribing: ${e.message}');
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Subscription failed');
      }
      rethrow;
    }
  }

  // Cancel subscription
  Future<bool> cancelSubscription() async {
    await _ensureInitialized();
    debugPrint('=== CANCELLING SUBSCRIPTION ===');

    try {
      final response = await _apiService!.dio.post(ApiConfig.cancelSubscription);
      debugPrint('Cancel Status: ${response.statusCode}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error cancelling subscription: ${e.message}');
      return false;
    }
  }
}