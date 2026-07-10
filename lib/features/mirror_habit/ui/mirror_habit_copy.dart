import 'package:knowme/features/mirror_experience/mirror_copy.dart';

import '../domain/life_trend.dart';
import '../domain/mirror_comparison.dart';
import '../domain/mirror_period_reflection.dart';
import '../domain/mirror_streak.dart';

/// Phase D — habit-loop copy. Same rule as the rest of the Mirror: **explain
/// life, not astrology**. Warm, encouraging, never clinical.
abstract final class MirrorHabitCopy {
  static const String reflectTitle = 'Which felt most true today?';
  static const String reflectOpportunity = 'The opening';
  static const String reflectCaution = 'The caution';
  static const String reflectFocus = 'The focus';
  static const String reflectedThanks = 'Saved. See you tomorrow.';

  static const String historyTitle = 'Your last week';
  static const String trendTitle = 'Your life lately';
  static const String weeklyTitle = 'This week';
  static const String monthlyTitle = 'This month';
  static const String yesterdayTitle = 'Since yesterday';

  static String streakLine(MirrorStreak streak) {
    if (streak.current <= 0) return 'Start your streak today.';
    if (streak.current == 1) {
      return streak.activeToday
          ? 'Day one. A good day to begin.'
          : 'One day so far — open today to keep it going.';
    }
    return '${streak.current} days in a row'
        '${streak.longest > streak.current ? ' · best ${streak.longest}' : ''}.';
  }

  static String returnTomorrow(MirrorStreak streak) {
    if (streak.current <= 0) {
      return 'Come back tomorrow to start a streak.';
    }
    return 'Come back tomorrow to make it ${streak.current + 1} in a row.';
  }

  static String yesterday(MirrorComparison c) {
    if (!c.hasYesterday) {
      return 'Open again tomorrow and you will see how things shift.';
    }
    switch (c.focusShift) {
      case MirrorShift.brightened:
        return 'A little brighter than yesterday — momentum is building.';
      case MirrorShift.softened:
        return 'A touch softer than yesterday — be gentle with your pace.';
      case MirrorShift.steady:
      case MirrorShift.unknown:
        return c.clarityDelta > 0
            ? 'Much like yesterday, with the picture a little clearer.'
            : 'Steady from yesterday — no big swings.';
    }
  }

  static String period(MirrorPeriodReflection p) {
    if (p.daysOpened == 0) {
      return 'No reflections yet in this window.';
    }
    final area = p.mostFocusedAreaKey == null
        ? null
        : MirrorCopy.areaTitle(p.mostFocusedAreaKey!);
    final tone = MirrorCopy.toneWord(p.dominantTone).toLowerCase();
    final base = 'Opened ${p.daysOpened} '
        '${p.daysOpened == 1 ? 'day' : 'days'}, '
        'reflected ${p.reflections}.';
    if (area == null) return '$base Mostly $tone.';
    return '$base Mostly $tone, often around $area.';
  }

  static String trend(LifeTrend t) {
    switch (t.direction) {
      case LifeTrendDirection.rising:
        return 'Your recent days lean toward momentum — energy is gathering.';
      case LifeTrendDirection.easing:
        return 'Your recent days ask for more care — a softer season.';
      case LifeTrendDirection.steady:
        return 'Your recent days have been steady and even.';
      case LifeTrendDirection.unknown:
        return 'Keep opening daily and a longer arc will appear here.';
    }
  }

  static String reflectChoiceLabel(String choice) {
    switch (choice) {
      case 'opportunity':
        return reflectOpportunity;
      case 'caution':
        return reflectCaution;
      case 'focus':
        return reflectFocus;
      default:
        return choice;
    }
  }
}
