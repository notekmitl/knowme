/// Birth-time → selection confidence mapping for Thai Beta Narrative V1.1.1.
library;

/// Single source of truth for curated-block confidence thresholds.
abstract final class ThaiBetaNarrativeConfidence {
  /// Full confidence when birth time is present.
  static const double withBirthTime = 1.0;

  /// Reduced confidence when birth time is missing — never select
  /// high-specificity / unsafe-without-time blocks.
  static const double withoutBirthTime = 0.5;

  /// Derive query confidence from birth-time availability.
  static double forBirthTime(bool hasBirthTime) =>
      hasBirthTime ? withBirthTime : withoutBirthTime;

  /// Effective minimum confidence required by a block given its birth-time flags.
  ///
  /// Blocks that are not safe without birth time (or that require birth time)
  /// must clear [withBirthTime]. Safe-without-time blocks keep their declared
  /// [declaredMinimum] (typically ≤ [withoutBirthTime]).
  static double effectiveMinimum({
    required double declaredMinimum,
    required bool requiresBirthTime,
    required bool safeWithoutBirthTime,
  }) {
    if (requiresBirthTime || !safeWithoutBirthTime) {
      final floor = withBirthTime;
      return declaredMinimum > floor ? declaredMinimum : floor;
    }
    return declaredMinimum;
  }
}
