import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Handles the network call for registering that a post was viewed.
///
/// This is meant to be used as a best-effort, fire-and-forget background
/// call — callers typically don't need to surface its errors to the user.
class PostViewApiService {
  PostViewApiService._();

  static const String _viewUrl =
      'https://fama.digitalpreps.com/api/posts/view';

  static const Duration _timeout = Duration(seconds: 15);

  /// Registers a view for [postId].
  ///
  /// [token] is the logged-in user's access token (from SessionManager),
  /// sent as a Bearer token in the Authorization header.
  ///
  /// Throws an [Exception] with a clear message on failure.
  static Future<void> incrementView({
    required String token,
    required int postId,
  }) async {
    http.Response response;

    // ── Network call ────────────────────────────────────────────────
    try {
      response = await http
          .post(
        Uri.parse(_viewUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'post_id': postId}),
      )
          .timeout(_timeout);
    } on SocketException {
      throw Exception('No internet connection.');
    } on TimeoutException {
      throw Exception('The view request timed out.');
    } catch (e) {
      throw Exception('Something went wrong while registering the view.');
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
      return; // success — nothing to return, just registered the view.
    }

    final String? serverMessage = decoded['message']?.toString();
    throw Exception(
      serverMessage != null && serverMessage.trim().isNotEmpty
          ? serverMessage
          : 'Failed to register the view (status ${response.statusCode}).',
    );
  }
}