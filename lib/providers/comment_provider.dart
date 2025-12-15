// lib/providers/comment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:injera/api/ad_service.dart';
import 'package:injera/models/Comment.dart';

final commentProvider =
    StateNotifierProvider.family<CommentNotifier, CommentState, String>(
      (ref, adId) => CommentNotifier(adId, ref),
    );

class CommentNotifier extends StateNotifier<CommentState> {
  final String adId;
  final Ref ref;
  bool _isLoadingMore = false;

  CommentNotifier(this.adId, this.ref) : super(CommentState.initial()) {
    _loadComments();
  }

  Future<void> _loadComments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await AdService.getComments(adId);

      state = state.copyWith(
        comments: response.comments,
        commentCount: response.commentCount,
        pagination: response.pagination,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !state.pagination.hasMorePages || state.isLoadingMore)
      return;

    _isLoadingMore = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.pagination.currentPage + 1;
      final response = await AdService.getComments(adId, page: nextPage);

      final newComments = [...state.comments, ...response.comments];

      state = state.copyWith(
        comments: newComments,
        pagination: response.pagination,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> addComment(String commentText) async {
    try {
      final response = await AdService.addComment(adId, commentText);

      // Add new comment to the beginning of the list
      final newComments = [response.comment, ...state.comments];

      state = state.copyWith(
        comments: newComments,
        commentCount: state.commentCount + 1,
      );

      return Future.value();
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> addReply(String commentId, String replyText) async {
    try {
      final response = await AdService.addReply(adId, commentId, replyText);

      // Find the comment and add the reply
      final updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          return Comment(
            id: comment.id,
            adId: comment.adId,
            userId: comment.userId,
            comment: comment.comment,
            createdAt: comment.createdAt,
            user: comment.user,
            replies: [...comment.replies, response.reply],
          );
        }
        return comment;
      }).toList();

      state = state.copyWith(comments: updatedComments);

      return Future.value();
    } catch (e) {
      throw Exception('Failed to add reply: $e');
    }
  }

  void refresh() {
    _loadComments();
  }
}

class CommentState {
  final List<Comment> comments;
  final int commentCount;
  final PaginationInfo pagination;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const CommentState({
    required this.comments,
    required this.commentCount,
    required this.pagination,
    required this.isLoading,
    required this.isLoadingMore,
    this.error,
  });

  factory CommentState.initial() => CommentState(
    comments: [],
    commentCount: 0,
    pagination: PaginationInfo(
      currentPage: 1,
      lastPage: 1,
      perPage: 20,
      total: 0,
    ),
    isLoading: true,
    isLoadingMore: false,
    error: null,
  );

  CommentState copyWith({
    List<Comment>? comments,
    int? commentCount,
    PaginationInfo? pagination,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      commentCount: commentCount ?? this.commentCount,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
