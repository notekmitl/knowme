import 'package:knowme/features/tests/eq/domain/eq_models.dart';
import 'package:knowme/features/tests/eq/domain/eq_test_type.dart';

import '../../domain/personality_confidence.dart';
import '../../domain/personality_core_themes.dart';
import '../../domain/personality_lens_evidence.dart';
import '../../domain/personality_lens_id.dart';
import '../../domain/personality_lens_snapshot.dart';
import '../../domain/personality_lens_theme_output.dart';
import '../../domain/personality_theme_activation.dart';
import '../personality_theme_output_builder.dart';

/// Maps one [EqResultSummary] → [PersonalityLensSnapshot] for its module.
abstract final class EqPersonalityLensAdapter {
  static PersonalityLensSnapshot map({
    required PersonalityLensId lensId,
    required EqResultSummary? result,
  }) {
    if (result == null) {
      return PersonalityLensSnapshot.unavailable(lensId);
    }

    final sourceVersion = PersonalitySourceVersionMeta(
      scoredQuestionCount: result.scoredQuestionCount,
      scoringVersion: result.scoringVersion,
      depthTier: 'module_20',
      resultScoredAt: result.completedAt,
    );

    final levelMultiplier = _levelMultiplier(result.level);
    final lensConfidence = PersonalityConfidenceBands.clamp(0.55 * levelMultiplier);
    final themes = <PersonalityLensThemeOutput>[];

    for (final rule in _rulesForLens(lensId, result.level)) {
      final output = PersonalityThemeOutputBuilder.build(
        lensId: lensId,
        themeId: rule.themeId,
        activation: rule.activation,
        confidence: lensConfidence,
        evidence: [
          PersonalityLensEvidence(
            sourceField: 'level',
            sourceValue: result.level,
            ruleId: rule.ruleId,
            weight: 1.0,
          ),
        ],
        sourceVersion: sourceVersion,
      );
      if (output != null) themes.add(output);
    }

    return PersonalityLensSnapshot(
      lensId: lensId,
      themes: themes,
      lensConfidence: lensConfidence,
      sourceVersion: sourceVersion,
      available: true,
    );
  }

  static PersonalityLensId lensIdForEqTestType(EqTestType type) {
    return switch (type) {
      EqTestType.awareness => PersonalityLensId.eqAwareness,
      EqTestType.regulation => PersonalityLensId.eqRegulation,
      EqTestType.empathy => PersonalityLensId.eqEmpathy,
      EqTestType.social => PersonalityLensId.eqSocial,
      EqTestType.decision => PersonalityLensId.eqDecision,
      EqTestType.stress => PersonalityLensId.eqStress,
    };
  }

  static EqTestType? eqTestTypeForLensId(PersonalityLensId lensId) {
    return switch (lensId) {
      PersonalityLensId.eqAwareness => EqTestType.awareness,
      PersonalityLensId.eqRegulation => EqTestType.regulation,
      PersonalityLensId.eqEmpathy => EqTestType.empathy,
      PersonalityLensId.eqSocial => EqTestType.social,
      PersonalityLensId.eqDecision => EqTestType.decision,
      PersonalityLensId.eqStress => EqTestType.stress,
      _ => null,
    };
  }

  static double _levelMultiplier(String level) {
    return switch (level) {
      EqLevelIds.strong => 0.75,
      EqLevelIds.emerging => 0.50,
      _ => 0.35,
    };
  }

  static List<_EqThemeRule> _rulesForLens(
    PersonalityLensId lensId,
    String level,
  ) {
    final isStrong = level == EqLevelIds.strong;
    final isEmerging = level == EqLevelIds.emerging;

    return switch (lensId) {
      PersonalityLensId.eqAwareness => isStrong
          ? [
              _EqThemeRule(
                PersonalityCoreThemeIds.responsive,
                PersonalityThemeActivation.supportive,
                'eq.awareness.strong',
              ),
            ]
          : isEmerging
              ? [
                  _EqThemeRule(
                    PersonalityCoreThemeIds.calm,
                    PersonalityThemeActivation.growth,
                    'eq.awareness.emerging',
                  ),
                ]
              : const [],
      PersonalityLensId.eqRegulation => isStrong
          ? [
              _EqThemeRule(
                PersonalityCoreThemeIds.calm,
                PersonalityThemeActivation.supportive,
                'eq.regulation.strong',
              ),
            ]
          : isEmerging
              ? [
                  _EqThemeRule(
                    PersonalityCoreThemeIds.responsive,
                    PersonalityThemeActivation.growth,
                    'eq.regulation.emerging',
                  ),
                ]
              : const [],
      PersonalityLensId.eqEmpathy => isStrong
          ? [
              _EqThemeRule(
                PersonalityCoreThemeIds.supportive,
                PersonalityThemeActivation.supportive,
                'eq.empathy.strong',
              ),
              _EqThemeRule(
                PersonalityCoreThemeIds.diplomatic,
                PersonalityThemeActivation.supportive,
                'eq.empathy.diplomatic',
              ),
            ]
          : isEmerging
              ? [
                  _EqThemeRule(
                    PersonalityCoreThemeIds.reserved,
                    PersonalityThemeActivation.growth,
                    'eq.empathy.emerging',
                  ),
                ]
              : const [],
      PersonalityLensId.eqSocial => isStrong
          ? [
              _EqThemeRule(
                PersonalityCoreThemeIds.diplomatic,
                PersonalityThemeActivation.supportive,
                'eq.social.strong',
              ),
            ]
          : isEmerging
              ? [
                  _EqThemeRule(
                    PersonalityCoreThemeIds.reserved,
                    PersonalityThemeActivation.growth,
                    'eq.social.emerging',
                  ),
                ]
              : const [],
      PersonalityLensId.eqDecision => isStrong
          ? [
              _EqThemeRule(
                PersonalityCoreThemeIds.analytical,
                PersonalityThemeActivation.supportive,
                'eq.decision.strong',
              ),
              _EqThemeRule(
                PersonalityCoreThemeIds.structured,
                PersonalityThemeActivation.supportive,
                'eq.decision.structured',
              ),
            ]
          : isEmerging
              ? [
                  _EqThemeRule(
                    PersonalityCoreThemeIds.flexible,
                    PersonalityThemeActivation.growth,
                    'eq.decision.emerging',
                  ),
                ]
              : const [],
      PersonalityLensId.eqStress => isStrong
          ? [
              _EqThemeRule(
                PersonalityCoreThemeIds.calm,
                PersonalityThemeActivation.supportive,
                'eq.stress.strong',
              ),
            ]
          : isEmerging
              ? [
                  _EqThemeRule(
                    PersonalityCoreThemeIds.responsive,
                    PersonalityThemeActivation.growth,
                    'eq.stress.emerging',
                  ),
                ]
              : const [],
      _ => const [],
    };
  }
}

class _EqThemeRule {
  const _EqThemeRule(this.themeId, this.activation, this.ruleId);

  final String themeId;
  final PersonalityThemeActivation activation;
  final String ruleId;
}
