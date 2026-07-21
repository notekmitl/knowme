import 'package:knowme/features/mirror_experience/mirror_view_models.dart';

/// Phase D — the longer-arc direction of life over recent weeks.
enum LifeTrendDirection {
  /// Energy building over the window.
  rising,

  /// Roughly level.
  steady,

  /// Easing / asking for more care over the window.
  easing,

  /// Not enough history to read a trend.
  unknown,
}

/// Phase D — the Life Trend: a gentle arc, not a forecast (no new reasoning).
class LifeTrend {
  const LifeTrend({
    required this.direction,
    required this.averageClarity,
    required this.sampleDays,
    required this.recentTone,
  });

  final LifeTrendDirection direction;
  final double averageClarity;
  final int sampleDays;
  final MirrorTone recentTone;

  static const LifeTrend unknown = LifeTrend(
    direction: LifeTrendDirection.unknown,
    averageClarity: 0,
    sampleDays: 0,
    recentTone: MirrorTone.steady,
  );
}
