import '../domain/mbti_cognitive_models.dart';
import 'mbti_cognitive_stack_matcher.dart';

/// Likert scoring into eight cognitive function totals (paired poles per question).
class MbtiCognitiveScorer {
  const MbtiCognitiveScorer();

  MbtiCognitiveResultSummary score({
    required List<MbtiCognitiveQuestion> questions,
    required Map<String, int> answers,
    DateTime? scoredAt,
    int? scoredQuestionCount,
  }) {
    final scores = calculateFunctionScores(questions, answers);
    final topFunctions = orderedFunctionsFromScores(scores);
    final stackTypeHints = stackHintsForTopFour(topFunctions.take(4).toList());

    return MbtiCognitiveResultSummary(
      testId: mbtiCognitiveTestId,
      scores: scores,
      topFunctions: topFunctions,
      scoredAt: scoredAt ?? DateTime.now(),
      stackTypeHints: stackTypeHints,
      scoredQuestionCount: scoredQuestionCount ?? questions.length,
    );
  }

  static Map<String, double> calculateFunctionScores(
    List<MbtiCognitiveQuestion> questions,
    Map<String, int> answers,
  ) {
    final scores = {
      for (final fn in mbtiCognitiveFunctions) fn: 0.0,
    };

    for (final question in questions) {
      final answer = answers[question.id];
      if (answer == null) continue;

      double primary = answer.toDouble();
      if (question.reverse) {
        primary = 6 - primary;
      }
      final secondary = 6 - primary;

      scores[question.positiveFunction] =
          scores[question.positiveFunction]! + primary;
      scores[question.negativeFunction] =
          scores[question.negativeFunction]! + secondary;
    }

    return scores;
  }

  static List<String> orderedFunctionsFromScores(Map<String, double> scores) {
    final entries = scores.entries.toList()
      ..sort((a, b) {
        final byScore = b.value.compareTo(a.value);
        if (byScore != 0) return byScore;
        return a.key.compareTo(b.key);
      });
    return entries.map((e) => e.key).toList();
  }

  /// Share of total score mass (0–100) for bar display.
  static int displayPercent(String function, Map<String, double> scores) {
    final total = scores.values.fold<double>(0, (sum, v) => sum + v);
    if (total <= 0) return 0;
    return ((scores[function]! / total) * 100).round().clamp(0, 100);
  }
}
