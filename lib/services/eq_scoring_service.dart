import 'package:knowme/domain/models/test_question.dart';

class EQScoringService {
  static Map<String, double> calculate(Map<String, int> answers) {
    double awareness = 0;
    double regulation = 0;
    double empathy = 0;

    answers.forEach((key, value) {
      /// Emotional Awareness
      if (["eq1", "eq2", "eq3", "eq4", "eq5"].contains(key)) {
        awareness += value;
      }

      /// Emotion Regulation
      if (["eq6", "eq7", "eq8", "eq9", "eq10"].contains(key)) {
        regulation += value;
      }

      /// Empathy
      if (["eq11", "eq12", "eq13", "eq14", "eq15"].contains(key)) {
        empathy += value;
      }
    });

    double convert(double score) {
      return (score / 25) * 100;
    }

    return {
      "awareness": convert(awareness),
      "regulation": convert(regulation),
      "empathy": convert(empathy),
    };
  }
}
