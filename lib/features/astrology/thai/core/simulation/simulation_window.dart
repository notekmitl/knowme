import 'package:knowme/features/astrology/thai/core/decision/decision_window.dart';

/// V14 — the timing of a simulated option, projected from the runtime's V11
/// [DecisionWindow]. Age bounds + the window's net favourability. Evidence only.
class SimulationWindow {
  const SimulationWindow({
    required this.startAge,
    required this.endAge,
    required this.favourability,
    required this.available,
  });

  factory SimulationWindow.fromDecision(DecisionWindow w) => SimulationWindow(
        startAge: w.startAge,
        endAge: w.endAge,
        favourability: w.favourability,
        available: w.available,
      );

  final int startAge;
  final int endAge;
  final int favourability;
  final bool available;
}
