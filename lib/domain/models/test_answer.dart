class TestAnswer {
  final String questionId;
  final int score;

  TestAnswer({required this.questionId, required this.score});

  Map<String, dynamic> toMap() {
    return {"questionId": questionId, "score": score};
  }
}
