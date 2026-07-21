import 'global_agreement.dart';
import 'global_confidence.dart';
import 'global_coverage.dart';
import 'global_fusion_input.dart';
import 'global_tension.dart';
import 'global_theme_activation.dart';

/// Full Global Fusion foundation snapshot contract (GF-F0 — no synthesis logic).
class GlobalFusionSnapshot {
  const GlobalFusionSnapshot({
    required this.version,
    required this.generatedAt,
    required this.input,
    required this.normalizedThemes,
    required this.agreements,
    required this.tensions,
    required this.confidence,
    required this.coverage,
  });

  static const String versionId = 'global_fusion.v0_foundation';

  final String version;
  final DateTime generatedAt;
  final GlobalFusionInput input;
  final List<GlobalThemeActivation> normalizedThemes;
  final List<GlobalAgreement> agreements;
  final List<GlobalTension> tensions;
  final GlobalConfidence confidence;
  final GlobalCoverage coverage;
}
