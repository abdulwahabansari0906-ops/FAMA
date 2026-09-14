import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'session_manager.dart';

class ReportApiException implements Exception {
  const ReportApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ReportApiService {
  ReportApiService._();

  static final Uri _endpoint =
  Uri.parse('https://fama.digitalpreps.com/api/report');

  static Future<String> reportPost({
    required int postId,
    required String reason,
    required String details,
  }) async {
    final token = SessionManager.accessToken?.trim();

    if (token == null || token.isEmpty) {
      throw const ReportApiException(
        'Session expired. Please log in again.',
      );
    }

    if (postId <= 0) {
      throw const ReportApiException('Invalid post.');
    }

    if (reason.trim().isEmpty || details.trim().isEmpty) {
      throw const ReportApiException(
        'Please enter a reason and details.',
      );
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
          'reported_type': 'post',
          'reported_id': postId,
          'reason': reason.trim(),
          'details': details.trim(),
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401) {
        throw const ReportApiException(
          'Session expired. Please log in again.',
        );
      }

      Object? decoded;

      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw const ReportApiException(
          'Unexpected server response. Please try again.',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw const ReportApiException(
          'Unexpected server response. Please try again.',
        );
      }

      final rawMessage = decoded['message'];
      final message = rawMessage is String ? rawMessage.trim() : '';

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['status'] == true) {
        return message.isNotEmpty
            ? message
            : 'Report submitted successfully.';
      }

      final validationMessages = <String>[];
      final errors = decoded['errors'];

      if (errors is Map) {
        for (final value in errors.values) {
          if (value is String && value.trim().isNotEmpty) {
            validationMessages.add(value.trim());
          } else if (value is List) {
            validationMessages.addAll(
              value
                  .whereType<String>()
                  .map((item) => item.trim())
                  .where((item) => item.isNotEmpty),
            );
          }
        }
      }

      throw ReportApiException(
        validationMessages.isNotEmpty
            ? validationMessages.join('\n')
            : message.isNotEmpty
            ? message
            : 'Could not submit report. Please try again.',
      );
    } on TimeoutException {
      throw const ReportApiException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException {
      throw const ReportApiException(
        'Could not connect. Please check your internet connection.',
      );
    } finally {
      client.close();
    }
  }
}
