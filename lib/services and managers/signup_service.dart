import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/signup_response_model.dart';

class SignUpService {
  static const String _baseUrl = 'https://fama.digitalpreps.com/api';

  /// Returns SignupResponse on success, throws Exception with server
  /// message (or a generic one) on failure — screen just needs to
  /// catch and show it via AppHelpers.showError.
  static Future<SignupResponse> signUp({
    required String phoneNumber,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/signup');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == true){
      return SignupResponse.fromJson(body);
    } else {
      throw Exception(body['message'] ?? 'Signup failed. Please try again.');
    }
  }
}