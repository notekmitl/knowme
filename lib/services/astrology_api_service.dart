import 'package:firebase_auth/firebase_auth.dart';
import 'package:knowme/core/config/api_config.dart';
import 'package:knowme/core/network/astrology_api_client.dart';

class WesternAuthSession {
  const WesternAuthSession({required this.uid, required this.idToken});

  final String uid;
  final String idToken;
}

typedef WesternAuthSessionLoader = Future<WesternAuthSession> Function();
typedef WesternPostJson =
    Future<void> Function({
      required Uri endpoint,
      required Map<String, dynamic> body,
      required String failureLabel,
      required Map<String, String> headers,
    });

class AstrologyApiService {
  static Future<void> generateChart({
    required String uid,
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
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
    await send(
      endpoint: ApiConfig.astrologyGenerateChartUri(),
      body: {
        'uid': uid,
        'birth_date': birthDate,
        'birth_time': birthTime,
        'latitude': latitude,
        'longitude': longitude,
      },
      failureLabel: 'Failed to generate chart',
      headers: {'Authorization': 'Bearer ${session.idToken}'},
    );
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

  static Future<void> _postJson({
    required Uri endpoint,
    required Map<String, dynamic> body,
    required String failureLabel,
    required Map<String, String> headers,
  }) {
    return AstrologyApiClient.postJson(
      endpoint: endpoint,
      body: body,
      failureLabel: failureLabel,
      headers: headers,
    );
  }
}
