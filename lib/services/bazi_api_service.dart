import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:knowme/core/config/api_config.dart';

class BaziApiService {
  static Future<void> generateBazi({
    required String uid,
    required String birthDate,
    required String birthTime,
    required String timezone,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'uid': uid,
      'birth_date': birthDate,
      'birth_time': birthTime,
      'timezone': timezone,
    };

    if (latitude != null) {
      body['latitude'] = latitude;
    }
    if (longitude != null) {
      body['longitude'] = longitude;
    }

    final response = await http.post(
      ApiConfig.baziGenerateUri(),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate BaZi chart');
    }
  }
}
