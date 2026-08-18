/// Canonical fixed-point representation for audit degrees at persistence,
/// hashing, seed, and research-equivalence boundaries.
///
/// Engine and product decisions continue to use their raw [double] values.
/// One canonical unit is 1e-9 degree, which is substantially finer than the
/// displayed/product precision while keeping a full turn JavaScript-safe.
abstract final class ThaiBetaCanonicalDegree {
  static const int unitsPerDegree = 1000000000;
  static const int unitsPerTurn = 360 * unitsPerDegree;
  static const int maxJavaScriptSafeInteger = 9007199254740991;
  static const bool isJavaScriptSafe = unitsPerTurn < maxJavaScriptSafeInteger;

  /// Normalizes a finite degree value to [0, 360), rounds half away from zero
  /// after scaling, and returns an integer in [0, unitsPerTurn).
  static int? fromDegrees(double? degrees) {
    if (degrees == null) return null;
    if (!degrees.isFinite) {
      throw ArgumentError.value(degrees, 'degrees', 'must be finite');
    }

    var normalized = degrees % 360.0;
    if (normalized < 0) normalized += 360.0;
    if (normalized == 0) normalized = 0;

    final units = (normalized * unitsPerDegree).round();
    return units == unitsPerTurn ? 0 : units;
  }

  /// Accepts both new fixed-point snapshot integers and legacy raw-degree
  /// doubles/decimal strings. This keeps hash/research readers compatible
  /// with snapshots written before the fixed-point contract.
  static int? fromSnapshotValue(Object? value) {
    if (value == null) return null;
    if (value is int) {
      if (value < 0 || value >= unitsPerTurn) {
        throw ArgumentError.value(
          value,
          'value',
          'canonical units must be within one turn',
        );
      }
      return value;
    }
    if (value is double) return fromDegrees(value);
    if (value is num) return fromDegrees(value.toDouble());
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        throw ArgumentError.value(value, 'value', 'must not be empty');
      }
      if (trimmed.contains(RegExp(r'[.eE]'))) {
        return fromDegrees(double.parse(trimmed));
      }
      return fromSnapshotValue(int.parse(trimmed));
    }
    throw ArgumentError.value(value, 'value', 'unsupported degree value');
  }

  static String fixedDecimal(int units) {
    final checked = fromSnapshotValue(units)!;
    final degrees = checked ~/ unitsPerDegree;
    final fraction = (checked % unitsPerDegree).toString().padLeft(9, '0');
    return '$degrees.$fraction';
  }
}
