import 'package:knowme/domain/models/test_question.dart';

import '../domain/mbti_models.dart';

/// MBTI scoring for the mini module — algorithm parity with [MbtiScoringService].
class MbtiScorer {
  const MbtiScorer();

  MbtiResultSummary score({
    required List<TestQuestion> questions,
    required Map<String, int> answers,
    DateTime? scoredAt,
  }) {
    final dimensions = calculateDimensions(questions, answers);
    final type = typeFromDimensions(dimensions);

    return MbtiResultSummary(
      testId: mbtiMiniTestId,
      type: type,
      dimensions: dimensions,
      scoredAt: scoredAt ?? DateTime.now(),
      scoredQuestionCount: questions.length,
    );
  }

  /// Legacy-compatible dimension totals (Likert 1–5, reverse → `6 - score`).
  static Map<String, double> calculateDimensions(
    List<TestQuestion> questions,
    Map<String, int> answers,
  ) {
    double e = 0, i = 0;
    double s = 0, n = 0;
    double t = 0, f = 0;
    double j = 0, p = 0;

    for (final question in questions) {
      final answer = answers[question.id];
      if (answer == null) continue;

      double score = answer.toDouble();
      if (question.reverse) {
        score = 6 - score;
      }

      switch (question.trait) {
        case 'E':
          e += score;
          break;
        case 'I':
          i += score;
          break;
        case 'S':
          s += score;
          break;
        case 'N':
          n += score;
          break;
        case 'T':
          t += score;
          break;
        case 'F':
          f += score;
          break;
        case 'J':
          j += score;
          break;
        case 'P':
          p += score;
          break;
      }
    }

    return {'E': e, 'I': i, 'S': s, 'N': n, 'T': t, 'F': f, 'J': j, 'P': p};
  }

  /// Likert paired scoring: each answered question adds 6 to one axis (primary + opposite).
  static const double dimensionPointsPerQuestion = 6;

  static double dimensionScoreMass(Map<String, double> dimensions) {
    return dimensions.values.fold<double>(0, (sum, v) => sum + v);
  }

  /// Legacy results without [scoredQuestionCount] — infer checkpoint from dimension mass.
  static int inferScoredQuestionCountFromDimensions(Map<String, double> dimensions) {
    const standardThreshold = 168; // midpoint 96 (16) and 240 (40)
    const accurateThreshold = 360; // midpoint 240 (40) and 480 (80)
    final mass = dimensionScoreMass(dimensions);
    if (mass >= accurateThreshold) return mbtiAccurateCheckpoint;
    if (mass >= standardThreshold) return mbtiStandardCheckpoint;
    return mbtiMiniCheckpoint;
  }

  /// Type letters use `>=` tie-break (same as legacy UI + [MbtiScoringService]).
  static String typeFromDimensions(Map<String, double> dimensions) {
    final ei = dimensions['E']! >= dimensions['I']! ? 'E' : 'I';
    final sn = dimensions['S']! >= dimensions['N']! ? 'S' : 'N';
    final tf = dimensions['T']! >= dimensions['F']! ? 'T' : 'F';
    final jp = dimensions['J']! >= dimensions['P']! ? 'J' : 'P';
    return '$ei$sn$tf$jp';
  }
}
