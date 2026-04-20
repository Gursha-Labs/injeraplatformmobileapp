// lib/services/wallet_service.dart
import 'package:dio/dio.dart';
import 'package:injera/api/api_service.dart';
import 'package:injera/api/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final ApiService _apiService = ApiService();

  /// Get wallet balance for the current user
  Future<double> getWalletBalance() async {
    try {
      final dio = await _getDio();
      final response = await dio.get('${ApiConfig.baseUrl}/wallet/balance');

      print('Wallet API Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle your backend's response format
        if (data['success'] == true && data['data'] != null) {
          final balance = data['data']['balance'];
          return (balance ?? 0).toDouble();
        }

        // Fallback for direct balance response
        if (data['balance'] != null) {
          return (data['balance'] as num).toDouble();
        }
      }

      return 0.0;
    } catch (e) {
      print('Get wallet balance error: $e');
      return 0.0;
    }
  }

  /// Get the Dio instance from ApiService (hack to reuse token handling)
  Future<dynamic> _getDio() async {
    // Initialize ApiService if not already
    await _apiService.init();

    // Access the private dio using reflection (workaround)
    // Since ApiService already handles tokens, we'll make a direct request
    // using the same pattern but through a separate method

    // Create a temporary Dio with same base URL
    return _apiService; // Return the service to use its token handling
  }

  /// Alternative: Make request through ApiService's Dio
  Future<dynamic> _makeAuthenticatedRequest(String path) async {
    // Since ApiService doesn't expose its Dio, we'll use the existing
    // getAdvertiserProfile pattern which works with auth
    final dio = await _getDioInstance();
    return await dio.get(path);
  }

  Future<dynamic> _getDioInstance() async {
    // This is a workaround - we need to access the Dio instance
    // For now, we'll create our own with token from SharedPreferences

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    return dio;
  }
}
