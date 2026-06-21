import '../content/models/thai_content_type.dart';

/// Default source multipliers for Thai Theme Resolver V1.
///
/// Tune here without changing aggregation logic.
abstract final class ThaiThemeSourceWeights {
  static const double lagna = 1.00;
  static const double lagnaLord = 0.80;
  static const double ramahabhuta = 0.60;
  static const double mahabhutaPosition = 0.65;
  static const double myanmarSeven = 0.50;

  static double forType(ThaiContentType type) {
    return switch (type) {
      ThaiContentType.lagna => lagna,
      ThaiContentType.lagnaLord => lagnaLord,
      ThaiContentType.ramahabhuta => ramahabhuta,
      ThaiContentType.mahabhutaPosition => mahabhutaPosition,
      ThaiContentType.myanmarSeven => myanmarSeven,
    };
  }
}
