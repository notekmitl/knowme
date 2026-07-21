import '../../content/models/thai_content_key.dart';

/// Traditional Thai lagna lord rulership (frozen V1).
///
/// Saturn rules Aquarius + Capricorn; Jupiter rules Sagittarius + Pisces.
abstract final class ThaiLagnaRulership {
  static const Map<String, String> lagnaToLord = {
    ThaiContentKeys.lagnaAries: ThaiContentKeys.lagnaLordMars,
    ThaiContentKeys.lagnaTaurus: ThaiContentKeys.lagnaLordVenus,
    ThaiContentKeys.lagnaGemini: ThaiContentKeys.lagnaLordMercury,
    ThaiContentKeys.lagnaCancer: ThaiContentKeys.lagnaLordMoon,
    ThaiContentKeys.lagnaLeo: ThaiContentKeys.lagnaLordSun,
    ThaiContentKeys.lagnaVirgo: ThaiContentKeys.lagnaLordMercury,
    ThaiContentKeys.lagnaLibra: ThaiContentKeys.lagnaLordVenus,
    ThaiContentKeys.lagnaScorpio: ThaiContentKeys.lagnaLordMars,
    ThaiContentKeys.lagnaSagittarius: ThaiContentKeys.lagnaLordJupiter,
    ThaiContentKeys.lagnaCapricorn: ThaiContentKeys.lagnaLordSaturn,
    ThaiContentKeys.lagnaAquarius: ThaiContentKeys.lagnaLordSaturn,
    ThaiContentKeys.lagnaPisces: ThaiContentKeys.lagnaLordJupiter,
  };

  static String? lordForLagna(String? lagnaKey) {
    if (lagnaKey == null) return null;
    return lagnaToLord[lagnaKey];
  }
}
