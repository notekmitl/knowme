/// Domain models for MBTI mini module (`mbti_mini` test id).
const String mbtiMiniTestId = 'mbti_mini';

const int mbtiMiniQuestionCount = 16;

/// Progressive MBTI checkpoint boundaries (question counts, inclusive).
const int mbtiMiniCheckpoint = 16;
const int mbtiStandardCheckpoint = 40;
const int mbtiAccurateCheckpoint = 80;

enum MbtiCheckpoint {
  mini,
  standard,
  accurate,
}

const int mbtiMiniScoringVersion = 1;

class MbtiResultSummary {
  final String testId;
  final String type;
  final Map<String, double> dimensions;
  final DateTime scoredAt;
  final int scoringVersion;

  /// Progressive questions included when this summary was scored.
  final int scoredQuestionCount;

  const MbtiResultSummary({
    required this.testId,
    required this.type,
    required this.dimensions,
    required this.scoredAt,
    this.scoringVersion = mbtiMiniScoringVersion,
    this.scoredQuestionCount = mbtiMiniCheckpoint,
  });

  double dimension(String key) => dimensions[key] ?? 0;

  bool get isMiniCheckpointResult =>
      scoredQuestionCount <= mbtiMiniCheckpoint;
}

class MbtiMiniSession {
  final Map<String, int> answers;
  final int answered;
  final int total;
  final bool completed;

  const MbtiMiniSession({
    required this.answers,
    required this.answered,
    required this.total,
    this.completed = false,
  });

  factory MbtiMiniSession.empty({required int total}) {
    return MbtiMiniSession(answers: const {}, answered: 0, total: total);
  }
}

class MbtiMiniProgress {
  final int answered;
  final int total;
  final bool completed;

  const MbtiMiniProgress({
    required this.answered,
    required this.total,
    required this.completed,
  });
}
