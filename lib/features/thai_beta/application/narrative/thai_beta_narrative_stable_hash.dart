/// Cross-platform stable hashing for deterministic Thai Beta narrative selection.
library;

abstract final class ThaiBetaNarrativeStableHash {
  /// FNV-1a 32-bit hash — stable across Dart runtimes and platforms.
  static int fnv1a32(String input) {
    const prime = 0x01000193;
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return hash;
  }

  /// Combines [profileSeed] with stable string ids (never [String.hashCode]).
  static int seedOffset(int profileSeed, Iterable<String> parts) {
    var offset = 0;
    for (final part in parts) {
      offset ^= fnv1a32(part);
    }
    return profileSeed + offset;
  }
}
