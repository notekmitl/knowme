import 'personality_lens_id.dart';

/// Readiness snapshot for which personality lenses have stored results.
class PersonalityCoverage {
  const PersonalityCoverage({
    required this.availableLensIds,
    required this.missingLensIds,
    required this.eqModulesCompleted,
    required this.eqModulesExpected,
    required this.weightedCoverage,
  });

  final List<PersonalityLensId> availableLensIds;
  final List<PersonalityLensId> missingLensIds;
  final int eqModulesCompleted;
  final int eqModulesExpected;
  final double weightedCoverage;

  bool get hasMbti => availableLensIds.contains(PersonalityLensId.mbti);

  bool get hasBigFive => availableLensIds.contains(PersonalityLensId.bigFive);

  bool get hasAnyEq => eqModulesCompleted > 0;
}
