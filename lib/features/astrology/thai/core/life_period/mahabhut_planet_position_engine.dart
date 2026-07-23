import '../../knowledge/canon/integration/thai_canon_evidence_index.dart';
import '../../knowledge/canon/ontology/canon_ontology_data.dart';
import 'life_period_engine.dart';
import 'life_planet.dart';
import 'thai_archetype_context_metadata.dart';
import 'thai_archetype_planet_placement_index.dart';
import 'thai_life_period_archetype_planet_position_resolver.dart';
import 'thai_life_period_context_metadata.dart';
import 'thai_life_period_position_metadata.dart';

/// User-facing Mahabhut position for Life Map — never invents a name.
class MahabhutPlanetPosition {
  const MahabhutPlanetPosition({
    required this.planet,
    required this.periodIndex,
    required this.known,
    this.canonId,
    this.thaiName,
    this.unknownReason,
  });

  final LifePlanet planet;
  final int periodIndex;
  final bool known;
  final String? canonId;

  /// Canon Thai surface form only when [known] is true.
  final String? thaiName;

  /// Machine reason when unknown (for tests / traces — UI shows soft copy).
  final String? unknownReason;

  static const unknownLabel = 'ยังยืนยันตำแหน่งไม่ได้';

  String get displayLabel => known ? (thaiName ?? unknownLabel) : unknownLabel;
}

/// Bridges existing Canon placement resolvers into Life Map presentation.
///
/// Shows a real Thai name **only** when Canon yields a unique confirmed
/// `mahabhutPosition.*`. Ambiguous / missing / conflict → unknown.
abstract final class MahabhutPlanetPositionEngine {
  /// Canon id → primary Thai alias (vocabulary only; no invented ราชาโชค).
  static String? thaiNameForCanonId(String? canonId) {
    if (canonId == null || canonId.isEmpty) return null;
    for (final entity in CanonOntologyData.mahabhutPositions) {
      if (entity.id == canonId) {
        return entity.aliases.isNotEmpty ? entity.aliases.first : null;
      }
    }
    return null;
  }

  static MahabhutPlanetPosition resolve({
    required PeriodState period,
    ThaiArchetypeContextMetadata? archetypeMetadata,
    ThaiLifePeriodContextMetadata? periodContextMetadata,
    ThaiCanonEvidenceIndex? canonIndex,
    ThaiArchetypePlanetPlacementIndex? placementIndex,
  }) {
    final metadata = ThaiLifePeriodPositionMetadataResolver.resolveCombined(
      period: period,
      archetypeMetadata: archetypeMetadata,
      periodContextMetadata: periodContextMetadata,
      canonIndex: canonIndex,
      placementIndex: placementIndex,
    );

    if (metadata == null) {
      final detailed = periodContextMetadata != null
          ? ThaiLifePeriodPositionMetadataResolver.resolveDetailed(
              period: period,
              archetypeMetadata: archetypeMetadata,
              periodContextMetadata: periodContextMetadata,
              canonIndex: canonIndex,
            )
          : ThaiLifePeriodArchetypePlanetPositionResolver.resolveDetailed(
              period: period,
              archetypeMetadata: archetypeMetadata,
              placementIndex: placementIndex,
              canonIndex: canonIndex,
            );

      return MahabhutPlanetPosition(
        planet: period.planet,
        periodIndex: period.index,
        known: false,
        unknownReason:
            detailed.missingReason ??
            LifePeriodPositionMetadataBlocker.blockedBySourceGap,
      );
    }

    final thai = thaiNameForCanonId(metadata.mahabhutPositionCanonId);
    if (thai == null) {
      return MahabhutPlanetPosition(
        planet: period.planet,
        periodIndex: period.index,
        known: false,
        canonId: metadata.mahabhutPositionCanonId,
        unknownReason: 'UNKNOWN_CANON_POSITION_LABEL',
      );
    }

    return MahabhutPlanetPosition(
      planet: period.planet,
      periodIndex: period.index,
      known: true,
      canonId: metadata.mahabhutPositionCanonId,
      thaiName: thai,
    );
  }

  static Map<int, MahabhutPlanetPosition> resolveAll({
    required LifeTimeline timeline,
    ThaiArchetypeContextMetadata? archetypeMetadata,
    Map<int, ThaiLifePeriodContextMetadata?>? contextByPeriod,
    ThaiCanonEvidenceIndex? canonIndex,
    ThaiArchetypePlanetPlacementIndex? placementIndex,
  }) {
    final contexts =
        contextByPeriod ?? const <int, ThaiLifePeriodContextMetadata?>{};
    final index =
        placementIndex ??
        (canonIndex == null
            ? null
            : ThaiArchetypePlanetPlacementIndex.build(canonIndex));
    final out = <int, MahabhutPlanetPosition>{};
    for (final period in timeline.periods) {
      out[period.index] = resolve(
        period: period,
        archetypeMetadata: archetypeMetadata,
        periodContextMetadata: contexts[period.index],
        canonIndex: canonIndex,
        placementIndex: index,
      );
    }
    return out;
  }
}
