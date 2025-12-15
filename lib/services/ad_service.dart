import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:injera/api/config.dart';
import 'package:injera/utils/storage_service.dart';

import '../models/ad_video_model.dart';

final adServiceProvider = Provider((ref) => AdService());

class AdService {
  Future<String?> _getToken() async {
    final storage = await StorageService.getInstance();
    return storage.getToken();
  }

  Future<FeedResponse> fetchFeed({String? cursor}) async {
    final token = await _getToken();
    final endpoint = cursor != null
        ? '${ApiConfig.baseUrl}/ads/feed?cursor=$cursor'
        : '${ApiConfig.baseUrl}/ads/feed';

    final response = await http.get(
      Uri.parse(endpoint),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load videos');
    }

    final json = jsonDecode(response.body);
    return FeedResponse.fromJson(json);
  }

  Future<void> trackView(String adId, int percentage) async {
    final token = await _getToken();
    if (token == null) return;

    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ads/$adId/view'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'watched_percentage': percentage}),
    );
  }

  Future<int> getPoints() async {
    final token = await _getToken();
    if (token == null) return 0;

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user/points'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['points'] ?? 0;
    }
    return 0;
  }
}
