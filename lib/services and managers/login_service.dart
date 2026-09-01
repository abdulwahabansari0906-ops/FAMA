import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/loogin_response_model.dart';

class LoginService {
  static const String _baseUrl = 'https://fama.digitalpreps.com/api';

  static Future<LoginResponse> login({
    required String phoneNumber,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');

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
        body['status'] == true) {
      return LoginResponse.fromJson(body);
    } else {
      throw Exception(body['message'] ?? 'Login failed. Please try again.');
    }
  }
}