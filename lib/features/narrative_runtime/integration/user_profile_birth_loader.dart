import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowme/core/profile/canonical_profile_resolver.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_engine_adapter.dart';

/// Loads birth input from `users/{uid}/profile/main`.
///
/// Birth resolution (timezone, coordinates, sunrise day boundary) is delegated
/// to Birth Normalization via [ThaiEngineAdapter] — this loader no longer parses
/// raw birth fields or duplicates timezone logic.
abstract final class UserProfileBirthLoader {
  static Future<ThaiBirthData?> load(String uid, {FirebaseFirestore? firestore}) async {
    if (uid.isEmpty) return null;

    final profile = await CanonicalProfileResolver(firestore: firestore)
        .loadCanonicalProfile(uid);
    if (profile == null) return null;
    return fromMap(profile.toMap());
  }

  static ThaiBirthData? fromMap(Map<String, dynamic> profile) {
    return ThaiEngineAdapter.fromProfileMap(profile);
  }
}
