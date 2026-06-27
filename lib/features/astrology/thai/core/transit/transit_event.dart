import 'transit_signal.dart';
import 'transit_window.dart';

/// What a transit event relates the transiting planet to.
enum TransitEventKind {
  /// The day-ruler transiting against the natal birth ruler.
  dayVersusNatal,

  /// The day-ruler transiting against the current life-period planet.
  dayVersusPeriod,
}

/// V15 — a discrete current-transit occurrence: a [signal] of a given [kind]
/// within a [window]. Evidence only — no copy.
class TransitEvent {
  const TransitEvent({
    required this.kind,
    required this.signal,
    required this.window,
  });

  final TransitEventKind kind;
  final TransitSignal signal;
  final TransitWindow window;
}
