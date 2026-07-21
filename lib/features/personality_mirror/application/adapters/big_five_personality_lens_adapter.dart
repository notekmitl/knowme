import 'package:knowme/features/tests/big_five/domain/big_five_depth_tier.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_trait_id.dart';

import '../../domain/personality_confidence.dart';
import '../../domain/personality_core_themes.dart';
import '../../domain/personality_lens_evidence.dart';
import '../../domain/personality_lens_id.dart';
import '../../domain/personality_lens_snapshot.dart';
import '../../domain/personality_lens_theme_output.dart';
import '../../domain/personality_theme_activation.dart';
import '../personality_theme_output_builder.dart';

/// Maps [BigFiveResultSummary] → [PersonalityLensSnapshot].
abstract final class BigFivePersonalityLensAdapter {
  static PersonalityLensSnapshot map(BigFiveResultSummary? result) {
    if (result == null) {
      return PersonalityLensSnapshot.unavailable(PersonalityLensId.bigFive);
    }

    final sourceVersion = PersonalitySourceVersionMeta(
      scoredQuestionCount: result.scoredQuestionCount,
      scoringVersion: result.scoringVersion,
      depthTier: result.depthTier.storageKey,
      resultScoredAt: result.scoredAt,
    );

    final lensConfidence = _lensConfidence(result.depthTier);
    final themes = <PersonalityLensThemeOutput>[];

    for (final trait in BigFiveTraitId.all) {
      final band = result.bandForTrait(trait);
      final rules = _rulesForTrait(trait, band);
      for (final rule in rules) {
        final output = PersonalityThemeOutputBuilder.build(
          lensId: PersonalityLensId.bigFive,
          themeId: rule.themeId,
          activation: rule.activation,
          confidence: lensConfidence * _bandClarity(band),
          evidence: [
            PersonalityLensEvidence(
              sourceField: BigFiveTraitId.bandField(trait),
              sourceValue: band,
              ruleId: rule.ruleId,
              weight: 1.0,
            ),
          ],
          sourceVersion: sourceVersion,
        );
        if (output != null) themes.add(output);
      }
    }

    _addCrossTraitPatterns(result, themes, sourceVersion, lensConfidence);

    return PersonalityLensSnapshot(
      lensId: PersonalityLensId.bigFive,
      themes: themes,
      lensConfidence: lensConfidence,
      sourceVersion: sourceVersion,
      available: true,
    );
  }

  static void _addCrossTraitPatterns(
    BigFiveResultSummary result,
    List<PersonalityLensThemeOutput> themes,
    PersonalitySourceVersionMeta sourceVersion,
    PersonalityConfidence lensConfidence,
  ) {
    final openness = result.bandForTrait(BigFiveTraitId.openness);
    final conscientiousness =
        result.bandForTrait(BigFiveTraitId.conscientiousness);
    final extraversion = result.bandForTrait(BigFiveTraitId.extraversion);
    final agreeableness = result.bandForTrait(BigFiveTraitId.agreeableness);

    void maybeAdd({
      required String themeId,
      required String ruleId,
      required bool condition,
    }) {
      if (!condition || themes.any((t) => t.themeId == themeId)) return;
      final output = PersonalityThemeOutputBuilder.build(
        lensId: PersonalityLensId.bigFive,
        themeId: themeId,
        activation: PersonalityThemeActivation.supportive,
        confidence: lensConfidence * 0.7,
        evidence: [
          PersonalityLensEvidence(
            sourceField: 'cross_trait',
            sourceValue: ruleId,
            ruleId: ruleId,
            weight: 0.7,
          ),
        ],
        sourceVersion: sourceVersion,
        ruleWeight: 0.7,
      );
      if (output != null) themes.add(output);
    }

    maybeAdd(
      themeId: PersonalityCoreThemeIds.creative,
      ruleId: 'big_five.cross.open_con',
      condition: openness == BigFiveBandId.strong &&
          conscientiousness == BigFiveBandId.strong,
    );
    maybeAdd(
      themeId: PersonalityCoreThemeIds.responsible,
      ruleId: 'big_five.cross.extra_agree',
      condition: extraversion == BigFiveBandId.strong &&
          agreeableness == BigFiveBandId.strong,
    );
  }

  static List<_TraitThemeRule> _rulesForTrait(String trait, String band) {
    return switch (trait) {
      BigFiveTraitId.openness => switch (band) {
          BigFiveBandId.strong => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.creative,
              PersonalityThemeActivation.supportive,
              'big_five.openness.strong',
            ),
            _TraitThemeRule(
              PersonalityCoreThemeIds.intuitive,
              PersonalityThemeActivation.supportive,
              'big_five.openness.intuitive',
            ),
          ],
          BigFiveBandId.emerging => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.adaptable,
              PersonalityThemeActivation.growth,
              'big_five.openness.emerging',
            ),
          ],
          _ => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.adaptable,
              PersonalityThemeActivation.neutral,
              'big_five.openness.moderate',
            ),
          ],
        },
      BigFiveTraitId.conscientiousness => switch (band) {
          BigFiveBandId.strong => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.responsible,
              PersonalityThemeActivation.supportive,
              'big_five.conscientiousness.strong',
            ),
            _TraitThemeRule(
              PersonalityCoreThemeIds.reliable,
              PersonalityThemeActivation.supportive,
              'big_five.conscientiousness.reliable',
            ),
          ],
          BigFiveBandId.emerging => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.flexible,
              PersonalityThemeActivation.growth,
              'big_five.conscientiousness.emerging',
            ),
          ],
          _ => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.grounded,
              PersonalityThemeActivation.neutral,
              'big_five.conscientiousness.moderate',
            ),
          ],
        },
      BigFiveTraitId.extraversion => switch (band) {
          BigFiveBandId.strong => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.expressive,
              PersonalityThemeActivation.supportive,
              'big_five.extraversion.strong',
            ),
          ],
          BigFiveBandId.emerging => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.reserved,
              PersonalityThemeActivation.supportive,
              'big_five.extraversion.emerging',
            ),
          ],
          _ => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.adaptable,
              PersonalityThemeActivation.neutral,
              'big_five.extraversion.moderate',
            ),
          ],
        },
      BigFiveTraitId.agreeableness => switch (band) {
          BigFiveBandId.strong => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.supportive,
              PersonalityThemeActivation.supportive,
              'big_five.agreeableness.strong',
            ),
            _TraitThemeRule(
              PersonalityCoreThemeIds.diplomatic,
              PersonalityThemeActivation.supportive,
              'big_five.agreeableness.diplomatic',
            ),
          ],
          BigFiveBandId.emerging => const [],
          _ => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.diplomatic,
              PersonalityThemeActivation.neutral,
              'big_five.agreeableness.moderate',
            ),
          ],
        },
      BigFiveTraitId.neuroticism => switch (band) {
          BigFiveBandId.strong => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.responsive,
              PersonalityThemeActivation.supportive,
              'big_five.stress_sensitivity.strong',
            ),
          ],
          _ => [
            _TraitThemeRule(
              PersonalityCoreThemeIds.calm,
              PersonalityThemeActivation.supportive,
              'big_five.stress_sensitivity.calm',
            ),
          ],
        },
      _ => const [],
    };
  }

  static double _bandClarity(String band) {
    return switch (band) {
      BigFiveBandId.moderate => 0.5,
      BigFiveBandId.emerging => 0.85,
      BigFiveBandId.strong => 0.85,
      _ => 0.5,
    };
  }

  static PersonalityConfidence _lensConfidence(BigFiveDepthTier depthTier) {
    return switch (depthTier) {
      BigFiveDepthTier.deep => 0.85,
      BigFiveDepthTier.standard => 0.65,
      BigFiveDepthTier.quick => 0.40,
    };
  }
}

class _TraitThemeRule {
  const _TraitThemeRule(this.themeId, this.activation, this.ruleId);

  final String themeId;
  final PersonalityThemeActivation activation;
  final String ruleId;
}
