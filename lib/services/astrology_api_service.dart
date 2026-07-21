import 'package:knowme/core/config/api_config.dart';
import 'package:knowme/core/network/astrology_api_client.dart';

class AstrologyApiService {
  static Future<void> generateChart({
    required String uid,
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
  }) async {
    await AstrologyApiClient.postJson(
      endpoint: ApiConfig.astrologyGenerateChartUri(),
      body: {
        'uid': uid,
        'birth_date': birthDate,
        'birth_time': birthTime,
        'latitude': latitude,
        'longitude': longitude,
      },
      failureLabel: 'Failed to generate chart',
    );
  }
}
