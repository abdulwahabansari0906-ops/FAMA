import 'dart:convert';
import 'package:http/http.dart' as http;

/// Response model for `/api/posts/eligibility`.
class PostEligibilityResponse {
  final bool canPost;
  final DateTime? nextPostAllowedAt;
  final double secondsRemaining;

  const PostEligibilityResponse({
    required this.canPost,
    required this.nextPostAllowedAt,
    required this.secondsRemaining,
  });

  factory PostEligibilityResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json['data'] as Map<String, dynamic>?) ?? const {};

    return PostEligibilityResponse(
      canPost: data['can_post'] as bool? ?? false,
      nextPostAllowedAt: data['next_post_allowed_at'] != null
          ? DateTime.tryParse(data['next_post_allowed_at'].toString())
          : null,
      secondsRemaining: (data['seconds_remaining'] as num?)?.toDouble() ?? 0,
    );
  }

  /// `seconds_remaining` ko readable form mein convert karta hai,
  /// e.g. "39m 2s" ya "1h 4m".
  String get remainingFormatted {
    final int totalSeconds = secondsRemaining.round();
    if (totalSeconds <= 0) return '0s';

    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}

/// Post karne se pehle eligibility check karne wali API.
class PostEligibilityService {
  PostEligibilityService._();

  static const String _url =
      'https://fama.digitalpreps.com/api/posts/eligibility';

  /// Session se token lekar eligibility check karta hai.
  /// Token request body mein bhejta hai (jaisa API expect karti hai).
  static Future<PostEligibilityResponse> checkEligibility({
    required String token,
  }) async {
    final http.Response response = await http.post(
      Uri.parse(_url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'token': token}),
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
          'Could not check posting eligibility. Please try again.';
      throw Exception(message);
    }

    return PostEligibilityResponse.fromJson(decoded);
  }
}