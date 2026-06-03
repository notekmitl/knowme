import 'package:knowme/domain/models/test_question.dart';

import 'mbti_bank.dart';

/// Curated MBTI mini v2 — 4 items per dimension (2 forward, 2 reverse).
const List<String> mbtiMiniV2QuestionIds = [
  'mbti_acc_1',
  'mbti_acc_3',
  'mbti_acc_4',
  'mbti_acc_14',
  'mbti_acc_21',
  'mbti_acc_25',
  'mbti_acc_22',
  'mbti_acc_28',
  'mbti_acc_41',
  'mbti_acc_43',
  'mbti_acc_42',
  'mbti_acc_48',
  'mbti_acc_61',
  'mbti_acc_67',
  'mbti_acc_62',
  'mbti_acc_64',
];

final Map<String, TestQuestion> _mbtiBankById = {
  for (final q in mbtiBank) q.id: q,
};

final List<TestQuestion> mbtiMiniQuestions = [
  for (final id in mbtiMiniV2QuestionIds) _mbtiBankById[id]!,
];
