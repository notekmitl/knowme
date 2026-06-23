import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowme/core/profile/birth_profile_format.dart';
import 'package:knowme/core/profile/canonical_profile_resolver.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';

/// Loads birth input from `users/{uid}/profile/main`.
abstract final class UserProfileBirthLoader {
  static Future<ThaiBirthData?> load(String uid, {FirebaseFirestore? firestore}) async {
    if (uid.isEmpty) return null;

    final profile = await CanonicalProfileResolver(firestore: firestore)
        .loadCanonicalProfile(uid);
    if (profile == null) return null;
    return fromMap(profile.toMap());
  }

  static ThaiBirthData? fromMap(Map<String, dynamic> profile) {
    final birthDateRaw = profile['birthDate']?.toString().trim() ?? '';
    if (birthDateRaw.isEmpty) return null;

    final parsedDate = BirthProfileFormat.parseStoredDate(birthDateRaw);
    if (parsedDate == null) return null;

    final birthTimeRaw = profile['birthTime']?.toString().trim() ?? '';
    final hasBirthTime =
        birthTimeRaw.isNotEmpty && birthTimeRaw.toLowerCase() != 'unknown';
    var hour = 12;
    var minute = 0;
    if (hasBirthTime) {
      final parts = birthTimeRaw.split(':');
      hour = int.tryParse(parts.first) ?? 12;
      minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    }

    return ThaiBirthData(
      localDateTime: DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        hour,
        minute,
      ),
      timeZoneOffset: _offsetForTimezone(
        profile['timezone']?.toString() ?? 'Asia/Bangkok',
      ),
      latitude: (profile['latitude'] as num?)?.toDouble() ?? 13.7563,
      longitude: (profile['longitude'] as num?)?.toDouble() ?? 100.5018,
      hasBirthTime: hasBirthTime,
    );
  }

  static Duration _offsetForTimezone(String timezone) {
    final normalized = timezone.toLowerCase();
    if (normalized.contains('bangkok') || normalized == 'asia/bangkok') {
      return const Duration(hours: 7);
    }
    return Duration.zero;
  }
}
