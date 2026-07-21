import 'package:knowme/domain/models/test_question.dart';

import '../domain/big_five_depth_tier.dart';
import '../domain/big_five_models.dart';
import '../domain/big_five_trait_id.dart';

/// Deterministic Big Five scoring — trait averages and band resolution only.
class BigFiveScorer {
  const BigFiveScorer();

  BigFiveResultSummary score({
    required List<TestQuestion> questions,
    required Map<String, int> answers,
    DateTime? scoredAt,
  }) {
    final traitScores = calculateTraitAverages(questions, answers);
    final scoredQuestionCount = _countAnsweredInSet(questions, answers);
    final depthTier = BigFiveDepthTier.forScoredQuestionCount(
      scoredQuestionCount,
    );
    final traitBands = resolveBands(
      traitScores: traitScores,
      depthTier: depthTier,
      scoredQuestionCount: scoredQuestionCount,
    );

    return BigFiveResultSummary(
      testId: bigFiveTestId,
      traitScoreFields: traitAveragesToScoreFields(traitScores),
      traitBandFields: traitBandsToBandFields(traitBands),
      depthTier: depthTier,
      scoredQuestionCount: scoredQuestionCount,
      scoredAt: scoredAt ?? DateTime.now(),
    );
  }

  /// Likert 1–5 averages per trait (`reverse` → `6 - score`).
  static Map<String, double> calculateTraitAverages(
    List<TestQuestion> questions,
    Map<String, int> answers,
  ) {
    final buckets = <String, List<int>>{
      for (final trait in BigFiveTraitId.all) trait: <int>[],
    };

    for (final question in questions) {
      final answer = answers[question.id];
      if (answer == null) continue;

      var score = answer;
      if (question.reverse) {
        score = 6 - score;
      }

      final trait = question.trait;
      if (!buckets.containsKey(trait)) continue;
      buckets[trait]!.add(score);
    }

    final averages = <String, double>{};
    for (final trait in BigFiveTraitId.all) {
      final scores = buckets[trait]!;
      if (scores.isEmpty) {
        averages[trait] = 0;
        continue;
      }
      averages[trait] = scores.reduce((a, b) => a + b) / scores.length;
    }

    return averages;
  }

  static Map<String, String> resolveBands({
    required Map<String, double> traitScores,
    required BigFiveDepthTier depthTier,
    required int scoredQuestionCount,
  }) {
    final thresholds = _thresholdsFor(depthTier, scoredQuestionCount);
    final bands = <String, String>{};

    traitScores.forEach((trait, average) {
      bands[trait] = _bandForAverage(average, thresholds);
    });

    return bands;
  }

  static int _countAnsweredInSet(
    List<TestQuestion> questions,
    Map<String, int> answers,
  ) {
    var count = 0;
    for (final question in questions) {
      if (answers.containsKey(question.id)) count++;
    }
    return count;
  }

  static _BandThresholds _thresholdsFor(
    BigFiveDepthTier depthTier,
    int scoredQuestionCount,
  ) {
    // Slightly wider moderate band at quick depth (fewer items per trait).
    return switch (depthTier) {
      BigFiveDepthTier.quick => const _BandThresholds(
          emergingMax: 2.4,
          moderateMax: 3.6,
        ),
      BigFiveDepthTier.standard => const _BandThresholds(
          emergingMax: 2.5,
          moderateMax: 3.5,
        ),
      BigFiveDepthTier.deep => const _BandThresholds(
          emergingMax: 2.5,
          moderateMax: 3.5,
        ),
    };
  }

  static String _bandForAverage(double average, _BandThresholds thresholds) {
    if (average <= 0) return BigFiveBandId.moderate;
    if (average < thresholds.emergingMax) return BigFiveBandId.emerging;
    if (average <= thresholds.moderateMax) return BigFiveBandId.moderate;
    return BigFiveBandId.strong;
  }
}

class _BandThresholds {
  const _BandThresholds({
    required this.emergingMax,
    required this.moderateMax,
  });

  final double emergingMax;
  final double moderateMax;
}
