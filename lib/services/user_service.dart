import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    final userRef = _db.collection('users').doc(user.uid);

    final snapshot = await userRef.get();

    // ป้องกัน overwrite
    if (snapshot.exists) {
      return;
    }

    await userRef.set({
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
