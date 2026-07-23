import '../../foundation/models/thai_astrology_profile.dart';
import '../../foundation/models/thai_birth_data.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_index.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'life_period_engine.dart';
import 'mahabhut_planet_position_engine.dart';
import 'thai_archetype_context_metadata.dart';
import 'thai_archetype_planet_placement_index.dart';
import 'thai_life_period_context_metadata.dart';
import 'thai_life_period_position_metadata.dart';
import 'thai_remainder_runtime_metadata.dart';

/// Shared Life Map Mahabhut inputs — same resolver path as Canon evidence enricher.
///
/// Builds archetype + placement index from Frozen Canon; never invents positions.
class ThaiLifeMapMahabhutResolution {
  ThaiLifeMapMahabhutResolution._({
    required this.canonIndex,
    required this.placementIndex,
    required this.archetypeMetadata,
  });

  final ThaiCanonEvidenceIndex canonIndex;
  final ThaiArchetypePlanetPlacementIndex placementIndex;
  final ThaiArchetypeContextMetadata? archetypeMetadata;

  /// True when Frozen Canon index is available for resolution.
  bool get hasCanonIndex => true;

  /// Resolves using [ThaiCanonEvidenceRepository.cachedIndexOrNull] when
  /// [canonIndex] is omitted.
  static ThaiLifeMapMahabhutResolution? tryCreate({
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    final index =
        canonIndex ?? ThaiCanonEvidenceRepository.cachedIndexOrNull;
    if (index == null) return null;

    final remainderMetadata = ThaiRemainderMetadataResolver.resolve(
      profile: profile,
      birthData: birthData,
    );
    final archetypeMetadata = ThaiArchetypeContextResolver.resolve(
      remainderMetadata: remainderMetadata,
      canonIndex: index,
    ).metadata;

    return ThaiLifeMapMahabhutResolution._(
      canonIndex: index,
      placementIndex: ThaiArchetypePlanetPlacementIndex.build(index),
      archetypeMetadata: archetypeMetadata,
    );
  }

  MahabhutPlanetPosition resolve(PeriodState period) {
    final periodContext = archetypeMetadata == null
        ? null
        : ThaiLifePeriodContextResolver.resolve(
            period: period,
            archetypeMetadata: archetypeMetadata!,
            canonIndex: canonIndex,
          );

    return MahabhutPlanetPositionEngine.resolve(
      period: period,
      archetypeMetadata: archetypeMetadata,
      periodContextMetadata: periodContext,
      canonIndex: canonIndex,
      placementIndex: placementIndex,
    );
  }

  /// Direct combined metadata (tests / traces) — same path as display resolve.
  ThaiLifePeriodPositionMetadata? resolveMetadata(PeriodState period) {
    final periodContext = archetypeMetadata == null
        ? null
        : ThaiLifePeriodContextResolver.resolve(
            period: period,
            archetypeMetadata: archetypeMetadata!,
            canonIndex: canonIndex,
          );
    return ThaiLifePeriodPositionMetadataResolver.resolveCombined(
      period: period,
      archetypeMetadata: archetypeMetadata,
      periodContextMetadata: periodContext,
      canonIndex: canonIndex,
      placementIndex: placementIndex,
    );
  }
}
