import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    final doc = _db.collection('users').doc(user.uid);

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'photo': user.photoURL,
        'provider': user.providerData.first.providerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
