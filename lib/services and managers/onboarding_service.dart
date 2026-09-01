import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/onboarding_response_model.dart';
import 'session_manager.dart';

class OnboardingService {
  static const String _baseUrl = 'https://fama.digitalpreps.com/api';

  static Future<OnboardingResponse> completeOnboarding({
    required String name,
    required String birthday, // format: yyyy-MM-dd
    required String gender,
    required int locationId,
    required int schoolId,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/onboarding');
    final token = SessionManager.accessToken;

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'birthday': birthday,
        'gender': gender,
        'location_id': locationId,
        'school_id': schoolId,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 401) {
      await SessionManager.logout();
      throw Exception('Session expired. Please login again.');
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == true) {
      return OnboardingResponse.fromJson(body);
    } else {
      throw Exception(body['message'] ?? 'Onboarding failed. Please try again.');
    }
  }
}