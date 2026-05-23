import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:knowme/core/config/api_config.dart';

class AstrologyApiService {
  static Future<void> generateChart({
    required String uid,
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
  }) async {
    final response = await http.post(
      ApiConfig.astrologyGenerateChartUri(),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode({
        'uid': uid,
        'birth_date': birthDate,
        'birth_time': birthTime,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate chart');
    }
  }
}
