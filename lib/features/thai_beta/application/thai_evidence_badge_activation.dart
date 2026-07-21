/// Active phase: invited beta testers only on Thai Beta Research Result.
///
/// Rollback: set to `null` or `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=off`.
/// Re-enable internal-only cohort: set to `internal_only`.
abstract final class ThaiEvidenceBadgeActivation {
  static const String? configuredState = 'invited_beta';
}
