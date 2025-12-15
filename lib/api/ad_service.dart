import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injera/models/Comment.dart';
import 'package:injera/models/ad_video_model.dart' hide Comment;
import 'package:injera/api/config.dart';

import 'package:injera/utils/storage_service.dart';

class AdService {
  static Future<String?> _getToken() async {
    final storage = await StorageService.getInstance();
    return storage.getToken();
  }

  static Future<FeedResponse> fetchAdsFeed({String? cursor}) async {
    try {
      final Uri uri = cursor != null && cursor.isNotEmpty
          ? Uri.parse('${ApiConfig.baseUrl}/ads/feed?cursor=$cursor')
          : Uri.parse('${ApiConfig.baseUrl}/ads/feed');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FeedResponse.fromJson(data);
      } else {
        throw Exception('Failed to load ads feed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch ads: $e');
    }
  }

  static Future<TrackResponse> trackVideoView({required String adId}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ads/$adId/view');
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'watched_percentage': 100}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return TrackResponse.fromJson(data);
      } else {
        throw Exception('Failed to track view: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to track video view: $e');
    }
  }

  static Future<CommentsResponse> getComments(
    String adId, {
    int page = 1,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/ads/$adId/comments?page=$page',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CommentsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  // Add comment to an ad
  static Future<AddCommentResponse> addComment(
    String adId,
    String comment,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ads/$adId/comment');

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'comment': comment}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return AddCommentResponse.fromJson(data);
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  static Future<AddReplyResponse> addReply(
    String adId,
    String commentId,
    String reply,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/ads/$adId/comments/$commentId/reply',
      );

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('Sending reply to: ${uri.toString()}'); // Debug log
      print('Reply data: $reply'); // Debug log

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'reply': reply}),
          )
          .timeout(const Duration(seconds: 10));

      print('Reply response status: ${response.statusCode}'); // Debug log
      print('Reply response body: ${response.body}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return AddReplyResponse.fromJson(data);
      } else {
        throw Exception(
          'Failed to add reply: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Reply error: $e'); // Debug log
      throw Exception('Failed to add reply: $e');
    }
  }

  static Future<UserPointsResponse> getUserPoints() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/user/points');
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return UserPointsResponse(points: 0);
      }

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserPointsResponse.fromJson(data);
      } else {
        throw Exception('Failed to get points: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user points: $e');
    }
  }
}

// Fetch comments for an ad

// All model classes remain the same (TrackResponse, UserPointsResponse, AdVideo, Advertiser, Category, Tag, Comment, FeedResponse)
// Copy them exactly as in your original code if not already present.

class CommentsResponse {
  final bool success;
  final String message;
  final String adId;
  final int commentCount;
  final List<Comment> comments;
  final PaginationInfo pagination;

  CommentsResponse({
    required this.success,
    required this.message,
    required this.adId,
    required this.commentCount,
    required this.comments,
    required this.pagination,
  });

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    return CommentsResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      adId: json['ad_id']?.toString() ?? '',
      commentCount: json['comment_count'] is int ? json['comment_count'] : 0,
      comments: (json['data']['data'] as List? ?? [])
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      pagination: PaginationInfo.fromJson(json['data']),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginationInfo({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] is int ? json['current_page'] : 1,
      lastPage: json['last_page'] is int ? json['last_page'] : 1,
      perPage: json['per_page'] is int ? json['per_page'] : 20,
      total: json['total'] is int ? json['total'] : 0,
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}

class AddCommentResponse {
  final String message;
  final Comment comment;

  AddCommentResponse({required this.message, required this.comment});

  factory AddCommentResponse.fromJson(Map<String, dynamic> json) {
    return AddCommentResponse(
      message: json['message']?.toString() ?? '',
      comment: Comment.fromJson(json['comment'] ?? {}),
    );
  }
}

class AddReplyResponse {
  final String message;
  final CommentReply reply;

  AddReplyResponse({required this.message, required this.reply});

  factory AddReplyResponse.fromJson(Map<String, dynamic> json) {
    return AddReplyResponse(
      message: json['message']?.toString() ?? '',
      reply: CommentReply.fromJson(json['reply'] ?? {}),
    );
  }
}

class TrackResponse {
  final bool success;
  final bool rewarded;
  final int pointsEarned;
  final int totalPoints;
  final String message;

  const TrackResponse({
    required this.success,
    required this.rewarded,
    required this.pointsEarned,
    required this.totalPoints,
    required this.message,
  });

  factory TrackResponse.fromJson(Map<String, dynamic> json) {
    return TrackResponse(
      success: json['success'] ?? false,
      rewarded: json['rewarded'] ?? false,
      pointsEarned: json['points_earned'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class UserPointsResponse {
  final int points;

  UserPointsResponse({required this.points});

  factory UserPointsResponse.fromJson(Map<String, dynamic> json) {
    return UserPointsResponse(points: json['points'] ?? 0);
  }
}
