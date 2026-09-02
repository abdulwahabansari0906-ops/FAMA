import 'dart:convert';
import 'package:http/http.dart' as http;

/// One row in the "Celebrities" (users) leaderboard.
class LeaderboardUserEntry {
  final int id;
  final String? name;
  final String? avatarUrl;
  final int? locationId;
  final int? schoolId;
  final int points;

  const LeaderboardUserEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.locationId,
    required this.schoolId,
    required this.points,
  });

  factory LeaderboardUserEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserEntry(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      locationId: json['location_id'] as int?,
      schoolId: json['school_id'] as int?,
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }
}

/// One row in the "Videos" leaderboard.
class LeaderboardVideoEntry {
  final int postId;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? caption;
  final int points;
  final int userId;
  final String? userName;
  final int? locationId;
  final int? schoolId;

  const LeaderboardVideoEntry({
    required this.postId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.points,
    required this.userId,
    required this.userName,
    required this.locationId,
    required this.schoolId,
  });

  factory LeaderboardVideoEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardVideoEntry(
      postId: json['post_id'] as int? ?? 0,
      videoUrl: json['video_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      caption: json['caption'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String?,
      locationId: json['location_id'] as int?,
      schoolId: json['school_id'] as int?,
    );
  }
}

/// `range` values accepted by both leaderboard endpoints.
enum LeaderboardRange { day, week, month, all }

extension on LeaderboardRange {
  String get apiValue {
    switch (this) {
      case LeaderboardRange.day:
        return 'day';
      case LeaderboardRange.week:
        return 'week';
      case LeaderboardRange.month:
        return 'month';
      case LeaderboardRange.all:
        return 'all';
    }
  }
}

/// `/api/leaderboard/users` and `/api/leaderboard/videos`.
class LeaderboardService {
  LeaderboardService._();

  static const String _usersUrl =
      'https://fama.digitalpreps.com/api/leaderboard/users';
  static const String _videosUrl =
      'https://fama.digitalpreps.com/api/leaderboard/videos';

  static Future<List<LeaderboardUserEntry>> fetchUsers({
    required String token,
    required LeaderboardRange range,
    int? locationId,
    int? schoolId,
    String? gender,
  }) async {
    final Map<String, dynamic> decoded = await _post(
      url: _usersUrl,
      token: token,
      range: range,
      locationId: locationId,
      schoolId: schoolId,
      gender: gender,
    );

    final List<dynamic> data = (decoded['data'] as List<dynamic>?) ?? [];
    return data
        .map((e) => LeaderboardUserEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<LeaderboardVideoEntry>> fetchVideos({
    required String token,
    required LeaderboardRange range,
    int? locationId,
    int? schoolId,
    String? gender,
  }) async {
    final Map<String, dynamic> decoded = await _post(
      url: _videosUrl,
      token: token,
      range: range,
      locationId: locationId,
      schoolId: schoolId,
      gender: gender,
    );

    final List<dynamic> data = (decoded['data'] as List<dynamic>?) ?? [];
    return data
        .map((e) => LeaderboardVideoEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> _post({
    required String url,
    required String token,
    required LeaderboardRange range,
    int? locationId,
    int? schoolId,
    String? gender,
  }) async {
    final Map<String, dynamic> body = {
      'range': range.apiValue,
      if (locationId != null) 'location_id': locationId,
      if (schoolId != null) 'school_id': schoolId,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Something went wrong. Please try again.');
    }

    final bool status = decoded['status'] as bool? ?? false;
    if (response.statusCode != 200 || !status) {
      final String message = decoded['message']?.toString() ??
          'Could not load leaderboard. Please try again.';
      throw Exception(message);
    }

    return decoded;
  }
}