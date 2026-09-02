import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_service.dart';

/// Fetches another user's profile (avatar/bio/socials/rank/posts) by their
/// user id. Reuses the same ProfileData/ProfileUser/ProfilePostApi models
/// as the logged-in user's own profile.
class PublicProfileApiService {
  static const String _profileUrl = 'https://fama.digitalpreps.com/api/profile';

  static Future<ProfileData> getProfileByTargetId({
    required String token,
    required int targetId,
  }) async {
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
        body: jsonEncode({'target_id': targetId}),
      )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Server took too long to respond. Please try again.');
    } catch (_) {
      throw Exception('Could not connect. Please check your internet connection.');
    }

    // ignore: avoid_print
    print('PUBLIC PROFILE DEBUG -> status: ${response.statusCode}, body: ${response.body}');

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