import '../../domain/models/test_module.dart';
import '../../domain/models/test_question.dart';

import '../scoring/bigfive_scoring_service.dart';
import '../scoring/eq_scoring_service.dart';
import '../scoring/attachment_scoring_service.dart';
import '../scoring/motivation_scoring_service.dart';
import '../scoring/mbti_scoring_service.dart';

class ScoringRouter {
  static Map<String, double> calculate(
    TestModule module,
    Map<String, int> answers,
    List<TestQuestion> questions,
  ) {
    /// BIG FIVE
    if (module.id.startsWith("bigfive")) {
      return BigFiveScoringService.calculate(answers, questions);
    }

    /// EQ
    if (module.id.startsWith("eq")) {
      return EQScoringService.calculate(answers, questions);
    }

    /// ATTACHMENT
    if (module.id.startsWith("attachment")) {
      return AttachmentScoringService.calculate(answers);
    }

    /// MOTIVATION
    if (module.id.startsWith("motivation")) {
      return MotivationScoringService.calculate(answers);
    }

    return {};
  }
}
