/// Phase D — the habit metrics that answer "is this becoming a daily habit?".
///
/// Per-user, computed deterministically from the persisted day records. These
/// feed the internal product dashboard (retention, sessions, streak, reflection
/// rate); they are not user-facing.
class MirrorHabitMetrics {
  const MirrorHabitMetrics({
    required this.totalOpenedDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.daysActiveLast7,
    required this.daysActiveLast30,
    required this.retained7,
    required this.retained30,
    required this.averageSessionsPerWeek,
    required this.reflectionRate,
  });

  final int totalOpenedDays;
  final int currentStreak;
  final int longestStreak;
  final int daysActiveLast7;
  final int daysActiveLast30;

  /// History is at least 7 days old AND the user opened within the last 7 days.
  final bool retained7;

  /// History is at least 30 days old AND the user opened within the last 30 days.
  final bool retained30;

  final double averageSessionsPerWeek;

  /// reflected days / opened days (0 when none).
  final double reflectionRate;

  static const MirrorHabitMetrics empty = MirrorHabitMetrics(
    totalOpenedDays: 0,
    currentStreak: 0,
    longestStreak: 0,
    daysActiveLast7: 0,
    daysActiveLast30: 0,
    retained7: false,
    retained30: false,
    averageSessionsPerWeek: 0,
    reflectionRate: 0,
  );
}
