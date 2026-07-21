import '../domain/life_trend.dart';
import '../domain/mirror_comparison.dart';
import '../domain/mirror_day_record.dart';
import '../domain/mirror_period_reflection.dart';
import '../domain/mirror_streak.dart';
import 'mirror_habit_engine.dart';

/// Phase D — everything the Daily Mirror needs to show the habit loop, derived
/// in one deterministic pass from the user's day records.
class MirrorHabitSnapshot {
  const MirrorHabitSnapshot({
    required this.streak,
    required this.comparison,
    required this.weekly,
    required this.monthly,
    required this.trend,
  });

  final MirrorStreak streak;
  final MirrorComparison comparison;
  final MirrorPeriodReflection weekly;
  final MirrorPeriodReflection monthly;
  final LifeTrend trend;

  factory MirrorHabitSnapshot.from(
    List<MirrorDayRecord> records,
    DateTime today,
  ) =>
      MirrorHabitSnapshot(
        streak: MirrorHabitEngine.streak(records, today),
        comparison: MirrorHabitEngine.compare(records, today),
        weekly: MirrorHabitEngine.period(records, today, 7),
        monthly: MirrorHabitEngine.period(records, today, 30),
        trend: MirrorHabitEngine.trend(records, today),
      );
}
