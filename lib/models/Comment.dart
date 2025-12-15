// lib/models/comment_model.dart
class Comment {
  final String id;
  final String adId;
  final String userId;
  final String comment;
  final DateTime createdAt;
  final CommentUser user;
  final List<CommentReply> replies;

  Comment({
    required this.id,
    required this.adId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.user,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    var repliesList = json['replies'] as List? ?? [];
    List<CommentReply> replies = repliesList
        .map((r) => CommentReply.fromJson(r))
        .toList();

    return Comment(
      id: json['id']?.toString() ?? '',
      adId: json['ad_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      user: CommentUser.fromJson(json['user'] ?? {}),
      replies: replies,
    );
  }
}

class CommentUser {
  final String id;
  final String username;
  final String profilePicture;

  CommentUser({
    required this.id,
    required this.username,
    required this.profilePicture,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    // Handle the quoted key issue from your API
    String profilePic = '';

    // Try multiple possible key formats
    if (json['"profile_picture"'] != null) {
      profilePic = json['"profile_picture"']?.toString() ?? '';
    } else if (json['profile_picture'] != null) {
      profilePic = json['profile_picture']?.toString() ?? '';
    }

    return CommentUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profilePicture: profilePic,
    );
  }
}

class CommentReply {
  final String id;
  final String commentId;
  final String userId;
  final String reply;
  final DateTime createdAt;
  final CommentUser user;

  CommentReply({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.reply,
    required this.createdAt,
    required this.user,
  });

  factory CommentReply.fromJson(Map<String, dynamic> json) {
    return CommentReply(
      id: json['id']?.toString() ?? '',
      commentId: json['ad_comment_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      reply: json['reply']?.toString() ?? '',
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      user: CommentUser.fromJson(json['user'] ?? {}),
    );
  }
}
