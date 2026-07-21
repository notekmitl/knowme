import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/tests/big_five/application/big_five_scorer.dart';
import 'package:knowme/features/tests/big_five/data/modules/big_five_progressive_questions.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_depth_tier.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_trait_id.dart';

void main() {
  group('BigFiveProgressiveQuestions', () {
    test('exposes 10 / 44 / 80 tiers with prefix preservation', () {
      expect(BigFiveProgressiveQuestions.quick.length, bigFiveQuickCheckpoint);
      expect(
        BigFiveProgressiveQuestions.standard.length,
        bigFiveStandardCheckpoint,
      );
      expect(BigFiveProgressiveQuestions.deep.length, bigFiveDeepCheckpoint);

      final quickIds =
          BigFiveProgressiveQuestions.quick.map((q) => q.id).toList();
      final standardIds =
          BigFiveProgressiveQuestions.standard.map((q) => q.id).toList();
      final deepIds = BigFiveProgressiveQuestions.deep.map((q) => q.id).toList();

      expect(standardIds.take(quickIds.length).toList(), quickIds);
      expect(deepIds.take(standardIds.length).toList(), standardIds);
    });

    test('legacy bank abstraction exposes extended import', () {
      expect(
        BigFiveProgressiveQuestions.legacyBankAvailableCount,
        greaterThanOrEqualTo(
          bigFiveDeepCheckpoint - bigFiveStandardCheckpoint,
        ),
      );
      expect(bigFiveLegacyBankMax, greaterThanOrEqualTo(bigFiveDeepCheckpoint));
    });
  });

  group('BigFiveScorer', () {
    const scorer = BigFiveScorer();

    test('scores trait averages and bands deterministically', () {
      final questions = BigFiveProgressiveQuestions.quick;
      final answers = {
        for (final question in questions) question.id: 4,
      };

      final summary = scorer.score(questions: questions, answers: answers);

      expect(summary.testId, bigFiveTestId);
      expect(summary.scoredQuestionCount, bigFiveQuickCheckpoint);
      expect(summary.depthTier, BigFiveDepthTier.quick);
      expect(summary.scoringVersion, bigFiveScoringVersion);

      for (final trait in BigFiveTraitId.all) {
        expect(summary.scoreForTrait(trait), greaterThan(0));
        expect(summary.bandForTrait(trait), isNotEmpty);
        expect(
          summary.traitScoreFields[BigFiveTraitId.scoreField(trait)],
          greaterThan(0),
        );
      }
    });

    test('reverse items invert Likert scoring', () {
      final reverseQuestion = BigFiveProgressiveQuestions.quick
          .firstWhere((question) => question.reverse);
      final forwardQuestion = BigFiveProgressiveQuestions.quick
          .firstWhere((question) => !question.reverse);

      final reverseOnly = scorer.score(
        questions: [reverseQuestion],
        answers: {reverseQuestion.id: 1},
      );
      final forwardOnly = scorer.score(
        questions: [forwardQuestion],
        answers: {forwardQuestion.id: 5},
      );

      expect(
        reverseOnly.scoreForTrait(reverseQuestion.trait),
        forwardOnly.scoreForTrait(forwardQuestion.trait),
      );
    });
  });

  group('Progressive checkpoints', () {
    test('mandatory 10 → 44 → 80 boundaries resolve depth tiers', () {
      expect(
        BigFiveDepthTier.forScoredQuestionCount(10),
        BigFiveDepthTier.quick,
      );
      expect(
        BigFiveDepthTier.forScoredQuestionCount(44),
        BigFiveDepthTier.standard,
      );
      expect(
        BigFiveDepthTier.forScoredQuestionCount(80),
        BigFiveDepthTier.deep,
      );

      bool canOfferStandardContinue(int answered) =>
          answered >= bigFiveQuickCheckpoint &&
          answered < bigFiveStandardCheckpoint;
      bool canOfferDeepContinue(int answered) =>
          answered >= bigFiveStandardCheckpoint &&
          answered < bigFiveDeepCheckpoint;

      expect(canOfferStandardContinue(10), isTrue);
      expect(canOfferDeepContinue(10), isFalse);
      expect(canOfferStandardContinue(44), isFalse);
      expect(canOfferDeepContinue(44), isTrue);
    });
  });
}
