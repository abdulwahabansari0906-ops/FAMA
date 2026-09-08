import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// One row from POST /api/conversations/list.
class ConversationSummary {
  final int id;
  final int otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ConversationSummary({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    final String? rawLastMessageAt = json['last_message_at'] as String?;

    return ConversationSummary(
      id: json['id'] as int? ?? 0,
      otherUserId: json['other_user_id'] as int? ?? 0,
      otherUserName: json['other_user_name'] as String?,
      otherUserAvatar: json['other_user_avatar'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: rawLastMessageAt != null
          ? DateTime.tryParse(rawLastMessageAt)
          : null,
    );
  }

  /// "3 Hrs Ago" style relative label for the UI. Empty if there's no
  /// last message yet.
  String get timeAgo {
    final DateTime? at = lastMessageAt;
    if (at == null) return '';

    final Duration diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Single message row from POST /api/conversations/messages/list.
class ChatMessageApi {
  final int id;
  final int conversationId;
  final int senderId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageApi({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageApi.fromJson(Map<String, dynamic> json) {
    return ChatMessageApi(
      id: json['id'] as int? ?? 0,
      conversationId: json['conversation_id'] as int? ?? 0,
      senderId: json['sender_id'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      isRead: _parseBool(json['is_read']),
      createdAt:
      DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }
}

/// Handles `/api/conversations`, `/api/conversations/messages/list`, and
/// `/api/conversations/messages/send`.
class ConversationApiService {
  ConversationApiService._();

  static const String _baseUrl =
      'https://fama.digitalpreps.com/api/conversations';

  static const Duration _timeout = Duration(seconds: 20);

  /// Fetches the current user's conversation list.
  static Future<List<ConversationSummary>> getConversations({
    required String token,
  }) async {
    final Map<String, dynamic> decoded = await _post(
      url: '$_baseUrl/list',
      token: token,
      body: const {},
    );

    final List<dynamic> data = decoded['data'] as List<dynamic>? ?? [];
    return data
        .map((dynamic e) =>
        ConversationSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Creates (or fetches the existing) conversation with [recipientId].
  /// Returns the conversation id.
  static Future<int> getOrCreateConversation({
    required String token,
    required int recipientId,
  }) async {
    final Map<String, dynamic> decoded = await _post(
      url: _baseUrl,
      token: token,
      body: {'recipient_id': recipientId},
    );

    final dynamic rawId = decoded['data']?['id'];
    final int? conversationId =
    rawId is int ? rawId : int.tryParse('$rawId');

    if (conversationId == null) {
      throw Exception('Could not start the conversation.');
    }
    return conversationId;
  }

  /// Fetches all messages for [conversationId].
  static Future<List<ChatMessageApi>> getMessages({
    required String token,
    required int conversationId,
  }) async {
    final Map<String, dynamic> decoded = await _post(
      url: '$_baseUrl/messages/list',
      token: token,
      body: {'conversation_id': conversationId},
    );

    final List<dynamic> data = decoded['data'] as List<dynamic>? ?? [];
    return data
        .map((dynamic e) => ChatMessageApi.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sends [message] into [conversationId].
  static Future<void> sendMessage({
    required String token,
    required int conversationId,
    required String message,
  }) async {
    await _post(
      url: '$_baseUrl/messages/send',
      token: token,
      body: {
        'conversation_id': conversationId,
        'message': message,
      },
    );
  }

  static Future<Map<String, dynamic>> _post({
    required String url,
    required String token,
    required Map<String, dynamic> body,
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
        body: jsonEncode(body),
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
      return decoded;
    }

    final String? serverMessage = decoded['message']?.toString();
    throw Exception(
      serverMessage != null && serverMessage.trim().isNotEmpty
          ? serverMessage
          : 'Request failed (status ${response.statusCode}).',
    );
  }
}