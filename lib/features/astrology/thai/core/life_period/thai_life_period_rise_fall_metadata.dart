import '../../foundation/models/thai_astrology_profile.dart';
import '../../foundation/models/thai_birth_data.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_index.dart';
import '../../knowledge/canon/integration/thai_canon_period_status_runtime_mapping.dart';
import 'life_period_engine.dart';
import 'thai_archetype_context_metadata.dart';
import 'thai_life_period_context_metadata.dart';
import 'thai_life_period_position_metadata.dart';
import 'thai_remainder_runtime_metadata.dart';

/// Allowed Canon ids for internal period-status metadata (when available).
abstract final class LifePeriodStatusMetadataValues {
  static const duengKhuen = 'periodStatus.duengKhuen';
  static const duengTok = 'periodStatus.duengTok';

  static const allowedCanonIds = {duengKhuen, duengTok};
}

/// Blocker codes when period-status metadata cannot be exposed.
abstract final class LifePeriodStatusMetadataBlocker {
  static const needsEnginePositionMetadata = 'NEEDS_ENGINE_POSITION_METADATA';
  static const partialRuntimeStatusMetadata = 'PARTIAL_RUNTIME_STATUS_METADATA';

  /// Legacy trace alias — superseded by [needsEnginePositionMetadata].
  static const blockedByRuntimeStatusAbsence = needsEnginePositionMetadata;

  static const noLifeTimeline = 'NO_LIFE_TIMELINE';
}

/// Feasibility outcome for engine life-period rise/fall metadata.
enum LifePeriodRiseFallFeasibilityResult {
  readyToExposeMetadata,
  partialRuntimeStatusMetadata,
  needsEnginePositionMetadata,
  blockedByModelingGap,
  blockedBySourceGap,
}

extension LifePeriodRiseFallFeasibilityResultWire on
    LifePeriodRiseFallFeasibilityResult {
  String get wire => switch (this) {
        LifePeriodRiseFallFeasibilityResult.readyToExposeMetadata =>
          'READY_TO_EXPOSE_METADATA',
        LifePeriodRiseFallFeasibilityResult.partialRuntimeStatusMetadata =>
          'PARTIAL_RUNTIME_STATUS_METADATA',
        LifePeriodRiseFallFeasibilityResult.needsEnginePositionMetadata =>
          'NEEDS_ENGINE_POSITION_METADATA',
        LifePeriodRiseFallFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
        LifePeriodRiseFallFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
      };
}

/// Deterministic feasibility audit — read-only, no Canon mutation.
class ThaiLifePeriodRiseFallFeasibilityAudit {
  const ThaiLifePeriodRiseFallFeasibilityAudit({
    required this.result,
    required this.hasGoverningPlanetPerPeriod,
    required this.hasPerPeriodMahabhutPosition,
    required this.hasPerPeriodArchetypeContext,
    required this.hasExistingRiseFallField,
    required this.canClassifyFromExistingFields,
    this.periodCount = 0,
    this.periodsWithPositionMetadata = 0,
    this.periodsWithRuntimeStatus = 0,
    this.periodsEligibleForRiseFall = 0,
    this.periodsIneligibleForRiseFall = 0,
  });

  final LifePeriodRiseFallFeasibilityResult result;
  final bool hasGoverningPlanetPerPeriod;
  final bool hasPerPeriodMahabhutPosition;
  final bool hasPerPeriodArchetypeContext;
  final bool hasExistingRiseFallField;
  final bool canClassifyFromExistingFields;
  final int periodCount;
  final int periodsWithPositionMetadata;
  final int periodsWithRuntimeStatus;
  final int periodsEligibleForRiseFall;
  final int periodsIneligibleForRiseFall;

  String? get metadataBlocker => switch (result) {
        LifePeriodRiseFallFeasibilityResult.readyToExposeMetadata => null,
        LifePeriodRiseFallFeasibilityResult.partialRuntimeStatusMetadata =>
          LifePeriodStatusMetadataBlocker.partialRuntimeStatusMetadata,
        LifePeriodRiseFallFeasibilityResult.needsEnginePositionMetadata =>
          LifePeriodStatusMetadataBlocker.needsEnginePositionMetadata,
        LifePeriodRiseFallFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
        LifePeriodRiseFallFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
      };
}

/// Internal rise/fall status values (Canon ids).
enum LifePeriodRiseFallStatus {
  duengKhuen,
  duengTok,
}

extension LifePeriodRiseFallStatusCanon on LifePeriodRiseFallStatus {
  String get canonId => switch (this) {
        LifePeriodRiseFallStatus.duengKhuen =>
          LifePeriodStatusMetadataValues.duengKhuen,
        LifePeriodRiseFallStatus.duengTok =>
          LifePeriodStatusMetadataValues.duengTok,
      };
}

/// Frozen Canon p17 rise/fall position sets (structural rules only).
abstract final class ThaiLifePeriodRiseFallP17Rules {
  static const risePositionIds = {
    'mahabhutPosition.thongchai',
    'mahabhutPosition.khumsap',
    'mahabhutPosition.racha',
    'mahabhutPosition.athibodi',
  };

  static const fallPositionIds = {
    'mahabhutPosition.phangkha',
    'mahabhutPosition.marana',
    'mahabhutPosition.puti',
  };
}

/// Internal runtime rise/fall metadata (not user-facing).
class ThaiLifePeriodRiseFallRuntimeMetadata {
  const ThaiLifePeriodRiseFallRuntimeMetadata({
    required this.periodIndex,
    required this.periodStatusCanonId,
    required this.periodStatusLabel,
    required this.mahabhutPositionCanonId,
    required this.positionEvidenceUnitId,
    this.statusEvidenceUnitId,
    this.sourcePage,
    this.source = 'runtime_position_plus_canon_rule',
    this.confidence = 'deterministic',
  });

  final int periodIndex;
  final String periodStatusCanonId;
  final String periodStatusLabel;
  final String mahabhutPositionCanonId;
  final String positionEvidenceUnitId;
  final String? statusEvidenceUnitId;
  final String? sourcePage;
  final String source;
  final String confidence;
}

class ThaiLifePeriodRiseFallResolution {
  const ThaiLifePeriodRiseFallResolution({
    this.metadata,
    this.missingReason,
  });

  final ThaiLifePeriodRiseFallRuntimeMetadata? metadata;
  final String? missingReason;
}

/// Deterministic resolver — requires per-period Mahabhut position input.
///
/// Returns null when [positionMetadata] is absent (preferred over guessing).
abstract final class ThaiLifePeriodRiseFallResolver {
  static const sourceRuntimePositionPlusCanonRule =
      'runtime_position_plus_canon_rule';

  static String? canonIdForMahabhutPosition(String? mahabhutPositionCanonId) {
    if (mahabhutPositionCanonId == null ||
        mahabhutPositionCanonId.trim().isEmpty) {
      return null;
    }
    if (ThaiLifePeriodRiseFallP17Rules.risePositionIds
        .contains(mahabhutPositionCanonId)) {
      return LifePeriodStatusMetadataValues.duengKhuen;
    }
    if (ThaiLifePeriodRiseFallP17Rules.fallPositionIds
        .contains(mahabhutPositionCanonId)) {
      return LifePeriodStatusMetadataValues.duengTok;
    }
    return null;
  }

  static String? canonIdForPeriod({
    required PeriodState period,
    required String? mahabhutPositionCanonId,
  }) {
    assert(period.planet.name.isNotEmpty);
    return canonIdForMahabhutPosition(mahabhutPositionCanonId);
  }

  static ThaiLifePeriodRiseFallRuntimeMetadata? resolve({
    required PeriodState period,
    required ThaiLifePeriodPositionMetadata? positionMetadata,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    return resolveDetailed(
      period: period,
      positionMetadata: positionMetadata,
      canonIndex: canonIndex,
    ).metadata;
  }

  static ThaiLifePeriodRiseFallResolution resolveDetailed({
    required PeriodState period,
    required ThaiLifePeriodPositionMetadata? positionMetadata,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (positionMetadata == null) {
      return const ThaiLifePeriodRiseFallResolution(
        missingReason: 'NO_POSITION_METADATA',
      );
    }

    final statusCanonId =
        canonIdForMahabhutPosition(positionMetadata.mahabhutPositionCanonId);
    if (statusCanonId == null) {
      return const ThaiLifePeriodRiseFallResolution(
        missingReason: 'NO_P17_RULE_FOR_POSITION',
      );
    }

    if (!LifePeriodStatusMetadataValues.allowedCanonIds
        .contains(statusCanonId)) {
      return const ThaiLifePeriodRiseFallResolution(
        missingReason: 'DISALLOWED_STATUS_CANON_ID',
      );
    }

    final label =
        ThaiCanonPeriodStatusRuntimeMapping.runtimeLabelForCanonId(statusCanonId);
    if (label == null) {
      return const ThaiLifePeriodRiseFallResolution(
        missingReason: 'NO_RUNTIME_LABEL_FOR_STATUS',
      );
    }

    String? statusEvidenceUnitId;
    String? sourcePage = positionMetadata.sourcePage;
    if (canonIndex != null) {
      final statusUnits = canonIndex.bySubject(statusCanonId);
      if (statusUnits.isNotEmpty) {
        statusEvidenceUnitId = statusUnits.first.id;
        sourcePage ??= statusUnits.first.evidence.page;
      }
    }

    return ThaiLifePeriodRiseFallResolution(
      metadata: ThaiLifePeriodRiseFallRuntimeMetadata(
        periodIndex: period.index,
        periodStatusCanonId: statusCanonId,
        periodStatusLabel: label,
        mahabhutPositionCanonId: positionMetadata.mahabhutPositionCanonId,
        positionEvidenceUnitId: positionMetadata.canonEvidenceUnitId,
        statusEvidenceUnitId: statusEvidenceUnitId,
        sourcePage: sourcePage,
      ),
    );
  }

  static Map<int, ThaiLifePeriodRiseFallRuntimeMetadata?> resolveAll({
    required LifeTimeline timeline,
    required ThaiArchetypeContextMetadata? archetypeMetadata,
    required Map<int, ThaiLifePeriodPositionMetadata?> positionByPeriod,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    final out = <int, ThaiLifePeriodRiseFallRuntimeMetadata?>{};
    for (final period in timeline.periods) {
      out[period.index] = resolve(
        period: period,
        positionMetadata: positionByPeriod[period.index],
        canonIndex: canonIndex,
      );
    }
    return out;
  }
}

/// Audits whether runtime can expose rise/fall metadata without new astrology.
abstract final class ThaiLifePeriodRiseFallFeasibility {
  static ThaiLifePeriodRiseFallFeasibilityAudit audit({
    LifeTimeline? timeline,
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
    int? periodsWithRuntimeStatus,
  }) {
    if (timeline == null || timeline.periods.isEmpty) {
      return const ThaiLifePeriodRiseFallFeasibilityAudit(
        result: LifePeriodRiseFallFeasibilityResult.needsEnginePositionMetadata,
        hasGoverningPlanetPerPeriod: false,
        hasPerPeriodMahabhutPosition: false,
        hasPerPeriodArchetypeContext: false,
        hasExistingRiseFallField: false,
        canClassifyFromExistingFields: false,
      );
    }

    final positionAudit = ThaiLifePeriodPositionMetadataFeasibility.audit(
      timeline: timeline,
      profile: profile,
      birthData: birthData,
      canonIndex: canonIndex,
    );

    final runtimeCount = periodsWithRuntimeStatus ??
        _countResolvedRuntimeStatus(
          timeline: timeline,
          profile: profile,
          birthData: birthData,
          canonIndex: canonIndex,
        );

    final hasPlanet = positionAudit.hasGoverningPlanetPerPeriod;
    final hasArchetype = positionAudit.hasArchetypeChartIdentity;
    final hasFullPosition = positionAudit.hasFullPositionIdentity;
    final hasRiseFallField = runtimeCount > 0;
    final hasFullRuntime = runtimeCount == timeline.periods.length;

    final result = _classify(
      runtimeCount: runtimeCount,
      periodCount: timeline.periods.length,
      positionCount: positionAudit.periodsWithPositionMetadata,
    );

    return ThaiLifePeriodRiseFallFeasibilityAudit(
      result: result,
      hasGoverningPlanetPerPeriod: hasPlanet,
      hasPerPeriodMahabhutPosition: hasFullPosition,
      hasPerPeriodArchetypeContext: hasArchetype,
      hasExistingRiseFallField: hasRiseFallField,
      canClassifyFromExistingFields: hasFullRuntime && hasArchetype,
      periodCount: timeline.periods.length,
      periodsWithPositionMetadata: positionAudit.periodsWithPositionMetadata,
      periodsWithRuntimeStatus: runtimeCount,
      periodsEligibleForRiseFall: positionAudit.periodsWithPositionMetadata,
      periodsIneligibleForRiseFall:
          timeline.periods.length - positionAudit.periodsWithPositionMetadata,
    );
  }

  static LifePeriodRiseFallFeasibilityResult _classify({
    required int runtimeCount,
    required int periodCount,
    required int positionCount,
  }) {
    if (runtimeCount == periodCount && periodCount > 0) {
      return LifePeriodRiseFallFeasibilityResult.readyToExposeMetadata;
    }
    if (runtimeCount > 0) {
      return LifePeriodRiseFallFeasibilityResult.partialRuntimeStatusMetadata;
    }
    if (positionCount > 0) {
      return LifePeriodRiseFallFeasibilityResult.needsEnginePositionMetadata;
    }
    return LifePeriodRiseFallFeasibilityResult.needsEnginePositionMetadata;
  }

  static int _countResolvedRuntimeStatus({
    required LifeTimeline timeline,
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (canonIndex == null) return 0;

    final archetypeMetadata = ThaiArchetypeContextResolver.resolve(
      remainderMetadata: ThaiRemainderMetadataResolver.resolve(
        profile: profile,
        birthData: birthData,
      ),
      canonIndex: canonIndex,
    ).metadata;

    final contextByPeriod = ThaiLifePeriodContextResolver.resolveAll(
      timeline: timeline,
      archetypeMetadata: archetypeMetadata,
      canonIndex: canonIndex,
    );
    final positionByPeriod = ThaiLifePeriodPositionMetadataResolver.resolveAll(
      timeline: timeline,
      archetypeMetadata: archetypeMetadata,
      contextByPeriod: contextByPeriod,
      canonIndex: canonIndex,
    );
    final runtimeByPeriod = ThaiLifePeriodRiseFallResolver.resolveAll(
      timeline: timeline,
      archetypeMetadata: archetypeMetadata,
      positionByPeriod: positionByPeriod,
      canonIndex: canonIndex,
    );

    return runtimeByPeriod.values.where((m) => m != null).length;
  }
}
