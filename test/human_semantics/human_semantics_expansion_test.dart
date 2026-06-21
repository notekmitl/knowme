import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/human_model/human_model_domain.dart';
import 'package:knowme/features/human_pattern/human_pattern_domain.dart';
import 'package:knowme/features/runtime_integration/runtime_integration_domain.dart';

import '../human_model/human_model_test_fixtures.dart';
import '../human_pattern/human_pattern_test_fixtures.dart';

void main() {
  group('HS1 Semantic Source Types', () {
    test('defines four fusion-derived source types', () {
      expect(
        HumanSemanticSourceType.values.map((item) => item.key).toList(),
        containsAll(['agreement', 'tension', 'reinforcement', 'blind_spot']),
      );
    });
  });

  group('HS2 Human Meaning Mapping', () {
    test('maps tension to growth edge for action mirror context', () {
      final mapping = FusionFindingToMeaningMapper.resolve(
        sourceType: HumanSemanticSourceType.tension,
        mirrorKey: 'MIRROR_ACTION_STYLE',
        mirrorDimension: 'action',
      );

      expect(mapping.meaningCategory, HumanMeaningCategory.growthEdge);
      expect(mapping.patternKey, 'tension_action_style_growth_edge');
    });

    test('maps blind spot to hidden potential for relationship mirror', () {
      final mapping = FusionFindingToMeaningMapper.resolve(
        sourceType: HumanSemanticSourceType.blindSpot,
        mirrorKey: 'MIRROR_RELATIONAL_PATTERN',
        mirrorDimension: 'relationships',
      );

      expect(mapping.meaningCategory, HumanMeaningCategory.hiddenPotential);
      expect(
        mapping.patternKey,
        'blind_spot_relational_pattern_hidden_potential',
      );
    });

    test('maps reinforcement to core strength', () {
      final mapping = FusionFindingToMeaningMapper.resolve(
        sourceType: HumanSemanticSourceType.reinforcement,
        mirrorKey: 'MIRROR_GROWTH_ORIENTATION',
        mirrorDimension: 'growth',
      );

      expect(mapping.meaningCategory, HumanMeaningCategory.coreStrength);
    });
  });

  group('HS3 Human Model Expansion', () {
    test('maps multiple fusion finding types to human patterns', () {
      final fusion = HumanModelTestFixtures.fusionSnapshot(seed: 7);
      final mapping = FusionToHumanMapper.map(fusion);
      final types =
          mapping.patterns.map((item) => item.fusionFindingType).toSet();

      expect(mapping.patterns, isNotEmpty);
      expect(types.length, greaterThan(1));
      for (final pattern in mapping.patterns) {
        expect(pattern.fusionFindingIds, isNotEmpty);
        expect(
          HumanSemanticPatternCatalog.byMirrorKeyAndType(
            mirrorKey: pattern.supportingMirrorKeys.first,
            fusionFindingType: pattern.fusionFindingType,
          ),
          isNotNull,
        );
      }
    });

    test('maps blind spot findings from fixture fusion', () {
      final fusion = HumanModelTestFixtures.fusionSnapshot(seed: 5);
      final mapping = FusionToHumanMapper.map(fusion);

      expect(
        mapping.patterns.any((item) => item.fusionFindingType == 'blind_spot'),
        isTrue,
      );
    });
  });

  group('HS4 Human Pattern Expansion', () {
    test('registry includes conflict growth and blind spot families', () {
      final families = HumanPatternRegistry.allEntries
          .map((item) => item.patternFamilyId)
          .toSet();

      expect(families, contains('conflict_pattern'));
      expect(families, contains('growth_edge_pattern'));
      expect(families, contains('blind_spot_pattern'));
    });

    test('semantic registry entries exceed v1 baseline', () {
      expect(HumanPatternRegistry.allEntries.length, greaterThan(25));
    });
  });

  group('HS5 Coverage Validation', () {
    test('real runtime activation rate exceeds zero percent', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final semanticAudit =
          HumanSemanticAudit.analyze(pipeline.globalFusionSnapshot);
      final fusionFindingCount = pipeline.globalFusionSnapshot.agreements.length +
          pipeline.globalFusionSnapshot.tensions.length +
          pipeline.globalFusionSnapshot.reinforcements.length +
          pipeline.globalFusionSnapshot.blindSpots.length;

      final report = HumanSemanticsCoverageValidation.validate(
        humanModelSnapshot: pipeline.humanModelSnapshot,
        humanPatternSnapshot: pipeline.humanPatternSnapshot,
        meaningCoverageRate: semanticAudit.meaningCoverageRate,
        fusionFindingCount: fusionFindingCount,
      );

      expect(report.humanModelPatternCount, greaterThan(0));
      expect(report.activatedPatternCount, greaterThan(0));
      expect(report.activationRate, greaterThan(0));
      expect(report.passed, isTrue, reason: report.issues.join('; '));
    });
  });

  group('HS6 Semantic Audit', () {
    test('reports meaning coverage for fusion findings', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final audit = HumanSemanticAudit.analyze(pipeline.globalFusionSnapshot);

      expect(audit.totalFusionFindings, greaterThan(0));
      expect(audit.meaningCoverageRate, greaterThan(0));
      expect(audit.bySourceType.containsKey('tension'), isTrue);
      expect(audit.bySourceType.containsKey('blind_spot'), isTrue);
    });

    test('achieves full meaning coverage on real runtime fusion output', () {
      final pipeline = KnowMeRuntimePipeline.run(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );
      final audit = HumanSemanticAudit.analyze(pipeline.globalFusionSnapshot);

      expect(audit.mappedFusionFindings, audit.totalFusionFindings);
      expect(audit.meaningCoverageRate, 1.0);
      expect(audit.unmappedFusionFindingIds, isEmpty);
    });
  });

  group('HS Activation Coverage', () {
    test('activates patterns from semantic human model foundation', () {
      final input = HumanPatternTestFixtures.patternInput(seed: 7);
      final snapshot = HumanPatternSnapshotBuilder.build(input);

      expect(snapshot.activations.length, greaterThan(0));
      expect(
        input.humanModelSnapshot.patterns
            .map((item) => item.fusionFindingType)
            .toSet(),
        isNotEmpty,
      );
    });
  });
}
