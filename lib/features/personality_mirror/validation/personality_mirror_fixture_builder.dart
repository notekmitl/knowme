import '../application/personality_theme_output_builder.dart';
import '../domain/personality_core_themes.dart';
import '../domain/personality_lens_evidence.dart';
import '../domain/personality_lens_id.dart';
import '../domain/personality_lens_snapshot.dart';
import '../domain/personality_lens_theme_output.dart';
import '../domain/personality_theme_activation.dart';

/// Builds deterministic lens snapshots for golden fixtures.
abstract final class PersonalityMirrorFixtureBuilder {
  static const _fixtureEvidence = PersonalityLensEvidence(
    sourceField: 'fixture',
    sourceValue: 'golden',
    ruleId: 'golden.fixture',
    weight: 1.0,
  );

  static const _fixtureMeta = PersonalitySourceVersionMeta(
    scoredQuestionCount: 40,
    scoringVersion: 1,
    depthTier: 'standard',
  );

  static PersonalityLensSnapshot lens({
    required PersonalityLensId lensId,
    required List<String> themeIds,
    required double lensConfidence,
    double themeConfidence = 0.72,
    PersonalityThemeActivation activation =
        PersonalityThemeActivation.supportive,
  }) {
    final themes = <PersonalityLensThemeOutput>[];
    for (final themeId in themeIds) {
      final output = PersonalityThemeOutputBuilder.build(
        lensId: lensId,
        themeId: themeId,
        activation: activation,
        confidence: themeConfidence,
        evidence: const [_fixtureEvidence],
        sourceVersion: _fixtureMeta,
      );
      if (output != null) themes.add(output);
    }

    return PersonalityLensSnapshot(
      lensId: lensId,
      themes: themes,
      lensConfidence: lensConfidence,
      sourceVersion: _fixtureMeta,
      available: true,
    );
  }

  static PersonalityLensSnapshot unavailable(PersonalityLensId lensId) =>
      PersonalityLensSnapshot.unavailable(lensId);

  static List<String> get alignedStructureThemes => const [
        PersonalityCoreThemeIds.structured,
        PersonalityCoreThemeIds.responsible,
      ];

  static List<String> get tensionCoreSelfThemes => const [
        PersonalityCoreThemeIds.reserved,
      ];

  static List<String> get expressiveCoreSelfThemes => const [
        PersonalityCoreThemeIds.expressive,
      ];

  static List<String> get alignedSupportThemes => const [
        PersonalityCoreThemeIds.supportive,
        PersonalityCoreThemeIds.diplomatic,
      ];
}
