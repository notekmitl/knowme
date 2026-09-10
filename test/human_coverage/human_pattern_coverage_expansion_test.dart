import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/human_model/human_model_domain.dart';
import 'package:knowme/features/human_pattern/human_pattern_domain.dart';
import 'package:knowme/features/runtime_integration/runtime_integration_domain.dart';

void main() {
  group('HPC1 Coverage Layer Audit', () {
    test('reports coverage loss at each layer from real runtime', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final snapshot = HumanCoverageSnapshotBuilder.build(
        mirrorSnapshots: [
          pipeline.astrologyMirrorSnapshot,
          pipeline.personalityMirrorSnapshot,
        ],
        fusionSnapshot: pipeline.globalFusionSnapshot,
        humanModelSnapshot: pipeline.humanModelSnapshot,
        humanPatternSnapshot: pipeline.humanPatternSnapshot,
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );

      expect(snapshot.layerAudit.themeCount, greaterThan(0));
      expect(snapshot.layerAudit.mirrorToFusionLossRate, greaterThan(0));
      expect(
        snapshot.layerAudit.themesInFusionEvidence,
        greaterThan(RuntimeThemeMeaningCatalog.supportedThemeIds.length),
      );
      expect(
        snapshot.layerAudit.fusionToMeaningLossRate,
        inInclusiveRange(0, 1),
      );
      expect(snapshot.humanModelPatternCount, greaterThan(2));
    });
  });

  group('HPC2 Theme Mapping Audit', () {
    test('identifies themes without human meaning support', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final snapshot = HumanCoverageSnapshotBuilder.build(
        mirrorSnapshots: [
          pipeline.astrologyMirrorSnapshot,
          pipeline.personalityMirrorSnapshot,
        ],
        fusionSnapshot: pipeline.globalFusionSnapshot,
        humanModelSnapshot: pipeline.humanModelSnapshot,
        humanPatternSnapshot: pipeline.humanPatternSnapshot,
      );

      final supported = RuntimeThemeMeaningCatalog.supportedThemeIds.toSet();
      final fusionThemes = snapshot.themeAudit.themesInFusionEvidence.toSet();
      final expectedGap = fusionThemes.difference(supported).toList()..sort();

      expect(fusionThemes, containsAll(supported));
      expect(snapshot.themeAudit.themesWithMeaningSupport.toSet(), supported);
      expect(snapshot.themeAudit.meaningGapThemeIds, expectedGap);
      expect(expectedGap, isNotEmpty);
      expect(snapshot.themeAudit.unusedThemeIds, isNotEmpty);
    });
  });

  group('HPC3 Pattern Activation Audit', () {
    test('classifies registry patterns by reachability', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final report = PatternActivationReachabilityAudit.analyze(
        humanModelSnapshot: pipeline.humanModelSnapshot,
        humanPatternSnapshot: pipeline.humanPatternSnapshot,
      );

      expect(
        report.totalRegistryPatterns,
        HumanPatternRegistry.allEntries.length,
      );
      expect(report.activated, isNotEmpty);
      expect(
        report.activated.length +
            report.partiallyReachable.length +
            report.unreachable.length,
        report.totalRegistryPatterns,
      );
    });
  });

  group('HPC4 Theme Meaning Expansion', () {
    test('creates theme-derived human patterns from fusion evidence only', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );

      final themePatterns = pipeline.humanModelSnapshot.patterns
          .where((item) => item.fusionFindingType == 'theme_evidence')
          .map((item) => item.patternKey)
          .toSet();

      expect(
        themePatterns,
        containsAll([
          'theme_builder_constructive_force',
          'theme_responsible_accountable_operator',
          'theme_teacher_guiding_influence',
        ]),
      );
    });
  });

  group('HPC5 Activation Density Validation', () {
    test('real runtime exceeds 30 percent activation target', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final report = ActivationDensityValidation.validate(
        pipeline.humanPatternSnapshot,
      );

      expect(report.passed, isTrue);
      expect(report.target30Reached, isTrue);
      expect(report.activationRate, greaterThanOrEqualTo(0.30));
      expect(report.activatedPatternCount, greaterThanOrEqualTo(10));
    });

    test('reports actual progress toward 50 percent target', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final report = ActivationDensityValidation.validate(
        pipeline.humanPatternSnapshot,
      );

      expect(report.target50Reached, isA<bool>());
      if (!report.target50Reached) {
        expect(report.issues.any((item) => item.contains('50%')), isTrue);
      }
    });
  });

  group('HPC6 Coverage Snapshot', () {
    test('builds deterministic coverage snapshot for tracking', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final snapshot = HumanCoverageSnapshotBuilder.build(
        mirrorSnapshots: [
          pipeline.astrologyMirrorSnapshot,
          pipeline.personalityMirrorSnapshot,
        ],
        fusionSnapshot: pipeline.globalFusionSnapshot,
        humanModelSnapshot: pipeline.humanModelSnapshot,
        humanPatternSnapshot: pipeline.humanPatternSnapshot,
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );

      expect(snapshot.version, isNotEmpty);
      expect(snapshot.toMap()['activationRate'], isA<double>());
      expect(snapshot.activatedPatternIds, isNotEmpty);
    });
  });

  group('HPC Mapping Validation', () {
    test('theme mapper only uses runtime catalog entries', () {
      expect(RuntimeThemeMeaningCatalog.entries.length, 3);
      expect(
        RuntimeThemeMeaningCatalog.supportedThemeIds,
        equals(['builder', 'responsible', 'teacher']),
      );
    });

    test('fusion and theme mappings merge without duplicate keys', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final keys = pipeline.humanModelSnapshot.patterns
          .map((item) => item.patternKey)
          .toList();
      expect(keys.length, keys.toSet().length);
    });
  });
}
