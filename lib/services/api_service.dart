// services/api_service.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:injera/models/ad_feed_response.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.137.1:8000/api';

  Future<AdFeedResponse> getAdsFeed({String? cursor}) async {
    try {
      final queryParams = cursor != null ? '?cursor=$cursor' : '';
      final url = Uri.parse('$_baseUrl/ads/feed$queryParams');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return AdFeedResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load ads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Add other API methods as needed
  Future<void> trackAdView(String adId) async {
    try {
      final url = Uri.parse('$_baseUrl/ads/$adId/view');
      await http.post(url);
    } catch (e) {
      // Silent fail for view tracking
      print('Failed to track view: $e');
    }
  }

  Future<int> getUserPoints() async {
    try {
      final url = Uri.parse('$_baseUrl/user/points');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['points'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}

final apiServiceProvider = Provider((ref) => ApiService());
