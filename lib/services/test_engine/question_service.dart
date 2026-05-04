import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';

import 'package:knowme/data/questions/bigfive/tipi_10.dart';
import 'package:knowme/data/questions/bigfive/bfi_44.dart';
import 'package:knowme/data/questions/bigfive/ipip_120.dart';

import 'package:knowme/data/questions/eq/eq_quick_12.dart';
import 'package:knowme/data/questions/eq/eq_core_60.dart';
import 'package:knowme/data/questions/eq/eq_advanced_120.dart';

import 'package:knowme/data/questions/mbti/mbti_mini.dart';
import 'package:knowme/data/questions/mbti/mbti_short.dart';
import 'package:knowme/data/questions/mbti/mbti_accurate.dart';
import 'package:knowme/data/questions/mbti/mbti_cognitive.dart';

class QuestionService {
  static final Map<String, List<TestQuestion>> _registry = {
    /// MBTI
    "mbti_mini": mbtiMiniQuestions,
    "mbti_short": mbtiShortQuestions,
    "mbti_accurate": mbtiAccurateQuestions,
    "mbti_cognitive": mbtiCognitiveQuestions,

    /// Big Five
    "bigfive_mini": tipiQuestions,
    "bigfive_short": bfi44Questions,
    "bigfive_accurate": ipip120Questions,

    /// EQ
    "eq_quick": eqQuick12,
    "eq_core": eqCore60,
    "eq_advanced": eqAdvanced120,
  };

  static List<TestQuestion> getQuestions(TestModule module) {
    return _registry[module.id] ?? [];
  }
}
