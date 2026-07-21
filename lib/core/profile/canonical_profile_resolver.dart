import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowme/core/profile/birth_profile_format.dart';
import 'package:knowme/domain/models/profile_model.dart';
import 'package:knowme/features/astrology/application/birth_profile_readiness.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_profile_input.dart';

/// Single resolver for `users/{uid}/profile/main` with legacy root migration.
class CanonicalProfileResolver {
  CanonicalProfileResolver({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Loads canonical profile after ensuring legacy root data is migrated.
  Future<ProfileModel?> loadCanonicalProfile(String uid) async {
    if (uid.isEmpty) return null;

    await ensureMigrated(uid);

    final doc = await _mainRef(uid).get();
    if (!doc.exists || doc.data() == null) return null;

    return _normalizeProfile(ProfileModel.fromMap(doc.data()!));
  }

  Future<void> saveCanonicalProfile(String uid, ProfileModel profile) async {
    if (uid.isEmpty) {
      throw Exception('User not found');
    }
    await _mainRef(uid).set(profile.toMap());
  }

  /// Idempotent: copies birth fields from `users/{uid}` when `profile/main` is missing.
  Future<bool> ensureMigrated(String uid) async {
    if (uid.isEmpty) return false;

    final mainSnap = await _mainRef(uid).get();
    if (mainSnap.exists && mainSnap.data() != null) {
      return true;
    }

    final rootSnap = await _rootRef(uid).get();
    if (!rootSnap.exists || rootSnap.data() == null) {
      return false;
    }

    final rootData = rootSnap.data()!;
    if (!hasLegacyBirthFields(rootData)) {
      return false;
    }

    final profile = profileFromLegacyRoot(rootData);
    await _mainRef(uid).set(profile.toMap());
    return true;
  }

  static bool hasLegacyBirthFields(Map<String, dynamic> rootData) {
    final birthDate = rootData['birthDate']?.toString().trim() ?? '';
    return birthDate.isNotEmpty;
  }

  static ProfileModel profileFromLegacyRoot(Map<String, dynamic> rootData) {
    final rawBirthDate = rootData['birthDate']?.toString().trim() ?? '';
    final parsedDate = BirthProfileFormat.parseStoredDate(rawBirthDate);
    final birthDate = parsedDate != null
        ? BirthProfileFormat.storageDate(parsedDate)
        : rawBirthDate;

    return ProfileModel(
      name: rootData['name']?.toString() ?? '',
      gender: rootData['gender']?.toString() ?? '',
      birthDate: birthDate,
      birthTime: rootData['birthTime']?.toString() ?? '',
      birthPlace: rootData['birthPlace']?.toString() ?? '',
      latitude: (rootData['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (rootData['longitude'] as num?)?.toDouble() ?? 0,
      timezone: rootData['timezone']?.toString().isNotEmpty == true
          ? rootData['timezone'].toString()
          : 'Asia/Bangkok',
    );
  }

  static ExplorationProfileInput explorationInput(ProfileModel? profile) {
    if (profile == null) return ExplorationProfileInput.empty;

    return ExplorationProfileInput(
      hasName: profile.name.trim().isNotEmpty,
      hasBirthDate: profile.birthDate.trim().isNotEmpty,
      hasBirthTime: profile.birthTime.trim().isNotEmpty,
      hasBirthPlace: profile.birthPlace.trim().isNotEmpty,
      hasCoordinates: profile.latitude != 0 || profile.longitude != 0,
      birthProfileComplete: BirthProfileReadiness.isComplete(profile),
    );
  }

  static Map<String, String> profileFields(ProfileModel? profile) {
    if (profile == null) return const {};
    return {
      'name': profile.name,
      'birthDate': profile.birthDate,
      'birthTime': profile.birthTime,
      'birthPlace': profile.birthPlace,
    };
  }

  DocumentReference<Map<String, dynamic>> _mainRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('main');
  }

  DocumentReference<Map<String, dynamic>> _rootRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  ProfileModel _normalizeProfile(ProfileModel profile) {
    final parsed = BirthProfileFormat.parseStoredDate(profile.birthDate.trim());
    if (parsed == null) return profile;

    final normalized = BirthProfileFormat.storageDate(parsed);
    if (normalized == profile.birthDate) return profile;

    return ProfileModel(
      name: profile.name,
      gender: profile.gender,
      birthDate: normalized,
      birthTime: profile.birthTime,
      birthPlace: profile.birthPlace,
      latitude: profile.latitude,
      longitude: profile.longitude,
      timezone: profile.timezone,
    );
  }
}
