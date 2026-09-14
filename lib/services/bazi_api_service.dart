import 'package:knowme/core/config/api_config.dart';
import 'package:knowme/core/network/astrology_api_client.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BaziAuthSession {
  const BaziAuthSession({required this.uid, required this.idToken});

  final String uid;
  final String idToken;
}

typedef BaziAuthSessionLoader = Future<BaziAuthSession> Function();
typedef BaziPostJson =
    Future<void> Function({
      required Uri endpoint,
      required Map<String, dynamic> body,
      required String failureLabel,
      required Map<String, String> headers,
    });

class BaziApiService {
  static Future<void> generateBazi({
    required String uid,
    required String birthDate,
    required String? birthTime,
    required String timezone,
    double? latitude,
    double? longitude,
    BaziAuthSessionLoader? loadAuthSession,
    BaziPostJson? postJson,
  }) async {
    final session = await (loadAuthSession ?? _loadFirebaseSession)();
    if (session.uid != uid) {
      throw StateError('Authenticated user does not match requested BaZi uid');
    }
    if (session.idToken.trim().isEmpty) {
      throw StateError('Firebase ID token is unavailable');
    }

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

    final send = postJson ?? _postJson;
    await send(
      endpoint: ApiConfig.baziGenerateUri(),
      body: body,
      failureLabel: 'Failed to generate BaZi chart',
      headers: {'Authorization': 'Bearer ${session.idToken}'},
    );
  }

  static Future<BaziAuthSession> _loadFirebaseSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Authentication is required to generate a BaZi chart');
    }
    final token = await user.getIdToken();
    if (token == null || token.trim().isEmpty) {
      throw StateError('Firebase ID token is unavailable');
    }
    return BaziAuthSession(uid: user.uid, idToken: token);
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
