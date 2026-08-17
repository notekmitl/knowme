/// Cross-platform stable hashing for deterministic Thai Beta narrative selection.
library;

abstract final class ThaiBetaNarrativeStableHash {
  static final _mask32 = BigInt.from(0xFFFFFFFF);

  /// FNV-1a 32-bit hash — stable across Dart runtimes and platforms.
  static int fnv1a32(String input) {
    const prime = 0x01000193;
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash = _xor32(hash, unit);
      hash = _multiply32(hash, prime);
    }
    return hash;
  }

  /// Combines [profileSeed] with stable string ids (never [String.hashCode]).
  static int seedOffset(int profileSeed, Iterable<String> parts) {
    var offset = 0;
    for (final part in parts) {
      offset = _xor32(offset, fnv1a32(part));
    }
    return profileSeed + offset;
  }

  /// Exact XOR for the report-hash fallback seed when products exceed 32 bits.
  static int exactXor(int left, int right) {
    final mixed = BigInt.from(left) ^ BigInt.from(right);
    if (mixed.abs().bitLength > 53) {
      throw StateError('Narrative seed exceeds the 53-bit selection range');
    }
    return mixed.toInt();
  }

  static int _xor32(int left, int right) =>
      ((BigInt.from(left) ^ BigInt.from(right)) & _mask32).toInt();

  /// Exact low-32-bit product; dart2js must not round the FNV multiplication.
  static int _multiply32(int left, int right) =>
      ((BigInt.from(left) * BigInt.from(right)) & _mask32).toInt();
}
