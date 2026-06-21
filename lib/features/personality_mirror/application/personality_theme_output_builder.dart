import '../domain/personality_confidence.dart';
import '../domain/personality_core_themes.dart';
import '../domain/personality_lens_evidence.dart';
import '../domain/personality_lens_id.dart';
import '../domain/personality_lens_theme_output.dart';
import '../domain/personality_theme_activation.dart';

abstract final class PersonalityThemeOutputBuilder {
  static PersonalityLensThemeOutput? build({
    required PersonalityLensId lensId,
    required String themeId,
    required PersonalityThemeActivation activation,
    required PersonalityConfidence confidence,
    required List<PersonalityLensEvidence> evidence,
    required PersonalitySourceVersionMeta sourceVersion,
    double ruleWeight = 1.0,
  }) {
    final theme = PersonalityCoreThemeRegistry.get(themeId);
    if (theme == null) return null;

    final adjusted = PersonalityConfidenceBands.clamp(
      confidence * ruleWeight,
    );

    return PersonalityLensThemeOutput(
      lensId: lensId,
      themeId: theme.id,
      category: theme.category,
      family: theme.family,
      activation: activation,
      confidence: adjusted,
      evidence: evidence,
      sourceVersion: sourceVersion,
    );
  }
}
