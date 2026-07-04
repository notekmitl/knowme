/// Internal audit of Canon ↔ report mapping gaps (QA / review only).
class ThaiCanonEvidenceTrace {
  const ThaiCanonEvidenceTrace({
    this.signalsWithoutCanonEvidence = const [],
    this.runtimeKeysWithoutCanonMapping = const [],
    this.unmappedCanonEvidenceCandidates = const [],
    this.skippedRemedyEvidenceCount = 0,
    this.skippedTaksaEvidenceCount = 0,
    this.skippedPeriodStatusNotes = const [],
  });

  /// Report content keys / signals with no deterministic Canon match.
  final List<String> signalsWithoutCanonEvidence;

  /// Runtime keys present in the report but absent from ontology runtime map.
  final List<String> runtimeKeysWithoutCanonMapping;

  /// Canon-side ids available but not attachable without runtime mapping.
  final List<String> unmappedCanonEvidenceCandidates;

  /// Remedy units indexed but intentionally not attached to report sections.
  final int skippedRemedyEvidenceCount;

  /// Taksa units skipped because report has no Taksa runtime keys.
  final int skippedTaksaEvidenceCount;

  /// periodStatus.* notes (no runtime rise/fall keys).
  final List<String> skippedPeriodStatusNotes;

  int get totalUnmappedSignals => signalsWithoutCanonEvidence.length;
}
