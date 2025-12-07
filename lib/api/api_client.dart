import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiClient {
  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final defaultHeaders = {'Content-Type': 'application/json'};

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return await http.post(
      url,
      headers: defaultHeaders,
      body: json.encode(body),
    );
  }

  // You can add GET, PUT, DELETE methods here as needed
}
