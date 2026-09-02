import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_service.dart';

class ProfileUpdateApiService {
  static const String _updateUrl =
      'https://fama.digitalpreps.com/api/profile/update';

  /// Updates the logged-in user's profile. Pass [avatarDataUri] only when
  /// the user picked a new photo (a `data:image/...;base64,...` string) —
  /// leave it null to keep the existing avatar untouched on the server.
  /// Throws an [Exception] with a user-facing message on failure.
  static Future<ProfileData> updateProfile({
    required String token,
    required String bio,
    String? avatarDataUri,
    required String instagramHandle,
    required String tiktokHandle,
    required String facebookHandle,
  }) async {
    final Map<String, dynamic> payload = {
      'bio': bio,
      'instagram_handle': instagramHandle,
      'tiktok_handle': tiktokHandle,
      'facebook_handle': facebookHandle,
      if (avatarDataUri != null) 'avatar_url': avatarDataUri,
    };

    final http.Response response;
    try {
      response = await http
          .post(
        Uri.parse(_updateUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (_) {
      throw Exception('Could not connect. Please check your internet connection.');
    }

    // ignore: avoid_print
    print('PROFILE UPDATE DEBUG -> status: ${response.statusCode}, body: ${response.body}');

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Unexpected response from server.');
    }

    if (response.statusCode != 200 || decoded['status'] != true) {
      throw Exception(
        decoded['message']?.toString() ?? 'Failed to update profile.',
      );
    }

    return ProfileData.fromJson(decoded['data'] as Map<String, dynamic>? ?? {});
  }
}