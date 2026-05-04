import 'package:knowme/domain/models/test_question.dart';

class MbtiScoringService {
  static Map<String, double> calculate(
    List<TestQuestion> questions,
    Map<String, dynamic> answers,
  ) {
    double e = 0, i = 0;
    double s = 0, n = 0;
    double t = 0, f = 0;
    double j = 0, p = 0;

    for (final question in questions) {
      final answer = answers[question.id];

      /// skip unanswered
      if (answer == null) continue;

      double score = (answer as num).toDouble();

      if (question.reverse) {
        score = 6 - score;
      }

      switch (question.trait) {
        case "E":
          e += score;
          break;

        case "I":
          i += score;
          break;

        case "S":
          s += score;
          break;

        case "N":
          n += score;
          break;

        case "T":
          t += score;
          break;

        case "F":
          f += score;
          break;

        case "J":
          j += score;
          break;

        case "P":
          p += score;
          break;
      }
    }

    return {"E": e, "I": i, "S": s, "N": n, "T": t, "F": f, "J": j, "P": p};
  }

  static String getType(Map<String, double> score) {
    final ei = score["E"]! >= score["I"]! ? "E" : "I";
    final sn = score["S"]! >= score["N"]! ? "S" : "N";
    final tf = score["T"]! >= score["F"]! ? "T" : "F";
    final jp = score["J"]! >= score["P"]! ? "J" : "P";

    return "$ei$sn$tf$jp";
  }
}
