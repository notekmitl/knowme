import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';

import 'package:knowme/data/questions/bigfive/tipi_10.dart';
import 'package:knowme/data/questions/bigfive/bfi_44.dart';
import 'package:knowme/data/questions/bigfive/ipip_120.dart';

import 'package:knowme/data/questions/eq/advanced/eq_awareness_20.dart';
import 'package:knowme/data/questions/eq/advanced/eq_regulation_20.dart';
import 'package:knowme/data/questions/eq/advanced/eq_empathy_20.dart';
import 'package:knowme/data/questions/eq/advanced/eq_social_20.dart';
import 'package:knowme/data/questions/eq/advanced/eq_stress_20.dart';
import 'package:knowme/data/questions/eq/advanced/eq_decision_20.dart';

import 'package:knowme/data/questions/mbti/mbti_mini.dart';
import 'package:knowme/data/questions/mbti/mbti_short.dart';
import 'package:knowme/data/questions/mbti/mbti_accurate.dart';

class QuestionService {
  static final Map<String, List<TestQuestion>> _questionBank = {
    /// MBTI
    "mbti_mini": mbtiMiniQuestions,
    "mbti_short": mbtiShortQuestions,
    "mbti_accurate": mbtiAccurateQuestions,

    /// BIG FIVE
    "bigfive_tipi": tipiQuestions,
    "bigfive_bfi44": bfi44Questions,
    "bigfive_ipip120": ipip120Questions,

    /// EQ
    "eq_awareness": eqAwareness20,
    "eq_regulation": eqRegulation20,
    "eq_empathy": eqEmpathy20,
    "eq_social": eqSocial20,
    "eq_stress": eqStress20,
    "eq_decision": eqDecision20,
  };

  static List<TestQuestion> getQuestions(TestModule module) {
    final questions = _questionBank[module.id];

    if (questions == null) {
      print("QuestionService: Module not found ${module.id}");
      return [];
    }

    return questions;
  }
}
