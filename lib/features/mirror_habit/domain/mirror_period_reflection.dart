import 'package:knowme/features/mirror_experience/mirror_view_models.dart';

/// Phase D — a Weekly or Monthly reflection: how the loop went over a window.
class MirrorPeriodReflection {
  const MirrorPeriodReflection({
    required this.windowDays,
    required this.daysOpened,
    required this.actionsTaken,
    required this.reflections,
    required this.reflectionRate,
    required this.dominantTone,
    this.mostFocusedAreaKey,
  });

  /// 7 for weekly, 30 for monthly.
  final int windowDays;

  final int daysOpened;
  final int actionsTaken;
  final int reflections;

  /// reflections / daysOpened (0 when no days opened).
  final double reflectionRate;

  /// The tone the focus held most often across opened days.
  final MirrorTone dominantTone;

  /// The life area most often in focus across the window (key, if any).
  final String? mostFocusedAreaKey;

  static MirrorPeriodReflection emptyFor(int windowDays) =>
      MirrorPeriodReflection(
        windowDays: windowDays,
        daysOpened: 0,
        actionsTaken: 0,
        reflections: 0,
        reflectionRate: 0,
        dominantTone: MirrorTone.steady,
      );
}
