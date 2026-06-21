import '../synthetic_population/pipeline/synthetic_human_run_record.dart';
import '../synthetic_population_v2/simulation/validation_v2_recovery_simulator.dart';
import '../synthetic_population_v2/synthetic_population_v2_runner.dart';
import 'audits/life_direction_coverage_audit.dart';
import 'audits/vg006_calibration_audit.dart';
import 'factory/synthetic_human_profile_factory_v3.dart';
import 'pipeline/synthetic_human_pipeline_runner_v3.dart';

class Gf2CalibrationAuditResult {
  const Gf2CalibrationAuditResult({
    required this.records,
    required this.lifeDirectionCoverage,
    required this.populationQuality,
    required this.deadZoneRevalidation,
    required this.v2Simulation,
    required this.patternRecovery,
    required this.vg006Calibration,
    required this.validationGates,
    required this.finalDecision,
  });

  final List<SyntheticHumanRunRecord> records;
  final Map<String, dynamic> lifeDirectionCoverage;
  final Map<String, dynamic> populationQuality;
  final Map<String, dynamic> deadZoneRevalidation;
  final Map<String, dynamic> v2Simulation;
  final Map<String, dynamic> patternRecovery;
  final Map<String, dynamic> vg006Calibration;
  final Map<String, dynamic> validationGates;
  final Map<String, dynamic> finalDecision;
}

abstract final class Gf2CalibrationRunner {
  static Gf2CalibrationAuditResult runAll() {
    final profiles = SyntheticHumanProfileFactoryV3.buildAll();
    final records = <SyntheticHumanRunRecord>[];

    for (var index = 0; index < profiles.length; index++) {
      records.add(
        SyntheticHumanPipelineRunnerV3.run(
          profiles[index],
          generatedAt: DateTime.utc(2026, 6, 21, index % 24, index % 60),
        ),
      );
    }

    final populationQuality =
        SyntheticHumanProfileFactoryV3.populationQualityReport(profiles);
    final lifeDirectionCoverage = LifeDirectionCoverageAudit.analyze(records);
    final deadZones = DeadZoneRevalidationAudit.analyze(records);
    final v2Sim = V2RecoverySimulationAudit.analyze(records);
    final patternRecovery = _patternRecoveryReport(records);
    final records200 = Vg006CalibrationAudit.buildPopulation200();
    final vg006Calibration = Vg006CalibrationAudit.analyze(
      records200: records200,
      records1000: records,
    );
    final validationGates = ValidationGatesAudit.evaluateCalibrated(
      records: records,
      v2Sim: v2Sim,
      deadZones: deadZones,
      vg006Calibration: vg006Calibration,
    );
    final finalDecision = _finalDecision(
      validationGates: validationGates,
      v2Sim: v2Sim,
      patternRecovery: patternRecovery,
      lifeDirectionCoverage: lifeDirectionCoverage,
    );

    return Gf2CalibrationAuditResult(
      records: records,
      lifeDirectionCoverage: lifeDirectionCoverage,
      populationQuality: populationQuality,
      deadZoneRevalidation: deadZones,
      v2Simulation: v2Sim,
      patternRecovery: patternRecovery,
      vg006Calibration: vg006Calibration,
      validationGates: validationGates,
      finalDecision: finalDecision,
    );
  }

  static Map<String, dynamic> _patternRecoveryReport(
    List<SyntheticHumanRunRecord> records,
  ) {
    var adaptiveBaseline = 0;
    var adaptiveSimulated = 0;
    var stableBaseline = 0;
    var stableSimulated = 0;
    var r004Total = 0;
    var mp001Total = 0;
    var gf2ReinforcementTotal = 0;
    var gf2AgreementTotal = 0;
    final adaptiveLineage = <Map<String, dynamic>>[];
    final stableLineage = <Map<String, dynamic>>[];

    for (final record in records) {
      if (record.humanPatternSnapshot.activations
          .any((a) => a.patternId == 'adaptive_creator')) {
        adaptiveBaseline++;
      }
      if (record.humanPatternSnapshot.activations
          .any((a) => a.patternId == 'stable_orientation')) {
        stableBaseline++;
      }

      final sim = ValidationV2RecoverySimulator.simulateRecord(record);
      mp001Total += sim.mp001AgreementCount;
      gf2AgreementTotal += sim.gf2AgreementCount;
      gf2ReinforcementTotal += sim.gf2ReinforcementCount;
      r004Total += sim.r004ReinforcementCount;

      final adaptiveActive = sim.humanPatternSnapshot.activations
          .any((a) => a.patternId == 'adaptive_creator');
      if (adaptiveActive) {
        adaptiveSimulated++;
        if (adaptiveLineage.length < 3) {
          adaptiveLineage.add(_patternLineage(record, sim, 'adaptive_creator'));
        }
      }

      final stableActive = sim.humanPatternSnapshot.activations
          .any((a) => a.patternId == 'stable_orientation');
      if (stableActive) {
        stableSimulated++;
        if (stableLineage.length < 3) {
          stableLineage.add(_patternLineage(record, sim, 'stable_orientation'));
        }
      }
    }

    return {
      'recoveryRulesEnabled': {
        'MP-001': true,
        'GF2-R001': true,
        'GF2-R002': true,
        'GF2-R003': true,
        'GF2-R004': true,
      },
      'recoveryCounts': {
        'mp001Promotions': mp001Total,
        'gf2SupplementalAgreements_R002': gf2AgreementTotal,
        'gf2SupplementalReinforcements_R001_R003': gf2ReinforcementTotal,
        'gf2R004Reinforcements': r004Total,
      },
      'adaptiveCreator': {
        'baselineActivations': adaptiveBaseline,
        'simulatedActivations': adaptiveSimulated,
        'validated': adaptiveSimulated > 0,
        'lineageSamples': adaptiveLineage,
      },
      'stableOrientation': {
        'baselineActivations': stableBaseline,
        'simulatedActivations': stableSimulated,
        'validated': stableSimulated > 0,
        'lineageSamples': stableLineage,
      },
    };
  }

  static Map<String, dynamic> _patternLineage(
    SyntheticHumanRunRecord record,
    ValidationV2SimulationResult sim,
    String patternId,
  ) {
    final activation = sim.humanPatternSnapshot.activations
        .firstWhere((a) => a.patternId == patternId);
    final fusionFindings = [
      ...sim.composedFusion.agreements.map((f) => f.id),
      ...sim.composedFusion.reinforcements.map((f) => f.id),
    ];
    final evidence = sim.humanPatternSnapshot.evidence
        .where((e) => e.registryPatternId == patternId)
        .take(3)
        .map(
          (e) => {
            'systemId': e.systemId,
            'mirrorKey': e.mirrorKey,
            'mirrorRoleId': e.mirrorRoleId,
            'fusionFindingId': e.fusionFindingId,
            'mirrorFindingId': e.mirrorFindingId,
          },
        )
        .toList();

    return {
      'profileId': record.profile.profileId,
      'patternId': patternId,
      'sourceHumanPatternKey': activation.sourceHumanPatternKey,
      'sourceHumanPatternId': activation.sourceHumanPatternId,
      'composedFusionFindingCount': fusionFindings.length,
      'lineageComplete': fusionFindings.isNotEmpty &&
          activation.sourceHumanPatternId.isNotEmpty,
      'evidenceSample': evidence,
    };
  }

  static Map<String, dynamic> _finalDecision({
    required Map<String, dynamic> validationGates,
    required Map<String, dynamic> v2Sim,
    required Map<String, dynamic> patternRecovery,
    required Map<String, dynamic> lifeDirectionCoverage,
  }) {
    final allPass = validationGates['allGatesPass'] as bool;
    final recommendation = allPass ? 'IMPLEMENT GF2' : 'REJECT GF2';

    return {
      'recommendation': recommendation,
      'allGatesPass': allPass,
      'failedGates': validationGates['failedGates'],
      'adaptiveCreatorValidated':
          patternRecovery['adaptiveCreator']['validated'],
      'stableOrientationValidated':
          patternRecovery['stableOrientation']['validated'],
      'lifeDirectionCoverageProfiles':
          lifeDirectionCoverage['coverageProfiles'],
      'r004Applied': v2Sim['simulatedAfterRecovery']['r004ReinforcementsApplied'],
    };
  }
}
