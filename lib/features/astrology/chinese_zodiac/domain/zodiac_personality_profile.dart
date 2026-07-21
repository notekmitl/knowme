/// Resolved personality lens for a Chinese Year Animal (interpretation only).
class ZodiacPersonalityProfile {
  const ZodiacPersonalityProfile({
    required this.animalKey,
    required this.coreTraits,
    required this.workStyle,
    required this.relationshipStyle,
    required this.strengths,
    required this.challenges,
    required this.growthSuggestions,
  });

  final String animalKey;
  final String coreTraits;
  final String workStyle;
  final String relationshipStyle;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> growthSuggestions;
}
