import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/core/profile/canonical_profile_resolver.dart';
import 'package:knowme/domain/models/profile_model.dart';

class ProfileService {
  ProfileService({
    CanonicalProfileResolver? resolver,
    Future<ProfileModel?> Function(String uid)? testProfileLoader,
  })  : _resolver = resolver ?? CanonicalProfileResolver(),
        _testProfileLoader = testProfileLoader;

  /// Test-only constructor — avoids Firestore in unit tests.
  ProfileService.testing(Future<ProfileModel?> Function(String uid) loader)
      : _resolver = null,
        _testProfileLoader = loader;

  final CanonicalProfileResolver? _resolver;
  final Future<ProfileModel?> Function(String uid)? _testProfileLoader;

  Future<ProfileModel?> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return loadProfileForUid(user.uid);
  }

  Future<ProfileModel?> loadProfileForUid(String uid) async {
    if (_testProfileLoader != null) {
      return _testProfileLoader(uid);
    }
    return _resolver!.loadCanonicalProfile(uid);
  }

  Future<void> saveProfile(ProfileModel profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not found');
    }
    await _resolver!.saveCanonicalProfile(user.uid, profile);
  }
}
