import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';

/// Client-side mirror of the backend Reader V3 input hash contract.
abstract final class BaziInputFingerprint {
  static const String version = 'knowme_bazi_reader_v3';

  static String forProfile(ProfileModel profile) {
    final time = profile.birthTime.trim();
    final payload = <String, dynamic>{
      'birth_date': BirthProfileReadiness.apiBirthDate(profile),
      'birth_time': time.isEmpty ? null : time,
      'gender': _normalizedGender(profile.gender),
      'latitude': time.isEmpty ? null : _coordinate(profile.latitude),
      'longitude': time.isEmpty ? null : _coordinate(profile.longitude),
      'timezone': profile.timezone.trim(),
      'version': version,
    };
    return sha256.convert(utf8.encode(jsonEncode(payload))).toString();
  }

  static double _coordinate(double value) =>
      (value * 1000000).roundToDouble() / 1000000;

  static String? _normalizedGender(String value) {
    final normalized = value.trim().toLowerCase();
    if (const {'ชาย', 'ช', 'male', 'man', 'm', '1'}.contains(normalized)) {
      return 'male';
    }
    if (const {'หญิง', 'ญ', 'female', 'woman', 'f', '0'}.contains(normalized)) {
      return 'female';
    }
    return null;
  }
}
