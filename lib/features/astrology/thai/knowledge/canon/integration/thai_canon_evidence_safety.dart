/// Audience / safety classification for Canon evidence lookups.
///
/// Remedy Canon is always [remedyInternalOnly] — queryable internally but
/// must never be wired to user-facing copy in this phase.
enum ThaiCanonEvidenceSafety {
  /// Non-remedy Canon facts — internal traceability only (no UI in this phase).
  traceabilityInternal,

  /// Remedy domain — internal query only; never user-facing advice.
  remedyInternalOnly,
}

extension ThaiCanonEvidenceSafetyX on ThaiCanonEvidenceSafety {
  bool get isNotSafeForUserOutput =>
      this == ThaiCanonEvidenceSafety.remedyInternalOnly;

  bool get isInternalOnly => true;
}
