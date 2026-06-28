import '../reasoning_capability.dart';
import 'fusion_agreement.dart';
import 'fusion_conflict.dart';
import 'fusion_confidence.dart';
import 'fusion_evidence.dart';
import 'fusion_observation.dart';
import 'fusion_priority.dart';

/// P2 — the single unified reasoning result fusion produces.
///
/// Bundles every provider's [observations], the detected [agreements] and
/// [conflicts], the per-domain merged [mergedEvidence], the [priorities]
/// ordering, the fused [confidence], the [missingEvidence] domains (covered by
/// some providers but not all), and the [singleProviderMode] flag (true when only
/// one provider answered). Evidence only — no copy, no presenter.
class FusionResult {
  const FusionResult({
    required this.capability,
    required this.observations,
    required this.agreements,
    required this.conflicts,
    required this.mergedEvidence,
    required this.priorities,
    required this.confidence,
    required this.singleProviderMode,
    required this.missingEvidence,
  });

  final ReasoningCapability capability;
  final List<FusionObservation> observations;
  final List<FusionAgreement> agreements;
  final List<FusionConflict> conflicts;
  final List<FusionEvidence> mergedEvidence;
  final List<FusionPriority> priorities;
  final FusionConfidence confidence;
  final bool singleProviderMode;
  final List<String> missingEvidence;
}
