import 'astrology_house_modifiers.dart';
import 'astrology_planet_interpretation_engine.dart';
import 'astrology_planet_sign_core.dart';
import 'astrology_semantic_dedupe.dart';

/// Local Big 7 planet interpretations: planet×sign core + house modifier.
abstract final class AstrologyPlanetInterpretation {
  static const _displayOrder = [
    'sun',
    'moon',
    'mercury',
    'venus',
    'mars',
    'jupiter',
    'saturn',
  ];

  /// Big7 copy with cross-card semantic dedupe (display order).
  static Map<String, String> composedForChart(
    Map<String, dynamic> planets,
    String lang,
  ) {
    final draft = <String, String>{};
    for (final planet in _displayOrder) {
      final data = planets[planet];
      if (data is! Map) continue;
      final text = composed(
        planetKey: planet,
        signRaw: data['sign']?.toString(),
        houseRaw: data['house'],
        lang: lang,
      );
      if (text != null && text.isNotEmpty) draft[planet] = text;
    }
    return AstrologySemanticDedupe.dedupePlanetCards(draft, lang);
  }

  static String? composed({
    required String planetKey,
    required String? signRaw,
    required dynamic houseRaw,
    required String lang,
  }) {
    if (!AstrologyPlanetInterpretationEngine.isBig7(planetKey)) {
      return null;
    }

    final planet = planetKey.toLowerCase();
    final sign = AstrologyPlanetInterpretationEngine.normalizeSign(signRaw);
    if (sign == null) return null;

    final core = AstrologyPlanetSignCore.core(planet, sign, lang);
    if (core == null || core.isEmpty) return null;

    final house = AstrologyPlanetInterpretationEngine.parseHouse(houseRaw);
    final tail = house == null
        ? ''
        : (AstrologyHouseModifiers.forHouse(
              house,
              lang,
              planet: planet,
              sign: sign,
            ) ??
            '');

    final merged = AstrologyPlanetInterpretationEngine.compose(
      core: core,
      houseTail: tail,
      lang: lang,
      planet: planet,
      sign: sign,
      house: house,
    );

    return AstrologySemanticDedupe.surfaceCleanup(merged, lang);
  }
}
