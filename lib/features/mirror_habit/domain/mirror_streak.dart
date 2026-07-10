/// Phase D — the Mirror Streak: consecutive days the user has opened today's read.
class MirrorStreak {
  const MirrorStreak({
    required this.current,
    required this.longest,
    required this.activeToday,
    this.lastOpened,
  });

  /// Days in the current run (counting back from today, or yesterday as grace).
  final int current;

  /// Longest run ever recorded.
  final int longest;

  /// Whether today has been opened.
  final bool activeToday;

  /// The most recent day opened, if any.
  final DateTime? lastOpened;

  static const MirrorStreak empty =
      MirrorStreak(current: 0, longest: 0, activeToday: false);
}
