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
