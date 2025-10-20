class Video {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnail;
  final User user;
  final int likes;
  final int comments;
  final int shares;
  final String music;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnail,
    required this.user,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.music,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      music: json['music'] ?? '',
    );
  }
}

class User {
  final String id;
  final String username;
  final String profileImage;
  final int followers;

  User({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.followers,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['profileImage'] ?? '',
      followers: json['followers'] ?? 0,
    );
  }
}
