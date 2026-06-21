import '../domain/zodiac_theme_weight_model.dart';

/// Year Animal → Theme Foundation calibration (Primary / Secondary / Weak).
///
/// Derived from [ZodiacPersonalityLibrary] content — not consumed at runtime yet.
abstract final class ZodiacThemeCalibrationCatalog {
  static const Map<String, ZodiacThemeWeightModel> byAnimal = {
    'rat': ZodiacThemeWeightModel(
      animalKey: 'rat',
      primary: [
        'strategic',
        'adaptable',
        'entrepreneurial',
        'analytical',
      ],
      secondary: [
        'curious',
        'adaptability',
        'independent',
        'innovator',
        'overthinking',
        'relationship_oriented',
      ],
      weak: [
        'builder',
        'persistence',
        'stable',
      ],
    ),
    'ox': ZodiacThemeWeightModel(
      animalKey: 'ox',
      primary: [
        'disciplined',
        'grounded',
        'builder',
        'reliability',
        'persistence',
      ],
      secondary: [
        'practical',
        'stable',
        'loyal',
        'systematic',
      ],
      weak: [
        'explorer',
        'fast_moving',
        'entrepreneurial',
        'embrace_change',
      ],
    ),
    'tiger': ZodiacThemeWeightModel(
      animalKey: 'tiger',
      primary: [
        'ambitious',
        'protective',
        'independent',
        'leader',
        'leadership',
      ],
      secondary: [
        'expressive',
        'persistence',
        'protective_of_others',
        'fast_moving',
        'impulsiveness',
      ],
      weak: [
        'diplomatic',
        'reflective',
        'avoidance',
      ],
    ),
    'rabbit': ZodiacThemeWeightModel(
      animalKey: 'rabbit',
      primary: [
        'empathetic',
        'sensitive',
        'diplomatic',
        'supportive',
      ],
      secondary: [
        'reserved',
        'relationship_oriented',
        'detail_oriented',
        'empathy',
        'avoidance',
        'people_pleasing',
      ],
      weak: [
        'leader',
        'fast_moving',
        'entrepreneurial',
      ],
    ),
    'dragon': ZodiacThemeWeightModel(
      animalKey: 'dragon',
      primary: [
        'visionary',
        'ambitious',
        'big_picture',
        'leader',
      ],
      secondary: [
        'creative',
        'entrepreneurial',
        'communication',
        'leadership',
        'impulsiveness',
        'self_criticism',
        'supportive',
      ],
      weak: [
        'detail_oriented',
        'systematic',
        'specialist',
      ],
    ),
    'snake': ZodiacThemeWeightModel(
      animalKey: 'snake',
      primary: [
        'reflective',
        'strategic',
        'systematic',
        'specialist',
      ],
      secondary: [
        'reserved',
        'calm_under_pressure',
        'persistence',
        'analytical',
        'overthinking',
        'control',
        'loyal',
      ],
      weak: [
        'fast_moving',
        'expressive',
        'explorer',
      ],
    ),
    'horse': ZodiacThemeWeightModel(
      animalKey: 'horse',
      primary: [
        'explorer',
        'fast_moving',
        'adaptable',
        'communication',
      ],
      secondary: [
        'ambitious',
        'independent',
        'adaptability',
        'innovator',
        'impulsiveness',
        'independent_in_relationships',
      ],
      weak: [
        'systematic',
        'disciplined',
        'persistence',
      ],
    ),
    'goat': ZodiacThemeWeightModel(
      animalKey: 'goat',
      primary: [
        'empathetic',
        'creative',
        'relationship_oriented',
        'supportive',
      ],
      secondary: [
        'sensitive',
        'diplomatic',
        'teacher',
        'empathy',
        'people_pleasing',
      ],
      weak: [
        'leader',
        'entrepreneurial',
        'fast_moving',
      ],
    ),
    'monkey': ZodiacThemeWeightModel(
      animalKey: 'monkey',
      primary: [
        'curious',
        'creative',
        'innovator',
        'adaptability',
      ],
      secondary: [
        'adaptable',
        'entrepreneurial',
        'communication',
        'creativity',
        'impulsiveness',
        'overthinking',
        'supportive',
      ],
      weak: [
        'disciplined',
        'systematic',
        'persistence',
      ],
    ),
    'rooster': ZodiacThemeWeightModel(
      animalKey: 'rooster',
      primary: [
        'detail_oriented',
        'systematic',
        'disciplined',
        'practical',
      ],
      secondary: [
        'reliability',
        'builder',
        'leader',
        'perfectionism',
        'self_criticism',
        'loyal',
      ],
      weak: [
        'adaptable',
        'explorer',
        'impulsiveness',
      ],
    ),
    'dog': ZodiacThemeWeightModel(
      animalKey: 'dog',
      primary: [
        'loyal',
        'grounded',
        'protective',
        'reliability',
      ],
      secondary: [
        'supportive',
        'protective_of_others',
        'builder',
        'persistence',
        'overthinking',
      ],
      weak: [
        'explorer',
        'entrepreneurial',
        'diplomatic',
      ],
    ),
    'pig': ZodiacThemeWeightModel(
      animalKey: 'pig',
      primary: [
        'supportive',
        'relationship_oriented',
        'empathetic',
        'reliability',
      ],
      secondary: [
        'sensitive',
        'loyal',
        'teacher',
        'empathy',
        'avoidance',
      ],
      weak: [
        'leader',
        'fast_moving',
        'entrepreneurial',
        'people_pleasing',
      ],
    ),
  };
}
