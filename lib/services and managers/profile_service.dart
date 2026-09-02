import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Logged-in user's own profile info, as returned inside `data.user`.
class ProfileUser {
  final int id;
  final String name;
  final String phoneNumber;
  final String? bio;
  final String? avatarUrl;
  final String? instagramHandle;
  final String? tiktokHandle;
  final String? facebookHandle;
  final int famaPoints;
  final int locationId;
  final int schoolId;
  final String locationName;
  final String schoolName;

  const ProfileUser({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.famaPoints,
    required this.locationId,
    required this.schoolId,
    required this.locationName,
    required this.schoolName,
    this.bio,
    this.avatarUrl,
    this.instagramHandle,
    this.tiktokHandle,
    this.facebookHandle,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      instagramHandle: json['instagram_handle'] as String?,
      tiktokHandle: json['tiktok_handle'] as String?,
      facebookHandle: json['facebook_handle'] as String?,
      famaPoints: json['fama_points'] as int? ?? 0,
      locationId: json['location_id'] as int? ?? 0,
      schoolId: json['school_id'] as int? ?? 0,
      locationName: json['location_name'] as String? ?? '',
      schoolName: json['school_name'] as String? ?? '',
    );
  }
}

/// A single post entry as returned inside `data.posts`.
class ProfilePostApi {
  final int id;
  final String videoUrl;
  final String? thumbnailUrl;
  final bool allowComments;
  final int famaPoints;
  final int viewsCount;
  final int sharesCount;
  final DateTime createdAt;

  const ProfilePostApi({
    required this.id,
    required this.videoUrl,
    required this.allowComments,
    required this.famaPoints,
    required this.viewsCount,
    required this.sharesCount,
    required this.createdAt,
    this.thumbnailUrl,
  });

  factory ProfilePostApi.fromJson(Map<String, dynamic> json) {
    return ProfilePostApi(
      id: json['id'] as int? ?? 0,
      videoUrl: json['video_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      allowComments: (json['allow_comments'] as int? ?? 1) == 1,
      famaPoints: json['fama_points'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Full payload of `data` from GET /api/profile.
class ProfileData {
  final ProfileUser user;
  final int locationRank;
  final int schoolRank;
  final List<ProfilePostApi> posts;

  const ProfileData({
    required this.user,
    required this.locationRank,
    required this.schoolRank,
    required this.posts,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> postsJson = json['posts'] as List<dynamic>? ?? [];
    return ProfileData(
      user: ProfileUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      locationRank: json['location_rank'] as int? ?? 0,
      schoolRank: json['school_rank'] as int? ?? 0,
      posts: postsJson
          .map((dynamic item) =>
          ProfilePostApi.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProfileApiService {
  static const String _profileUrl = 'https://fama.digitalpreps.com/api/profile';

  /// Fetches the logged-in user's profile (info + posts) using their
  /// bearer [token]. Server route only accepts POST (not GET). Throws an
  /// [Exception] with a user-facing message on failure.
  static Future<ProfileData> getProfile({required String token}) async {
    final http.Response response;

    try {
      response = await http
          .post(
        Uri.parse(_profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (_) {
      throw Exception('Could not connect. Please check your internet connection.');
    }

    // ignore: avoid_print
    print('PROFILE DEBUG -> status: ${response.statusCode}, body: ${response.body}');

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Unexpected response from server.');
    }

    if (response.statusCode != 200 || decoded['status'] != true) {
      throw Exception(
        decoded['message']?.toString() ?? 'Failed to load profile.',
      );
    }

    return ProfileData.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }
}