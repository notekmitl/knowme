import '../../domain/global_agreement.dart';
import '../../domain/global_agreement_strength.dart';
import '../../domain/global_confidence.dart';
import '../../domain/global_coverage.dart';
import '../../domain/global_tension.dart';
import '../../domain/global_theme_activation.dart';

/// Composes Global Fusion confidence from coverage, agreements, and tensions (GF-F2).
abstract final class GlobalConfidenceComposer {
  static const weakAgreementBonus = 0.10;
  static const mediumAgreementBonus = 0.20;
  static const strongAgreementBonus = 0.30;
  static const tensionPenaltyPerTension = 0.10;

  static GlobalConfidence compose({
    required GlobalCoverage coverage,
    required List<GlobalAgreement> agreements,
    required List<GlobalTension> tensions,
    required List<GlobalThemeActivation> themes,
  }) {
    return analyze(
      coverage: coverage,
      agreements: agreements,
      tensions: tensions,
      themes: themes,
    ).toConfidence();
  }

  static GlobalConfidenceBreakdown analyze({
    required GlobalCoverage coverage,
    required List<GlobalAgreement> agreements,
    required List<GlobalTension> tensions,
    required List<GlobalThemeActivation> themes,
  }) {
    final coverageScore = _coverageScore(coverage);
    final coverageContribution = _coverageContribution(
      coverage: coverage,
      agreements: agreements,
    );
    final agreementBonus = _agreementBonus(agreements);
    final tensionPenalty = _tensionPenalty(tensions);

    final composite = GlobalConfidenceBands.clamp(
      coverageContribution + agreementBonus - tensionPenalty,
    );

    return GlobalConfidenceBreakdown(
      coverageScore: coverageScore,
      coverageContribution: coverageContribution,
      agreementBonus: agreementBonus,
      tensionPenalty: tensionPenalty,
      composite: composite,
      band: GlobalConfidenceBands.bandFor(composite),
    );
  }

  /// Mirror availability tier from GlobalCoverage (spec table).
  static double _coverageScore(GlobalCoverage coverage) {
    if (coverage.hasBothMirrors) return 1.0;
    if (coverage.hasAnyMirror) return 0.5;
    return 0.0;
  }

  /// Cross-mirror support base — both mirrors need agreement for full 1.0 base.
  static double _coverageContribution({
    required GlobalCoverage coverage,
    required List<GlobalAgreement> agreements,
  }) {
    if (!coverage.hasAnyMirror) return 0.0;
    if (!coverage.hasBothMirrors) return 0.5;
    if (agreements.isEmpty) return 0.5;
    return 1.0;
  }

  static double _agreementBonus(List<GlobalAgreement> agreements) {
    var bonus = 0.0;
    for (final agreement in agreements) {
      bonus += switch (agreement.strength) {
        GlobalAgreementStrength.weak => weakAgreementBonus,
        GlobalAgreementStrength.medium => mediumAgreementBonus,
        GlobalAgreementStrength.strong => strongAgreementBonus,
      };
    }
    return bonus;
  }

  static double _tensionPenalty(List<GlobalTension> tensions) {
    return tensions.length * tensionPenaltyPerTension;
  }
}
