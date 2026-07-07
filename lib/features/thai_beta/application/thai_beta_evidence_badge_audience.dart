/// Audience context for controlled beta evidence badges.
class ThaiBetaEvidenceBadgeAudience {
  const ThaiBetaEvidenceBadgeAudience({
    required this.isInternalTester,
    required this.isInvitedBetaTester,
  });

  const ThaiBetaEvidenceBadgeAudience.anonymous()
      : isInternalTester = false,
        isInvitedBetaTester = false;

  const ThaiBetaEvidenceBadgeAudience.internalTester()
      : isInternalTester = true,
        isInvitedBetaTester = false;

  const ThaiBetaEvidenceBadgeAudience.invitedBetaTester()
      : isInternalTester = false,
        isInvitedBetaTester = true;

  final bool isInternalTester;
  final bool isInvitedBetaTester;
}

/// Injectable invite list for `invited_beta` gate (tests / future Firestore).
abstract final class ThaiBetaInvitedTesterRegistry {
  static final Set<String> invitedUserIds = <String>{};

  static bool isInvited(String? userId) =>
      userId != null && invitedUserIds.contains(userId);

  static void reset() => invitedUserIds.clear();
}
