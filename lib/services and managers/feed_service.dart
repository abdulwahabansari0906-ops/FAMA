import 'dart:convert';
import 'package:http/http.dart' as http;

/// Single feed post returned by GET/POST /api/feed.
class FeedPost {
  final int id;
  final int userId;
  final String videoUrl;
  final String? thumbnailUrl;
  final int famaPoints;
  final int viewsCount;
  final int sharesCount;
  final bool allowComments;
  final DateTime createdAt;
  final String userName;
  final String avatarUrl;
  final int locationId;
  final String locationName;
  final int schoolId;
  final String schoolName;

  const FeedPost({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.famaPoints,
    required this.viewsCount,
    required this.sharesCount,
    required this.allowComments,
    required this.createdAt,
    required this.userName,
    required this.avatarUrl,
    required this.locationId,
    required this.locationName,
    required this.schoolId,
    required this.schoolName,
    this.thumbnailUrl,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      videoUrl: json['video_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      famaPoints: json['fama_points'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      allowComments: (json['allow_comments'] as int? ?? 1) == 1,
      createdAt:
      DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      userName: json['user_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      locationId: json['location_id'] as int? ?? 0,
      locationName: json['location_name'] as String? ?? '',
      schoolId: json['school_id'] as int? ?? 0,
      schoolName: json['school_name'] as String? ?? '',
    );
  }

  /// "3 Hrs Ago" style relative label for the UI.
  String get timeAgo {
    final Duration diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} Min Ago';
    if (diff.inHours < 24) return '${diff.inHours} Hrs Ago';
    return '${diff.inDays} Days Ago';
  }
}

class FeedApiService {
  static const String _feedUrl = 'https://fama.digitalpreps.com/api/feed';

  /// Fetches a page of feed posts for the given [locationId].
  /// Throws an [Exception] with a user-facing message on failure.
  static Future<List<FeedPost>> getFeed({
    required String token,
    int locationId = 1,
    int page = 1,
    int perPage = 15,
  }) async {
    final http.Response response;

    try {
      response = await http.post(
        Uri.parse(_feedUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'location_id': locationId,
          'page': page,
          'per_page': perPage,
        }),
      );
    } catch (_) {
      throw Exception('Could not connect. Please check your internet connection.');
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Unexpected response from server.');
    }

    if (response.statusCode != 200 || decoded['status'] != true) {
      throw Exception(
        decoded['message']?.toString() ?? 'Failed to load feed.',
      );
    }

    final List<dynamic> data = decoded['data'] as List<dynamic>? ?? [];
    return data
        .map((dynamic item) => FeedPost.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}