import 'package:knowme/domain/models/test_question.dart';

class EQScoringService {
  static Map<String, double> calculate(
    Map<String, int> answers,
    List<TestQuestion> questions,
  ) {
    Map<String, List<int>> dimensionScores = {};

    for (var q in questions) {
      final answer = answers[q.id];

      if (answer == null) continue;

      final dimension = q.trait;

      dimensionScores.putIfAbsent(dimension, () => []);

      dimensionScores[dimension]!.add(answer);
    }

    Map<String, double> results = {};

    dimensionScores.forEach((dimension, scores) {
      double avg = scores.reduce((a, b) => a + b) / scores.length;

      double normalized = (avg - 1) / 4 * 100;

      results[dimension] = normalized;
    });

    return results;
  }
}
