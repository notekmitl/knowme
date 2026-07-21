import 'package:knowme/domain/models/test_question.dart';

import 'mbti_cognitive.dart';

/// Progressive cognitive run order (single test, checkpoints @ 16 / 40 / 80).
const String mbtiCognitiveProgressiveQuestionVersion =
    'knowme.mbti_cognitive.progressive.curated.v1';

const int mbtiCognitiveMiniCheckpoint = 16;
const int mbtiCognitiveStandardCheckpoint = 40;
const int mbtiCognitiveAccurateCheckpoint = 80;

/// Ten curated items per function (bank order within each function).
const Map<String, List<String>> mbtiCognitiveFunctionQuestionIds = {
  'Ni': [
    'cog_1',
    'cog_2',
    'cog_3',
    'cog_4',
    'cog_33',
    'cog_34',
    'cog_35',
    'cog_36',
    'cog_37',
    'cog_38',
  ],
  'Ne': [
    'cog_5',
    'cog_6',
    'cog_7',
    'cog_8',
    'cog_39',
    'cog_40',
    'cog_41',
    'cog_42',
    'cog_43',
    'cog_44',
  ],
  'Ti': [
    'cog_17',
    'cog_18',
    'cog_19',
    'cog_20',
    'cog_57',
    'cog_58',
    'cog_59',
    'cog_60',
    'cog_61',
    'cog_62',
  ],
  'Te': [
    'cog_21',
    'cog_22',
    'cog_23',
    'cog_24',
    'cog_63',
    'cog_64',
    'cog_65',
    'cog_66',
    'cog_67',
    'cog_68',
  ],
  'Fi': [
    'cog_25',
    'cog_26',
    'cog_27',
    'cog_28',
    'cog_69',
    'cog_70',
    'cog_71',
    'cog_72',
    'cog_73',
    'cog_74',
  ],
  'Fe': [
    'cog_29',
    'cog_30',
    'cog_31',
    'cog_32',
    'cog_75',
    'cog_76',
    'cog_77',
    'cog_78',
    'cog_79',
    'cog_80',
  ],
  'Si': [
    'cog_9',
    'cog_10',
    'cog_11',
    'cog_12',
    'cog_45',
    'cog_46',
    'cog_47',
    'cog_48',
    'cog_49',
    'cog_50',
  ],
  'Se': [
    'cog_13',
    'cog_14',
    'cog_15',
    'cog_16',
    'cog_51',
    'cog_52',
    'cog_53',
    'cog_54',
    'cog_55',
    'cog_56',
  ],
};

/// Round-robin across functions — deterministic, balanced at each checkpoint.
List<String> _buildInterleavedProgressiveIds(int roundsPerFunction) {
  const order = ['Ni', 'Ne', 'Ti', 'Te', 'Fi', 'Fe', 'Si', 'Se'];
  final ids = <String>[];
  for (var round = 0; round < roundsPerFunction; round++) {
    for (final fn in order) {
      ids.add(mbtiCognitiveFunctionQuestionIds[fn]![round]);
    }
  }
  return ids;
}

/// Canonical progressive order (80 ids).
final List<String> mbtiCognitiveProgressiveQuestionIds =
    _buildInterleavedProgressiveIds(10);

final Map<String, TestQuestion> _cognitiveBankById = {
  for (final q in mbtiCognitiveQuestions) q.id: q,
};

List<TestQuestion> _questionsFromIds(List<String> ids) {
  return [for (final id in ids) _cognitiveBankById[id]!];
}

void _assertCognitiveProgressiveCatalog(List<TestQuestion> progressive) {
  assert(
    mbtiCognitiveProgressiveQuestionIds.length == mbtiCognitiveAccurateCheckpoint,
    'progressive id list must be 80',
  );
  assert(
    progressive.length == mbtiCognitiveAccurateCheckpoint,
    'progressive questions must be 80',
  );

  final ids = progressive.map((q) => q.id).toList();
  assert(ids.toSet().length == 80, 'progressive ids must be unique');
  assert(
    ids.toSet().length == mbtiCognitiveQuestions.length,
    'progressive must include every cognitive bank id once',
  );

  void assertFunctionCounts(int prefixLen, int perFunction) {
    final slice = progressive.take(prefixLen);
    final counts = <String, int>{};
    for (final q in slice) {
      counts[q.trait] = (counts[q.trait] ?? 0) + 1;
    }
    for (final fn in mbtiCognitiveFunctionQuestionIds.keys) {
      assert(
        counts[fn] == perFunction,
        '$fn count @ $prefixLen expected $perFunction got ${counts[fn]}',
      );
    }
  }

  assertFunctionCounts(mbtiCognitiveMiniCheckpoint, 2);
  assertFunctionCounts(mbtiCognitiveStandardCheckpoint, 5);
  assertFunctionCounts(mbtiCognitiveAccurateCheckpoint, 10);
}

final List<TestQuestion> mbtiCognitiveProgressiveQuestions = () {
  final questions = _questionsFromIds(mbtiCognitiveProgressiveQuestionIds);
  _assertCognitiveProgressiveCatalog(questions);
  return questions;
}();

final List<TestQuestion> mbtiCognitiveMiniQuestions = mbtiCognitiveProgressiveQuestions
    .sublist(0, mbtiCognitiveMiniCheckpoint);

final List<TestQuestion> mbtiCognitiveStandardQuestions =
    mbtiCognitiveProgressiveQuestions.sublist(0, mbtiCognitiveStandardCheckpoint);

final List<TestQuestion> mbtiCognitiveAccurateQuestions =
    mbtiCognitiveProgressiveQuestions;
