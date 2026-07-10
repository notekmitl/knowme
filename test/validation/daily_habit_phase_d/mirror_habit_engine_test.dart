import 'package:flutter_test/flutter_test.dart';

import 'package:knowme/features/mirror_experience/mirror_view_models.dart';
import 'package:knowme/features/mirror_habit/application/mirror_habit_engine.dart';
import 'package:knowme/features/mirror_habit/application/mirror_habit_snapshot.dart';
import 'package:knowme/features/mirror_habit/domain/life_trend.dart';
import 'package:knowme/features/mirror_habit/domain/mirror_comparison.dart';
import 'package:knowme/features/mirror_habit/domain/mirror_day_record.dart';

/// Phase D — the habit math is pure and deterministic: streak, Yesterday-vs-
/// Today, weekly/monthly reflection, life trend and retention metrics.
void main() {
  final today = DateTime(2026, 6, 28);

  MirrorDayRecord rec(
    int offset, {
    bool opened = true,
    bool reflected = false,
    bool action = false,
    MirrorTone focus = MirrorTone.steady,
    int clarity = 50,
    String? focusKey,
  }) =>
      MirrorDayRecord(
        date: today.subtract(Duration(days: offset)),
        opened: opened,
        reflected: reflected,
        actionTaken: action,
        focusTone: focus,
        clarity: clarity,
        focusKey: focusKey,
      );

  group('streak', () {
    test('counts consecutive days ending today', () {
      final records = [rec(0), rec(1), rec(2), rec(4)];
      final s = MirrorHabitEngine.streak(records, today);
      expect(s.current, 3);
      expect(s.longest, 3);
      expect(s.activeToday, isTrue);
    });

    test('grace day: yesterday opened, today not yet', () {
      final records = [rec(1), rec(2)];
      final s = MirrorHabitEngine.streak(records, today);
      expect(s.current, 2);
      expect(s.activeToday, isFalse);
    });

    test('broken streak resets to zero', () {
      final records = [rec(3), rec(4)];
      final s = MirrorHabitEngine.streak(records, today);
      expect(s.current, 0);
      expect(s.longest, 2);
    });

    test('empty history', () {
      expect(MirrorHabitEngine.streak(const [], today).current, 0);
    });
  });

  group('comparison (yesterday vs today)', () {
    test('focus brightening is detected', () {
      final records = [
        rec(0, focus: MirrorTone.strong, clarity: 70),
        rec(1, focus: MirrorTone.steady, clarity: 60),
      ];
      final c = MirrorHabitEngine.compare(records, today);
      expect(c.hasYesterday, isTrue);
      expect(c.focusShift, MirrorShift.brightened);
      expect(c.clarityDelta, 10);
    });

    test('no yesterday → none', () {
      final c = MirrorHabitEngine.compare([rec(0)], today);
      expect(c.hasYesterday, isFalse);
    });
  });

  group('period reflection', () {
    test('weekly counts opens, reflections and dominant tone', () {
      final records = [
        rec(0, reflected: true, focus: MirrorTone.strong, focusKey: 'career'),
        rec(1, focus: MirrorTone.strong, focusKey: 'career'),
        rec(2, focus: MirrorTone.tender, focusKey: 'health'),
        rec(10), // outside the 7-day window
      ];
      final w = MirrorHabitEngine.period(records, today, 7);
      expect(w.daysOpened, 3);
      expect(w.reflections, 1);
      expect(w.dominantTone, MirrorTone.strong);
      expect(w.mostFocusedAreaKey, 'career');
      expect(w.reflectionRate, closeTo(1 / 3, 1e-9));
    });
  });

  group('life trend', () {
    test('rising when later days carry more momentum', () {
      final records = [
        rec(0, focus: MirrorTone.strong),
        rec(1, focus: MirrorTone.strong),
        rec(2, focus: MirrorTone.tender),
        rec(3, focus: MirrorTone.tender),
      ];
      final t = MirrorHabitEngine.trend(records, today);
      expect(t.direction, LifeTrendDirection.rising);
      expect(t.sampleDays, 4);
    });

    test('too little history → unknown', () {
      final t = MirrorHabitEngine.trend([rec(0)], today);
      expect(t.direction, LifeTrendDirection.unknown);
    });
  });

  group('metrics', () {
    test('short history is not yet retained at 7 days', () {
      final records = [rec(0), rec(1), rec(2), rec(4)];
      final m = MirrorHabitEngine.metrics(records, today);
      expect(m.totalOpenedDays, 4);
      expect(m.currentStreak, 3);
      expect(m.daysActiveLast7, 4);
      expect(m.retained7, isFalse); // history spans only 5 days
    });

    test('older active history is retained at 7 and 30 days', () {
      final records = [
        for (var i = 0; i <= 40; i += 3) rec(i, reflected: i.isEven),
      ];
      final m = MirrorHabitEngine.metrics(records, today);
      expect(m.retained7, isTrue);
      expect(m.retained30, isTrue);
      expect(m.reflectionRate, greaterThan(0));
      expect(m.averageSessionsPerWeek, greaterThan(0));
    });
  });

  test('snapshot bundles all views deterministically', () {
    final records = [rec(0), rec(1), rec(2)];
    final a = MirrorHabitSnapshot.from(records, today);
    final b = MirrorHabitSnapshot.from(records, today);
    expect(a.streak.current, b.streak.current);
    expect(a.weekly.daysOpened, b.weekly.daysOpened);
    expect(a.monthly.daysOpened, b.monthly.daysOpened);
    expect(a.trend.direction, b.trend.direction);
  });
}
