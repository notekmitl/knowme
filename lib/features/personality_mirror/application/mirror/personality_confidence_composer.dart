import '../../domain/personality_agreement.dart';
import '../../domain/personality_agreement_kind.dart';
import '../../domain/personality_confidence.dart';
import '../../domain/personality_confidence_breakdown.dart';
import '../../domain/personality_lens_id.dart';
import '../../domain/personality_mirror_constants.dart';
import '../../domain/personality_tension.dart';
import '../personality_lens_load_result.dart';

/// Composes mirror-level confidence from lens depth, coverage, agreement, tension.
abstract final class PersonalityConfidenceComposer {
  static PersonalityConfidence compose({
    required PersonalityLensLoadResult load,
    required List<PersonalityAgreement> agreements,
    required List<PersonalityTension> tensions,
  }) {
    return analyze(
      load: load,
      agreements: agreements,
      tensions: tensions,
    ).compositeConfidence;
  }

  static PersonalityConfidenceBreakdown analyze({
    required PersonalityLensLoadResult load,
    required List<PersonalityAgreement> agreements,
    required List<PersonalityTension> tensions,
  }) {
    final base = _weightedLensMean(load);
    final coverageFactor = load.coverage.weightedCoverage.clamp(0.0, 1.0);
    final agreementBoost = _agreementBoost(agreements);
    final penalty = _contradictionPenalty(tensions);

    final composite = PersonalityConfidenceBands.clamp(
      (base * coverageFactor) + agreementBoost - penalty,
    );

    return PersonalityConfidenceBreakdown(
      baseLensMean: base,
      coverageFactor: coverageFactor,
      agreementBoost: agreementBoost,
      contradictionPenalty: penalty,
      compositeConfidence: composite,
    );
  }

  static double _weightedLensMean(PersonalityLensLoadResult load) {
    var weightedSum = 0.0;
    var weightTotal = 0.0;

    final mbti = load.snapshotFor(PersonalityLensId.mbti);
    if (mbti != null && mbti.available) {
      weightedSum += mbti.lensConfidence * PersonalityMirrorWeights.mbti;
      weightTotal += PersonalityMirrorWeights.mbti;
    }

    final bigFive = load.snapshotFor(PersonalityLensId.bigFive);
    if (bigFive != null && bigFive.available) {
      weightedSum += bigFive.lensConfidence * PersonalityMirrorWeights.bigFive;
      weightTotal += PersonalityMirrorWeights.bigFive;
    }

    final eqConfidence = _eqAggregateConfidence(load);
    if (eqConfidence != null) {
      weightedSum += eqConfidence * PersonalityMirrorWeights.eq;
      weightTotal += PersonalityMirrorWeights.eq;
    }

    if (weightTotal <= 0) return 0;
    return weightedSum / weightTotal;
  }

  static double? _eqAggregateConfidence(PersonalityLensLoadResult load) {
    final values = <double>[];
    for (final lensId in PersonalityLensId.eqLenses) {
      final snapshot = load.snapshotFor(lensId);
      if (snapshot != null && snapshot.available) {
        values.add(snapshot.lensConfidence);
      }
    }
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _agreementBoost(List<PersonalityAgreement> agreements) {
    var boost = 0.0;

    for (final agreement in agreements) {
      final extraLenses = agreement.supportingAgreementLenses.length - 1;
      if (extraLenses <= 0) continue;

      boost += switch (agreement.kind) {
        PersonalityAgreementKind.theme => _themeBoost(extraLenses),
        PersonalityAgreementKind.family =>
          PersonalityMirrorConfidenceRules.familyBoost,
        PersonalityAgreementKind.category =>
          PersonalityMirrorConfidenceRules.categoryBoost,
      };
    }

    return boost;
  }

  static double _themeBoost(int extraLensCount) {
    final raw = extraLensCount *
        PersonalityMirrorConfidenceRules.exactBoostPerExtraLens;
    return raw.clamp(0.0, PersonalityMirrorConfidenceRules.exactBoostCap);
  }

  static double _contradictionPenalty(List<PersonalityTension> tensions) {
    if (tensions.isEmpty) return 0;
    final raw = tensions.length *
        PersonalityMirrorConfidenceRules.penaltyPerTension;
    return raw.clamp(0.0, PersonalityMirrorConfidenceRules.maxContradictionPenalty);
  }
}
