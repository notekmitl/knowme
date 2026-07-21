import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:knowme/core/network/astrology_api_failure.dart';

/// Shared POST helper for astrology backend endpoints.
abstract final class AstrologyApiClient {
  static const Duration defaultTimeout = Duration(seconds: 60);

  static Future<void> postJson({
    required Uri endpoint,
    required Map<String, dynamic> body,
    required String failureLabel,
    Duration timeout = defaultTimeout,
  }) async {
    try {
      final response = await http
          .post(
            endpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return;
      }

      final failure = AstrologyApiFailure(
        endpoint: endpoint.toString(),
        message: failureLabel,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
      debugPrint('[AstrologyApi] $failure');
      throw failure;
    } catch (e, stack) {
      if (e is AstrologyApiFailure) rethrow;

      final failure = AstrologyApiFailure(
        endpoint: endpoint.toString(),
        message: failureLabel,
        cause: e,
      );
      debugPrint('[AstrologyApi] $failure');
      debugPrint('[AstrologyApi] $stack');
      throw failure;
    }
  }
}
