import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Access level for the internal Thai Astrology Research admin surface.
enum ThaiResearchAccess {
  /// Resolving (auth/admin lookup in flight).
  unknown,

  /// No authenticated user.
  signedOut,

  /// Authenticated but not on the admin allow-list.
  notAdmin,

  /// Authenticated admin.
  admin,
}

/// Resolves whether the current user may view the research admin surface.
///
/// Abstracted so the guard widget is testable without Firebase.
abstract class ThaiResearchAdminAccess {
  Stream<ThaiResearchAccess> watch();
}

/// Production resolver: existing FirebaseAuth + an explicit `admins/{uid}`
/// allow-list (the same source of truth enforced by `firestore.rules`).
///
/// Fails **closed** — any lookup error resolves to [ThaiResearchAccess.notAdmin]
/// so a transient failure can never expose admin data.
class FirebaseThaiResearchAdminAccess implements ThaiResearchAdminAccess {
  FirebaseThaiResearchAdminAccess({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String adminsCollection = 'admins';

  @override
  Stream<ThaiResearchAccess> watch() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return ThaiResearchAccess.signedOut;
      try {
        final doc =
            await _firestore.collection(adminsCollection).doc(user.uid).get();
        return doc.exists
            ? ThaiResearchAccess.admin
            : ThaiResearchAccess.notAdmin;
      } catch (_) {
        return ThaiResearchAccess.notAdmin;
      }
    });
  }
}
