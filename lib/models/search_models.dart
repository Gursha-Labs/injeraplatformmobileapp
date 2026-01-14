// models/search_models.dart
import 'package:injera/models/ad_video_model.dart';

class SearchResponse {
  final bool success;
  final String? message;
  final List<AdVideo>? data;
  final Pagination? pagination;

  SearchResponse({
    required this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
                .map((item) => AdVideo.fromJson(item))
                .toList()
          : null,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;
  final bool hasMorePages;
  final bool hasPreviousPages;
  final String? nextPageUrl;
  final String? previousPageUrl;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
    required this.hasMorePages,
    required this.hasPreviousPages,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
      hasMorePages: json['has_more_pages'] ?? false,
      hasPreviousPages: json['has_previous_pages'] ?? false,
      nextPageUrl: json['next_page_url'],
      previousPageUrl: json['previous_page_url'],
    );
  }
}
