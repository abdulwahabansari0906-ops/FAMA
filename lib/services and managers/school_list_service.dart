import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/school_model.dart';
import 'session_manager.dart';

class SchoolService {
  static const String _baseUrl = 'https://fama.digitalpreps.com/api';

  static Future<List<SchoolModel>> fetchSchools({String search = ''}) async {
    final uri = Uri.parse('$_baseUrl/auth/schools/list');
    final token = SessionManager.accessToken;

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'search': search}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 401) {
      await SessionManager.logout();
      throw Exception('Session expired. Please login again.');
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == true) {
      final List<dynamic> list = body['data'] ?? [];
      return list.map((e) => SchoolModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Failed to load schools.');
    }
  }
}