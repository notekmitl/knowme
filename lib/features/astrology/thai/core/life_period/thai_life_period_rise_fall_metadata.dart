import '../../foundation/models/thai_astrology_profile.dart';
import 'life_period_engine.dart';

/// Allowed Canon ids for internal period-status metadata (when available).
abstract final class LifePeriodStatusMetadataValues {
  static const duengKhuen = 'periodStatus.duengKhuen';
  static const duengTok = 'periodStatus.duengTok';

  static const allowedCanonIds = {duengKhuen, duengTok};
}

/// Blocker codes when period-status metadata cannot be exposed.
abstract final class LifePeriodStatusMetadataBlocker {
  static const needsEnginePositionMetadata = 'NEEDS_ENGINE_POSITION_METADATA';

  /// Legacy trace alias — superseded by [needsEnginePositionMetadata].
  static const blockedByRuntimeStatusAbsence = needsEnginePositionMetadata;

  static const noLifeTimeline = 'NO_LIFE_TIMELINE';
}

/// Feasibility outcome for engine life-period rise/fall metadata.
enum LifePeriodRiseFallFeasibilityResult {
  readyToExposeMetadata,
  needsEnginePositionMetadata,
  blockedByModelingGap,
  blockedBySourceGap,
}

extension LifePeriodRiseFallFeasibilityResultWire on
    LifePeriodRiseFallFeasibilityResult {
  String get wire => switch (this) {
        LifePeriodRiseFallFeasibilityResult.readyToExposeMetadata =>
          'READY_TO_EXPOSE_METADATA',
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
  });

  final LifePeriodRiseFallFeasibilityResult result;
  final bool hasGoverningPlanetPerPeriod;
  final bool hasPerPeriodMahabhutPosition;
  final bool hasPerPeriodArchetypeContext;
  final bool hasExistingRiseFallField;
  final bool canClassifyFromExistingFields;
  final int periodCount;

  String? get metadataBlocker => switch (result) {
        LifePeriodRiseFallFeasibilityResult.readyToExposeMetadata => null,
        LifePeriodRiseFallFeasibilityResult.needsEnginePositionMetadata =>
          'NEEDS_ENGINE_POSITION_METADATA',
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

/// Deterministic resolver — requires per-period Mahabhut position input.
///
/// Returns null when [mahabhutPositionCanonId] is absent (preferred over guessing).
abstract final class ThaiLifePeriodRiseFallResolver {
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
    // Period planet is available but insufficient alone — position required.
    assert(period.planet.name.isNotEmpty);
    return canonIdForMahabhutPosition(mahabhutPositionCanonId);
  }
}

/// Audits whether runtime can expose rise/fall metadata without new astrology.
abstract final class ThaiLifePeriodRiseFallFeasibility {
  static ThaiLifePeriodRiseFallFeasibilityAudit audit({
    LifeTimeline? timeline,
    ThaiAstrologyProfile? profile,
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

    final hasPlanet = timeline.periods.every((p) => p.planet.name.isNotEmpty);

    // Natal Mahabhut keys exist on profile but are not keyed by life-period index.
    final hasPerPeriodPosition = false;

    // Archetype chart context exists in frozen Canon life_period units only.
    final hasArchetype = false;

    final hasRiseFallField = false;

    final canClassify = hasPlanet && hasPerPeriodPosition && hasArchetype;

    final result = canClassify
        ? LifePeriodRiseFallFeasibilityResult.readyToExposeMetadata
        : LifePeriodRiseFallFeasibilityResult.needsEnginePositionMetadata;

    return ThaiLifePeriodRiseFallFeasibilityAudit(
      result: result,
      hasGoverningPlanetPerPeriod: hasPlanet,
      hasPerPeriodMahabhutPosition: hasPerPeriodPosition,
      hasPerPeriodArchetypeContext: hasArchetype,
      hasExistingRiseFallField: hasRiseFallField,
      canClassifyFromExistingFields: canClassify,
      periodCount: timeline.periods.length,
    );
  }
}
