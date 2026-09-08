import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// A single comment, whether it came from the list endpoint (`id`) or the
/// add endpoint (`comment_id`) — both shapes are handled here.
class PostComment {
  final int id;
  final int postId;
  final int userId;
  final String comment;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: (json['id'] ?? json['comment_id']) as int? ?? 0,
      postId: json['post_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
    );
  }
}

/// Result of GET (POST-style) /api/posts/comments — the list plus a couple
/// of extra flags the endpoint returns alongside it.
class CommentsListResult {
  final bool allowComments;
  final int totalComments;
  final List<PostComment> comments;

  const CommentsListResult({
    required this.allowComments,
    required this.totalComments,
    required this.comments,
  });
}

class PostCommentsApiService {
  static const String _listUrl = 'https://fama.digitalpreps.com/api/posts/comments';
  static const String _addUrl = 'https://fama.digitalpreps.com/api/posts/comment';
  static const String _deleteUrl = 'https://fama.digitalpreps.com/api/posts/comment/delete';

  static Future<Map<String, dynamic>> _post({
    required String url,
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final http.Response response;
    try {
      response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (_) {
      throw Exception('Could not connect. Please check your internet connection.');
    }

    // ignore: avoid_print
    print('COMMENTS DEBUG -> $url -> status: ${response.statusCode}, body: ${response.body}');

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Unexpected response from server.');
    }

    final bool isSuccessStatus = response.statusCode == 200 || response.statusCode == 201;
    if (!isSuccessStatus || decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Something went wrong.');
    }

    return decoded;
  }

  /// GET-style fetch (server route is POST) for a post's comments.
  static Future<CommentsListResult> getComments({
    required String token,
    required int postId,
  }) async {
    final Map<String, dynamic> decoded = await _post(
      url: _listUrl,
      token: token,
      body: {'post_id': postId},
    );

    final List<dynamic> data = decoded['data'] as List<dynamic>? ?? [];
    return CommentsListResult(
      allowComments: decoded['allow_comments'] as bool? ?? true,
      totalComments: decoded['total_comments'] as int? ?? data.length,
      comments: data
          .map((dynamic item) => PostComment.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Adds a comment and returns the newly created [PostComment].
  static Future<PostComment> addComment({
    required String token,
    required int postId,
    required String comment,
  }) async {
    final Map<String, dynamic> decoded = await _post(
      url: _addUrl,
      token: token,
      body: {'post_id': postId, 'comment': comment},
    );

    return PostComment.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }

  /// Deletes a comment by its id.
  static Future<void> deleteComment({
    required String token,
    required int commentId,
  }) async {
    await _post(
      url: _deleteUrl,
      token: token,
      body: {'comment_id': commentId},
    );
  }
}