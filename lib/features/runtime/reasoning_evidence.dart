import 'reasoning_module.dart';

/// V17 — a system-agnostic evidence atom.
///
/// Each provider flattens its own evidence into this shape so the runtime can
/// aggregate provenance across systems uniformly. [module] records which system
/// produced it, [layer] is the system-local layer name (a stable string, not an
/// enum the generic runtime would have to know), [sourceName] is the originating
/// signal code, [magnitude] is the signed contribution. [domain]/[tag] are
/// optional system markers (e.g. a life domain, a planet). No copy.
class ReasoningEvidence {
  const ReasoningEvidence({
    required this.module,
    required this.layer,
    required this.sourceName,
    required this.magnitude,
    this.domain,
    this.tag,
  });

  final ReasoningModule module;
  final String layer;
  final String sourceName;
  final int magnitude;
  final String? domain;
  final String? tag;
}
