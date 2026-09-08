import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostShareResult {
  final int postId;
  final int sharesCount;

  const PostShareResult({required this.postId, required this.sharesCount});

  factory PostShareResult.fromJson(Map<String, dynamic> json) {
    return PostShareResult(
      postId: json['post_id'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
    );
  }
}

class PostShareApiService {
  static const String _shareUrl = 'https://fama.digitalpreps.com/api/posts/share';

  /// Records a share for [postId] and returns the updated shares_count
  /// from the server. Throws an [Exception] with a user-facing message
  /// on failure.
  static Future<PostShareResult> sharePost({
    required String token,
    required int postId,
  }) async {
    final http.Response response;

    try {
      response = await http
          .post(
        Uri.parse(_shareUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'post_id': postId}),
      )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (_) {
      throw Exception('Could not connect. Please check your internet connection.');
    }

    // ignore: avoid_print
    print('SHARE DEBUG -> postId: $postId, status: ${response.statusCode}, body: ${response.body}');

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Unexpected response from server.');
    }

    if (response.statusCode != 200 || decoded['status'] != true) {
      throw Exception(
        decoded['message']?.toString() ?? 'Failed to share post.',
      );
    }

    return PostShareResult.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }
}