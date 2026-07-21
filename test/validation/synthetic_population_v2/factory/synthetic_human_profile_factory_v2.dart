import '../../synthetic_population/factory/synthetic_human_profile_factory.dart';
import '../../synthetic_population/models/synthetic_human_archetype_spec.dart';
import '../../synthetic_population/models/synthetic_human_profile.dart';
import '../../synthetic_population/models/synthetic_human_variant.dart';
import '../data/synthetic_population_v2_archetype_catalog.dart';

/// 250 archetypes × 4 variants = 1000 synthetic humans.
abstract final class SyntheticHumanProfileFactoryV2 {
  static List<SyntheticHumanProfile> buildAll() {
    final profiles = <SyntheticHumanProfile>[];
    for (final spec in SyntheticPopulationV2ArchetypeCatalog.generate()) {
      for (final variant in SyntheticHumanVariant.values) {
        profiles.add(
          SyntheticHumanProfileFactory.build(spec: spec, variant: variant),
        );
      }
    }
    return profiles;
  }

  static Map<String, dynamic> populationQualityReport(
    List<SyntheticHumanProfile> profiles,
  ) {
    final archetypeCounts = <String, int>{};
    final mbtiCounts = <String, int>{};
    final attachmentCounts = <String, int>{};
    final eqAwarenessCounts = <String, int>{};
    final eqRegulationCounts = <String, int>{};
    final animalCounts = <String, int>{};

    for (final profile in profiles) {
      archetypeCounts[profile.archetypeId] =
          (archetypeCounts[profile.archetypeId] ?? 0) + 1;
      mbtiCounts[profile.mbtiType] = (mbtiCounts[profile.mbtiType] ?? 0) + 1;
      attachmentCounts[profile.attachmentStyle.name] =
          (attachmentCounts[profile.attachmentStyle.name] ?? 0) + 1;
      eqAwarenessCounts[profile.eqAwarenessLevel] =
          (eqAwarenessCounts[profile.eqAwarenessLevel] ?? 0) + 1;
      eqRegulationCounts[profile.eqRegulationLevel] =
          (eqRegulationCounts[profile.eqRegulationLevel] ?? 0) + 1;
      animalCounts[profile.yearAnimalKey] =
          (animalCounts[profile.yearAnimalKey] ?? 0) + 1;
    }

    final maxArchetypeShare = archetypeCounts.values.isEmpty
        ? 0.0
        : archetypeCounts.values.reduce((a, b) => a > b ? a : b) /
            profiles.length;

    return {
      'populationSize': profiles.length,
      'archetypeCount': archetypeCounts.length,
      'maxArchetypeShare': maxArchetypeShare,
      'maxArchetypeSharePass': maxArchetypeShare <= 0.05,
      'mbtiDistribution': _sorted(mbtiCounts),
      'attachmentDistribution': _sorted(attachmentCounts),
      'eqAwarenessDistribution': _sorted(eqAwarenessCounts),
      'eqRegulationDistribution': _sorted(eqRegulationCounts),
      'yearAnimalDistribution': _sorted(animalCounts),
    };
  }

  static Map<String, int> _sorted(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map<String, int>.fromEntries(entries);
  }
}
