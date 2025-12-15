class AdVideo {
  final String id;
  final String title;
  final String videoUrl;
  final String advertiserId;
  final String categoryId;
  final int viewCount;
  int commentCount;
  final int? duration;
  final DateTime createdAt;
  final Advertiser advertiser;
  final Category category;
  final List<Tag> tags;

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
  });

  factory AdVideo.fromJson(Map<String, dynamic> json) {
    return AdVideo(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      videoUrl: json['video_url']?.toString() ?? '',
      advertiserId: json['advertiser_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      viewCount: json['view_count'] is int ? json['view_count'] : 0,
      commentCount: json['comment_count'] is int ? json['comment_count'] : 0,
      duration: json['duration'] is int ? json['duration'] : null,
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toString(),
      ),
      advertiser: Advertiser.fromJson(json['advertiser'] ?? {}),
      category: Category.fromJson(json['category'] ?? {}),
      tags: (json['tags'] as List? ?? [])
          .map((tag) => Tag.fromJson(tag))
          .toList(),
    );
  }
}

class Advertiser {
  final String id;
  final String username;
  final String profilePicture;

  Advertiser({
    required this.id,
    required this.username,
    required this.profilePicture,
  });

  factory Advertiser.fromJson(Map<String, dynamic> json) {
    String profilePic = '';
    if (json['"profile_picture"'] != null) {
      profilePic = json['"profile_picture"']?.toString() ?? '';
    } else if (json['profile_picture'] != null) {
      profilePic = json['profile_picture']?.toString() ?? '';
    }

    return Advertiser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profilePicture: profilePic,
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class Tag {
  final String id;
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class FeedResponse {
  final List<AdVideo> data;
  final String? nextCursor;
  final bool hasMore;

  FeedResponse({required this.data, this.nextCursor, required this.hasMore});

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      data: (json['data'] as List? ?? [])
          .map((item) => AdVideo.fromJson(item))
          .toList(),
      nextCursor: json['next_cursor']?.toString(),
      hasMore: json['has_more'] == true,
    );
  }
}
