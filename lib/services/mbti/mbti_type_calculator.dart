import 'mbti_function_stack.dart';
import '../../domain/models/mbti_type_result.dart';

class MbtiTypeCalculator {
  static MbtiTypeResult calculate(Map<String, double> scores) {
    String bestType = "";
    double bestScore = -999;

    mbtiFunctionStacks.forEach((type, stack) {
      double score = 0;

      score += (scores[stack[0]] ?? 0) * 4;
      score += (scores[stack[1]] ?? 0) * 3;
      score += (scores[stack[2]] ?? 0) * 2;
      score += (scores[stack[3]] ?? 0) * 1;

      if (score > bestScore) {
        bestScore = score;
        bestType = type;
      }
    });

    final stack = mbtiFunctionStacks[bestType]!;

    return MbtiTypeResult(
      type: bestType,
      dominant: stack[0],
      auxiliary: stack[1],
      tertiary: stack[2],
      inferior: stack[3],
    );
  }
}
