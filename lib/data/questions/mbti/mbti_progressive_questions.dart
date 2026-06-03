import 'package:knowme/domain/models/test_question.dart';

import 'mbti_bank.dart';

/// Progressive MBTI run order (single test, checkpoints @ 16 / 40 / 80).
/// Does not mutate [mbtiBank] — lookup by id only.
const String mbtiProgressiveQuestionVersion =
    'knowme.mbti.progressive.curated.v1';

/// Positions 1–16 (mini checkpoint).
const List<String> _miniIds = [
  'mbti_acc_1',
  'mbti_acc_21',
  'mbti_acc_41',
  'mbti_acc_61',
  'mbti_acc_3',
  'mbti_acc_25',
  'mbti_acc_43',
  'mbti_acc_67',
  'mbti_acc_4',
  'mbti_acc_22',
  'mbti_acc_42',
  'mbti_acc_62',
  'mbti_acc_14',
  'mbti_acc_28',
  'mbti_acc_48',
  'mbti_acc_64',
];

/// Positions 17–40 (standard tier — additions after mini set).
const List<String> _standardAdditionIds = [
  'mbti_acc_6',
  'mbti_acc_2',
  'mbti_acc_11',
  'mbti_acc_10',
  'mbti_acc_17',
  'mbti_acc_20',
  'mbti_acc_23',
  'mbti_acc_26',
  'mbti_acc_29',
  'mbti_acc_32',
  'mbti_acc_33',
  'mbti_acc_38',
  'mbti_acc_57',
  'mbti_acc_46',
  'mbti_acc_47',
  'mbti_acc_52',
  'mbti_acc_55',
  'mbti_acc_58',
  'mbti_acc_63',
  'mbti_acc_66',
  'mbti_acc_69',
  'mbti_acc_72',
  'mbti_acc_77',
  'mbti_acc_80',
];

/// Canonical progressive order (80 ids).
const List<String> mbtiProgressiveQuestionIds = [
  ..._miniIds,
  ..._standardAdditionIds,
  // Positions 41–80: remaining bank ids once, in bank order.
  'mbti_acc_5',
  'mbti_acc_7',
  'mbti_acc_8',
  'mbti_acc_9',
  'mbti_acc_12',
  'mbti_acc_13',
  'mbti_acc_15',
  'mbti_acc_16',
  'mbti_acc_18',
  'mbti_acc_19',
  'mbti_acc_24',
  'mbti_acc_27',
  'mbti_acc_30',
  'mbti_acc_31',
  'mbti_acc_34',
  'mbti_acc_35',
  'mbti_acc_36',
  'mbti_acc_37',
  'mbti_acc_39',
  'mbti_acc_40',
  'mbti_acc_44',
  'mbti_acc_45',
  'mbti_acc_49',
  'mbti_acc_50',
  'mbti_acc_51',
  'mbti_acc_53',
  'mbti_acc_54',
  'mbti_acc_56',
  'mbti_acc_59',
  'mbti_acc_60',
  'mbti_acc_65',
  'mbti_acc_68',
  'mbti_acc_70',
  'mbti_acc_71',
  'mbti_acc_73',
  'mbti_acc_74',
  'mbti_acc_75',
  'mbti_acc_76',
  'mbti_acc_78',
  'mbti_acc_79',
];

const int mbtiProgressiveMiniCount = 16;
const int mbtiProgressiveStandardCount = 40;
const int mbtiProgressiveAccurateCount = 80;

final Map<String, TestQuestion> _bankById = {
  for (final q in mbtiBank) q.id: q,
};

List<TestQuestion> _questionsFromIds(List<String> ids) {
  return [for (final id in ids) _bankById[id]!];
}

void _assertProgressiveCatalog(List<TestQuestion> progressive) {
  assert(
    mbtiProgressiveQuestionIds.length == mbtiProgressiveAccurateCount,
    'progressive id list must be 80',
  );
  assert(
    progressive.length == mbtiProgressiveAccurateCount,
    'progressive questions must be 80',
  );

  final ids = progressive.map((q) => q.id).toList();
  assert(ids.toSet().length == 80, 'progressive ids must be unique');
  assert(
    ids.toSet().length == mbtiBank.length,
    'progressive must include every bank id once',
  );

  void assertTraitCounts(int prefixLen, int e, int s, int t, int j) {
    final slice = progressive.take(prefixLen);
    final counts = <String, int>{};
    for (final q in slice) {
      counts[q.trait] = (counts[q.trait] ?? 0) + 1;
    }
    assert(counts['E'] == e, 'E count @ $prefixLen');
    assert(counts['S'] == s, 'S count @ $prefixLen');
    assert(counts['T'] == t, 'T count @ $prefixLen');
    assert(counts['J'] == j, 'J count @ $prefixLen');
  }

  assertTraitCounts(16, 4, 4, 4, 4);
  assertTraitCounts(40, 10, 10, 10, 10);
  assertTraitCounts(80, 20, 20, 20, 20);
}

final List<TestQuestion> mbtiProgressiveQuestions = () {
  final questions = _questionsFromIds(mbtiProgressiveQuestionIds);
  _assertProgressiveCatalog(questions);
  return questions;
}();

/// Checkpoint prefixes (same [TestQuestion] instances as bank).
final List<TestQuestion> mbtiMiniQuestions =
    mbtiProgressiveQuestions.sublist(0, mbtiProgressiveMiniCount);

final List<TestQuestion> mbtiStandardQuestions =
    mbtiProgressiveQuestions.sublist(0, mbtiProgressiveStandardCount);

final List<TestQuestion> mbtiAccurateQuestions = mbtiProgressiveQuestions;
