import '../constants/thai_lagna_rulership.dart';

/// Lookup-only lagna lord resolver (Traditional Thai rulership).
abstract final class LagnaLordEngine {
  static String? resolve(String? lagnaKey) {
    return ThaiLagnaRulership.lordForLagna(lagnaKey);
  }
}
