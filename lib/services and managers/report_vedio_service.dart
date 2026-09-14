import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

/// A single reported video entry as returned by the
/// `/api/user/reported-videos` endpoint.
class ReportedVideo {
  const ReportedVideo({
    required this.reportId,
    required this.postId,
    required this.reason,
    required this.reportDetails,
    required this.status,
    required this.statusLabel,
    required this.reportedAt,
    required this.statusUpdatedAt,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.creatorId,
    required this.creatorName,
    required this.isContentAvailable,
  });

  final int reportId;
  final int postId;
  final String reason;
  final String? reportDetails;
  final String status;
  final String statusLabel;
  final DateTime reportedAt;
  final DateTime statusUpdatedAt;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? caption;
  final int creatorId;
  final String creatorName;
  final bool isContentAvailable;

  factory ReportedVideo.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String? value) {
      if (value == null) return DateTime.now();
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return ReportedVideo(
      reportId: json['report_id'] is int
          ? json['report_id'] as int
          : int.tryParse('${json['report_id']}') ?? 0,
      postId: json['post_id'] is int
          ? json['post_id'] as int
          : int.tryParse('${json['post_id']}') ?? 0,
      reason: (json['reason'] as String?)?.trim() ?? '',
      reportDetails: (json['report_details'] as String?)?.trim(),
      status: (json['status'] as String?)?.trim() ?? '',
      statusLabel: (json['status_label'] as String?)?.trim() ?? '',
      reportedAt: parseDate(json['reported_at'] as String?),
      statusUpdatedAt: parseDate(json['status_updated_at'] as String?),
      videoUrl: (json['video_url'] as String?)?.trim() ?? '',
      thumbnailUrl: (json['thumbnail_url'] as String?)?.trim(),
      caption: (json['caption'] as String?)?.trim(),
      creatorId: json['creator_id'] is int
          ? json['creator_id'] as int
          : int.tryParse('${json['creator_id']}') ?? 0,
      creatorName: (json['creator_name'] as String?)?.trim() ?? '',
      isContentAvailable: json['is_content_available'] as bool? ?? true,
    );
  }
}

class ReportedVideosApiException implements Exception {
  ReportedVideosApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ReportedVideosApiService {
  ReportedVideosApiService._();

  static const String _endpoint =
      'https://fama.digitalpreps.com/api/user/reported-videos';

  static Future<List<ReportedVideo>> getReportedVideos({
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      throw ReportedVideosApiException('Session expired. Please log in again.');
    }

    final client = http.Client();

    try {
      final response = await client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer ${token.trim()}',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('REPORTS HTTP: ${response.statusCode}');

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw ReportedVideosApiException('Unexpected server response.');
      }

      final message = decoded['message'];
      final errorMessage = message is String
          ? message
          : 'Could not load your reports. Please try again.';

      if (response.statusCode != 200 || decoded['status'] != true) {
        throw ReportedVideosApiException(errorMessage);
      }

      final data = decoded['data'];

      if (data is! List) {
        throw ReportedVideosApiException(
          'Unexpected response: reports list is missing.',
        );
      }

      debugPrint('REPORTS COUNT: ${data.length}');

      final reports = <ReportedVideo>[];

      for (var index = 0; index < data.length; index++) {
        final item = data[index];

        if (item is! Map<String, dynamic>) {
          throw ReportedVideosApiException(
            'Invalid report entry at index $index.',
          );
        }

        try {
          reports.add(ReportedVideo.fromJson(item));
        } catch (error, stackTrace) {
          debugPrint('REPORT PARSING FAILED at index $index: $error');
          debugPrintStack(stackTrace: stackTrace);

          throw ReportedVideosApiException(
            'Could not read report ${index + 1}: invalid field format.',
          );
        }
      }

      return reports;
    } on ReportedVideosApiException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('REPORTS LOAD FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);

      throw ReportedVideosApiException(
        'Could not load reports. Check your connection and try again.',
      );
    } finally {
      client.close();
    }
  }
}
