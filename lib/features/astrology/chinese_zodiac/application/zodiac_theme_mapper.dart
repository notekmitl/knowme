import '../domain/zodiac_fusion_theme_bundle.dart';

/// Year Animal → Fusion Theme Registry ids (preparation layer — not consumed at runtime yet).
abstract final class ZodiacThemeMapper {
  static const Map<String, ZodiacFusionThemeBundle> animalThemes = {
    'rat': ZodiacFusionThemeBundle(
      coreSelf: ['adaptable', 'analytical'],
      relationships: ['diplomatic', 'supportive'],
      workAndAmbition: ['growth_focused', 'flexible'],
      strengths: ['creative', 'reliable'],
      growthAreas: ['overthinking', 'impatience'],
    ),
    'ox': ZodiacFusionThemeBundle(
      coreSelf: ['grounded', 'reserved'],
      relationships: ['loyal', 'supportive'],
      workAndAmbition: ['responsible', 'persistent'],
      strengths: ['reliable', 'persistent'],
      growthAreas: ['rigidity', 'overthinking'],
    ),
    'tiger': ZodiacFusionThemeBundle(
      coreSelf: ['independent', 'expressive'],
      relationships: ['loyal', 'independent_connection'],
      workAndAmbition: ['driven', 'leadership'],
      strengths: ['persistent', 'creative'],
      growthAreas: ['impatience', 'rigidity'],
    ),
    'rabbit': ZodiacFusionThemeBundle(
      coreSelf: ['reserved', 'responsive'],
      relationships: ['supportive', 'diplomatic'],
      workAndAmbition: ['responsible', 'growth_focused'],
      strengths: ['reliable', 'creative'],
      growthAreas: ['overthinking', 'rigidity'],
    ),
    'dragon': ZodiacFusionThemeBundle(
      coreSelf: ['expressive', 'independent'],
      relationships: ['supportive', 'loyal'],
      workAndAmbition: ['leadership', 'driven'],
      strengths: ['creative', 'persistent'],
      growthAreas: ['impatience', 'rigidity'],
    ),
    'snake': ZodiacFusionThemeBundle(
      coreSelf: ['reserved', 'intuitive'],
      relationships: ['loyal', 'independent_connection'],
      workAndAmbition: ['growth_focused', 'structured'],
      strengths: ['persistent', 'analytical'],
      growthAreas: ['overthinking', 'rigidity'],
    ),
    'horse': ZodiacFusionThemeBundle(
      coreSelf: ['independent', 'expressive'],
      relationships: ['independent_connection', 'supportive'],
      workAndAmbition: ['driven', 'growth_focused'],
      strengths: ['creative', 'reliable'],
      growthAreas: ['impatience', 'rigidity'],
    ),
    'goat': ZodiacFusionThemeBundle(
      coreSelf: ['expressive', 'responsive'],
      relationships: ['supportive', 'diplomatic'],
      workAndAmbition: ['growth_focused', 'responsible'],
      strengths: ['creative', 'reliable'],
      growthAreas: ['overthinking', 'rigidity'],
    ),
    'monkey': ZodiacFusionThemeBundle(
      coreSelf: ['adaptable', 'expressive'],
      relationships: ['supportive', 'independent_connection'],
      workAndAmbition: ['growth_focused', 'flexible'],
      strengths: ['creative', 'reliable'],
      growthAreas: ['impatience', 'overthinking'],
    ),
    'rooster': ZodiacFusionThemeBundle(
      coreSelf: ['structured', 'reserved'],
      relationships: ['loyal', 'diplomatic'],
      workAndAmbition: ['responsible', 'driven'],
      strengths: ['reliable', 'persistent'],
      growthAreas: ['rigidity', 'impatience'],
    ),
    'dog': ZodiacFusionThemeBundle(
      coreSelf: ['grounded', 'loyal'],
      relationships: ['loyal', 'supportive'],
      workAndAmbition: ['responsible', 'reliable'],
      strengths: ['reliable', 'persistent'],
      growthAreas: ['overthinking', 'rigidity'],
    ),
    'pig': ZodiacFusionThemeBundle(
      coreSelf: ['expressive', 'supportive'],
      relationships: ['supportive', 'loyal'],
      workAndAmbition: ['responsible', 'growth_focused'],
      strengths: ['reliable', 'creative'],
      growthAreas: ['overthinking', 'rigidity'],
    ),
  };

  static ZodiacFusionThemeBundle? themesForAnimal(String animalKey) {
    return animalThemes[animalKey.trim().toLowerCase()];
  }

  static List<String> allThemeIdsForAnimal(String animalKey) {
    final bundle = themesForAnimal(animalKey);
    if (bundle == null) return const [];

    return List<String>.unmodifiable([
      ...bundle.coreSelf,
      ...bundle.relationships,
      ...bundle.workAndAmbition,
      ...bundle.strengths,
      ...bundle.growthAreas,
    ]);
  }
}
