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
    this.profilesWithArchetypeContextMetadata = const [],
    this.profilesWithoutArchetypeContextMetadata = const [],
    this.archetypeMappingSource,
    this.archetypeContextMetadataBlocker,
    this.archetypeChartCanonId,
    this.lifePeriodsWithPeriodContextMetadata = const [],
    this.lifePeriodsWithoutPeriodContextMetadata = const [],
    this.periodContextMetadataBlocker,
    this.periodContextMatchMethods = const [],
    this.periodContextMissingReasons = const [],
    this.periodContextRawMatches = const [],
    this.periodContextNormalizedMatches = const [],
    this.periodContextAmbiguousMatches = const [],
    this.periodContextMissingRuntimeAgeRange = const [],
    this.periodContextMissingCanonAgeRange = const [],
    this.periodContextNormalizationBlocker,
    this.periodContextNormalizationFeasibilityResult,
    this.lifePeriodsWithPositionMetadata = const [],
    this.lifePeriodsWithoutPositionMetadata = const [],
    this.positionMetadataMissingReasons = const [],
    this.positionMetadataEligiblePeriods = const [],
    this.positionMetadataIneligiblePeriods = const [],
    this.positionMatchMethods = const [],
    this.ambiguousArchetypePlanetPairs = const [],
    this.missingArchetypePlanetPairs = const [],
    this.conflictedArchetypePlanetPairs = const [],
    this.archetypePlanetPositionStrategyFeasibilityResult,
    this.lifePeriodsEligibleForRuntimeStatus = const [],
    this.lifePeriodsIneligibleForRuntimeStatus = const [],
    this.runtimeStatusMissingReasons = const [],
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

  /// Profile anchors with archetype context metadata attached.
  final List<String> profilesWithArchetypeContextMetadata;

  /// Profile anchors without archetype context metadata.
  final List<String> profilesWithoutArchetypeContextMetadata;

  /// `canon_structural` or `source_forensics_patch` when metadata is present.
  final String? archetypeMappingSource;

  /// Set when archetype chart identity metadata is blocked.
  final String? archetypeContextMetadataBlocker;

  /// archetypeChart.* when metadata is present.
  final String? archetypeChartCanonId;

  /// Life-period anchors with Canon `life_period` context metadata.
  final List<String> lifePeriodsWithPeriodContextMetadata;

  /// Life-period anchors without period context metadata.
  final List<String> lifePeriodsWithoutPeriodContextMetadata;

  /// Set when period context mapping is blocked.
  final String? periodContextMetadataBlocker;

  /// Match methods used when period context metadata is present.
  final List<String> periodContextMatchMethods;

  /// Explicit missing reasons for unmapped life periods.
  final List<String> periodContextMissingReasons;

  /// Life-period anchors matched via raw structural context.
  final List<String> periodContextRawMatches;

  /// Life-period anchors matched via normalized context key.
  final List<String> periodContextNormalizedMatches;

  /// Life-period anchors with ambiguous normalized/raw candidates.
  final List<String> periodContextAmbiguousMatches;

  /// Periods where runtime lacks structured age range.
  final List<String> periodContextMissingRuntimeAgeRange;

  /// Canon labels in scope lacking parseable age range.
  final List<String> periodContextMissingCanonAgeRange;

  /// Normalization layer blocker.
  final String? periodContextNormalizationBlocker;

  /// Normalization feasibility audit wire.
  final String? periodContextNormalizationFeasibilityResult;

  /// Life-period anchors with Mahabhut position metadata.
  final List<String> lifePeriodsWithPositionMetadata;

  /// Life-period anchors without Mahabhut position metadata.
  final List<String> lifePeriodsWithoutPositionMetadata;

  /// Explicit missing reasons for periods without position metadata.
  final List<String> positionMetadataMissingReasons;

  /// Periods with period context — eligible for position resolution.
  final List<String> positionMetadataEligiblePeriods;

  /// Periods without period context — ineligible for position resolution.
  final List<String> positionMetadataIneligiblePeriods;

  /// Match methods used when position metadata is present.
  final List<String> positionMatchMethods;

  /// archetypeChart.*:planet.* pairs with ambiguous placement evidence.
  final List<String> ambiguousArchetypePlanetPairs;

  /// archetypeChart.*:planet.* pairs with no placement evidence.
  final List<String> missingArchetypePlanetPairs;

  /// archetypeChart.*:planet.* pairs with source-internal position conflict.
  final List<String> conflictedArchetypePlanetPairs;

  /// Placement strategy feasibility audit wire.
  final String? archetypePlanetPositionStrategyFeasibilityResult;

  /// Periods with position metadata — eligible for runtime rise/fall.
  final List<String> lifePeriodsEligibleForRuntimeStatus;

  /// Periods without position metadata — ineligible for runtime rise/fall.
  final List<String> lifePeriodsIneligibleForRuntimeStatus;

  /// Explicit missing reasons when runtime status cannot be resolved.
  final List<String> runtimeStatusMissingReasons;

  /// Set when period-status metadata is blocked (e.g. engine gap — not silent).
  final String? lifePeriodStatusMetadataBlocker;

  int get totalUnmappedSignals => inCanonScopeUnmappedSignals.length;
}
