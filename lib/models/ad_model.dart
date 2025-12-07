// models/ad_video.dart
class AdVideo {
  final String id;
  final String title;
  final String videoUrl;
  final String advertiserId;
  final String categoryId;
  final int viewCount;
  final int commentCount;
  final int? duration;
  final DateTime createdAt;
  final Advertiser advertiser;
  final Category category;
  final List<Tag> tags;
  final List<Comment> comments;

  AdVideo({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.advertiserId,
    required this.categoryId,
    required this.viewCount,
    required this.commentCount,
    this.duration,
    required this.createdAt,
    required this.advertiser,
    required this.category,
    required this.tags,
    required this.comments,
  });

  factory AdVideo.fromJson(Map<String, dynamic> json) {
    return AdVideo(
      id: json['id'],
      title: json['title'],
      videoUrl: json['video_url'],
      advertiserId: json['advertiser_id'],
      categoryId: json['category_id'],
      viewCount: json['view_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      duration: json['duration'],
      createdAt: DateTime.parse(json['created_at']),
      advertiser: Advertiser.fromJson(json['advertiser']),
      category: Category.fromJson(json['category']),
      tags: (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList(),
      comments: (json['comments'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList(),
    );
  }
}

class Advertiser {
  final String id;
  final String username;
  final String? profilePicture;

  Advertiser({required this.id, required this.username, this.profilePicture});

  factory Advertiser.fromJson(Map<String, dynamic> json) {
    // Fix the escaped quotes in the profile picture field
    String? profilePic;
    if (json.containsKey('"profile_picture"')) {
      profilePic = json['"profile_picture"'];
    } else if (json.containsKey('profile_picture')) {
      profilePic = json['profile_picture'];
    }

    return Advertiser(
      id: json['id'],
      username: json['username'],
      profilePicture: profilePic,
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name']);
  }
}

class Tag {
  final String id;
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(id: json['id'], name: json['name']);
  }
}

class Comment {
  final String id;
  final String userId;
  final String comment;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.comment,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
