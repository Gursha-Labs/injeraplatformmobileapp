import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiClient {
  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    // Create headers with defaults
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    try {
      print('🌐 API Request: POST $url');
      print('📦 Request Body: ${json.encode(body)}');

      // Make the request with timeout
      final response = await http
          .post(url, headers: requestHeaders, body: json.encode(body))
          .timeout(timeout);

      print('✅ API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      // Return response regardless of status code
      // Let the calling code handle 400, 422, etc.
      return response;
    } on TimeoutException catch (_) {
      print('⏰ Request timeout for $url');
      rethrow; // Re-throw so AuthNotifier can handle it
    } on http.ClientException catch (e) {
      print('❌ ClientException for $url: ${e.message}');
      // Don't wrap in another ClientException - just rethrow
      rethrow;
    } catch (e) {
      print('⚠️ Unexpected error in ApiClient: $e');
      // Wrap other exceptions as ClientException for consistency
      throw http.ClientException('Request failed for $url: $e');
    }
  }

  // GET method added here with same error handling pattern
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    // Create headers with defaults
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    try {
      print('🌐 API Request: GET $url');

      // Make the request with timeout
      final response = await http
          .get(url, headers: requestHeaders)
          .timeout(timeout);

      print('✅ API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      // Return response regardless of status code
      // Let the calling code handle 400, 422, etc.
      return response;
    } on TimeoutException catch (_) {
      print('⏰ Request timeout for $url');
      rethrow; // Re-throw so calling code can handle it
    } on http.ClientException catch (e) {
      print('❌ ClientException for $url: ${e.message}');
      // Don't wrap in another ClientException - just rethrow
      rethrow;
    } catch (e) {
      print('⚠️ Unexpected error in ApiClient GET: $e');
      // Wrap other exceptions as ClientException for consistency
      throw http.ClientException('GET request failed for $url: $e');
    }
  }

  // Optional: Add PUT method if needed
  Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    try {
      print('🌐 API Request: PUT $url');
      print('📦 Request Body: ${json.encode(body)}');

      final response = await http
          .put(url, headers: requestHeaders, body: json.encode(body))
          .timeout(timeout);

      print('✅ API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      return response;
    } on TimeoutException catch (_) {
      print('⏰ Request timeout for $url');
      rethrow;
    } on http.ClientException catch (e) {
      print('❌ ClientException for $url: ${e.message}');
      rethrow;
    } catch (e) {
      print('⚠️ Unexpected error in ApiClient PUT: $e');
      throw http.ClientException('PUT request failed for $url: $e');
    }
  }

  // Optional: Add DELETE method if needed
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    try {
      print('🌐 API Request: DELETE $url');

      final response = await http
          .delete(url, headers: requestHeaders)
          .timeout(timeout);

      print('✅ API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      return response;
    } on TimeoutException catch (_) {
      print('⏰ Request timeout for $url');
      rethrow;
    } on http.ClientException catch (e) {
      print('❌ ClientException for $url: ${e.message}');
      rethrow;
    } catch (e) {
      print('⚠️ Unexpected error in ApiClient DELETE: $e');
      throw http.ClientException('DELETE request failed for $url: $e');
    }
  }

  // Optional: Add PATCH method if needed
  Future<http.Response> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    try {
      print('🌐 API Request: PATCH $url');
      print('📦 Request Body: ${json.encode(body)}');

      final response = await http
          .patch(url, headers: requestHeaders, body: json.encode(body))
          .timeout(timeout);

      print('✅ API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      return response;
    } on TimeoutException catch (_) {
      print('⏰ Request timeout for $url');
      rethrow;
    } on http.ClientException catch (e) {
      print('❌ ClientException for $url: ${e.message}');
      rethrow;
    } catch (e) {
      print('⚠️ Unexpected error in ApiClient PATCH: $e');
      throw http.ClientException('PATCH request failed for $url: $e');
    }
  }
}
