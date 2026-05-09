import 'dart:convert';

import 'package:http/http.dart' as http;

class AstrologyApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<void> generateChart({
    required String uid,

    required String birthDate,

    required String birthTime,

    required double latitude,

    required double longitude,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/generate-chart').replace(
        queryParameters: {
          'uid': uid,

          'birth_date': birthDate,

          'birth_time': birthTime,

          'latitude': latitude.toString(),

          'longitude': longitude.toString(),
        },
      );

      print('CALLING ASTROLOGY API');

      print(uri);

      final response = await http.post(
        uri,

        headers: {'accept': 'application/json'},
      );

      print(response.statusCode);

      print(response.body);

      if (response.statusCode != 200) {
        throw Exception('Failed to generate chart');
      }

      final data = jsonDecode(response.body);

      print(data);
    } catch (e) {
      print(e);
    }
  }
}
