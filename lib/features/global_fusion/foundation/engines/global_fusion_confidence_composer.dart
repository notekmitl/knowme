import '../contracts/global_fusion_input.dart';
import '../domain/global_fusion_confidence.dart';
import '../domain/global_fusion_coverage.dart';
import '../domain/global_fusion_findings.dart';

/// GF7 — composes confidence from structural factors, not mirror averages.
abstract final class GlobalFusionConfidenceComposer {
  static const _diversityWeight = 0.25;
  static const _evidenceWeight = 0.25;
  static const _agreementWeight = 0.30;
  static const _coverageWeight = 0.20;
  static const _tensionPenaltyUnit = 0.08;

  static GlobalFusionConfidence compose({
    required GlobalFusionInput input,
    required GlobalFusionCoverage coverage,
    required List<GlobalFusionCrossMirrorAgreement> agreements,
    required List<GlobalFusionCrossMirrorTension> tensions,
    required List<GlobalFusionCrossMirrorReinforcement> reinforcements,
  }) {
    final mirrorCount = input.mirrorCount;
    final diversityScore = mirrorCount <= 1
        ? 0.35
        : (mirrorCount / (mirrorCount + 1)).clamp(0.0, 1.0);

    final evidenceRows = input.mirrors.fold<int>(
      0,
      (sum, ref) => sum + ref.snapshot.evidence.length,
    );
    final evidenceDepthScore = mirrorCount == 0
        ? 0.0
        : (evidenceRows / (mirrorCount * 6)).clamp(0.0, 1.0);

    final agreementStrengthScore = agreements.isEmpty
        ? 0.0
        : agreements
            .map((item) => item.agreementStrength)
            .reduce((a, b) => a > b ? a : b)
            .clamp(0.0, 1.0);

    final reinforcementBoost = reinforcements.isEmpty
        ? 0.0
        : reinforcements
            .map((item) => item.reinforcementBoost)
            .reduce((a, b) => a + b)
            .clamp(0.0, 0.45);

    final coverageScore = coverage.weightedCoverage.clamp(0.0, 1.0);
    final tensionPenalty = (tensions.length * _tensionPenaltyUnit)
        .clamp(0.0, 0.24);

    final composite = (
            diversityScore * _diversityWeight +
            evidenceDepthScore * _evidenceWeight +
            agreementStrengthScore * _agreementWeight +
            coverageScore * _coverageWeight +
            reinforcementBoost)
        .clamp(0.0, 1.0) -
        tensionPenalty;

    return GlobalFusionConfidence(
      composite: composite.clamp(0.0, 1.0),
      mirrorDiversityScore: diversityScore,
      evidenceDepthScore: evidenceDepthScore,
      agreementStrengthScore: agreementStrengthScore,
      coverageScore: coverageScore,
      tensionPenalty: tensionPenalty,
    );
  }
}
