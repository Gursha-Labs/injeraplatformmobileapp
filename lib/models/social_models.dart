// models/social_models.dart
import 'package:injera/models/user_models.dart';

class Comment {
  final String id;
  final String userId;
  final String videoId;
  final String text;
  final int likeCount;
  final DateTime createdAt;
  final User? user;

  Comment({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.text,
    required this.likeCount,
    required this.createdAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      videoId: json['video_id'],
      text: json['text'],
      likeCount: json['like_count'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Like {
  final String id;
  final String userId;
  final String commentId;

  Like({required this.id, required this.userId, required this.commentId});

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      userId: json['user_id'],
      commentId: json['comment_id'],
    );
  }
}

class ViewedVideo {
  final String id;
  final String userId;
  final String videoId;
  final int watchedDuration;
  final bool completed;
  final DateTime createdAt;

  ViewedVideo({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.watchedDuration,
    required this.completed,
    required this.createdAt,
  });

  factory ViewedVideo.fromJson(Map<String, dynamic> json) {
    return ViewedVideo(
      id: json['id'],
      userId: json['user_id'],
      videoId: json['video_id'],
      watchedDuration: json['watched_duration'],
      completed: json['completed'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class FavoriteVideo {
  final String id;
  final String userId;
  final String videoId;
  final DateTime createdAt;

  FavoriteVideo({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.createdAt,
  });

  factory FavoriteVideo.fromJson(Map<String, dynamic> json) {
    return FavoriteVideo(
      id: json['id'],
      userId: json['user_id'],
      videoId: json['video_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
