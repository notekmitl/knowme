import 'transit_event.dart';
import 'transit_evidence.dart';
import 'transit_impact.dart';
import 'transit_influence.dart';
import 'transit_window.dart';

/// V15 — the full product of evaluating the current transit.
///
/// Bundles the [events], their per-domain [influences], the aggregate [impact],
/// the emitted [evidence] (to be merged into the runtime evidence pool) and the
/// [window] the transit applies to. Evidence only — no decision, no prediction,
/// no answer.
class TransitAssessment {
  const TransitAssessment({
    required this.events,
    required this.influences,
    required this.impact,
    required this.evidence,
    required this.window,
  });

  final List<TransitEvent> events;
  final List<TransitInfluence> influences;
  final TransitImpact impact;
  final List<TransitEvidence> evidence;
  final TransitWindow window;
}
