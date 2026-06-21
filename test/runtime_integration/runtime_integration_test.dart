import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/runtime_integration/runtime_integration_domain.dart';

void main() {
  group('RT7 Runtime Integration', () {
    late KnowMeRuntimePipelineResult pipelineResult;
    late ArchitectureCoverageReport report;

    setUpAll(() {
      pipelineResult = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      report = ArchitectureCoverageReportBuilder.build(pipelineResult);
    });

    test('creates full snapshot chain from real lens adapters', () {
      expect(pipelineResult.astrologyMirrorSnapshot.snapshotId, isNotEmpty);
      expect(pipelineResult.personalityMirrorSnapshot.snapshotId, isNotEmpty);
      expect(pipelineResult.globalFusionSnapshot.snapshotId, isNotEmpty);
      expect(pipelineResult.humanModelSnapshot.snapshotId, isNotEmpty);
      expect(pipelineResult.humanPatternSnapshot.snapshotId, isNotEmpty);
      expect(pipelineResult.themeCount, greaterThan(0));
    });

    test('uses real personality lens load not synthetic mirror factory', () {
      expect(
        pipelineResult.personalityLensLoad.availableSnapshots,
        isNotEmpty,
      );
      expect(
        pipelineResult.personalityLensLoad.snapshotFor(
          pipelineResult.personalityLensLoad.availableSnapshots.first.lensId,
        )?.available,
        isTrue,
      );
    });

    test('passes runtime pipeline integrity validation', () {
      final validation = RuntimeValidation.validate(pipelineResult);

      expect(validation.snapshotsCreated, isTrue);
      expect(validation.lineageContinuous, isTrue);
      expect(validation.confidencePropagated, isTrue);
      expect(validation.pipelineIntegrityPassed, isTrue);
    });

    test('activates human patterns from real runtime data with BaZi mirror', () {
      final validation = RuntimeValidation.validate(pipelineResult);

      expect(report.activatedPatternCount, greaterThan(0));
      expect(validation.patternsActivated, isTrue);
      expect(report.fusionFindingCount, greaterThan(0));
    });

    test('identifies dead zones without failing pipeline', () {
      expect(report.deadZones.neverActivatedPatternIds, isNotEmpty);
      expect(report.unusedRegistryPatternCount, greaterThan(0));
      expect(report.deadZones.unusedMirrorKeys, isA<List<String>>());
    });

    test('architecture report aggregates layer counts', () {
      expect(report.themeCount, greaterThan(0));
      expect(report.mirrorFindingCount, greaterThan(0));
      expect(report.pipelineIntegrityPassed, isTrue);
      expect(report.validationPassed, isTrue);
      expect(report.toMap()['fusionFindingCount'], isA<int>());
    });

    test('pipeline is deterministic for fixed generatedAt', () {
      final a = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final b = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );

      expect(a.humanPatternSnapshot.snapshotId, b.humanPatternSnapshot.snapshotId);
      expect(a.globalFusionSnapshot.snapshotId, b.globalFusionSnapshot.snapshotId);
    });
  });
}
