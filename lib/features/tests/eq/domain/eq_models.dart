import 'package:knowme/domain/models/test_question.dart';

import '../data/modules/eq_awareness_20.dart';
import '../data/modules/eq_decision_20.dart';
import '../data/modules/eq_empathy_20.dart';
import '../data/modules/eq_regulation_20.dart';
import '../data/modules/eq_social_20.dart';
import '../data/modules/eq_stress_20.dart';
import 'eq_test_type.dart';

/// MVP: awareness only. Extend when cloning other EQ modules.
const EqTestType eqAwarenessTestType = EqTestType.awareness;

const int eqAwarenessQuestionCount = 20;

/// Firestore `scoringVersion` for results schema evolution.
const int eqScoringVersion = 1;

/// Stored in `users/{uid}/results/eq_awareness` (numeric fields only).
class EqResultSummary {
  const EqResultSummary({
    required this.testId,
    required this.averageScore,
    required this.level,
    required this.scoredQuestionCount,
    this.scoringVersion = eqScoringVersion,
    this.completedAt,
  });

  final String testId;
  final double averageScore;

  /// One of [EqLevelIds.emerging], [EqLevelIds.moderate], [EqLevelIds.strong].
  final String level;
  final int scoredQuestionCount;
  final int scoringVersion;
  final DateTime? completedAt;
}

abstract final class EqLevelIds {
  static const emerging = 'emerging';
  static const moderate = 'moderate';
  static const strong = 'strong';
}

/// Working state in `users/{uid}/tests/{testId}`.
class EqTestSession {
  const EqTestSession({
    required this.answers,
    required this.answered,
    required this.index,
    required this.total,
    required this.completed,
  });

  final Map<String, int> answers;
  final int answered;
  final int index;
  final int total;
  final bool completed;
}

/// Optimistic progress returned when leaving [EqTestPage] via back navigation.
class EqTestProgressHint {
  const EqTestProgressHint({
    required this.testType,
    required this.answered,
    required this.total,
  });

  final EqTestType testType;
  final int answered;
  final int total;
}

/// Questions for a given EQ test type.
List<TestQuestion> eqQuestionsFor(EqTestType type) {
  return switch (type) {
    EqTestType.awareness => List<TestQuestion>.unmodifiable(eqAwareness20),
    EqTestType.regulation => List<TestQuestion>.unmodifiable(eqRegulation20),
    EqTestType.empathy => List<TestQuestion>.unmodifiable(eqEmpathy20),
    EqTestType.social => List<TestQuestion>.unmodifiable(eqSocial20),
    EqTestType.decision => List<TestQuestion>.unmodifiable(eqDecision20),
    EqTestType.stress => List<TestQuestion>.unmodifiable(eqStress20),
  };
}
