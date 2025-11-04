// models/video_models.dart
class AdVideo {
  final String id;
  final String advertiserId;
  final String title;
  final String description;
  final String videoUrl;
  final String categoryId;
  final int duration;
  final int viewCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category? category;
  final List<Tag> tags;

  AdVideo({
    required this.id,
    required this.advertiserId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.categoryId,
    required this.duration,
    required this.viewCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.tags = const [],
  });

  factory AdVideo.fromJson(Map<String, dynamic> json) {
    return AdVideo(
      id: json['id'],
      advertiserId: json['advertiser_id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      categoryId: json['category_id'],
      duration: json['duration'],
      viewCount: json['view_count'],
      commentCount: json['comment_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List).map((e) => Tag.fromJson(e)).toList()
          : [],
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
  final DateTime createdAt;

  Tag({required this.id, required this.name, required this.createdAt});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
