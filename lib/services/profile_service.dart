import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/models/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<ProfileModel?> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final doc = await _db
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('main')
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return ProfileModel.fromMap(doc.data()!);
  }

  Future<void> saveProfile(ProfileModel profile) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not found");
    }

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('profile')
        .doc('main')
        .set(profile.toMap());
  }
}
