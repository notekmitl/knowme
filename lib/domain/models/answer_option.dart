class AnswerOption {
  final String id;

  /// ข้อความของตัวเลือก
  final Map<String, String> text;

  /// คะแนนของตัวเลือก
  final int score;

  const AnswerOption({
    required this.id,
    required this.text,
    required this.score,
  });
}
