/// Phase D — the direction a reading moved between two days.
enum MirrorShift {
  /// Lighter / more momentum than before.
  brightened,

  /// Softer / asking for more care than before.
  softened,

  /// Held the same.
  steady,

  /// Not enough history to compare.
  unknown,
}

/// Phase D — Yesterday vs Today: how the focus and clarity moved.
class MirrorComparison {
  const MirrorComparison({
    required this.hasYesterday,
    required this.focusShift,
    required this.clarityShift,
    required this.clarityDelta,
    this.focusKeyYesterday,
    this.focusKeyToday,
  });

  final bool hasYesterday;
  final MirrorShift focusShift;
  final MirrorShift clarityShift;
  final int clarityDelta;
  final String? focusKeyYesterday;
  final String? focusKeyToday;

  static const MirrorComparison none = MirrorComparison(
    hasYesterday: false,
    focusShift: MirrorShift.unknown,
    clarityShift: MirrorShift.unknown,
    clarityDelta: 0,
  );
}
