class AttachmentScoringService {
  static Map<String, double> calculate(Map<String, int> answers) {
    double secure = 0;
    double anxious = 0;
    double avoidant = 0;

    answers.forEach((key, value) {
      /// Secure
      if (["at1", "at2", "at3", "at4"].contains(key)) {
        secure += value;
      }

      /// Anxious
      if (["at5", "at6", "at7", "at8"].contains(key)) {
        anxious += value;
      }

      /// Avoidant
      if (["at9", "at10", "at11", "at12"].contains(key)) {
        avoidant += value;
      }
    });

    double convert(double score) {
      return (score / 20) * 100;
    }

    return {
      "secure": convert(secure),
      "anxious": convert(anxious),
      "avoidant": convert(avoidant),
    };
  }
}
