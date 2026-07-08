import 'package:firebase_auth/firebase_auth.dart';

import 'thai_beta_evidence_badge_audience.dart';
import 'thai_beta_invited_tester_registry.dart';
import 'thai_research_admin_access.dart';

/// Snapshot used to resolve badge audience from auth + admin access.
class ThaiBetaEvidenceBadgeAudienceSnapshot {
  const ThaiBetaEvidenceBadgeAudienceSnapshot({
    required this.researchAccess,
    this.userId,
  });

  final ThaiResearchAccess researchAccess;
  final String? userId;
}

/// Resolves badge audience for controlled beta gates.
abstract final class ThaiBetaEvidenceBadgeAudienceResolver {
  /// Maps research admin access and optional signed-in uid to audience flags.
  ///
  /// - [isInternalTester]: research admin (`admins/{uid}`)
  /// - [isInvitedBetaTester]: signed-in uid on [ThaiBetaInvitedTesterRegistry]
  static ThaiBetaEvidenceBadgeAudience resolve({
    required ThaiResearchAccess researchAccess,
    String? userId,
  }) {
    final isInternal = researchAccess == ThaiResearchAccess.admin;
    final isInvited = ThaiBetaInvitedTesterRegistry.isInvited(userId);
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

/// Injectable stream for production audience resolution (auth + admin access).
abstract class ThaiBetaEvidenceBadgeAudienceAccess {
  Stream<ThaiBetaEvidenceBadgeAudienceSnapshot> watch();
}

/// Firebase-backed audience access: uid from auth + admin allow-list lookup.
class FirebaseThaiBetaEvidenceBadgeAudienceAccess
    implements ThaiBetaEvidenceBadgeAudienceAccess {
  FirebaseThaiBetaEvidenceBadgeAudienceAccess({
    FirebaseAuth? auth,
    ThaiResearchAdminAccess? researchAdminAccess,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _researchAdminAccess =
            researchAdminAccess ?? FirebaseThaiResearchAdminAccess();

  final FirebaseAuth _auth;
  final ThaiResearchAdminAccess _researchAdminAccess;

  @override
  Stream<ThaiBetaEvidenceBadgeAudienceSnapshot> watch() {
    return _auth.authStateChanges().asyncExpand((user) {
      return _researchAdminAccess.watch().map(
            (access) => ThaiBetaEvidenceBadgeAudienceSnapshot(
              researchAccess: access,
              userId: user?.uid,
            ),
          );
    });
  }
}
