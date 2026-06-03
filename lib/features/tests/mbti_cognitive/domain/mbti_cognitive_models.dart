/// Domain models for MBTI Cognitive module (`mbti_cognitive` test id).
const String mbtiCognitiveTestId = 'mbti_cognitive';

const int mbtiCognitiveMiniCheckpoint = 16;
const int mbtiCognitiveStandardCheckpoint = 40;
const int mbtiCognitiveAccurateCheckpoint = 80;

enum MbtiCognitiveCheckpoint {
  mini,
  standard,
  accurate,
}

const int mbtiCognitiveScoringVersion = 1;

/// All eight cognitive functions scored by this module.
const List<String> mbtiCognitiveFunctions = [
  'Ni',
  'Ne',
  'Ti',
  'Te',
  'Fi',
  'Fe',
  'Si',
  'Se',
];

class MbtiCognitiveQuestion {
  const MbtiCognitiveQuestion({
    required this.id,
    required this.text,
    required this.positiveFunction,
    required this.negativeFunction,
    required this.options,
    this.reverse = false,
  });

  final String id;
  final Map<String, String> text;
  final String positiveFunction;
  final String negativeFunction;
  final List<dynamic> options;
  final bool reverse;
}

class MbtiCognitiveResultSummary {
  const MbtiCognitiveResultSummary({
    required this.testId,
    required this.scores,
    required this.topFunctions,
    required this.scoredAt,
    this.scoringVersion = mbtiCognitiveScoringVersion,
    this.stackTypeHints = const [],
    this.scoredQuestionCount = mbtiCognitiveMiniCheckpoint,
  });

  final String testId;
  final Map<String, double> scores;
  final List<String> topFunctions;
  final DateTime scoredAt;
  final int scoringVersion;

  /// Questions included when this summary was scored (16 / 40 / 80).
  final int scoredQuestionCount;

  /// Probabilistic MBTI-type hints from function overlap (not identity claims).
  final List<String> stackTypeHints;

  double scoreFor(String function) => scores[function] ?? 0;

  List<String> get topFour =>
      topFunctions.length >= 4 ? topFunctions.sublist(0, 4) : topFunctions;

  bool get isMiniCheckpointResult =>
      scoredQuestionCount <= mbtiCognitiveMiniCheckpoint;

  bool get isStandardCheckpointResult =>
      scoredQuestionCount <= mbtiCognitiveStandardCheckpoint &&
      scoredQuestionCount > mbtiCognitiveMiniCheckpoint;

  bool get isAccurateCheckpointResult =>
      scoredQuestionCount >= mbtiCognitiveAccurateCheckpoint;
}

class MbtiCognitiveSession {
  const MbtiCognitiveSession({
    required this.answers,
    required this.answered,
    required this.total,
    this.completed = false,
  });

  final Map<String, int> answers;
  final int answered;
  final int total;
  final bool completed;

  factory MbtiCognitiveSession.empty({required int total}) {
    return MbtiCognitiveSession(answers: const {}, answered: 0, total: total);
  }
}

class MbtiCognitiveProgress {
  const MbtiCognitiveProgress({
    required this.answered,
    required this.total,
    required this.completed,
  });

  final int answered;
  final int total;
  final bool completed;
}
