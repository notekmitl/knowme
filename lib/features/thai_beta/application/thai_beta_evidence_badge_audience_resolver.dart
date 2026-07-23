import 'package:firebase_auth/firebase_auth.dart';

import 'thai_beta_evidence_badge_audience.dart';
import 'thai_beta_invited_tester_registry.dart';
import 'thai_invited_beta_tester_access.dart';
import 'thai_research_admin_access.dart';

/// Snapshot used to resolve badge audience from auth + admin + invite access.
class ThaiBetaEvidenceBadgeAudienceSnapshot {
  const ThaiBetaEvidenceBadgeAudienceSnapshot({
    required this.researchAccess,
    this.userId,
    this.firestoreInvited = false,
  });

  final ThaiResearchAccess researchAccess;
  final String? userId;

  /// Trusted invite membership from Firestore `invited_beta_testers/{uid}`.
  final bool firestoreInvited;
}

/// Resolves badge audience for controlled beta gates.
abstract final class ThaiBetaEvidenceBadgeAudienceResolver {
  /// Maps research admin access and optional signed-in uid to audience flags.
  ///
  /// - [isInternalTester]: research admin (`admins/{uid}`)
  /// - [isInvitedBetaTester]: Firestore invite **or** in-memory test registry
  static ThaiBetaEvidenceBadgeAudience resolve({
    required ThaiResearchAccess researchAccess,
    String? userId,
    bool firestoreInvited = false,
  }) {
    final isInternal = researchAccess == ThaiResearchAccess.admin;
    final isInvited =
        firestoreInvited || ThaiBetaInvitedTesterRegistry.isInvited(userId);
    return ThaiBetaEvidenceBadgeAudience(
      isInternalTester: isInternal,
      isInvitedBetaTester: isInvited,
    );
  }

  @Deprecated('Use resolve(researchAccess:, userId:)')
  static ThaiBetaEvidenceBadgeAudience fromResearchAccess(
    ThaiResearchAccess access,
  ) {
    return resolve(researchAccess: access, userId: null);
  }
}

/// Injectable stream for production audience resolution.
abstract class ThaiBetaEvidenceBadgeAudienceAccess {
  Stream<ThaiBetaEvidenceBadgeAudienceSnapshot> watch();
}

/// Firebase-backed audience access: uid + admin allow-list + invited testers.
class FirebaseThaiBetaEvidenceBadgeAudienceAccess
    implements ThaiBetaEvidenceBadgeAudienceAccess {
  FirebaseThaiBetaEvidenceBadgeAudienceAccess({
    FirebaseAuth? auth,
    ThaiResearchAdminAccess? researchAdminAccess,
    ThaiInvitedBetaTesterAccess? invitedAccess,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _researchAdminAccess =
           researchAdminAccess ?? FirebaseThaiResearchAdminAccess(),
       _invitedAccess = invitedAccess ?? FirebaseThaiInvitedBetaTesterAccess();

  final FirebaseAuth _auth;
  final ThaiResearchAdminAccess _researchAdminAccess;
  final ThaiInvitedBetaTesterAccess _invitedAccess;

  @override
  Stream<ThaiBetaEvidenceBadgeAudienceSnapshot> watch() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(
          const ThaiBetaEvidenceBadgeAudienceSnapshot(
            researchAccess: ThaiResearchAccess.signedOut,
            userId: null,
            firestoreInvited: false,
          ),
        );
      }
      // Nested expand keeps latest admin + invite snapshots without rxdart.
      return _researchAdminAccess.watch().asyncExpand((access) {
        return _invitedAccess.watchIsInvited().map(
          (invited) => ThaiBetaEvidenceBadgeAudienceSnapshot(
            researchAccess: access,
            userId: user.uid,
            firestoreInvited: invited,
          ),
        );
      });
    });
  }
}
