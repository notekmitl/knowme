import 'package:knowme/features/astrology/fusion/application/astrology_fusion_entry_service.dart';
import 'package:knowme/features/personality_mirror/application/personality_mirror_entry_service.dart';
import 'package:knowme/features/tests/fusion/application/fusion_entry_service.dart';

import '../validation/home_surface_golden_scenario.dart';

/// Maps live Home entry signals to golden surface scenarios (MVP bridge).
abstract final class HomeMvpScenarioMapper {
  static HomeSurfaceGoldenScenario fromEntrySignals({
    AstrologyFusionEntryState? astrology,
    FusionEntryState? globalFusion,
    PersonalityMirrorEntryState? personality,
  }) {
    final hasAstro = astrology?.canOpen ?? false;
    final hasPersonality = personality?.canOpen ?? false;
    final hasFusion = globalFusion?.canOpen ?? false;

    if (hasAstro && hasPersonality && hasFusion) {
      return HomeSurfaceGoldenScenario.everythingReady;
    }
    if (hasAstro || hasPersonality || hasFusion) {
      return HomeSurfaceGoldenScenario.partialUser;
    }
    return HomeSurfaceGoldenScenario.emptyUser;
  }
}
