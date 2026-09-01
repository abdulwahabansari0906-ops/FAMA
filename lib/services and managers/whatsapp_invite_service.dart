import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Response model for the /api/referral/invite endpoint.
class InviteResponse {
  InviteResponse({
    required this.status,
    required this.whatsappUrl,
  });

  final bool status;

  /// The raw WhatsApp URL returned by the backend
  /// (may include a specific phone number and pre-filled text).
  final String whatsappUrl;

  factory InviteResponse.fromJson(Map<String, dynamic> json) {
    return InviteResponse(
      status: json['status'] == true,
      whatsappUrl: (json['data']?['whatsapp_url'] ?? '').toString(),
    );
  }

  /// Extracts just the pre-filled message text from [whatsappUrl].
  String get shareText {
    final Uri uri = Uri.parse(whatsappUrl);
    return uri.queryParameters['text'] ?? '';
  }

  /// Builds a WhatsApp URL with the same message text but WITHOUT a target
  /// phone number, so tapping it opens WhatsApp's own contact/chat list —
  /// letting the user pick who to send the invite to, instead of the app
  /// sending it to one fixed number.
  Uri get contactPickerUri {
    return Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareText)}');
  }
}

/// Handles all network calls related to the WhatsApp referral invite feature.
class InviteApiService {
  InviteApiService._();

  static const String _inviteUrl =
      'https://fama.digitalpreps.com/api/referral/invite';

  static const Duration _timeout = Duration(seconds: 15);

  /// Calls the invite API with the given [phoneNumber] and [token], and
  /// returns the WhatsApp deep link info received from the backend.
  ///
  /// [token] is the logged-in user's access token (from [SessionManager]),
  /// sent as a Bearer token in the Authorization header.
  ///
  /// Throws an [Exception] with a clear, user-facing message on failure.
  static Future<InviteResponse> getInviteLink({
    required String phoneNumber,
    required String token,
  }) async {
    http.Response response;

    // ── Network call ────────────────────────────────────────────────
    try {
      response = await http
          .post(
        Uri.parse(_inviteUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
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
      final InviteResponse invite = InviteResponse.fromJson(decoded);

      if (invite.whatsappUrl.isEmpty) {
        throw Exception('The server returned an empty WhatsApp link.');
      }

      return invite;
    }

    final String? serverMessage = decoded['message']?.toString();
    throw Exception(
      serverMessage != null && serverMessage.trim().isNotEmpty
          ? serverMessage
          : 'Failed to fetch the invite link (status ${response.statusCode}).',
    );
  }
}