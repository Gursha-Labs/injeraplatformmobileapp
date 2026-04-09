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
  
  // Callback for payment status updates
  Function(Map<String, dynamic>)? onPaymentSuccess;
  Function(String)? onPaymentFailed;
  Function(String)? onPaymentPending;

  Future<void> _ensureDio() async {
    if (_dio == null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      _dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ));
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
      
      final response = await _dio!.post('/deposit', data: {
        'amount': amount,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      });
      
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
      
      return {
        'success': false,
        'message': 'Failed to initialize deposit',
      };
    } on DioException catch (e) {
      debugPrint('❌ Initialize deposit error: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Step 2: Open Chapa payment WebView
  Future<bool> openPaymentWebView(BuildContext context, String checkoutUrl) async {
    final Completer<bool> completer = Completer<bool>();
    
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('🌐 WebView page started: $url');
            
            // Try to capture tx_ref from URL
            if (_currentTxRef == null) {
              final txRef = _extractTxRefFromUrl(url);
              if (txRef != null) {
                _currentTxRef = txRef;
                debugPrint('✅ Captured tx_ref from URL: $_currentTxRef');
              }
            }
            
            // Check if payment is completed (success page)
            if (url.contains('success') || 
                url.contains('complete') || 
                url.contains('payment-success') ||
                url.contains('return')) {
              debugPrint('🎉 Payment completion page detected!');
              _handlePaymentCompletion(completer, context);
            }
          },
          
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔗 Navigation request: ${request.url}');
            
            // Capture tx_ref from navigation URL
            if (_currentTxRef == null) {
              final txRef = _extractTxRefFromUrl(request.url);
              if (txRef != null) {
                _currentTxRef = txRef;
                debugPrint('✅ Captured tx_ref from navigation: $_currentTxRef');
              }
            }
            
            // Check for payment completion
            if (request.url.contains('success') || 
                request.url.contains('complete') ||
                request.url.contains('payment-success')) {
              
              debugPrint('🎉 Payment completion detected during navigation!');
              _handlePaymentCompletion(completer, context);
              return NavigationDecision.prevent;
            }
            
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
          
          onUrlChange: (UrlChange change) {
            debugPrint('🔄 URL changed to: ${change.url}');
            if (change.url != null && _currentTxRef == null) {
              final txRef = _extractTxRefFromUrl(change.url!);
              if (txRef != null) {
                _currentTxRef = txRef;
                debugPrint('✅ Captured tx_ref from URL change: $_currentTxRef');
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(checkoutUrl));
    
    // Show WebView dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
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
            child: Column(
              children: [
                AppBar(
                  title: const Text(
                    'Complete Payment',
                    style: TextStyle(fontSize: 18),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _stopPolling();
                      if (!completer.isCompleted) {
                        completer.complete(false);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        await controller.reload();
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: WebViewWidget(controller: controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    return completer.future;
  }

  /// Handle payment completion - check status via backend
  Future<void> _handlePaymentCompletion(Completer<bool> completer, BuildContext context) async {
    if (_currentTxRef == null) {
      debugPrint('⚠️ Cannot verify payment: No tx_ref captured');
      if (!completer.isCompleted) {
        completer.complete(false);
        Navigator.pop(context);
      }
      return;
    }
    
    debugPrint('🔍 Verifying payment for tx_ref: $_currentTxRef');
    
    // Start polling for payment status
    _startPolling(completer, context);
  }

  /// Poll backend for payment status
  void _startPolling(Completer<bool> completer, BuildContext context) {
    int attempts = 0;
    const maxAttempts = 20; // 20 attempts = 60 seconds (3 seconds each)
    
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      attempts++;
      debugPrint('🔄 Polling payment status... Attempt $attempts/$maxAttempts');
      
      final status = await checkPaymentStatus(_currentTxRef!);
      
      if (status['status'] == 'success') {
        // Payment successful
        timer.cancel();
        _pollingTimer = null;
        
        if (!completer.isCompleted) {
          completer.complete(true);
          Navigator.pop(context); // Close WebView
          
          // Show success dialog
          _showSuccessDialog(context, status['amount'] ?? 0);
          
          // Trigger callback
          if (onPaymentSuccess != null) {
            onPaymentSuccess!(status);
          }
        }
      } else if (status['status'] == 'failed') {
        // Payment failed
        timer.cancel();
        _pollingTimer = null;
        
        if (!completer.isCompleted) {
          completer.complete(false);
          Navigator.pop(context);
          
          if (onPaymentFailed != null) {
            onPaymentFailed!('Payment failed');
          }
        }
      } else if (attempts >= maxAttempts) {
        // Timeout
        timer.cancel();
        _pollingTimer = null;
        
        if (!completer.isCompleted) {
          completer.complete(false);
          Navigator.pop(context);
          
          if (onPaymentPending != null) {
            onPaymentPending!('Payment verification timeout');
          }
        }
      }
    });
  }

  /// Check payment status from backend
  Future<Map<String, dynamic>> checkPaymentStatus(String txRef) async {
    await _ensureDio();
    
    try {
      final response = await _dio!.get('/check-payment-status', queryParameters: {
        'tx_ref': txRef,
      });
      
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

  /// Manually process payment (fallback)
  Future<Map<String, dynamic>> processPaymentManually(String txRef) async {
    await _ensureDio();
    
    try {
      final response = await _dio!.post('/process-payment-manually', data: {
        'tx_ref': txRef,
      });
      
      return {
        'success': response.data['success'] ?? false,
        'balance': response.data['balance'] ?? 0,
        'amount': response.data['amount'] ?? 0,
        'error': response.data['error'],
      };
    } on DioException catch (e) {
      debugPrint('❌ Manual process error: ${e.message}');
      return {'success': false, 'error': e.message};
    }
  }

  /// Get wallet balance
  Future<double> getWalletBalance() async {
    await _ensureDio();
    
    try {
      final response = await _dio!.get('/wallet/balance');
      
      if (response.statusCode == 200) {
        return (response.data['balance'] ?? 0).toDouble();
      }
      return 0.0;
    } on DioException catch (e) {
      debugPrint('❌ Get balance error: ${e.message}');
      return 0.0;
    }
  }

  /// Debug transaction (for troubleshooting)
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
      // Method 1: Path segments
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        // Check if it looks like a tx_ref (alphanumeric, underscores, length > 15)
        if (lastSegment.contains('_') || 
            (lastSegment.length > 20 && lastSegment.length < 100)) {
          debugPrint('📝 Extracted tx_ref from path: $lastSegment');
          return lastSegment;
        }
      }
      
      // Method 2: Query parameters
      if (uri.queryParameters.containsKey('tx_ref')) {
        final txRef = uri.queryParameters['tx_ref'];
        debugPrint('📝 Extracted tx_ref from query: $txRef');
        return txRef;
      }
      
      // Method 3: Regex pattern
      final pattern = RegExp(r'tx_[a-zA-Z0-9_]+');
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('has been added to your wallet'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Stop polling timer
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Dispose service
  void dispose() {
    _stopPolling();
    _dio?.close();
  }
}