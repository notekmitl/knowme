import 'zodiac_theme_weight_tier.dart';

/// Primary / Secondary / Weak theme ids for one Year Animal (Theme Foundation ids).
class ZodiacThemeWeightModel {
  const ZodiacThemeWeightModel({
    required this.animalKey,
    required this.primary,
    required this.secondary,
    required this.weak,
  });

  final String animalKey;
  final List<String> primary;
  final List<String> secondary;
  final List<String> weak;

  List<String> themesForTier(ZodiacThemeWeightTier tier) {
    return switch (tier) {
      ZodiacThemeWeightTier.primary => primary,
      ZodiacThemeWeightTier.secondary => secondary,
      ZodiacThemeWeightTier.weak => weak,
    };
  }

  List<String> allThemes({bool includeWeak = true}) {
    return List<String>.unmodifiable([
      ...primary,
      ...secondary,
      if (includeWeak) ...weak,
    ]);
  }
}
