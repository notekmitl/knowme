import 'package:knowme/domain/models/test_question.dart';

class ScoringEngine {
  static Map<String, double> calculate(
    List<TestQuestion> questions,
    Map<String, dynamic> answers,
  ) {
    final Map<String, double> scores = {};

    for (final question in questions) {
      final answer = answers[question.id];

      /// skip unanswered
      if (answer == null) continue;

      double score = (answer as num).toDouble();

      /// reverse scoring
      if (question.reverse) {
        score = 6 - score;
      }

      /// create trait bucket
      scores.putIfAbsent(question.trait, () => 0);

      scores[question.trait] = scores[question.trait]! + score;
    }

    return scores;
  }
}
