// models/ad_feed_response.dart
import 'package:injera/models/ad_model.dart';

class AdFeedResponse {
  final List<AdVideo> ads;
  final bool hasMore;
  final String? nextCursor;

  AdFeedResponse({required this.ads, required this.hasMore, this.nextCursor});

  factory AdFeedResponse.fromJson(Map<String, dynamic> json) {
    return AdFeedResponse(
      ads: (json['data'] as List).map((e) => AdVideo.fromJson(e)).toList(),
      hasMore: json['has_more'] ?? false,
      nextCursor: json['next_cursor'],
    );
  }
}
