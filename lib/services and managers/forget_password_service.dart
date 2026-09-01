import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forget_password_model.dart';

class ForgotPasswordService {
  static const String _baseUrl = 'https://fama.digitalpreps.com/api';

  static Future<ForgotPasswordResponse> sendResetToken({
    required String phoneNumber,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/forgot-password');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == true) {
      return ForgotPasswordResponse.fromJson(body);
    } else {
      throw Exception(body['message'] ?? 'Something went wrong. Please try again.');
    }
  }

  static Future<String> resetPassword({
    required String phoneNumber,
    required String token,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/reset-password');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'token': token,
        'new_password': newPassword,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == true) {
      return body['message'] ?? 'Password reset successfully.';
    } else {
      throw Exception(body['message'] ?? 'Reset failed. Please try again.');
    }
  }
}