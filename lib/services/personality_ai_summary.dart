import 'package:knowme/domain/models/personality_profile.dart';

class PersonalityAISummary {
  static Map<String, String> generate(PersonalityProfile profile) {
    final strength = _strength(profile);
    final weakness = _weakness(profile);
    final workStyle = _workStyle(profile);
    final relationship = _relationship(profile);
    final growth = _growth(profile);

    return {
      "strength": strength,
      "weakness": weakness,
      "work_style": workStyle,
      "relationship_style": relationship,
      "growth_advice": growth,
    };
  }

  static String _strength(PersonalityProfile p) {
    if ((p.traits["openness"] ?? 0) > 4) {
      return "You are highly creative and open to new experiences.";
    }

    if ((p.traits["conscientiousness"] ?? 0) > 4) {
      return "You are disciplined, responsible, and goal-oriented.";
    }

    if ((p.traits["extraversion"] ?? 0) > 4) {
      return "You gain energy from interacting with others.";
    }

    if ((p.traits["agreeableness"] ?? 0) > 4) {
      return "You are compassionate and cooperative with people.";
    }

    return "You have a balanced personality and adapt well to situations.";
  }

  static String _weakness(PersonalityProfile p) {
    if ((p.traits["neuroticism"] ?? 0) > 4) {
      return "You may experience stress or emotional ups and downs.";
    }

    if ((p.traits["conscientiousness"] ?? 0) < 2.5) {
      return "You may sometimes struggle with structure and discipline.";
    }

    if ((p.traits["extraversion"] ?? 0) < 2.5) {
      return "You may prefer solitude and avoid large social environments.";
    }

    return "Your personality shows balanced emotional stability.";
  }

  static String _workStyle(PersonalityProfile p) {
    if ((p.traits["conscientiousness"] ?? 0) > 4 &&
        (p.traits["achievement"] ?? 0) > 4) {
      return "You perform best in structured environments with clear goals.";
    }

    if ((p.traits["openness"] ?? 0) > 4) {
      return "You thrive in creative environments with freedom to explore ideas.";
    }

    if ((p.traits["extraversion"] ?? 0) > 4) {
      return "You enjoy collaborative and social work environments.";
    }

    return "You adapt well to both independent and collaborative work.";
  }

  static String _relationship(PersonalityProfile p) {
    if ((p.traits["secure"] ?? 0) > (p.traits["anxious"] ?? 0) &&
        (p.traits["secure"] ?? 0) > (p.traits["avoidant"] ?? 0)) {
      return "You tend to build stable and secure relationships.";
    }

    if ((p.traits["anxious"] ?? 0) > (p.traits["secure"] ?? 0)) {
      return "You may seek reassurance and emotional closeness in relationships.";
    }

    if ((p.traits["avoidant"] ?? 0) > (p.traits["secure"] ?? 0)) {
      return "You may prefer independence and emotional space.";
    }

    return "You show a balanced relationship style.";
  }

  static String _growth(PersonalityProfile p) {
    if ((p.traits["neuroticism"] ?? 0) > 3.5) {
      return "Developing emotional regulation practices may improve your well-being.";
    }

    if ((p.traits["openness"] ?? 0) < 2.5) {
      return "Trying new experiences may help expand your perspective.";
    }

    if ((p.traits["conscientiousness"] ?? 0) < 3) {
      return "Building structured habits can help you achieve long-term goals.";
    }

    return "Continue exploring personal growth opportunities.";
  }
}
