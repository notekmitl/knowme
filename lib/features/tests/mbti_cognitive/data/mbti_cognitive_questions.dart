import 'package:knowme/data/questions/mbti/mbti_cognitive_progressive_questions.dart';
import 'package:knowme/domain/models/test_question.dart';

import '../domain/mbti_cognitive_models.dart';

/// Default paired pole when a bank [TestQuestion] only sets [TestQuestion.trait].
const Map<String, String> defaultCognitiveNegativeFunction = {
  'Ni': 'Se',
  'Ne': 'Si',
  'Si': 'Ne',
  'Se': 'Ni',
  'Ti': 'Fe',
  'Te': 'Fi',
  'Fi': 'Te',
  'Fe': 'Ti',
};

MbtiCognitiveQuestion cognitiveQuestionFromTestQuestion(TestQuestion q) {
  final positive = q.trait;
  return MbtiCognitiveQuestion(
    id: q.id,
    text: q.text,
    positiveFunction: positive,
    negativeFunction: defaultCognitiveNegativeFunction[positive] ?? 'Ne',
    options: q.options,
    reverse: q.reverse,
  );
}

List<MbtiCognitiveQuestion> cognitiveQuestionsFromTestQuestions(
  List<TestQuestion> source,
) {
  return source.map(cognitiveQuestionFromTestQuestion).toList();
}

final List<MbtiCognitiveQuestion> mbtiCognitiveMiniActiveQuestions =
    cognitiveQuestionsFromTestQuestions(mbtiCognitiveMiniQuestions);

final List<MbtiCognitiveQuestion> mbtiCognitiveStandardActiveQuestions =
    cognitiveQuestionsFromTestQuestions(mbtiCognitiveStandardQuestions);

final List<MbtiCognitiveQuestion> mbtiCognitiveAccurateActiveQuestions =
    cognitiveQuestionsFromTestQuestions(mbtiCognitiveAccurateQuestions);
