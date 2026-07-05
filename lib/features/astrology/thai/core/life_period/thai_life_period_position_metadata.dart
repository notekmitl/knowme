import '../../foundation/models/thai_astrology_profile.dart';
import 'life_period_engine.dart';

/// Feasibility outcome for per-life-period Mahabhut position metadata.
enum LifePeriodPositionMetadataFeasibilityResult {
  readyToExposeMetadata,
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
  static const blockedByModelingGap = 'BLOCKED_BY_MODELING_GAP';
  static const blockedBySourceGap = 'BLOCKED_BY_SOURCE_GAP';
  static const noLifeTimeline = 'NO_LIFE_TIMELINE';
}

/// Per-period Mahabhut position metadata (internal only — not user-facing).
class LifePeriodMahabhutPositionMetadata {
  const LifePeriodMahabhutPositionMetadata({
    required this.mahabhutPositionCanonId,
    this.archetypeChartCanonId,
    this.periodContextValue,
  });

  final String mahabhutPositionCanonId;
  final String? archetypeChartCanonId;
  final String? periodContextValue;
}

/// Deterministic feasibility audit — read-only, no Canon mutation.
class ThaiLifePeriodPositionMetadataFeasibilityAudit {
  const ThaiLifePeriodPositionMetadataFeasibilityAudit({
    required this.result,
    required this.hasGoverningPlanetPerPeriod,
    required this.hasArchetypeChartIdentity,
    required this.hasPeriodContextIdentity,
    required this.canMapToCanonWithoutPlanetInference,
    required this.canonLifePeriodPlacementsPresent,
    this.periodCount = 0,
  });

  final LifePeriodPositionMetadataFeasibilityResult result;
  final bool hasGoverningPlanetPerPeriod;
  final bool hasArchetypeChartIdentity;
  final bool hasPeriodContextIdentity;
  final bool canMapToCanonWithoutPlanetInference;
  final bool canonLifePeriodPlacementsPresent;
  final int periodCount;

  String? get metadataBlocker => switch (result) {
        LifePeriodPositionMetadataFeasibilityResult.readyToExposeMetadata =>
          null,
        LifePeriodPositionMetadataFeasibilityResult
              .needsArchetypeContextMetadata =>
          LifePeriodPositionMetadataBlocker.needsArchetypeContextMetadata,
        LifePeriodPositionMetadataFeasibilityResult.needsPeriodContextMapping =>
          LifePeriodPositionMetadataBlocker.needsPeriodContextMapping,
        LifePeriodPositionMetadataFeasibilityResult.blockedByModelingGap =>
          LifePeriodPositionMetadataBlocker.blockedByModelingGap,
        LifePeriodPositionMetadataFeasibilityResult.blockedBySourceGap =>
          LifePeriodPositionMetadataBlocker.blockedBySourceGap,
      };
}

/// Deterministic resolver — requires archetype + period context + planet.
///
/// Returns null when any input is absent (preferred over guessing).
abstract final class ThaiLifePeriodPositionMetadataResolver {
  static String? mahabhutPositionCanonId({
    required PeriodState period,
    required String? archetypeChartCanonId,
    required String? periodContextValue,
  }) {
    if (archetypeChartCanonId == null ||
        archetypeChartCanonId.trim().isEmpty ||
        periodContextValue == null ||
        periodContextValue.trim().isEmpty) {
      return null;
    }
    assert(period.planet.name.isNotEmpty);
    // Production wiring deferred until runtime exposes scoped identity inputs.
    return null;
  }
}

/// Audits whether runtime can expose per-period Mahabhut position metadata.
abstract final class ThaiLifePeriodPositionMetadataFeasibility {
  /// Frozen Canon has 215 `life_period` mahabhut placements (Phase D).
  static const canonLifePeriodMahabhutPlacementCount = 215;

  static ThaiLifePeriodPositionMetadataFeasibilityAudit audit({
    LifeTimeline? timeline,
    ThaiAstrologyProfile? profile,
  }) {
    if (timeline == null || timeline.periods.isEmpty) {
      return const ThaiLifePeriodPositionMetadataFeasibilityAudit(
        result: LifePeriodPositionMetadataFeasibilityResult
            .needsArchetypeContextMetadata,
        hasGoverningPlanetPerPeriod: false,
        hasArchetypeChartIdentity: false,
        hasPeriodContextIdentity: false,
        canMapToCanonWithoutPlanetInference: false,
        canonLifePeriodPlacementsPresent: true,
      );
    }

    final hasPlanet = timeline.periods.every((p) => p.planet.name.isNotEmpty);

    // Runtime profile exposes natal mahabhuta keys only — not archetype chart id.
    final hasArchetype = _hasArchetypeChartIdentity(profile);

    // No deterministic map from PeriodState ages → Canon life_period context value.
    final hasPeriodContext = _hasPeriodContextIdentity(timeline);

    // Canon life_period placements require archetype disambiguation — same planet +
    // life_period label can map to different mahabhutPosition.* across archetypes.
    final canMapWithoutPlanetInference =
        hasArchetype && hasPeriodContext && hasPlanet;

    final result = _classify(
      hasPlanet: hasPlanet,
      hasArchetype: hasArchetype,
      hasPeriodContext: hasPeriodContext,
    );

    return ThaiLifePeriodPositionMetadataFeasibilityAudit(
      result: result,
      hasGoverningPlanetPerPeriod: hasPlanet,
      hasArchetypeChartIdentity: hasArchetype,
      hasPeriodContextIdentity: hasPeriodContext,
      canMapToCanonWithoutPlanetInference: canMapWithoutPlanetInference,
      canonLifePeriodPlacementsPresent: true,
      periodCount: timeline.periods.length,
    );
  }

  static LifePeriodPositionMetadataFeasibilityResult _classify({
    required bool hasPlanet,
    required bool hasArchetype,
    required bool hasPeriodContext,
  }) {
    if (!hasPlanet) {
      return LifePeriodPositionMetadataFeasibilityResult
          .needsArchetypeContextMetadata;
    }
    if (!hasArchetype) {
      return LifePeriodPositionMetadataFeasibilityResult
          .needsArchetypeContextMetadata;
    }
    if (!hasPeriodContext) {
      return LifePeriodPositionMetadataFeasibilityResult
          .needsPeriodContextMapping;
    }
    return LifePeriodPositionMetadataFeasibilityResult.readyToExposeMetadata;
  }

  static bool _hasArchetypeChartIdentity(ThaiAstrologyProfile? profile) {
    if (profile == null) return false;
    // No runtime field exposes which frozen archetypeChart.* applies to the user.
    return false;
  }

  static bool _hasPeriodContextIdentity(LifeTimeline timeline) {
    // PeriodState carries numeric ages only — no Canon life_period context value.
    for (final period in timeline.periods) {
      if (period.startAge <= 0 || period.endAge < period.startAge) {
        return false;
      }
    }
    return false;
  }
}
