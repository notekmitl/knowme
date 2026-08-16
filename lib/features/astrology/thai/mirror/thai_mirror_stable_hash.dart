/// Cross-runtime deterministic hashing for Thai mirror content selection.
///
/// This reproduces the Dart VM 3.11 `String.hashCode` algorithm used when the
/// V1.5 acceptance fixtures were frozen. Dart does not promise `hashCode`
/// values across runtimes, so content selection must not call it directly.
abstract final class ThaiMirrorStableHash {
  static const _mask32 = 0xFFFFFFFF;
  static const _mask30 = 0x3FFFFFFF;

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
