import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';

/// Client-side mirror of the backend Compatibility V1 input hash contract.
abstract final class BaziInputFingerprint {
  static const String version = 'knowme_bazi_compatibility_v1';

  static String forProfile(ProfileModel profile) {
    final time = profile.birthTime.trim();
    final payload = <String, dynamic>{
      'birth_date': BirthProfileReadiness.apiBirthDate(profile),
      'birth_time': time.isEmpty ? null : time,
      'timezone': profile.timezone.trim(),
      'version': version,
    };
    return sha256.convert(utf8.encode(jsonEncode(payload))).toString();
  }
}
