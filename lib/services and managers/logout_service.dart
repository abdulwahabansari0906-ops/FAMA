import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class LogoutService {
  static const String _baseUrl = 'https://fama.digitalpreps.com/api';

  static Future<String> logout() async {
    final uri = Uri.parse('$_baseUrl/auth/logout');
    final token = SessionManager.accessToken;

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == true) {
      return body['message'] ?? 'Logged out successfully.';
    } else {
      throw Exception(body['message'] ?? 'Logout failed. Please try again.');
    }
  }
}