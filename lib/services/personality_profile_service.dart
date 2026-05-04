import 'package:knowme/domain/models/personality_profile.dart';

class PersonalityProfileService {
  PersonalityProfile buildProfile({
    Map<String, dynamic>? bigfive,
    Map<String, dynamic>? eq,
    Map<String, dynamic>? attachment,
    Map<String, dynamic>? motivation,
    String element = "unknown",
  }) {
    final Map<String, double> traits = {};

    /// Big Five
    traits["openness"] = (bigfive?["openness"] ?? 3).toDouble();
    traits["conscientiousness"] = (bigfive?["conscientiousness"] ?? 3)
        .toDouble();
    traits["extraversion"] = (bigfive?["extraversion"] ?? 3).toDouble();
    traits["agreeableness"] = (bigfive?["agreeableness"] ?? 3).toDouble();
    traits["neuroticism"] = (bigfive?["neuroticism"] ?? 3).toDouble();

    /// EQ
    traits["awareness"] = (eq?["awareness"] ?? 3).toDouble();
    traits["regulation"] = (eq?["regulation"] ?? 3).toDouble();
    traits["empathy"] = (eq?["empathy"] ?? 3).toDouble();

    /// Attachment
    traits["secure"] = (attachment?["secure"] ?? 3).toDouble();
    traits["anxious"] = (attachment?["anxious"] ?? 3).toDouble();
    traits["avoidant"] = (attachment?["avoidant"] ?? 3).toDouble();

    /// Motivation
    traits["growth"] = (motivation?["growth"] ?? 3).toDouble();
    traits["achievement"] = (motivation?["achievement"] ?? 3).toDouble();
    traits["purpose"] = (motivation?["purpose"] ?? 3).toDouble();

    /// Astrology
    traits["element"] = element == "fire"
        ? 1
        : element == "earth"
        ? 2
        : element == "air"
        ? 3
        : element == "water"
        ? 4
        : 0;

    return PersonalityProfile(traits: traits);
  }
}
