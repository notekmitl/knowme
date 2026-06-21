import '../domain/personality_coverage.dart';
import '../domain/personality_mirror_narrative_view.dart';
import 'mirror/personality_confidence_composer.dart';
import 'mirror/personality_mirror_engine.dart';
import 'narrative/personality_mirror_narrative_builder.dart';
import 'personality_lens_load_result.dart';
import 'personality_lens_loader.dart';

/// Read-only entry rules and mirror load for Personality Mirror V1.
class PersonalityMirrorEntryService {
  PersonalityMirrorEntryService({PersonalityLensLoader? loader})
      : _loader = loader ?? PersonalityLensLoader();

  final PersonalityLensLoader _loader;

  /// Mirror opens when at least two primary lens groups are present
  /// (MBTI, Big Five, EQ).
  static bool canOpenMirror(PersonalityCoverage coverage) =>
      primaryLensCount(coverage) >= 2;

  /// Full experience when all three primary lens groups are present.
  static bool canShowFullExperience(PersonalityCoverage coverage) =>
      primaryLensCount(coverage) >= 3;

  static int primaryLensCount(PersonalityCoverage coverage) {
    var count = 0;
    if (coverage.hasMbti) count++;
    if (coverage.hasBigFive) count++;
    if (coverage.hasAnyEq) count++;
    return count;
  }

  Future<PersonalityMirrorEntryState> evaluate(String uid) async {
    if (uid.isEmpty) {
      return const PersonalityMirrorEntryState(
        canOpen: false,
        canShowFullExperience: false,
        coverage: null,
      );
    }

    final load = await _loader.loadAll(uid);
    return PersonalityMirrorEntryState.fromCoverage(load.coverage);
  }

  Future<PersonalityMirrorExperienceBundle> loadExperience(String uid) async {
    final load = await _loader.loadAll(uid);
    final mirror = PersonalityMirrorEngine.build(load);
    final confidence = PersonalityConfidenceComposer.analyze(
      load: load,
      agreements: mirror.agreements,
      tensions: mirror.tensions,
    );
    final narrative = PersonalityMirrorNarrativeBuilder.build(
      mirror,
      confidenceBreakdown: confidence,
    );

    return PersonalityMirrorExperienceBundle(
      load: load,
      narrative: narrative,
      canShowFullExperience: canShowFullExperience(load.coverage),
    );
  }
}

/// Home tile readiness derived from primary lens groups only.
enum PersonalityMirrorTileStatus {
  locked,
  partial,
  ready,
}

/// Gate vs result availability from coverage only.
class PersonalityMirrorEntryState {
  const PersonalityMirrorEntryState({
    required this.canOpen,
    required this.canShowFullExperience,
    required this.coverage,
  });

  final bool canOpen;
  final bool canShowFullExperience;
  final PersonalityCoverage? coverage;

  PersonalityMirrorTileStatus get tileStatus {
    if (!canOpen) return PersonalityMirrorTileStatus.locked;
    if (!canShowFullExperience) return PersonalityMirrorTileStatus.partial;
    return PersonalityMirrorTileStatus.ready;
  }

  factory PersonalityMirrorEntryState.fromCoverage(
    PersonalityCoverage coverage,
  ) {
    return PersonalityMirrorEntryState(
      canOpen: PersonalityMirrorEntryService.canOpenMirror(coverage),
      canShowFullExperience:
          PersonalityMirrorEntryService.canShowFullExperience(coverage),
      coverage: coverage,
    );
  }
}

/// Loaded narrative bundle for the result page (read-only).
class PersonalityMirrorExperienceBundle {
  const PersonalityMirrorExperienceBundle({
    required this.load,
    required this.narrative,
    required this.canShowFullExperience,
  });

  final PersonalityLensLoadResult load;
  final PersonalityMirrorNarrativeView narrative;
  final bool canShowFullExperience;
}
