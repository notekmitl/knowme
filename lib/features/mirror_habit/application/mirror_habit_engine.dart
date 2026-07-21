import 'package:knowme/features/mirror_experience/mirror_view_models.dart';

import '../domain/life_trend.dart';
import '../domain/mirror_comparison.dart';
import '../domain/mirror_day_record.dart';
import '../domain/mirror_habit_metrics.dart';
import '../domain/mirror_period_reflection.dart';
import '../domain/mirror_streak.dart';

/// Phase D — the deterministic habit math.
///
/// Pure functions over day records: streak, Yesterday-vs-Today, weekly/monthly
/// reflection, life trend and the retention metrics. No reasoning, no AI, no
/// astrology — just counting days and tones.
abstract final class MirrorHabitEngine {
  static int toneScore(MirrorTone tone) {
    switch (tone) {
      case MirrorTone.strong:
        return 1;
      case MirrorTone.steady:
        return 0;
      case MirrorTone.tender:
        return -1;
    }
  }

  /// Opened days as a date-only set, plus a sorted ascending list.
  static List<DateTime> _openedDaysAsc(List<MirrorDayRecord> records) {
    final set = <String, DateTime>{};
    for (final r in records) {
      if (!r.opened) continue;
      final d = MirrorDate.dayOf(r.date);
      set[MirrorDate.key(d)] = d;
    }
    final list = set.values.toList()..sort();
    return list;
  }

  static MirrorStreak streak(List<MirrorDayRecord> records, DateTime today) {
    final days = _openedDaysAsc(records);
    if (days.isEmpty) return MirrorStreak.empty;

    final keys = days.map(MirrorDate.key).toSet();
    final t = MirrorDate.dayOf(today);
    final last = days.last;

    // Longest run of consecutive days.
    var longest = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      if (MirrorDate.daysBetween(days[i - 1], days[i]) == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > longest) longest = run;
    }

    // Current run: count back from today, or yesterday as a grace day.
    final activeToday = keys.contains(MirrorDate.key(t));
    DateTime? cursor;
    if (activeToday) {
      cursor = t;
    } else if (keys.contains(MirrorDate.key(t.subtract(const Duration(days: 1))))) {
      cursor = t.subtract(const Duration(days: 1));
    }

    var current = 0;
    while (cursor != null && keys.contains(MirrorDate.key(cursor))) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return MirrorStreak(
      current: current,
      longest: longest > current ? longest : current,
      activeToday: activeToday,
      lastOpened: last,
    );
  }

  static MirrorComparison compare(
    List<MirrorDayRecord> records,
    DateTime today,
  ) {
    final t = MirrorDate.dayOf(today);
    final y = t.subtract(const Duration(days: 1));
    MirrorDayRecord? todayR;
    MirrorDayRecord? yestR;
    for (final r in records) {
      final d = MirrorDate.dayOf(r.date);
      if (MirrorDate.key(d) == MirrorDate.key(t)) todayR = r;
      if (MirrorDate.key(d) == MirrorDate.key(y)) yestR = r;
    }
    if (todayR == null || yestR == null) {
      return MirrorComparison.none;
    }

    final focusDelta =
        toneScore(todayR.focusTone) - toneScore(yestR.focusTone);
    final clarityDelta = todayR.clarity - yestR.clarity;

    return MirrorComparison(
      hasYesterday: true,
      focusShift: _shift(focusDelta),
      clarityShift: _shift(clarityDelta),
      clarityDelta: clarityDelta,
      focusKeyYesterday: yestR.focusKey,
      focusKeyToday: todayR.focusKey,
    );
  }

  static MirrorShift _shift(int delta) {
    if (delta > 0) return MirrorShift.brightened;
    if (delta < 0) return MirrorShift.softened;
    return MirrorShift.steady;
  }

  static MirrorPeriodReflection period(
    List<MirrorDayRecord> records,
    DateTime today,
    int windowDays,
  ) {
    final t = MirrorDate.dayOf(today);
    final start = t.subtract(Duration(days: windowDays - 1));
    final inWindow = <MirrorDayRecord>[];
    for (final r in records) {
      if (!r.opened) continue;
      final d = MirrorDate.dayOf(r.date);
      if (MirrorDate.daysBetween(start, d) >= 0 &&
          MirrorDate.daysBetween(d, t) >= 0) {
        inWindow.add(r);
      }
    }
    if (inWindow.isEmpty) return MirrorPeriodReflection.emptyFor(windowDays);

    final daysOpened = inWindow.length;
    final actions = inWindow.where((r) => r.actionTaken).length;
    final reflections = inWindow.where((r) => r.reflected).length;

    final toneCounts = <MirrorTone, int>{};
    final areaCounts = <String, int>{};
    for (final r in inWindow) {
      toneCounts[r.focusTone] = (toneCounts[r.focusTone] ?? 0) + 1;
      final key = r.focusKey;
      if (key != null && key.isNotEmpty) {
        areaCounts[key] = (areaCounts[key] ?? 0) + 1;
      }
    }

    return MirrorPeriodReflection(
      windowDays: windowDays,
      daysOpened: daysOpened,
      actionsTaken: actions,
      reflections: reflections,
      reflectionRate: reflections / daysOpened,
      dominantTone: _mode(toneCounts) ?? MirrorTone.steady,
      mostFocusedAreaKey: _mode(areaCounts),
    );
  }

  static LifeTrend trend(
    List<MirrorDayRecord> records,
    DateTime today, {
    int windowDays = 30,
  }) {
    final t = MirrorDate.dayOf(today);
    final start = t.subtract(Duration(days: windowDays - 1));
    final inWindow = records.where((r) {
      if (!r.opened) return false;
      final d = MirrorDate.dayOf(r.date);
      return MirrorDate.daysBetween(start, d) >= 0 &&
          MirrorDate.daysBetween(d, t) >= 0;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (inWindow.isEmpty) return LifeTrend.unknown;

    final avgClarity =
        inWindow.map((r) => r.clarity).reduce((a, b) => a + b) /
            inWindow.length;
    final recentTone = inWindow.last.focusTone;

    if (inWindow.length < 4) {
      return LifeTrend(
        direction: LifeTrendDirection.unknown,
        averageClarity: avgClarity,
        sampleDays: inWindow.length,
        recentTone: recentTone,
      );
    }

    final half = inWindow.length ~/ 2;
    final first = inWindow.take(half);
    final second = inWindow.skip(inWindow.length - half);
    final avgFirst =
        first.map((r) => toneScore(r.focusTone)).reduce((a, b) => a + b) /
            first.length;
    final avgSecond =
        second.map((r) => toneScore(r.focusTone)).reduce((a, b) => a + b) /
            second.length;
    final delta = avgSecond - avgFirst;

    final direction = delta > 0.25
        ? LifeTrendDirection.rising
        : delta < -0.25
            ? LifeTrendDirection.easing
            : LifeTrendDirection.steady;

    return LifeTrend(
      direction: direction,
      averageClarity: avgClarity,
      sampleDays: inWindow.length,
      recentTone: recentTone,
    );
  }

  static MirrorHabitMetrics metrics(
    List<MirrorDayRecord> records,
    DateTime today,
  ) {
    final days = _openedDaysAsc(records);
    if (days.isEmpty) return MirrorHabitMetrics.empty;

    final t = MirrorDate.dayOf(today);
    final s = streak(records, today);
    final first = days.first;

    int activeWithin(int window) {
      final start = t.subtract(Duration(days: window - 1));
      return days
          .where((d) =>
              MirrorDate.daysBetween(start, d) >= 0 &&
              MirrorDate.daysBetween(d, t) >= 0)
          .length;
    }

    final last7 = activeWithin(7);
    final last30 = activeWithin(30);
    final spanDays = MirrorDate.daysBetween(first, t) + 1;
    final reflections = records.where((r) => r.opened && r.reflected).length;
    final weeks = spanDays / 7.0;

    return MirrorHabitMetrics(
      totalOpenedDays: days.length,
      currentStreak: s.current,
      longestStreak: s.longest,
      daysActiveLast7: last7,
      daysActiveLast30: last30,
      retained7: spanDays >= 7 && last7 > 0,
      retained30: spanDays >= 30 && last30 > 0,
      averageSessionsPerWeek: weeks <= 0 ? days.length.toDouble() : days.length / weeks,
      reflectionRate: reflections / days.length,
    );
  }

  static T? _mode<T>(Map<T, int> counts) {
    T? best;
    var bestCount = -1;
    counts.forEach((key, count) {
      if (count > bestCount) {
        bestCount = count;
        best = key;
      }
    });
    return best;
  }
}
