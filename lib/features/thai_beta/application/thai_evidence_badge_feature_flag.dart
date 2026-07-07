/// Controlled beta feature gate for LEVEL 1 public evidence badges.
///
/// Default: [off]. Invalid values resolve to [off].
enum ThaiEvidenceBadgeFeatureFlagState {
  off,
  internalOnly,
  invitedBeta,
}

/// Static feature flag — default off; injectable in tests.
abstract final class ThaiEvidenceBadgeFeatureFlag {
  static ThaiEvidenceBadgeFeatureFlagState state =
      ThaiEvidenceBadgeFeatureFlagState.off;

  static ThaiEvidenceBadgeFeatureFlagState parse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'internal_only' => ThaiEvidenceBadgeFeatureFlagState.internalOnly,
      'invited_beta' => ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
      'off' || '' || null => ThaiEvidenceBadgeFeatureFlagState.off,
      _ => ThaiEvidenceBadgeFeatureFlagState.off,
    };
  }

  static void resetToDefault() {
    state = ThaiEvidenceBadgeFeatureFlagState.off;
  }
}
