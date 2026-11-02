import 'package:firebase_auth/firebase_auth.dart';
import 'package:knowme/core/config/api_config.dart';
import 'package:knowme/core/network/astrology_api_client.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';

class WesternAuthSession {
  const WesternAuthSession({required this.uid, required this.idToken});

  final String uid;
  final String idToken;
}

typedef WesternAuthSessionLoader = Future<WesternAuthSession> Function();
typedef WesternPostJson =
    Future<Map<String, dynamic>> Function({
      required Uri endpoint,
      required Map<String, dynamic> body,
      required String failureLabel,
      required Map<String, String> headers,
    });

class AstrologyApiService {
  static Future<AstrologyChartModel> calculateChart({
    required String birthDate,
    required String birthTime,
    String timezone = 'Asia/Bangkok',
    required double latitude,
    required double longitude,
    WesternPostJson? postJson,
  }) async {
    final response = await (postJson ?? _postJson)(
      endpoint: ApiConfig.astrologyCalculateChartUri(),
      body: <String, dynamic>{
        'birth_date': birthDate,
        'birth_time': birthTime,
        'timezone': timezone,
        'latitude': latitude,
        'longitude': longitude,
      },
      failureLabel: 'Failed to calculate Western chart',
      headers: const {},
    );
    final rawChart = response['chart'];
    if (rawChart is! Map) {
      throw const FormatException('Western API response is missing chart data');
    }
    return AstrologyChartModel.fromMap(Map<String, dynamic>.from(rawChart));
  }

  static Future<AstrologyChartModel> generateChart({
    required String uid,
    required String birthDate,
    required String birthTime,
    String timezone = 'Asia/Bangkok',
    required double latitude,
    required double longitude,
    Map<String, dynamic>? canonicalProfile,
    WesternAuthSessionLoader? loadAuthSession,
    WesternPostJson? postJson,
  }) async {
    final session = await (loadAuthSession ?? _loadFirebaseSession)();
    if (session.uid != uid) {
      throw StateError(
        'Authenticated user does not match requested Western astrology uid',
      );
    }
    if (session.idToken.trim().isEmpty) {
      throw StateError('Firebase ID token is unavailable');
    }

    final send = postJson ?? _postJson;
    final body = <String, dynamic>{
      'uid': uid,
      'birth_date': birthDate,
      'birth_time': birthTime,
      'timezone': timezone,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (canonicalProfile != null) body['profile'] = canonicalProfile;

    final response = await send(
      endpoint: ApiConfig.astrologyGenerateChartUri(),
      body: body,
      failureLabel: 'Failed to generate chart',
      headers: {'Authorization': 'Bearer ${session.idToken}'},
    );
    final rawChart = response['chart'];
    if (rawChart is! Map) {
      throw const FormatException('Western API response is missing chart data');
    }
    return AstrologyChartModel.fromMap(Map<String, dynamic>.from(rawChart));
  }

  static Future<WesternAuthSession> _loadFirebaseSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError(
        'Authentication is required to generate a Western astrology chart',
      );
    }
    final token = await user.getIdToken();
    if (token == null || token.trim().isEmpty) {
      throw StateError('Firebase ID token is unavailable');
    }
    return WesternAuthSession(uid: user.uid, idToken: token);
  }

  static Future<Map<String, dynamic>> _postJson({
    required Uri endpoint,
    required Map<String, dynamic> body,
    required String failureLabel,
    required Map<String, String> headers,
  }) {
    return AstrologyApiClient.postJsonMap(
      endpoint: endpoint,
      body: body,
      failureLabel: failureLabel,
      headers: headers,
    );
  }
}
