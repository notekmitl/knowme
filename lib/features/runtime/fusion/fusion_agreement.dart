import '../reasoning_module.dart';

/// P2 — a domain where two or more providers point the same way.
///
/// [direction] is the shared sign (+1 favourable / -1 cautionary), [magnitude]
/// is the combined absolute strength, and [modules] are the agreeing providers.
class FusionAgreement {
  const FusionAgreement({
    required this.domain,
    required this.modules,
    required this.direction,
    required this.magnitude,
  });

  final String domain;
  final List<ReasoningModule> modules;
  final int direction;
  final int magnitude;
}
