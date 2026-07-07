import 'thai_evidence_badge_activation.dart';

/// Controlled beta feature gate for LEVEL 1 public evidence badges.
///
/// Default runtime fallback: [off]. Invalid values resolve to [off].
///
/// Configure at build time:
/// `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=internal_only|invited_beta|off`
///
/// When the dart-define is omitted, [ThaiEvidenceBadgeActivation.configuredState]
/// applies (currently `internal_only` for internal-only activation).
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

  /// Applies env override, then checked-in activation config, then off.
  static void applyConfiguredState() {
    const fromEnv = String.fromEnvironment('THAI_PUBLIC_EVIDENCE_BADGE_BETA');
    final raw = fromEnv.isNotEmpty
        ? fromEnv
        : ThaiEvidenceBadgeActivation.configuredState;
    state = parse(raw);
  }

  /// Resolved state after [applyConfiguredState] (env wins over activation).
  static ThaiEvidenceBadgeFeatureFlagState get configuredState {
    const fromEnv = String.fromEnvironment('THAI_PUBLIC_EVIDENCE_BADGE_BETA');
    final raw = fromEnv.isNotEmpty
        ? fromEnv
        : ThaiEvidenceBadgeActivation.configuredState;
    return parse(raw);
  }
}
