/// V1.2.1 — presentation-only selector for Life Timeline cards/segments.
///
/// Picks previous / current / next (max 3) without mutating the source list.
/// Does not change engine periods, Canon, or calculation rules.
abstract final class RelevantLifePeriodsSelector {
  /// Resolves the current index in [periods].
  ///
  /// Prefer the item marked [isCurrent]. When none is marked, use a
  /// deterministic fallback aligned with [LifePeriodEngine] bias:
  /// - first non-past period when any exist
  /// - otherwise the last period (age past the final window)
  /// - empty list → `-1`
  static int resolveCurrentIndex<T>({
    required List<T> periods,
    required bool Function(T item) isCurrent,
    required bool Function(T item) isPast,
  }) {
    if (periods.isEmpty) return -1;
    final marked = periods.indexWhere(isCurrent);
    if (marked >= 0) return marked;

    final firstNonPast = periods.indexWhere((p) => !isPast(p));
    if (firstNonPast >= 0) return firstNonPast;
    return periods.length - 1;
  }

  /// Returns a **new** list: previous (optional) → current → next (optional).
  /// Source [periods] is never mutated.
  static List<T> select<T>({
    required List<T> periods,
    required bool Function(T item) isCurrent,
    required bool Function(T item) isPast,
  }) {
    if (periods.isEmpty) return <T>[];

    final currentIndex = resolveCurrentIndex(
      periods: periods,
      isCurrent: isCurrent,
      isPast: isPast,
    );
    if (currentIndex < 0) return <T>[];

    final out = <T>[];
    if (currentIndex > 0) {
      out.add(periods[currentIndex - 1]);
    }
    out.add(periods[currentIndex]);
    if (currentIndex + 1 < periods.length) {
      out.add(periods[currentIndex + 1]);
    }
    return out;
  }

  /// Same selection as [select], but returns stable source indices.
  static List<int> selectIndices<T>({
    required List<T> periods,
    required bool Function(T item) isCurrent,
    required bool Function(T item) isPast,
  }) {
    if (periods.isEmpty) return const <int>[];

    final currentIndex = resolveCurrentIndex(
      periods: periods,
      isCurrent: isCurrent,
      isPast: isPast,
    );
    if (currentIndex < 0) return const <int>[];

    final out = <int>[];
    if (currentIndex > 0) out.add(currentIndex - 1);
    out.add(currentIndex);
    if (currentIndex + 1 < periods.length) out.add(currentIndex + 1);
    return out;
  }
}
