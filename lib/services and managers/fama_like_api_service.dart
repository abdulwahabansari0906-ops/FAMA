import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Handles the network calls for giving/removing a "FAMA" (star) on a post.
class FamaApiService {
  FamaApiService._();

  static const String _giveUrl = 'https://fama.digitalpreps.com/api/posts/fama';
  static const String _removeUrl =
      'https://fama.digitalpreps.com/api/posts/fama/remove';

  static const Duration _timeout = Duration(seconds: 15);

  /// Gives a FAMA (star) to the post with [postId].
  static Future<void> giveFama({
    required String token,
    required int postId,
  }) {
    return _post(url: _giveUrl, token: token, postId: postId);
  }

  /// Removes a previously given FAMA (star) from the post with [postId].
  static Future<void> removeFama({
    required String token,
    required int postId,
  }) {
    return _post(url: _removeUrl, token: token, postId: postId);
  }

  static Future<void> _post({
    required String url,
    required String token,
    required int postId,
  }) async {
    http.Response response;

    // ── Network call ────────────────────────────────────────────────
    try {
      response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'post_id': postId}),
      )
          .timeout(_timeout);
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw Exception('The request timed out. Please try again.');
    } catch (e) {
      throw Exception('Something went wrong while contacting the server.');
    }

    // ── Parse response body ─────────────────────────────────────────
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw Exception(
        'Received an invalid response from the server '
            '(status ${response.statusCode}).',
      );
    }

    // ── Validate result ──────────────────────────────────────────────
    final bool isSuccessStatusCode =
        response.statusCode == 200 || response.statusCode == 201;

    if (isSuccessStatusCode && decoded['status'] == true) {
      return;
    }

    final String? serverMessage = decoded['message']?.toString();
    throw Exception(
      serverMessage != null && serverMessage.trim().isNotEmpty
          ? serverMessage
          : 'Failed to update FAMA (status ${response.statusCode}).',
    );
  }
}