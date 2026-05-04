import '../../domain/models/test_module.dart';
import '../../domain/models/test_question.dart';

import 'package:knowme/services//test_engine/question_service.dart';
import 'package:knowme/services//test_engine/scoring_router.dart';

import 'package:knowme/application/personality_engine/trait_engine.dart';
import 'package:knowme/application/personality_engine/personality_fusion_engine.dart';

class TestRunner {
  static Map<String, double> runTest(
    TestModule module,
    Map<String, int> answers,
  ) {
    final questions = QuestionService.getQuestions(module);

    final result = ScoringRouter.calculate(module, answers, questions);

    /// รวม trait
    final mergedTraits = TraitEngine.mergeTraits([result]);

    /// normalize
    final normalizedTraits = PersonalityFusionEngine.normalizeTraits(
      mergedTraits,
    );

    return normalizedTraits;
  }
}
