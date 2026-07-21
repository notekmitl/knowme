import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/v2/global_fusion_v2_domain.dart';
import 'package:knowme/features/runtime_integration/runtime_integration_domain.dart';

void main() {
  group('FCR1 Fusion Coverage Audit', () {
    test('identifies fused vs filtered mirror findings on real runtime', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final input = _runtimeInput(pipeline);
      final result = GlobalFusionCoverageRecoveryBuilder.build(
        input: input,
        foundationSnapshot: pipeline.globalFusionSnapshot,
      );

      expect(result.coverageAudit.totalMirrorFindings, greaterThan(10));
      expect(result.coverageAudit.fusedCount, greaterThan(0));
      expect(result.coverageAudit.filteredCount, greaterThan(0));
      expect(
        result.coverageAudit.fusedCount + result.coverageAudit.filteredCount,
        result.coverageAudit.totalMirrorFindings,
      );
    });
  });

  group('FCR2 Fusion Compression Audit', () {
    test('classifies over-compression from cross-mirror agreement gate', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final result = GlobalFusionCoverageRecoveryBuilder.build(
        input: _runtimeInput(pipeline),
        foundationSnapshot: pipeline.globalFusionSnapshot,
      );

      expect(result.compressionAudit.compressionRate, greaterThan(0.65));
      expect(result.compressionAudit.overCompressionCount, greaterThan(0));
      expect(result.compressionAudit.rules, isNotEmpty);
    });
  });

  group('FCR3 Recoverable Findings', () {
    test('groups recoverable findings by risk level', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final result = GlobalFusionCoverageRecoveryBuilder.build(
        input: _runtimeInput(pipeline),
        foundationSnapshot: pipeline.globalFusionSnapshot,
      );

      expect(result.recoverableAudit.lowRisk, isNotEmpty);
      expect(result.recoverableAudit.totalRecoverable, greaterThan(0));
    });
  });

  group('FCR4 Coverage Recovery Layer', () {
    test('creates supplemental findings without modifying V1 snapshot', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final beforeId = pipeline.globalFusionSnapshot.snapshotId;
      final result = GlobalFusionCoverageRecoveryBuilder.build(
        input: _runtimeInput(pipeline),
        foundationSnapshot: pipeline.globalFusionSnapshot,
      );

      expect(result.recoveredSnapshot.foundationSnapshot.snapshotId, beforeId);
      expect(result.recoveredSnapshot.supplementalFindingCount, greaterThan(0));
      expect(result.recoveredSnapshot.supplementalReinforcements, isNotEmpty);
    });
  });

  group('FCR5 Runtime Simulation', () {
    test('improves fusion theme coverage and pattern activations', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final simulation = FusionRecoveryRuntimeSimulation.run(
        mirrorSnapshots: [
          pipeline.astrologyMirrorSnapshot,
          pipeline.personalityMirrorSnapshot,
        ],
        mirrorRoleIds: [
          GlobalFusionMirrorRoles.astrology,
          GlobalFusionMirrorRoles.personality,
        ],
        foundationSnapshot: pipeline.globalFusionSnapshot,
        baselineHumanModelSnapshot: pipeline.humanModelSnapshot,
        baselineHumanPatternSnapshot: pipeline.humanPatternSnapshot,
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );

      final report = simulation.comparativeReport;

      expect(report.beforeFusionThemeCount, greaterThan(0));
      expect(report.afterFusionThemeCount, greaterThan(report.beforeFusionThemeCount));
      expect(report.afterFusionFindings, greaterThan(report.beforeFusionFindings));
      expect(report.afterHumanMeanings, greaterThan(report.beforeHumanMeanings));
      expect(
        report.afterPatternActivations,
        greaterThan(report.beforePatternActivations),
      );
      expect(report.afterActivationRate, greaterThan(report.beforeActivationRate));
    });
  });

  group('FCR6 Comparative Report', () {
    test('reports before and after metrics on real runtime', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final simulation = FusionRecoveryRuntimeSimulation.run(
        mirrorSnapshots: [
          pipeline.astrologyMirrorSnapshot,
          pipeline.personalityMirrorSnapshot,
        ],
        mirrorRoleIds: [
          GlobalFusionMirrorRoles.astrology,
          GlobalFusionMirrorRoles.personality,
        ],
        foundationSnapshot: pipeline.globalFusionSnapshot,
        baselineHumanModelSnapshot: pipeline.humanModelSnapshot,
        baselineHumanPatternSnapshot: pipeline.humanPatternSnapshot,
      );

      final map = simulation.comparativeReport.toMap();
      expect(map['beforeFusionThemeCount'], isA<int>());
      expect(map['afterFusionThemeCount'], isA<int>());
      expect(map['activationImprovementRate'], isA<double>());
    });
  });

  group('FCR Validation', () {
    test('composed snapshot preserves V1 tensions and blind spots', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final recovery = GlobalFusionCoverageRecoveryBuilder.build(
        input: _runtimeInput(pipeline),
        foundationSnapshot: pipeline.globalFusionSnapshot,
      );
      final composed = GlobalFusionRecoveryComposer.composeForSimulation(
        input: _runtimeInput(pipeline),
        recovered: recovery.recoveredSnapshot,
      );

      expect(composed.tensions.length, pipeline.globalFusionSnapshot.tensions.length);
      expect(composed.blindSpots.length, pipeline.globalFusionSnapshot.blindSpots.length);
      expect(composed.reinforcements.length, greaterThan(
        pipeline.globalFusionSnapshot.reinforcements.length,
      ));
    });
  });
}

GlobalFusionInput _runtimeInput(dynamic pipeline) {
  return GlobalFusionInput(
    mirrors: [
      GlobalFusionMirrorRef(
        mirrorRoleId: GlobalFusionMirrorRoles.astrology,
        snapshot: pipeline.astrologyMirrorSnapshot,
      ),
      GlobalFusionMirrorRef(
        mirrorRoleId: GlobalFusionMirrorRoles.personality,
        snapshot: pipeline.personalityMirrorSnapshot,
      ),
    ],
  );
}
