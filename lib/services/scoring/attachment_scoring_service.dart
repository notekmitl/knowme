class AttachmentScoringService {
  static Map<String, double> calculate(Map<String, int> answers) {
    double avg = answers.values.isEmpty
        ? 0
        : answers.values.reduce((a, b) => a + b) / answers.length;

    double percent = ((avg - 1) / 4) * 100;

    return {"attachment": percent};
  }
}
