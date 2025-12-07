// services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryService {
  static const String baseUrl = 'http://192.168.137.1:8000/api';
  static const Duration timeout = Duration(seconds: 15);

  Future<List<Category>> fetchCategories({String? authToken}) async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      // Add auth token if provided
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http
          .get(Uri.parse('$baseUrl/categories'), headers: headers)
          .timeout(timeout);

      print('Category API Status: ${response.statusCode}');
      print('Category API Response: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Handle different response formats
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          return data.map((item) => Category.fromJson(item)).toList();
        } else if (responseData is List) {
          return responseData.map((item) => Category.fromJson(item)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to load categories: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      print('Network error: $e');
      throw Exception('Network error: $e');
    } catch (e) {
      print('Category fetch error: $e');
      throw Exception('Failed to load categories: $e');
    }
  }
}
