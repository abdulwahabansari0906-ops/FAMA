import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Response model for the POST /api/posts endpoint.
class CreatePostResponse {
  CreatePostResponse({
    required this.status,
    required this.message,
    this.postId,
    this.videoUrl,
    this.allowComments,
    this.createdAt,
  });

  final bool status;
  final String message;
  final int? postId;
  final String? videoUrl;
  final bool? allowComments;
  final String? createdAt;

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;

    return CreatePostResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      postId: int.tryParse('${data?['post_id']}'),
      videoUrl: data?['video_url']?.toString(),
      allowComments: data?['allow_comments'] == true,
      createdAt: data?['created_at']?.toString(),
    );
  }
}

class _FileEntry {
  const _FileEntry({required this.field, required this.file});
  final String field;
  final File file;
}

/// Handles the network calls for creating a new post (video or photo upload).
class CreatePostApiService {
  CreatePostApiService._();

  static const String _postsUrl = 'https://fama.digitalpreps.com/api/posts';

  // Uploads can take a while, so this gets a longer timeout than typical
  // JSON requests.
  static const Duration _timeout = Duration(minutes: 3);

  /// Uploads a single [videoFile] as a new post.
  ///
  /// [token] is the logged-in user's access token (from SessionManager),
  /// sent as a Bearer token in the Authorization header.
  static Future<CreatePostResponse> createVideoPost({
    required String token,
    required File videoFile,
    required bool allowComments,
    String? thumbnailUrl,
  }) {
    return _send(
      token: token,
      allowComments: allowComments,
      fields: {
        if (thumbnailUrl != null && thumbnailUrl.trim().isNotEmpty)
          'thumbnail_url': thumbnailUrl.trim(),
      },
      fileEntries: [
        _FileEntry(field: 'video', file: videoFile),
      ],
    );
  }

  /// Uploads one or more [imageFiles] as a new post.
  ///
  /// NOTE: the field name "images[]" and endpoint below are an assumption
  /// based on common REST conventions — the API spec you shared only
  /// documented the single-video upload. Please confirm the actual
  /// field name / endpoint for multi-photo posts with your backend and
  /// adjust here if needed.
  static Future<CreatePostResponse> createImagePost({
    required String token,
    required List<File> imageFiles,
    required bool allowComments,
  }) {
    return _send(
      token: token,
      allowComments: allowComments,
      fields: const {},
      fileEntries: [
        for (final File file in imageFiles) _FileEntry(field: 'images[]', file: file),
      ],
    );
  }

  static Future<CreatePostResponse> _send({
    required String token,
    required bool allowComments,
    required Map<String, String> fields,
    required List<_FileEntry> fileEntries,
  }) async {
    http.StreamedResponse streamedResponse;

    // ── Build & send the multipart request ────────────────────────────
    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(_postsUrl),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['allow_comments'] = allowComments.toString();
      request.fields.addAll(fields);

      for (final _FileEntry entry in fileEntries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.field, entry.file.path),
        );
      }

      streamedResponse = await request.send().timeout(_timeout);
    } on SocketException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw Exception('The upload timed out. Please try again.');
    } catch (e) {
      throw Exception('Something went wrong while uploading the post.');
    }

    final http.Response response =
    await http.Response.fromStream(streamedResponse);

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
      return CreatePostResponse.fromJson(decoded);
    }

    final String? serverMessage = decoded['message']?.toString();
    throw Exception(
      serverMessage != null && serverMessage.trim().isNotEmpty
          ? serverMessage
          : 'Failed to create the post (status ${response.statusCode}).',
    );
  }
}