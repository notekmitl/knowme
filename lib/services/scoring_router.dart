import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';

import 'scoring/bigfive_scoring_service.dart';
import 'scoring/eq_scoring_service.dart';
import 'scoring/attachment_scoring_service.dart';
import 'scoring/motivation_scoring_service.dart';
import 'scoring/mbti_scoring_service.dart';

class ScoringRouter {
  static Map<String, double> calculate(
    TestModule module,
    Map<String, int> answers,
    List<TestQuestion> questions,
  ) {
    final id = module.id;

    /// BIG FIVE
    if (id.startsWith("bigfive")) {
      return BigFiveScoringService.calculate(answers, questions);
    }

    /// EQ
    if (id.startsWith("eq")) {
      return EQScoringService.calculate(answers, questions);
    }

    /// ATTACHMENT
    if (id.startsWith("attachment")) {
      return AttachmentScoringService.calculate(answers);
    }

    /// MOTIVATION
    if (id.startsWith("motivation")) {
      return MotivationScoringService.calculate(answers);
    }

    /// MBTI
    if (id.startsWith("mbti")) {
      return MbtiScoringService.calculate(questions, answers);
    }

    print("ScoringRouter: Unknown module ${module.id}");

    return {};
  }
}
