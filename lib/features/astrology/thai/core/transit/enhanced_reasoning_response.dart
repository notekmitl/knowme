import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_response.dart';

import 'transit_assessment.dart';

/// Where a merged evidence atom came from.
enum EnhancedEvidenceOrigin { runtime, transit }

/// V15 — a single atom of the merged evidence pool, normalising runtime
/// `ReasoningEvidence` and `TransitEvidence` into one shape so consumers read a
/// single injected list. The `ReasoningLayer` enum stays frozen, so transit
/// atoms carry the literal layer name `transit`.
class EnhancedEvidence {
  const EnhancedEvidence({
    required this.origin,
    required this.layer,
    required this.sourceName,
    required this.magnitude,
    this.domain,
    this.planet,
  });

  final EnhancedEvidenceOrigin origin;

  /// The originating layer name (`timeline`/`prediction`/… or `transit`).
  final String layer;
  final String sourceName;
  final int magnitude;
  final LifeDomain? domain;
  final LifePlanet? planet;
}

/// V15 — the output of the Enhanced Runtime: the **untouched** runtime
/// [base] response plus the [transit] assessment, with a merged evidence view.
///
/// Transit contributes evidence only, so [confidence] and every base snapshot
/// are exactly the runtime's — the enhancement never alters a decision,
/// prediction or answer.
class EnhancedReasoningResponse {
  const EnhancedReasoningResponse({
    required this.base,
    required this.transit,
  });

  /// The original runtime response, unchanged.
  final ReasoningResponse base;

  /// The transit evidence layer.
  final TransitAssessment transit;

  int get confidence => base.confidence;

  /// The runtime evidence, unchanged.
  List<EnhancedEvidence> get runtimeEvidence => [
        for (final e in base.evidence)
          EnhancedEvidence(
            origin: EnhancedEvidenceOrigin.runtime,
            layer: e.layer.name,
            sourceName: e.sourceName,
            magnitude: e.magnitude,
            domain: e.domain,
            planet: e.planet,
          ),
      ];

  /// The transit evidence, normalised into the merged shape.
  List<EnhancedEvidence> get transitEvidence => [
        for (final e in transit.evidence)
          EnhancedEvidence(
            origin: EnhancedEvidenceOrigin.transit,
            layer: 'transit',
            sourceName: e.sourceName,
            magnitude: e.magnitude,
            domain: e.domain,
            planet: e.planet,
          ),
      ];

  /// The injected pool: runtime evidence followed by transit evidence.
  List<EnhancedEvidence> get mergedEvidence => [
        ...runtimeEvidence,
        ...transitEvidence,
      ];
}
