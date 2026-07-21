import '../reasoning_module.dart';

/// P2 — merged evidence for one domain across all providers.
///
/// [netMagnitude] is the signed sum of every provider's contribution to
/// [domain]; [modules] are the providers that contributed. This is the unified
/// evidence view fusion produces from the per-provider observations.
class FusionEvidence {
  const FusionEvidence({
    required this.domain,
    required this.netMagnitude,
    required this.modules,
  });

  final String domain;
  final int netMagnitude;
  final List<ReasoningModule> modules;

  /// Net direction: +1 favourable, -1 cautionary, 0 neutral.
  int get direction => netMagnitude.sign;
}
