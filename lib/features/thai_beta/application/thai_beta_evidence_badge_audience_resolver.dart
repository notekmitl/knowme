import 'thai_beta_evidence_badge_audience.dart';
import 'thai_research_admin_access.dart';

/// Resolves badge audience from research admin access (internal tester gate).
abstract final class ThaiBetaEvidenceBadgeAudienceResolver {
  static ThaiBetaEvidenceBadgeAudience fromResearchAccess(
    ThaiResearchAccess access,
  ) {
    return switch (access) {
      ThaiResearchAccess.admin =>
        const ThaiBetaEvidenceBadgeAudience.internalTester(),
      ThaiResearchAccess.signedOut ||
      ThaiResearchAccess.notAdmin ||
      ThaiResearchAccess.unknown =>
        const ThaiBetaEvidenceBadgeAudience.anonymous(),
    };
  }
}
