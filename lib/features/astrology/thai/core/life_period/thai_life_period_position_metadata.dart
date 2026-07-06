import '../../foundation/models/thai_astrology_profile.dart';
import '../../foundation/models/thai_birth_data.dart';
import '../../knowledge/canon/atomic/atomic_knowledge_unit.dart';
import '../../knowledge/canon/atomic/atomic_relation.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_index.dart';
import 'life_period_engine.dart';
import 'thai_archetype_context_metadata.dart';
import 'thai_life_period_context_metadata.dart';
import 'thai_remainder_runtime_metadata.dart';

/// Feasibility outcome for per-life-period Mahabhut position metadata.
enum LifePeriodPositionMetadataFeasibilityResult {
  readyToExposeMetadata,
  partialPositionMetadata,
  needsArchetypeContextMetadata,
  needsPeriodContextMapping,
  blockedByModelingGap,
  blockedBySourceGap,
}

extension LifePeriodPositionMetadataFeasibilityResultWire
    on LifePeriodPositionMetadataFeasibilityResult {
  String get wire => switch (this) {
        LifePeriodPositionMetadataFeasibilityResult.readyToExposeMetadata =>
          'READY_TO_EXPOSE_METADATA',
        LifePeriodPositionMetadataFeasibilityResult.partialPositionMetadata =>
          'PARTIAL_POSITION_METADATA',
        LifePeriodPositionMetadataFeasibilityResult
              .needsArchetypeContextMetadata =>
          'NEEDS_ARCHETYPE_CONTEXT_METADATA',
        LifePeriodPositionMetadataFeasibilityResult.needsPeriodContextMapping =>
          'NEEDS_PERIOD_CONTEXT_MAPPING',
        LifePeriodPositionMetadataFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
        LifePeriodPositionMetadataFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
      };
}

/// Blocker codes when per-period Mahabhut position metadata cannot be exposed.
abstract final class LifePeriodPositionMetadataBlocker {
  static const needsArchetypeContextMetadata =
      'NEEDS_ARCHETYPE_CONTEXT_METADATA';
  static const needsPeriodContextMapping = 'NEEDS_PERIOD_CONTEXT_MAPPING';
  static const partialPositionMetadata = 'PARTIAL_POSITION_METADATA';
  static const blockedByModelingGap = 'BLOCKED_BY_MODELING_GAP';
  static const blockedBySourceGap = 'BLOCKED_BY_SOURCE_GAP';
  static const noLifeTimeline = 'NO_LIFE_TIMELINE';
}

/// Per-period Mahabhut position metadata (internal only — not user-facing).
class ThaiLifePeriodPositionMetadata {
  const ThaiLifePeriodPositionMetadata({
    required this.periodIndex,
    required this.runtimePlanet,
    required this.archetypeChartCanonId,
    required this.canonLifePeriodContextValue,
    required this.mahabhutPositionCanonId,
    required this.canonEvidenceUnitId,
    required this.sourcePage,
    required this.contextType,
    required this.contextValue,
    this.confidence = 'deterministic',
  });

  final int periodIndex;
  final String runtimePlanet;
  final String archetypeChartCanonId;
  final String canonLifePeriodContextValue;
  final String mahabhutPositionCanonId;
  final String canonEvidenceUnitId;
  final String sourcePage;
  final String contextType;
  final String contextValue;
  final String confidence;
}

/// Legacy alias — prefer [ThaiLifePeriodPositionMetadata].
typedef LifePeriodMahabhutPositionMetadata = ThaiLifePeriodPositionMetadata;

class ThaiLifePeriodPositionResolution {
  const ThaiLifePeriodPositionResolution({
    this.metadata,
    this.missingReason,
  });

  final ThaiLifePeriodPositionMetadata? metadata;
  final String? missingReason;
}

/// Deterministic feasibility audit — read-only, no Canon mutation.
class ThaiLifePeriodPositionMetadataFeasibilityAudit {
  const ThaiLifePeriodPositionMetadataFeasibilityAudit({
    required this.result,
    required this.hasGoverningPlanetPerPeriod,
    required this.hasArchetypeChartIdentity,
    required this.hasPeriodContextIdentity,
    required this.hasFullPositionIdentity,
    required this.canMapToCanonWithoutPlanetInference,
    required this.canonLifePeriodPlacementsPresent,
    required this.archetypeFeasibility,
    required this.periodContextFeasibility,
    this.periodCount = 0,
    this.periodsWithContextMetadata = 0,
    this.periodsWithPositionMetadata = 0,
    this.periodsEligibleForPosition = 0,
    this.periodsIneligibleForPosition = 0,
  });

  final LifePeriodPositionMetadataFeasibilityResult result;
  final bool hasGoverningPlanetPerPeriod;
  final bool hasArchetypeChartIdentity;
  final bool hasPeriodContextIdentity;
  final bool hasFullPositionIdentity;
  final bool canMapToCanonWithoutPlanetInference;
  final bool canonLifePeriodPlacementsPresent;
  final ThaiArchetypeContextMetadataFeasibilityAudit archetypeFeasibility;
  final ThaiLifePeriodContextFeasibilityAudit periodContextFeasibility;
  final int periodCount;
  final int periodsWithContextMetadata;
  final int periodsWithPositionMetadata;
  final int periodsEligibleForPosition;
  final int periodsIneligibleForPosition;

  String? get metadataBlocker => switch (result) {
        LifePeriodPositionMetadataFeasibilityResult.readyToExposeMetadata =>
          null,
        LifePeriodPositionMetadataFeasibilityResult.partialPositionMetadata =>
          LifePeriodPositionMetadataBlocker.partialPositionMetadata,
        LifePeriodPositionMetadataFeasibilityResult
              .needsArchetypeContextMetadata =>
          archetypeFeasibility.metadataBlocker ??
              LifePeriodPositionMetadataBlocker.needsArchetypeContextMetadata,
        LifePeriodPositionMetadataFeasibilityResult.needsPeriodContextMapping =>
          LifePeriodPositionMetadataBlocker.needsPeriodContextMapping,
        LifePeriodPositionMetadataFeasibilityResult.blockedByModelingGap =>
          LifePeriodPositionMetadataBlocker.blockedByModelingGap,
        LifePeriodPositionMetadataFeasibilityResult.blockedBySourceGap =>
          LifePeriodPositionMetadataBlocker.blockedBySourceGap,
      };
}

/// Deterministic resolver — requires archetype + period context + planet + Canon.
///
/// Returns null when any input is absent (preferred over guessing).
abstract final class ThaiLifePeriodPositionMetadataResolver {
  static ThaiLifePeriodPositionMetadata? resolve({
    required PeriodState period,
    required ThaiArchetypeContextMetadata? archetypeMetadata,
    required ThaiLifePeriodContextMetadata? periodContextMetadata,
    required ThaiCanonEvidenceIndex? canonIndex,
  }) {
    return resolveDetailed(
      period: period,
      archetypeMetadata: archetypeMetadata,
      periodContextMetadata: periodContextMetadata,
      canonIndex: canonIndex,
    ).metadata;
  }

  static ThaiLifePeriodPositionResolution resolveDetailed({
    required PeriodState period,
    required ThaiArchetypeContextMetadata? archetypeMetadata,
    required ThaiLifePeriodContextMetadata? periodContextMetadata,
    required ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (periodContextMetadata == null) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: 'NO_PERIOD_CONTEXT_METADATA',
      );
    }
    if (archetypeMetadata == null) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: LifePeriodPositionMetadataBlocker.needsArchetypeContextMetadata,
      );
    }
    if (canonIndex == null) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: LifePeriodPositionMetadataBlocker.blockedBySourceGap,
      );
    }

    final archetypeId = archetypeMetadata.archetypeChartCanonId;
    if (archetypeId != periodContextMetadata.archetypeChartCanonId) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: 'ARCHETYPE_CONTEXT_MISMATCH',
      );
    }

    final planetId = 'planet.${period.planet.name}';
    if (periodContextMetadata.runtimePlanet != period.planet.name) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: 'PLANET_MISMATCH',
      );
    }

    final contextValue = periodContextMetadata.canonLifePeriodContextValue;
    final placements = <AtomicKnowledgeUnit>[];

    for (final unitId in periodContextMetadata.canonEvidenceUnitIds) {
      final unit = canonIndex.unitById(unitId);
      if (unit == null) continue;
      if (!_isValidPlacement(
        unit: unit,
        planetId: planetId,
        contextValue: contextValue,
        archetypeChartCanonId: archetypeId,
        canonIndex: canonIndex,
      )) {
        continue;
      }
      placements.add(unit);
    }

    if (placements.isEmpty) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: 'MISSING_CANON_PLACEMENT',
      );
    }

    final positions = placements.map((u) => u.object).toSet();
    if (positions.length > 1) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: 'AMBIGUOUS_MAHABHUT_POSITION',
      );
    }

    final unit = placements.first;
    return ThaiLifePeriodPositionResolution(
      metadata: ThaiLifePeriodPositionMetadata(
        periodIndex: period.index,
        runtimePlanet: period.planet.name,
        archetypeChartCanonId: archetypeId,
        canonLifePeriodContextValue: contextValue,
        mahabhutPositionCanonId: unit.object,
        canonEvidenceUnitId: unit.id,
        sourcePage: unit.evidence.page ?? '',
        contextType: AtomicContextType.lifePeriod.wire,
        contextValue: contextValue,
      ),
    );
  }

  /// Legacy convenience — returns position id only when full metadata path resolves.
  static String? mahabhutPositionCanonId({
    required PeriodState period,
    required String? archetypeChartCanonId,
    required String? periodContextValue,
    ThaiLifePeriodContextMetadata? periodContextMetadata,
    ThaiArchetypeContextMetadata? archetypeMetadata,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (periodContextMetadata != null &&
        archetypeMetadata != null &&
        canonIndex != null) {
      return resolve(
        period: period,
        archetypeMetadata: archetypeMetadata,
        periodContextMetadata: periodContextMetadata,
        canonIndex: canonIndex,
      )?.mahabhutPositionCanonId;
    }
    if (archetypeChartCanonId == null ||
        archetypeChartCanonId.trim().isEmpty ||
        periodContextValue == null ||
        periodContextValue.trim().isEmpty) {
      return null;
    }
    assert(period.planet.name.isNotEmpty);
    return null;
  }

  static bool _isValidPlacement({
    required AtomicKnowledgeUnit unit,
    required String planetId,
    required String contextValue,
    required String archetypeChartCanonId,
    required ThaiCanonEvidenceIndex canonIndex,
  }) {
    if (unit.relation != AtomicRelation.locatedIn) return false;
    if (!unit.object.startsWith('mahabhutPosition.')) return false;
    if (unit.subject != planetId) return false;
    final ctx = unit.context;
    if (ctx == null || ctx.type != AtomicContextType.lifePeriod) return false;
    if (ctx.value != contextValue) return false;

    final pages =
        ThaiArchetypeChartCanonPageIndex.build(canonIndex)[archetypeChartCanonId];
    if (pages == null || pages.isEmpty) return false;
    final page = int.tryParse(unit.evidence.page ?? '');
    if (page == null || !pages.contains(page)) return false;
    return true;
  }

  static Map<int, ThaiLifePeriodPositionMetadata?> resolveAll({
    required LifeTimeline timeline,
    required ThaiArchetypeContextMetadata? archetypeMetadata,
    required Map<int, ThaiLifePeriodContextMetadata?> contextByPeriod,
    required ThaiCanonEvidenceIndex? canonIndex,
  }) {
    final out = <int, ThaiLifePeriodPositionMetadata?>{};
    for (final period in timeline.periods) {
      out[period.index] = resolve(
        period: period,
        archetypeMetadata: archetypeMetadata,
        periodContextMetadata: contextByPeriod[period.index],
        canonIndex: canonIndex,
      );
    }
    return out;
  }
}

/// Audits whether runtime can expose per-period Mahabhut position metadata.
abstract final class ThaiLifePeriodPositionMetadataFeasibility {
  /// Frozen Canon has 215 `life_period` mahabhut placements (Phase D).
  static const canonLifePeriodMahabhutPlacementCount = 215;

  static ThaiLifePeriodPositionMetadataFeasibilityAudit audit({
    LifeTimeline? timeline,
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    final periodContextFeasibility = ThaiLifePeriodContextFeasibility.audit(
      timeline: timeline,
      canonIndex: canonIndex,
    );

    if (timeline == null || timeline.periods.isEmpty) {
      final archetypeFeasibility =
          ThaiArchetypeContextMetadataFeasibility.audit(
        profile: profile,
        birthData: birthData,
        canonIndex: canonIndex,
      );
      return ThaiLifePeriodPositionMetadataFeasibilityAudit(
        result: LifePeriodPositionMetadataFeasibilityResult
            .needsArchetypeContextMetadata,
        hasGoverningPlanetPerPeriod: false,
        hasArchetypeChartIdentity: false,
        hasPeriodContextIdentity: false,
        hasFullPositionIdentity: false,
        canMapToCanonWithoutPlanetInference: false,
        canonLifePeriodPlacementsPresent: true,
        archetypeFeasibility: archetypeFeasibility,
        periodContextFeasibility: periodContextFeasibility,
      );
    }

    final archetypeFeasibility = ThaiArchetypeContextMetadataFeasibility.audit(
      profile: profile,
      birthData: birthData,
      canonIndex: canonIndex,
    );

    final archetypeMetadata = ThaiArchetypeContextResolver.resolve(
      remainderMetadata: ThaiRemainderMetadataResolver.resolve(
        profile: profile,
        birthData: birthData,
      ),
      canonIndex: canonIndex,
    ).metadata;

    final hasPlanet = timeline.periods.every((p) => p.planet.name.isNotEmpty);

    final hasArchetype =
        archetypeFeasibility.result ==
        ArchetypeContextMetadataFeasibilityResult.readyToExposeMetadata;

    final contextByPeriod = ThaiLifePeriodContextResolver.resolveAll(
      timeline: timeline,
      archetypeMetadata: archetypeMetadata,
      canonIndex: canonIndex,
    );
    final periodsWithContext =
        contextByPeriod.values.where((m) => m != null).length;
    final hasPeriodContext = periodsWithContext == timeline.periods.length;

    final positionByPeriod = ThaiLifePeriodPositionMetadataResolver.resolveAll(
      timeline: timeline,
      archetypeMetadata: archetypeMetadata,
      contextByPeriod: contextByPeriod,
      canonIndex: canonIndex,
    );
    final periodsWithPosition =
        positionByPeriod.values.where((m) => m != null).length;
    final hasFullPosition =
        periodsWithPosition == timeline.periods.length;

    final canMapWithoutPlanetInference =
        hasArchetype && hasPeriodContext && hasPlanet;

    final result = _classify(
      hasPlanet: hasPlanet,
      hasArchetype: hasArchetype,
      hasPeriodContext: hasPeriodContext,
      hasFullPosition: hasFullPosition,
      periodsWithPosition: periodsWithPosition,
      periodContextReady: periodContextFeasibility.result ==
          PeriodContextMappingFeasibilityResult.readyToMapPeriodContext,
    );

    return ThaiLifePeriodPositionMetadataFeasibilityAudit(
      result: result,
      hasGoverningPlanetPerPeriod: hasPlanet,
      hasArchetypeChartIdentity: hasArchetype,
      hasPeriodContextIdentity: hasPeriodContext,
      hasFullPositionIdentity: hasFullPosition,
      canMapToCanonWithoutPlanetInference: canMapWithoutPlanetInference,
      canonLifePeriodPlacementsPresent: true,
      archetypeFeasibility: archetypeFeasibility,
      periodContextFeasibility: periodContextFeasibility,
      periodCount: timeline.periods.length,
      periodsWithContextMetadata: periodsWithContext,
      periodsWithPositionMetadata: periodsWithPosition,
      periodsEligibleForPosition: periodsWithContext,
      periodsIneligibleForPosition:
          timeline.periods.length - periodsWithContext,
    );
  }

  static LifePeriodPositionMetadataFeasibilityResult _classify({
    required bool hasPlanet,
    required bool hasArchetype,
    required bool hasPeriodContext,
    required bool hasFullPosition,
    required int periodsWithPosition,
    required bool periodContextReady,
  }) {
    if (!hasPlanet || !hasArchetype) {
      return LifePeriodPositionMetadataFeasibilityResult
          .needsArchetypeContextMetadata;
    }
    if (!periodContextReady) {
      return LifePeriodPositionMetadataFeasibilityResult
          .needsPeriodContextMapping;
    }
    if (hasFullPosition) {
      return LifePeriodPositionMetadataFeasibilityResult.readyToExposeMetadata;
    }
    if (periodsWithPosition > 0) {
      return LifePeriodPositionMetadataFeasibilityResult.partialPositionMetadata;
    }
    return LifePeriodPositionMetadataFeasibilityResult.needsPeriodContextMapping;
  }
}
