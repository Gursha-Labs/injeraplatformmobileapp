// services/spin_game_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/config.dart';
import '../models/spin_game/reward_model.dart';
import '../models/spin_game/spin_response.dart';
import '../models/spin_game/game_variables.dart';

class SpinGameService {
  // Get authentication headers with token from SharedPreferences
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all available rewards
  Future<List<RewardModel>> getRewards() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.rewards}'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RewardModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rewards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rewards: $e');
    }
  }

  // Get game variables (bet points, etc.)
  Future<GameVariables> getGameVariables() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.gameVariables}'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return GameVariables.fromJson(data.first);
        }
        throw Exception('No game variables found');
      } else {
        throw Exception(
          'Failed to load game variables: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching game variables: $e');
    }
  }

  // Perform spin
  Future<SpinResponse> spin() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.spinWheel}'),
            headers: headers,
            body: json.encode({
              'game_id':
                  'spin-wheel', // or the actual game ID from your backend
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return SpinResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Insufficient points');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('You are not allowed to play this game');
      } else {
        throw Exception('Failed to spin: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during spin: $e');
    }
  }

  // Get user points (optional, if you need to refresh points)
  Future<int> getUserPoints() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiEndpoints.userPoints}'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['points'] ?? 0;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to get user points');
      }
    } catch (e) {
      throw Exception('Error fetching user points: $e');
    }
  }
}
