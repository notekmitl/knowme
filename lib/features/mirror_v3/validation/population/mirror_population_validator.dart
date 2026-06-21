import '../../engine/knowme_mirror_engine.dart';
import '../../engine/models/knowme_mirror_engine_input.dart';
import '../constants/mirror_validation_constants.dart';
import '../fixtures/mirror_synthetic_bundle_factory.dart';
import '../models/mirror_population_validation_report.dart';

/// MV2.1 population validation across synthetic theme bundles.
abstract final class MirrorPopulationValidator {
  static MirrorPopulationValidationReport validate({
    required int caseCount,
  }) {
    final cases = MirrorSyntheticBundleFactory.buildCases(caseCount);

    var agreementTotal = 0;
    var tensionTotal = 0;
    var reinforcementTotal = 0;
    var blindSpotTotal = 0;
    var confidenceTotal = 0.0;

    var casesWithAgreement = 0;
    var casesWithTension = 0;
    var casesWithReinforcement = 0;
    var casesWithBlindSpot = 0;

    for (final input in cases) {
      final result = KnowMeMirrorEngine.reflect(input);

      agreementTotal += result.agreements.length;
      tensionTotal += result.tensions.length;
      reinforcementTotal += result.reinforcements.length;
      blindSpotTotal += result.blindSpots.length;
      confidenceTotal += result.compositeConfidence;

      if (result.agreements.isNotEmpty) casesWithAgreement++;
      if (result.tensions.isNotEmpty) casesWithTension++;
      if (result.reinforcements.isNotEmpty) casesWithReinforcement++;
      if (result.blindSpots.isNotEmpty) casesWithBlindSpot++;
    }

    final total = cases.length;
    final distribution = MirrorPopulationDistributionSummary(
      agreementPerCase: agreementTotal / total,
      tensionPerCase: tensionTotal / total,
      reinforcementPerCase: reinforcementTotal / total,
      blindSpotPerCase: blindSpotTotal / total,
      confidencePerCase: confidenceTotal / total,
    );

    final anomalies = <String>[];

    final agreementRate = casesWithAgreement / total;
    if (agreementRate > MirrorPopulationThresholds.maxAgreementRate) {
      anomalies.add(
        'agreement rate too high: ${agreementRate.toStringAsFixed(3)}',
      );
    }

    final tensionRate = casesWithTension / total;
    if (tensionRate > MirrorPopulationThresholds.maxTensionRate) {
      anomalies.add('tension rate too high: ${tensionRate.toStringAsFixed(3)}');
    }

    final reinforcementRate = casesWithReinforcement / total;
    if (reinforcementRate <
        MirrorPopulationThresholds.minReinforcementOccurrenceRate) {
      anomalies.add(
        'reinforcement never/rarely occurs: '
        '${reinforcementRate.toStringAsFixed(3)}',
      );
    }

    if (distribution.blindSpotPerCase >
        MirrorPopulationThresholds.maxBlindSpotMeanPerCase) {
      anomalies.add(
        'blind spot mean too high: '
        '${distribution.blindSpotPerCase.toStringAsFixed(2)}',
      );
    }

    final blindSpotRate = casesWithBlindSpot / total;
    if (blindSpotRate > MirrorPopulationThresholds.maxBlindSpotRate) {
      anomalies.add(
        'blind spot occurs in nearly every case: '
        '${blindSpotRate.toStringAsFixed(3)}',
      );
    }

    return MirrorPopulationValidationReport(
      totalCases: total,
      agreementCount: agreementTotal,
      tensionCount: tensionTotal,
      reinforcementCount: reinforcementTotal,
      blindSpotCount: blindSpotTotal,
      distribution: distribution,
      anomalies: anomalies,
      passed: anomalies.isEmpty,
    );
  }
}
