import 'package:knowme/core/config/api_config.dart';
import 'package:knowme/core/network/astrology_api_client.dart';

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

    await AstrologyApiClient.postJson(
      endpoint: ApiConfig.baziGenerateUri(),
      body: body,
      failureLabel: 'Failed to generate BaZi chart',
    );
  }
}
