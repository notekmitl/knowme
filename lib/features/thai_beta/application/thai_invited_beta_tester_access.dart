import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Resolves whether the signed-in user is on the invited-beta allow-list.
///
/// Production source of truth: Firestore `invited_beta_testers/{uid}` — the same
/// collection enforced by `firestore.rules`. Fails closed on lookup errors.
abstract class ThaiInvitedBetaTesterAccess {
  Stream<bool> watchIsInvited();
}

class FirebaseThaiInvitedBetaTesterAccess
    implements ThaiInvitedBetaTesterAccess {
  FirebaseThaiInvitedBetaTesterAccess({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String collectionName = 'invited_beta_testers';

  @override
  Stream<bool> watchIsInvited() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream<bool>.value(false);
      }
      return _firestore
          .collection(collectionName)
          .doc(user.uid)
          .snapshots()
          .map((snap) => snap.exists)
          .handleError((_) => false);
    });
  }

  /// One-shot membership check (fails closed).
  Future<bool> isInvitedUid(String uid) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(uid).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }
}
