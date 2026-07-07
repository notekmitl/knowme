/// Checked-in activation record for controlled beta phases.
///
/// Rollback: set [configuredState] to `null` or redeploy with
/// `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=off`.
abstract final class ThaiEvidenceBadgeActivation {
  /// Active phase: internal testers only on Thai Beta Research Result.
  static const String? configuredState = 'internal_only';
}
