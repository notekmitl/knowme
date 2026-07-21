import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';

/// Determines whether LEVEL 1 badges may render on Thai Beta Research Result.
abstract final class ThaiPublicEvidenceBadgeBetaGate {
  static bool shouldRenderBadges({
    ThaiEvidenceBadgeFeatureFlagState? flag,
    ThaiBetaEvidenceBadgeAudience? audience,
  }) {
    final resolvedFlag = flag ?? ThaiEvidenceBadgeFeatureFlag.state;
    final resolvedAudience =
        audience ?? const ThaiBetaEvidenceBadgeAudience.anonymous();

    return switch (resolvedFlag) {
      ThaiEvidenceBadgeFeatureFlagState.off => false,
      ThaiEvidenceBadgeFeatureFlagState.internalOnly =>
        resolvedAudience.isInternalTester,
      ThaiEvidenceBadgeFeatureFlagState.invitedBeta =>
        resolvedAudience.isInvitedBetaTester,
    };
  }

  static bool isBetaResearchResultSurface({required bool onThaiBetaReportPage}) {
    return onThaiBetaReportPage;
  }
}
