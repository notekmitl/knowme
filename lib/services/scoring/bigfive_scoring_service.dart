import 'package:knowme/domain/models/test_question.dart';

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

    /// loop ทุกคำถาม
    for (TestQuestion q in questions) {
      /// ถ้า user ไม่ตอบ ข้าม
      if (!answers.containsKey(q.id)) continue;

      int score = answers[q.id]!;

      /// reverse scoring
      if (q.reverse) {
        score = 6 - score;
      }

      /// เก็บคะแนนตาม trait
      traitScores[q.trait]!.add(score);
    }

    /// คำนวณค่าเฉลี่ย trait
    Map<String, double> result = {};

    traitScores.forEach((trait, scores) {
      if (scores.isEmpty) {
        result[trait] = 0;
        return;
      }

      double avg = scores.reduce((a, b) => a + b) / scores.length;

      result[trait] = avg;
    });

    return result;
  }
}
