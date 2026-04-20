// lib/services/payment_service.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:injera/api/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  Dio? _dio;
  String? _currentTxRef;
  Timer? _pollingTimer;
  String? _currentPageTitle;

  // Callback for payment status updates
  Function(Map<String, dynamic>)? onPaymentSuccess;
  Function(String)? onPaymentFailed;
  Function(String)? onPaymentPending;

  Future<void> _ensureDio() async {
    if (_dio == null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
    }
  }

  /// Step 1: Initialize deposit and get checkout URL
  Future<Map<String, dynamic>> initializeDeposit({
    required double amount,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    await _ensureDio();

    try {
      debugPrint('💰 Initializing deposit: $amount ETB');

      final response = await _dio!.post(
        '/deposit',
        data: {
          'amount': amount,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        },
      );

      debugPrint('Deposit response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'success' && data['data'] != null) {
          final checkoutUrl = data['data']['checkout_url'];

          // Extract tx_ref from checkout URL
          final txRef = _extractTxRefFromUrl(checkoutUrl);
          _currentTxRef = txRef;

          debugPrint('✅ Checkout URL: $checkoutUrl');
          debugPrint('✅ Extracted tx_ref: $txRef');

          return {
            'success': true,
            'checkout_url': checkoutUrl,
            'tx_ref': txRef,
          };
        }
      }

      return {'success': false, 'message': 'Failed to initialize deposit'};
    } on DioException catch (e) {
      debugPrint('❌ Initialize deposit error: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Step 2: Open Chapa payment WebView (FIXED VERSION)
  Future<bool> openPaymentWebView(
    BuildContext context,
    String checkoutUrl,
  ) async {
    final Completer<bool> completer = Completer<bool>();

    // Enable WebView debugging

    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('🌐 WebView page started: $url');

            // Update title based on URL
            if (url.contains('checkout.chapa.co')) {
              _currentPageTitle = 'Chapa Payment';
            } else if (url.contains('success')) {
              _currentPageTitle = 'Payment Success';
            } else if (url.contains('cancel')) {
              _currentPageTitle = 'Payment Cancelled';
            }

            // Try to capture tx_ref from URL
            if (_currentTxRef == null) {
              final txRef = _extractTxRefFromUrl(url);
              if (txRef != null) {
                _currentTxRef = txRef;
                debugPrint('✅ Captured tx_ref from URL: $_currentTxRef');
              }
            }

            // Check if payment is completed
            if (url.contains('success') ||
                url.contains('complete') ||
                url.contains('payment-success')) {
              debugPrint('🎉 Payment completion page detected!');
              _handlePaymentCompletion(completer, context);
            }

            // Check if payment was cancelled
            if (url.contains('cancel') || url.contains('failed')) {
              debugPrint('❌ Payment cancelled or failed');
              if (!completer.isCompleted) {
                completer.complete(false);
                Navigator.pop(context);
              }
            }
          },

          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔗 Navigation request: ${request.url}');

            // Allow all navigation
            return NavigationDecision.navigate;
          },

          onPageFinished: (String url) {
            debugPrint('✅ Page finished loading: $url');

            // Final attempt to capture tx_ref
            if (_currentTxRef == null) {
              final txRef = _extractTxRefFromUrl(url);
              if (txRef != null) {
                _currentTxRef = txRef;
                debugPrint('✅ Late capture of tx_ref: $_currentTxRef');
              }
            }
          },

          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebResourceError: ${error.description}');
          },
        ),
      )
      ..loadRequest(
        Uri.parse(checkoutUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
        },
      );

    // Show WebView dialog with improved UI
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return WillPopScope(
            onWillPop: () async {
              if (!completer.isCompleted) {
                completer.complete(false);
              }
              return true;
            },
            child: Dialog(
              insetPadding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: Column(
                  children: [
                    // Custom AppBar with white background and dynamic title
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              _stopPolling();
                              if (!completer.isCompleted) {
                                completer.complete(false);
                              }
                              Navigator.pop(context);
                            },
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPageTitle ?? 'Chapa Payment',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Secure Payment',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.black87,
                            ),
                            onPressed: () async {
                              await controller.reload();
                            },
                          ),
                        ],
                      ),
                    ),
                    // WebView
                    Expanded(child: WebViewWidget(controller: controller)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    return completer.future;
  }

  /// Handle payment completion - check status via backend
  Future<void> _handlePaymentCompletion(
    Completer<bool> completer,
    BuildContext context,
  ) async {
    if (_currentTxRef == null) {
      debugPrint('⚠️ Cannot verify payment: No tx_ref captured');
      if (!completer.isCompleted) {
        completer.complete(false);
        if (context.mounted) Navigator.pop(context);
      }
      return;
    }

    debugPrint('🔍 Verifying payment for tx_ref: $_currentTxRef');
    _startPolling(completer, context);
  }

  /// Poll backend for payment status
  void _startPolling(Completer<bool> completer, BuildContext context) {
    int attempts = 0;
    const maxAttempts = 30; // 90 seconds

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      attempts++;
      debugPrint('🔄 Polling payment status... Attempt $attempts/$maxAttempts');

      final status = await checkPaymentStatus(_currentTxRef!);

      if (status['status'] == 'success') {
        timer.cancel();
        _pollingTimer = null;

        if (!completer.isCompleted && context.mounted) {
          completer.complete(true);
          Navigator.pop(context); // Close WebView
          _showSuccessDialog(context, status['amount'] ?? 0);
          if (onPaymentSuccess != null) onPaymentSuccess!(status);
        }
      } else if (status['status'] == 'failed') {
        timer.cancel();
        _pollingTimer = null;

        if (!completer.isCompleted && context.mounted) {
          completer.complete(false);
          Navigator.pop(context);
          if (onPaymentFailed != null) onPaymentFailed!('Payment failed');
        }
      } else if (attempts >= maxAttempts) {
        timer.cancel();
        _pollingTimer = null;

        if (!completer.isCompleted && context.mounted) {
          completer.complete(false);
          Navigator.pop(context);
          if (onPaymentPending != null)
            onPaymentPending!('Payment verification timeout');
        }
      }
    });
  }

  /// Check payment status from backend
  Future<Map<String, dynamic>> checkPaymentStatus(String txRef) async {
    await _ensureDio();

    try {
      final response = await _dio!.get(
        '/check-payment-status',
        queryParameters: {'tx_ref': txRef},
      );

      debugPrint('Payment status response: ${response.data}');

      if (response.statusCode == 200) {
        return {
          'status': response.data['status'] ?? 'pending',
          'balance': response.data['balance'] ?? 0,
          'amount': response.data['amount'] ?? 0,
        };
      }
      return {'status': 'pending'};
    } on DioException catch (e) {
      debugPrint('❌ Check status error: ${e.message}');
      return {'status': 'pending'};
    }
  }

  /// Get wallet balance - FIXED
  Future<double> getWalletBalance() async {
    await _ensureDio();

    try {
      final response = await _dio!.get('/wallet/balance');
      debugPrint('Wallet balance raw response: ${response.data}');
      debugPrint('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // FIXED: Access as Map, not object
        final balance = response.data['balance'] ?? 0;
        debugPrint('Extracted balance: $balance');
        return balance.toDouble();
      }
      return 0.0;
    } on DioException catch (e) {
      debugPrint('❌ Get balance error: ${e.message}');
      if (e.response != null) {
        debugPrint('Error response data: ${e.response?.data}');
      }
      return 0.0;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return 0.0;
    }
  }

  /// Debug transaction
  Future<Map<String, dynamic>> debugTransaction(String txRef) async {
    await _ensureDio();
    try {
      final response = await _dio!.get('/debug-transaction/$txRef');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ Debug error: ${e.message}');
      return {'error': e.message};
    }
  }

  /// Extract tx_ref from Chapa URL
  String? _extractTxRefFromUrl(String url) {
    try {
      debugPrint('📝 Extracting tx_ref from: $url');

      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        if (lastSegment.length > 30 && lastSegment.length < 100) {
          debugPrint('📝 Extracted tx_ref from path: $lastSegment');
          return lastSegment;
        }
      }

      if (uri.queryParameters.containsKey('tx_ref')) {
        final txRef = uri.queryParameters['tx_ref'];
        debugPrint('📝 Extracted tx_ref from query: $txRef');
        return txRef;
      }

      final pattern = RegExp(r'[A-Za-z0-9]{40,}');
      final match = pattern.firstMatch(url);
      if (match != null) {
        debugPrint('📝 Extracted tx_ref via regex: ${match.group(0)}');
        return match.group(0);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error extracting tx_ref: $e');
      return null;
    }
  }

  /// Show success dialog
  void _showSuccessDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '$amount ETB',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Text('has been added to your wallet'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void dispose() {
    _stopPolling();
    _dio?.close();
  }
}
