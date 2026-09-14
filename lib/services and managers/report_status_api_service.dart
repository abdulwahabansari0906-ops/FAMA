import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_manager.dart';

class ReportStatus {
  const ReportStatus({
    required this.reportId,
    required this.reportedType,
    required this.reportedId,
    required this.reason,
    required this.details,
    required this.status,
    required this.statusLabel,
    required this.submittedAt,
    required this.updatedAt,
  });

  final int reportId;
  final String reportedType;
  final int reportedId;
  final String reason;
  final String details;
  final String status;
  final String statusLabel;
  final String submittedAt;
  final String updatedAt;

  factory ReportStatus.fromJson(Map<String, dynamic> json) {
    String text(String key) {
      final value = json[key];
      return value is String ? value.trim() : '';
    }

    int number(String key) {
      final value = json[key];
      return value is int ? value : int.tryParse('$value') ?? 0;
    }

    return ReportStatus(
      reportId: number('report_id'),
      reportedType: text('reported_type'),
      reportedId: number('reported_id'),
      reason: text('reason'),
      details: text('details'),
      status: text('status'),
      statusLabel: text('status_label'),
      submittedAt: text('submitted_at'),
      updatedAt: text('updated_at'),
    );
  }
}

class ReportStatusApiException implements Exception {
  const ReportStatusApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ReportStatusApiService {
  ReportStatusApiService._();

  static final Uri _endpoint =
  Uri.parse('https://fama.digitalpreps.com/api/report/status');

  static Future<ReportStatus> getReportStatus({
    required int reportId,
  }) async {
    final token = SessionManager.accessToken?.trim();

    if (token == null || token.isEmpty) {
      throw const ReportStatusApiException(
        'Session expired. Please log in again.',
      );
    }

    if (reportId <= 0) {
      throw const ReportStatusApiException('Invalid report.');
    }

    final client = http.Client();

    try {
      final response = await client
          .post(
        _endpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'report_id': reportId,
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401) {
        throw const ReportStatusApiException(
          'Session expired. Please log in again.',
        );
      }

      final Object? decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const ReportStatusApiException(
          'Unexpected server response. Please try again.',
        );
      }

      final rawMessage = decoded['message'];
      final message = rawMessage is String ? rawMessage.trim() : '';

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['status'] != true) {
        throw ReportStatusApiException(
          message.isNotEmpty
              ? message
              : 'Could not load report status. Please try again.',
        );
      }

      final data = decoded['data'];

      if (data is! Map<String, dynamic>) {
        throw const ReportStatusApiException(
          'Report details are missing.',
        );
      }

      final report = ReportStatus.fromJson(data);

      if (report.reportId != reportId) {
        throw const ReportStatusApiException(
          'Unexpected report received. Please try again.',
        );
      }

      return report;
    } on TimeoutException {
      throw const ReportStatusApiException(
        'Request timed out. Please try again.',
      );
    } on FormatException {
      throw const ReportStatusApiException(
        'Unexpected server response. Please try again.',
      );
    } on http.ClientException {
      throw const ReportStatusApiException(
        'Could not connect. Please check your internet connection.',
      );
    } finally {
      client.close();
    }
  }
}