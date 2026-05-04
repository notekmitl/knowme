import '../../domain/models/test_question.dart';

class BigFiveScoringService {
  static Map<String, double> calculate(
    Map<String, int> answers,
    List<TestQuestion> questions,
  ) {
    Map<String, List<int>> traitScores = {
      "openness": [],
      "conscientiousness": [],
      "extraversion": [],
      "agreeableness": [],
      "neuroticism": [],
    };

    /// loop questions
    for (TestQuestion q in questions) {
      if (!answers.containsKey(q.id)) continue;

      int score = answers[q.id]!;

      /// reverse scoring
      if (q.reverse) {
        score = 6 - score;
      }

      traitScores[q.trait]!.add(score);
    }

    /// calculate averages
    Map<String, double> result = {};

    traitScores.forEach((trait, scores) {
      if (scores.isEmpty) {
        result[trait] = 0;
        return;
      }

      double avg = scores.reduce((a, b) => a + b) / scores.length;

      /// convert to percentage
      double percent = ((avg - 1) / 4) * 100;

      result[trait] = percent;
    });

    return result;
  }
}
