class MotivationScoringService {
  static Map<String, double> calculate(Map<String, int> answers) {
    double growth = 0;
    double achievement = 0;
    double purpose = 0;

    answers.forEach((key, value) {
      /// Growth
      if (["mo1", "mo2", "mo3", "mo4"].contains(key)) {
        growth += value;
      }

      /// Achievement
      if (["mo5", "mo6", "mo7", "mo8"].contains(key)) {
        achievement += value;
      }

      /// Purpose
      if (["mo9", "mo10", "mo11", "mo12"].contains(key)) {
        purpose += value;
      }
    });

    double convert(double score) {
      return (score / 20) * 100;
    }

    return {
      "growth": convert(growth),
      "achievement": convert(achievement),
      "purpose": convert(purpose),
    };
  }
}
