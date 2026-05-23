// Composes planet×sign core meaning with a lightweight house tail.
import 'astrology_planet_interpretation_polish.dart';
import 'astrology_planet_rhythm.dart';



abstract final class AstrologyPlanetInterpretationEngine {

  static const big7Planets = {

    'sun',

    'moon',

    'mercury',

    'venus',

    'mars',

    'jupiter',

    'saturn',

  };



  static bool isBig7(String planetKey) =>

      big7Planets.contains(planetKey.toLowerCase());



  static String? normalizeSign(String? raw) {

    if (raw == null || raw.trim().isEmpty) return null;

    final s = raw.trim();

    final key = s[0].toUpperCase() + s.substring(1).toLowerCase();

    return _validSigns.contains(key) ? key : null;

  }



  static int? parseHouse(dynamic raw) {

    if (raw is int) return raw >= 1 && raw <= 12 ? raw : null;

    if (raw is num) {

      final n = raw.toInt();

      return n >= 1 && n <= 12 ? n : null;

    }

    if (raw is String) {

      final n = int.tryParse(raw.trim());

      if (n != null && n >= 1 && n <= 12) return n;

    }

    return null;

  }



  /// One flowing paragraph: polished core + optional house tail.

  static String compose({

    required String core,

    required String houseTail,

    required String lang,

    required String planet,

    required String sign,

    int? house,

  }) {

    var lead = streamlineCore(core);

    lead = AstrologyPlanetInterpretationPolish.polishCore(

      lead,

      lang,

      planet: planet,

      sign: sign,

      house: house,

      applyOpenerVariation: false,

    );

    final merged = AstrologyPlanetRhythm.finish(

      polishedCore: lead,

      houseTail: houseTail.trim(),

      lang: lang,

      planet: planet,

      sign: sign,

      house: house,

    );

    return AstrologyPlanetInterpretationPolish.clampLength(merged, lang);

  }

  /// Drops em-dash keyword tails; keeps the main idea for mobile readability.

  static String streamlineCore(String core) {

    var s = core.trim();

    final dash = s.indexOf('—');

    if (dash > 0) {

      s = s.substring(0, dash).trim();

    }

    return s.replaceAll(RegExp(r'\s+'), ' ');

  }



  static const _validSigns = {

    'Aries',

    'Taurus',

    'Gemini',

    'Cancer',

    'Leo',

    'Virgo',

    'Libra',

    'Scorpio',

    'Sagittarius',

    'Capricorn',

    'Aquarius',

    'Pisces',

  };

}


