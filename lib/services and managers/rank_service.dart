import 'dart:convert';
import 'package:http/http.dart' as http;

class RankData {
  final int overallRank;
  final int locationRank;
  final int schoolRank;
  final int famaPoints;

  const RankData({
    required this.overallRank,
    required this.locationRank,
    required this.schoolRank,
    required this.famaPoints,
  });

  factory RankData.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return RankData(
      overallRank: toInt(json['overall_rank']),
      locationRank: toInt(json['location_rank']),
      schoolRank: toInt(json['school_rank']),
      famaPoints: toInt(json['fama_points']),
    );
  }
}

class RankApiService {
  RankApiService._();

  static const String _url =
      'https://fama.digitalpreps.com/api/leaderboard/users/rank';

  /// POST /api/leaderboard/users/rank
  static Future<RankData> getUserRank({
    required String token,
  }) async {
    late final http.Response response;

    try {
      response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
    } catch (_) {
      throw Exception('Network error. Please check your connection.');
    }

    Map<String, dynamic> body;

    try {
      final decodedBody = jsonDecode(response.body);

      if (decodedBody is! Map<String, dynamic>) {
        throw const FormatException();
      }

      body = decodedBody;
    } catch (_) {
      throw Exception(
        'Invalid server response (${response.statusCode}).',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['status'] == true) {
      final data = body['data'];

      if (data is Map<String, dynamic>) {
        return RankData.fromJson(data);
      }

      throw Exception('Rank data is missing from server response.');
    }

    throw Exception(
      body['message']?.toString() ??
          'Failed to load rank (${response.statusCode}).',
    );
  }
}