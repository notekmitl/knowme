import '../application/mirror/personality_confidence_composer.dart';
import '../application/personality_lens_load_result.dart';
import '../domain/personality_agreement.dart';
import '../domain/personality_agreement_kind.dart';
import '../domain/personality_confidence.dart';
import '../domain/personality_confidence_breakdown.dart';
import '../domain/personality_mirror_constants.dart';
import '../domain/personality_tension.dart';

/// Verifies confidence math against approved PF-3 design rules.
abstract final class PersonalityMirrorConfidenceVerifier {
  static List<String> verify({
    required PersonalityLensLoadResult load,
    required List<PersonalityAgreement> agreements,
    required List<PersonalityTension> tensions,
    required PersonalityConfidenceBreakdown breakdown,
  }) {
    final issues = <String>[];

    final expectedBoost = _expectedAgreementBoost(agreements);
    if ((breakdown.agreementBoost - expectedBoost).abs() > 0.0001) {
      issues.add(
        'agreementBoost mismatch: expected $expectedBoost, '
        'got ${breakdown.agreementBoost}',
      );
    }

    final expectedPenalty = _expectedPenalty(tensions);
    if ((breakdown.contradictionPenalty - expectedPenalty).abs() > 0.0001) {
      issues.add(
        'contradictionPenalty mismatch: expected $expectedPenalty, '
        'got ${breakdown.contradictionPenalty}',
      );
    }

    final expectedCoverage = load.coverage.weightedCoverage.clamp(0.0, 1.0);
    if ((breakdown.coverageFactor - expectedCoverage).abs() > 0.0001) {
      issues.add(
        'coverageFactor mismatch: expected $expectedCoverage, '
        'got ${breakdown.coverageFactor}',
      );
    }

    final recomposed = PersonalityConfidenceBands.clamp(
      (breakdown.baseLensMean * breakdown.coverageFactor) +
          breakdown.agreementBoost -
          breakdown.contradictionPenalty,
    );
    if ((breakdown.compositeConfidence - recomposed).abs() > 0.0001) {
      issues.add(
        'composite formula mismatch: expected $recomposed, '
        'got ${breakdown.compositeConfidence}',
      );
    }

    final fromComposer = PersonalityConfidenceComposer.analyze(
      load: load,
      agreements: agreements,
      tensions: tensions,
    );
    if ((fromComposer.compositeConfidence - breakdown.compositeConfidence)
            .abs() >
        0.0001) {
      issues.add('breakdown does not match composer.analyze() output');
    }

    return issues;
  }

  static double _expectedAgreementBoost(List<PersonalityAgreement> agreements) {
    var boost = 0.0;
    for (final agreement in agreements) {
      final extra = agreement.supportingAgreementLenses.length - 1;
      if (extra <= 0) continue;

      boost += switch (agreement.kind) {
        PersonalityAgreementKind.theme => (extra *
                PersonalityMirrorConfidenceRules.exactBoostPerExtraLens)
            .clamp(0.0, PersonalityMirrorConfidenceRules.exactBoostCap),
        PersonalityAgreementKind.family =>
          PersonalityMirrorConfidenceRules.familyBoost,
        PersonalityAgreementKind.category =>
          PersonalityMirrorConfidenceRules.categoryBoost,
      };
    }
    return boost;
  }

  static double _expectedPenalty(List<PersonalityTension> tensions) {
    if (tensions.isEmpty) return 0;
    return (tensions.length * PersonalityMirrorConfidenceRules.penaltyPerTension)
        .clamp(0.0, PersonalityMirrorConfidenceRules.maxContradictionPenalty);
  }
}
