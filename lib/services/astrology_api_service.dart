import 'dart:convert';

import 'package:http/http.dart' as http;

class AstrologyApiService {
  static Future<void> generateChart({
    required String uid,
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
  }) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/generate-chart'),

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
