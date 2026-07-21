import '../../knowledge/canon/atomic/atomic_relation.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_index.dart';
import 'life_period_engine.dart';
import 'thai_archetype_context_metadata.dart';
import 'thai_archetype_planet_placement_index.dart';
import 'thai_life_period_position_metadata.dart';

/// Resolves Mahabhut position from archetype chart + governing planet only.
///
/// Does not use period context, sequence, or age order.
abstract final class ThaiLifePeriodArchetypePlanetPositionResolver {
  static ThaiLifePeriodPositionMetadata? resolve({
    required PeriodState period,
    required ThaiArchetypeContextMetadata? archetypeMetadata,
    ThaiArchetypePlanetPlacementIndex? placementIndex,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    return resolveDetailed(
      period: period,
      archetypeMetadata: archetypeMetadata,
      placementIndex: placementIndex,
      canonIndex: canonIndex,
    ).metadata;
  }

  static ThaiLifePeriodPositionResolution resolveDetailed({
    required PeriodState period,
    required ThaiArchetypeContextMetadata? archetypeMetadata,
    ThaiArchetypePlanetPlacementIndex? placementIndex,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (archetypeMetadata == null) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: LifePeriodPositionMetadataBlocker.needsArchetypeContextMetadata,
      );
    }
    if (placementIndex == null) {
      if (canonIndex == null) {
        return const ThaiLifePeriodPositionResolution(
          missingReason: LifePeriodPositionMetadataBlocker.blockedBySourceGap,
        );
      }
      return resolveDetailed(
        period: period,
        archetypeMetadata: archetypeMetadata,
        placementIndex: ThaiArchetypePlanetPlacementIndex.build(canonIndex),
        canonIndex: canonIndex,
      );
    }

    final planetId = 'planet.${period.planet.name}';
    final entry = placementIndex.entryFor(
      archetypeChartCanonId: archetypeMetadata.archetypeChartCanonId,
      planetCanonId: planetId,
    );

    if (entry == null) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: 'MISSING_ARCHETYPE_PLANET_PLACEMENT',
      );
    }

    return switch (entry.classification) {
      ArchetypePlanetPlacementClassification.uniquePosition =>
        _fromUniqueEntry(period: period, archetypeMetadata: archetypeMetadata, entry: entry),
      ArchetypePlanetPlacementClassification.missingPosition =>
        const ThaiLifePeriodPositionResolution(
          missingReason: 'MISSING_ARCHETYPE_PLANET_PLACEMENT',
        ),
      ArchetypePlanetPlacementClassification.ambiguousPosition =>
        ThaiLifePeriodPositionResolution(
          missingReason: 'AMBIGUOUS_ARCHETYPE_PLANET_PLACEMENT',
          ambiguousPositions: entry.distinctPositions.toList()..sort(),
        ),
      ArchetypePlanetPlacementClassification.sourceConflict =>
        ThaiLifePeriodPositionResolution(
          missingReason: 'SOURCE_CONFLICT_ARCHETYPE_PLANET_PLACEMENT',
          ambiguousPositions: entry.distinctPositions.toList()..sort(),
        ),
      ArchetypePlanetPlacementClassification.ocrBlocked =>
        const ThaiLifePeriodPositionResolution(
          missingReason: 'OCR_BLOCKED_ARCHETYPE_PLANET_PLACEMENT',
        ),
    };
  }

  static ThaiLifePeriodPositionResolution _fromUniqueEntry({
    required PeriodState period,
    required ThaiArchetypeContextMetadata archetypeMetadata,
    required ArchetypePlanetPlacementEntry entry,
  }) {
    final positionId = entry.uniquePositionCanonId;
    if (positionId == null || entry.units.isEmpty) {
      return const ThaiLifePeriodPositionResolution(
        missingReason: 'MISSING_ARCHETYPE_PLANET_PLACEMENT',
      );
    }

    final unitIds = entry.units.map((u) => u.id).toList()..sort();
    final pages = entry.units
        .map((u) => u.evidence.page)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    final primary = entry.units.first;
    final contextType = primary.context?.type.wire ?? '';
    final contextValue = primary.context?.value ?? '';

    return ThaiLifePeriodPositionResolution(
      metadata: ThaiLifePeriodPositionMetadata(
        periodIndex: period.index,
        runtimePlanet: period.planet.name,
        archetypeChartCanonId: archetypeMetadata.archetypeChartCanonId,
        mahabhutPositionCanonId: positionId,
        canonEvidenceUnitIds: unitIds,
        sourcePages: pages,
        matchMethod: PositionMatchMethod.archetypePlanetUniquePosition,
        contextType: contextType,
        contextValue: contextValue,
      ),
    );
  }
}
