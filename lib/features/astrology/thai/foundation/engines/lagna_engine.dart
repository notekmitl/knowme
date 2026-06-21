import '../../content/models/thai_content_key.dart';
import '../astronomy/sidereal_ascendant.dart';
import '../models/thai_birth_data.dart';

/// Sidereal lagna calculation — Lahiri ayanamsa, Whole Sign houses.
abstract final class LagnaEngine {
  static const _signIndexToKey = <String>[
    ThaiContentKeys.lagnaAries,
    ThaiContentKeys.lagnaTaurus,
    ThaiContentKeys.lagnaGemini,
    ThaiContentKeys.lagnaCancer,
    ThaiContentKeys.lagnaLeo,
    ThaiContentKeys.lagnaVirgo,
    ThaiContentKeys.lagnaLibra,
    ThaiContentKeys.lagnaScorpio,
    ThaiContentKeys.lagnaSagittarius,
    ThaiContentKeys.lagnaCapricorn,
    ThaiContentKeys.lagnaAquarius,
    ThaiContentKeys.lagnaPisces,
  ];

  static LagnaResult? calculate(ThaiBirthData birthData) {
    if (!birthData.hasBirthTime) return null;

    final siderealAsc = SiderealAscendant.siderealAscendantDegrees(
      utc: birthData.utcDateTime,
      latitude: birthData.latitude,
      longitudeEast: birthData.longitude,
    );
    final signIndex = SiderealAscendant.wholeSignIndex(siderealAsc);

    return LagnaResult(
      lagnaKey: _signIndexToKey[signIndex],
      siderealAscendantDeg: siderealAsc,
      signIndex: signIndex,
    );
  }
}

class LagnaResult {
  const LagnaResult({
    required this.lagnaKey,
    required this.siderealAscendantDeg,
    required this.signIndex,
  });

  final String lagnaKey;
  final double siderealAscendantDeg;
  final int signIndex;
}
