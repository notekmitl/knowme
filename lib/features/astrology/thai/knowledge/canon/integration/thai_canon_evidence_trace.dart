/// Internal audit of Canon ↔ report mapping gaps (QA / review only).
class ThaiCanonEvidenceTrace {
  const ThaiCanonEvidenceTrace({
    this.signalsWithoutCanonEvidence = const [],
    this.outOfCanonScopeSignals = const [],
    this.inCanonScopeUnmappedSignals = const [],
    this.traceOnlyEvidenceCandidates = const [],
    this.runtimeKeysWithoutCanonMapping = const [],
    this.unmappedCanonEvidenceCandidates = const [],
    this.skippedRemedyEvidenceCount = 0,
    this.skippedTaksaEvidenceCount = 0,
    this.skippedLookupTableEvidenceCount = 0,
    this.skippedPeriodStatusNotes = const [],
    this.lifePeriodsWithoutRuntimeStatus = const [],
    this.lifePeriodsWithCanonDerivedStatus = const [],
    this.lifePeriodsWithoutCanonStatusMarker = const [],
    this.lifePeriodsWithRuntimeStatus = const [],
    this.lifePeriodRiseFallFeasibilityResult,
    this.lifePeriodPositionFeasibilityResult,
    this.lifePeriodPositionMetadataBlocker,
    this.lifePeriodArchetypeFeasibilityResult,
    this.lifePeriodArchetypeMetadataBlocker,
    this.remainderFeasibilityResult,
    this.remainderCalculationFeasibilityResult,
    this.remainderMetadataBlocker,
    this.remainderSourceField,
    this.remainderCanonId,
    this.profilesWithRemainderMetadata = const [],
    this.profilesWithoutRemainderMetadata = const [],
    this.lifePeriodStatusMetadataBlocker,
  });

  /// Legacy combined list — in-scope unmapped signals only (excludes out-of-scope).
  final List<String> signalsWithoutCanonEvidence;

  /// Report signals outside frozen Mahabhut Canon (not mapping failures).
  final List<String> outOfCanonScopeSignals;

  /// In-scope signals with no deterministic Canon attachment.
  final List<String> inCanonScopeUnmappedSignals;

  /// Weak or bulk evidence kept trace-only (not section attachments).
  final List<String> traceOnlyEvidenceCandidates;

  /// Runtime keys in Canon scope but absent from ontology runtime map.
  final List<String> runtimeKeysWithoutCanonMapping;

  /// Canon-side ids available but not attachable without runtime mapping.
  final List<String> unmappedCanonEvidenceCandidates;

  final int skippedRemedyEvidenceCount;
  final int skippedTaksaEvidenceCount;
  final int skippedLookupTableEvidenceCount;
  final List<String> skippedPeriodStatusNotes;

  /// Life-period anchors with no exact ดวงขึ้น/ดวงตก label in runtime (not a mapping failure).
  final List<String> lifePeriodsWithoutRuntimeStatus;

  /// Life-period anchors with periodStatus evidence from exact Canon context markers.
  final List<String> lifePeriodsWithCanonDerivedStatus;

  /// Life-period anchors with structural evidence but no unambiguous Canon marker.
  final List<String> lifePeriodsWithoutCanonStatusMarker;

  /// Life-period anchors with engine/runtime rise/fall metadata attached.
  final List<String> lifePeriodsWithRuntimeStatus;

  /// Feasibility audit wire (e.g. NEEDS_ENGINE_POSITION_METADATA).
  final String? lifePeriodRiseFallFeasibilityResult;

  /// Position-metadata feasibility audit wire.
  final String? lifePeriodPositionFeasibilityResult;

  /// Set when per-period Mahabhut position metadata is blocked.
  final String? lifePeriodPositionMetadataBlocker;

  /// Archetype-context feasibility audit wire.
  final String? lifePeriodArchetypeFeasibilityResult;

  /// Set when archetype chart identity metadata is blocked.
  final String? lifePeriodArchetypeMetadataBlocker;

  /// Remainder-metadata feasibility audit wire.
  final String? remainderFeasibilityResult;

  /// Formula / lookup-table calculation feasibility audit wire.
  final String? remainderCalculationFeasibilityResult;

  /// Set when rotationIndex.remainderN metadata is blocked.
  final String? remainderMetadataBlocker;

  /// Exact profile/engine field used when remainder metadata is present.
  final String? remainderSourceField;

  /// rotationIndex.remainderN when metadata is present.
  final String? remainderCanonId;

  /// Profile anchors with engine remainder metadata attached.
  final List<String> profilesWithRemainderMetadata;

  /// Profile anchors without deterministic remainder metadata.
  final List<String> profilesWithoutRemainderMetadata;

  /// Set when period-status metadata is blocked (e.g. engine gap — not silent).
  final String? lifePeriodStatusMetadataBlocker;

  int get totalUnmappedSignals => inCanonScopeUnmappedSignals.length;
}
