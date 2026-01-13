import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injera/api/config.dart';
import 'package:injera/api/api_client.dart';
import 'package:injera/models/ad_video_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SearchService {
  final ApiClient _client = ApiClient();

  Future<SearchResponse> searchVideos({
    required String query,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(
        '/seach-video/$query',
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 404) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> videosData = data['data'] ?? [];
          final pagination = data['pagination'] ?? {};

          final videos = videosData.map<AdVideo>((video) {
            return AdVideo.fromJson(video);
          }).toList();

          return SearchResponse(
            videos: videos,
            currentPage: pagination['current_page'] ?? page,
            lastPage: pagination['last_page'] ?? 1,
            perPage: pagination['per_page'] ?? perPage,
            total: pagination['total'] ?? videos.length,
            hasMore: pagination['has_more_pages'] ?? false,
          );
        } else {
          throw Exception(data['message'] ?? 'Search failed');
        }
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return [];
      }

      Map<String, String> headers = {'Authorization': 'Bearer $token'};

      final response = await _client.get('/recent-searches', headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> searches = data['data'] ?? [];
          return searches.map<String>((search) => search.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching recent searches: $e');
      return [];
    }
  }
}

class SearchResponse {
  final List<AdVideo> videos;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  SearchResponse({
    required this.videos,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });
}
