import 'package:knowme/domain/models/personality_core_result.dart';
import 'package:knowme/domain/models/personality_question.dart';

class PersonalityScoringService {
  static PersonalityCoreResult calculate({
    required List<PersonalityQuestion> questions,
    required Map<String, int> answers,
  }) {
    final Map<String, List<int>> traitScores = {
      "openness": [],
      "conscientiousness": [],
      "extraversion": [],
      "agreeableness": [],
      "neuroticism": [],
    };

    for (final question in questions) {
      final rawScore = answers[question.id];

      if (rawScore == null) continue;

      int finalScore = rawScore;

      // Reverse scoring
      if (question.reverseScored) {
        finalScore = 6 - rawScore;
      }

      traitScores[question.trait]?.add(finalScore);
    }

    double calculateAverage(List<int> scores) {
      if (scores.isEmpty) return 0;
      final total = scores.reduce((a, b) => a + b);
      final avg = total / scores.length;
      return _normalize(avg);
    }

    return PersonalityCoreResult(
      openness: calculateAverage(traitScores["openness"]!),
      conscientiousness: calculateAverage(traitScores["conscientiousness"]!),
      extraversion: calculateAverage(traitScores["extraversion"]!),
      agreeableness: calculateAverage(traitScores["agreeableness"]!),
      neuroticism: calculateAverage(traitScores["neuroticism"]!),
    );
  }

  static double _normalize(double score) {
    return ((score - 1) / 4) * 100;
  }
}
