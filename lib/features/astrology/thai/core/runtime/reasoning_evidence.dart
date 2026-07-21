import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// The reasoning layer an evidence atom or trace step belongs to. Fixed order
/// mirrors the pipeline (V9 → V10 → V11 → V12).
enum ReasoningLayer { timeline, prediction, decision, question }

/// V13 — a unified evidence atom across all reasoning layers.
///
/// The runtime flattens each layer's typed evidence into this single shape so a
/// consumer (Transit, Compatibility, AI Conversation) can read provenance
/// uniformly without depending on per-layer evidence types. [sourceName] is the
/// originating enum's identifier (e.g. `predictionStrength`) — a stable code,
/// **not** copy. [magnitude] is the signed contribution carried over unchanged.
class ReasoningEvidence {
  const ReasoningEvidence({
    required this.layer,
    required this.sourceName,
    required this.magnitude,
    this.domain,
    this.planet,
  });

  final ReasoningLayer layer;

  /// Stable identifier of the originating signal (an enum name, never prose).
  final String sourceName;

  /// Signed contribution carried over from the source layer.
  final int magnitude;

  final LifeDomain? domain;
  final LifePlanet? planet;
}
