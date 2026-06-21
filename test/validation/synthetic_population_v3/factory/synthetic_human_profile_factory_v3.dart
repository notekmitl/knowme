import '../../synthetic_population/models/synthetic_human_profile.dart';
import '../../synthetic_population_v2/factory/synthetic_human_profile_factory_v2.dart';

/// Synthetic Population V3 — 1000 humans (250 archetypes × 4 variants).
/// Profile generation identical to V2; LIFE reinforcement coverage is pipeline overlay.
abstract final class SyntheticHumanProfileFactoryV3 {
  static List<SyntheticHumanProfile> buildAll() {
    return SyntheticHumanProfileFactoryV2.buildAll();
  }

  static Map<String, dynamic> populationQualityReport(
    List<SyntheticHumanProfile> profiles,
  ) {
    return SyntheticHumanProfileFactoryV2.populationQualityReport(profiles);
  }
}
