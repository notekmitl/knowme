import 'package:knowme/domain/models/test_question.dart';

import '../domain/eq_models.dart';

/// Deterministic Likert average → level band (no AI, no percentages in UI).
abstract final class EqScorer {
  static EqResultSummary score({
    required String testId,
    required List<TestQuestion> questions,
    required Map<String, int> answers,
    DateTime? completedAt,
  }) {
    var sum = 0.0;
    var count = 0;

    for (final question in questions) {
      final raw = answers[question.id];
      if (raw == null) continue;
      final value = question.reverse ? (6 - raw).toDouble() : raw.toDouble();
      sum += value;
      count++;
    }

    final average = count == 0 ? 0.0 : sum / count;
    final level = levelForAverage(average);

    return EqResultSummary(
      testId: testId,
      averageScore: double.parse(average.toStringAsFixed(2)),
      level: level,
      scoredQuestionCount: count,
      scoringVersion: eqScoringVersion,
      completedAt: completedAt ?? DateTime.now(),
    );
  }

  static String levelForAverage(double average) {
    if (average <= 2.4) return EqLevelIds.emerging;
    if (average <= 3.7) return EqLevelIds.moderate;
    return EqLevelIds.strong;
  }
}
