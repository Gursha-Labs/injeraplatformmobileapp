import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injera/models/ad_feed_response.dart';
import '../models/ad_model.dart';

class AdService {
  static const String baseUrl = 'http://192.168.137.1:8000/api';

  Future<AdFeedResponse> getAdFeed({String? cursor}) async {
    final url = Uri.parse(
      '$baseUrl/ads/feed${cursor != null ? '?cursor=$cursor' : ''}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AdFeedResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load ads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load ads: $e');
    }
  }
}
