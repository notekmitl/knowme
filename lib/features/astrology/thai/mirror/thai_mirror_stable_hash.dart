/// Cross-runtime deterministic hashing for Thai mirror content selection.
///
/// KnowMe Stable Hash v1 uses a UTF-16 Jenkins one-at-a-time mix, masks every
/// step to 32 bits, returns the low 30 bits, and maps zero to one. The contract
/// is owned here rather than delegated to Dart's runtime-dependent `hashCode`.
/// It preserves the already accepted V1.5 selection identities.
abstract final class ThaiMirrorStableHash {
  static const _mask32 = 0xFFFFFFFF;
  static const _mask30 = 0x3FFFFFFF;
  static const _signBit32 = 0x80000000;
  static const _uint32Range = 0x100000000;

  static int string(String value) {
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = (hash + codeUnit) & _mask32;
      hash = (hash + (hash << 10)) & _mask32;
      hash = (hash ^ (hash >>> 6)) & _mask32;
    }
    hash = (hash + (hash << 3)) & _mask32;
    hash = (hash ^ (hash >>> 11)) & _mask32;
    hash = (hash + (hash << 15)) & _mask32;
    hash &= _mask30;
    return hash == 0 ? 1 : hash;
  }

  static int strings(Iterable<String> values) {
    var hash = 0;
    for (final value in values) {
      hash = _combine(hash, string(value));
    }
    return _finalize(hash);
  }

  static int unsigned32(int value) => value & _mask32;

  static int signed32(int value) {
    final normalized = unsigned32(value);
    return normalized >= _signBit32
        ? normalized - _uint32Range
        : normalized;
  }

  /// Multiplies with an explicit 32-bit wrap without exceeding JS-safe range.
  static int multiply32(int left, int right) {
    final a = unsigned32(left);
    final b = unsigned32(right);
    final low = (a & 0xFFFF) * (b & 0xFFFF);
    final cross = ((a >>> 16) * (b & 0xFFFF)) +
        ((a & 0xFFFF) * (b >>> 16));
    return unsigned32(low + (cross << 16));
  }

  static int xor32(int left, int right) =>
      unsigned32(left) ^ unsigned32(right);

  /// Exact integer XOR for reader-visible seeds that intentionally exceed
  /// 32 bits. BigInt prevents dart2js from applying JavaScript's signed
  /// 32-bit bitwise coercion.
  static int exactXor(int left, int right) {
    final mixed = BigInt.from(left) ^ BigInt.from(right);
    if (mixed.abs().bitLength > 53) {
      throw StateError('Mirror seed exceeds the 53-bit selection range');
    }
    return mixed.toInt();
  }

  static int exactXorAll(Iterable<int> values) {
    var result = 0;
    for (final value in values) {
      result = exactXor(result, value);
    }
    return result;
  }

  /// Exact `(left ^ (value * multiplier)).abs() % modulus` used by nuance
  /// selection. The product is never rounded through a JavaScript Number.
  static int exactXorProductModulo({
    required int left,
    required int value,
    required int multiplier,
    required int modulus,
  }) {
    if (modulus <= 0) throw ArgumentError.value(modulus, 'modulus');
    final mixed = BigInt.from(left) ^
        (BigInt.from(value) * BigInt.from(multiplier));
    return (mixed.abs() % BigInt.from(modulus)).toInt();
  }

  static int _combine(int hash, int other) {
    var result = (hash + other) & _mask32;
    result = (result + (result << 10)) & _mask32;
    return (result ^ (result >>> 6)) & _mask32;
  }

  static int _finalize(int hash) {
    var result = (hash + (hash << 3)) & _mask32;
    result = (result ^ (result >>> 11)) & _mask32;
    result = (result + (result << 15)) & _mask32;
    result &= _mask30;
    return result == 0 ? 1 : result;
  }
}
