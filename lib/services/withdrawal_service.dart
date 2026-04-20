// lib/services/withdrawal_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injera/api/api_service.dart';
import 'package:injera/models/withdrawal.dart.dart';

class WithdrawalService {
  final ApiService _apiService = ApiService();

  // Available withdrawal methods for users
  static const List<String> withdrawalMethods = [
    'telebirr',
    'mpesa',
    'cbe_wallet',
    'cbe',
    'awash_bank',
    'dashen_bank',
    'boa',
  ];

  /// Get user's withdrawal requests (their own only)
  Future<List<Withdrawal>> getUserWithdrawals({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      // Call the same index endpoint but backend filters by user_id automatically
      final response = await _apiService.dio.get(
        '/withdrawals',
        queryParameters: {'page': page, 'size': perPage},
      );

      debugPrint('Withdrawals response: ${response.statusCode}');
      debugPrint('Withdrawals data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle paginated response
        if (data['data'] != null) {
          final List<dynamic> items = data['data']['data'] ?? data['data'];
          if (items is List) {
            return items.map((json) => Withdrawal.fromJson(json)).toList();
          }
        }

        // Handle direct list response
        if (data is List) {
          return data.map((json) => Withdrawal.fromJson(json)).toList();
        }

        return [];
      }

      throw Exception('Failed to load withdrawals: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Get withdrawals error: ${e.message}');
      debugPrint('Error response: ${e.response?.data}');
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Create a new withdrawal request
  Future<Withdrawal> createWithdrawal({
    required double amount,
    required String withdrawalMethod,
    required String accountNumber,
    required String accountName,
    String? currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate amount
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      // Validate withdrawal method
      if (!withdrawalMethods.contains(withdrawalMethod)) {
        throw Exception('Invalid withdrawal method');
      }

      // Validate account details
      if (accountNumber.isEmpty) {
        throw Exception('Account number is required');
      }

      if (accountName.isEmpty) {
        throw Exception('Account name is required');
      }

      final requestData = {
        'amount': amount,
        'withdrawal_method': withdrawalMethod,
        'account_number': accountNumber,
        'account_name': accountName,
        if (currency != null) 'currency': currency.toUpperCase(),
        if (metadata != null) 'metadata': metadata,
      };

      debugPrint('Creating withdrawal: $requestData');

      final response = await _apiService.dio.post(
        '/withdrawals',
        data: requestData,
      );

      debugPrint('Create withdrawal response: ${response.statusCode}');
      debugPrint('Create withdrawal data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Handle different response structures
        if (data['data'] != null) {
          return Withdrawal.fromJson(data['data']);
        }

        return Withdrawal.fromJson(data);
      }

      throw Exception('Failed to create withdrawal: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Create withdrawal error: ${e.message}');
      debugPrint('Error response: ${e.response?.data}');

      // Handle insufficient balance error
      if (e.response?.statusCode == 422) {
        final message = e.response?.data['message'] ?? 'Insufficient balance';
        throw Exception(message);
      }

      throw Exception(_getErrorMessage(e));
    }
  }

  /// Cancel a pending withdrawal request
  Future<Withdrawal> cancelWithdrawal(String withdrawalId) async {
    try {
      final response = await _apiService.dio.delete(
        '/withdrawals/$withdrawalId',
      );

      debugPrint('Cancel withdrawal response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['data'] != null) {
          return Withdrawal.fromJson(data['data']);
        }

        return Withdrawal.fromJson(data);
      }

      throw Exception('Failed to cancel withdrawal: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Cancel withdrawal error: ${e.message}');

      if (e.response?.statusCode == 422) {
        throw Exception('Only pending withdrawals can be cancelled');
      }

      if (e.response?.statusCode == 403) {
        throw Exception('You can only cancel your own withdrawals');
      }

      throw Exception(_getErrorMessage(e));
    }
  }

  /// Get single withdrawal details
  Future<Withdrawal> getWithdrawal(String withdrawalId) async {
    try {
      final response = await _apiService.dio.get('/withdrawals/$withdrawalId');

      debugPrint('Get withdrawal response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['data'] != null) {
          return Withdrawal.fromJson(data['data']);
        }

        return Withdrawal.fromJson(data);
      }

      throw Exception('Failed to load withdrawal: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Get withdrawal error: ${e.message}');

      if (e.response?.statusCode == 403) {
        throw Exception('You can only view your own withdrawals');
      }

      if (e.response?.statusCode == 404) {
        throw Exception('Withdrawal not found');
      }

      throw Exception(_getErrorMessage(e));
    }
  }

  String _getErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      if (data is Map) {
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['error'] != null) {
          return data['error'].toString();
        }
      }
    }
    return e.message ?? 'An error occurred';
  }
}
