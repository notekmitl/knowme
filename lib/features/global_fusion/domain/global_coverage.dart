import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';

/// Astrology mirror coverage slice — derived from mirror snapshot only.
class AstrologyMirrorCoverageSlice {
  const AstrologyMirrorCoverageSlice({
    required this.available,
    required this.completedLensCount,
    required this.totalLensCount,
    required this.completedLensIds,
  });

  final bool available;
  final int completedLensCount;
  final int totalLensCount;
  final List<String> completedLensIds;

  double get ratio =>
      totalLensCount <= 0 ? 0.0 : completedLensCount / totalLensCount;

  static const empty = AstrologyMirrorCoverageSlice(
    available: false,
    completedLensCount: 0,
    totalLensCount: 3,
    completedLensIds: [],
  );
}

/// Personality mirror coverage slice — derived from mirror snapshot only.
class PersonalityMirrorCoverageSlice {
  const PersonalityMirrorCoverageSlice({
    required this.available,
    required this.availableLensIds,
    required this.missingLensIds,
    required this.weightedCoverage,
    required this.eqModulesCompleted,
    required this.eqModulesExpected,
  });

  final bool available;
  final List<PersonalityLensId> availableLensIds;
  final List<PersonalityLensId> missingLensIds;
  final double weightedCoverage;
  final int eqModulesCompleted;
  final int eqModulesExpected;

  static const empty = PersonalityMirrorCoverageSlice(
    available: false,
    availableLensIds: [],
    missingLensIds: PersonalityLensId.values,
    weightedCoverage: 0,
    eqModulesCompleted: 0,
    eqModulesExpected: 0,
  );
}

/// Global coverage reflects each mirror separately — never merged into one score.
class GlobalCoverage {
  const GlobalCoverage({
    required this.astrology,
    required this.personality,
  });

  final AstrologyMirrorCoverageSlice astrology;
  final PersonalityMirrorCoverageSlice personality;

  bool get hasAstrology => astrology.available;

  bool get hasPersonality => personality.available;

  bool get hasAnyMirror => hasAstrology || hasPersonality;

  bool get hasBothMirrors => hasAstrology && hasPersonality;

  static const empty = GlobalCoverage(
    astrology: AstrologyMirrorCoverageSlice.empty,
    personality: PersonalityMirrorCoverageSlice.empty,
  );
}
