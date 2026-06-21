import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/human_model/human_model_domain.dart';

import 'human_model_test_fixtures.dart';

void main() {
  group('HM2 Canonical Dimensions', () {
    test('catalog contains eight discipline-neutral dimensions', () {
      expect(HumanDimensionCatalog.dimensions.length, 8);
      expect(
        HumanDimensionCatalog.dimensions.map((item) => item.key).toList(),
        containsAll([
          'identity',
          'motivation',
          'thinking',
          'emotion',
          'relationship',
          'action',
          'growth',
          'meaning',
        ]),
      );
    });
  });

  group('HM Foundation Identity', () {
    test('snapshotId is deterministic for same fusion input', () {
      final input = HumanModelTestFixtures.humanModelInput(seed: 3);
      final early = HumanModelFoundationBuilder.build(
        input,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final late = HumanModelFoundationBuilder.build(
        input,
        createdAt: DateTime.utc(2026, 12, 31),
      );

      expect(early.snapshotId, late.snapshotId);
      expect(early.structuralHash, late.structuralHash);
    });
  });

  group('HM4 Fusion Mapping', () {
    test('maps fusion findings to human patterns with trace ids', () {
      final fusion = HumanModelTestFixtures.fusionSnapshot(seed: 4);
      final mapping = FusionToHumanMapper.map(fusion);

      for (final pattern in mapping.patterns) {
        expect(pattern.fusionFindingIds, isNotEmpty);
        expect(mapping.fusionFindingByPatternId[pattern.id], isNotNull);
        expect(
          HumanSemanticPatternCatalog.byMirrorKeyAndType(
            mirrorKey: pattern.supportingMirrorKeys.first,
            fusionFindingType: pattern.fusionFindingType,
          ),
          isNotNull,
        );
      }
    });
  });

  group('HM5 Human Confidence', () {
    test('composite is composed not equal to fusion composite', () {
      final input = HumanModelTestFixtures.humanModelInput(seed: 5);
      final snapshot = HumanModelFoundationBuilder.build(input);

      expect(
        snapshot.confidence.composite,
        isNot(input.fusionSnapshot.confidence.composite),
      );
      expect(snapshot.confidence.fusionInfluenceScore, greaterThanOrEqualTo(0));
      expect(snapshot.confidence.evidenceDiversityScore, greaterThanOrEqualTo(0));
    });
  });

  group('HM6 Lineage', () {
    test('preserves pattern to fusion to mirror to theme chain', () {
      final snapshot = HumanModelFoundationBuilder.build(
        HumanModelTestFixtures.humanModelInput(seed: 6),
      );

      if (snapshot.patterns.isEmpty) return;

      final pattern = snapshot.patterns.first;
      final trace = HumanLineageTrace.tracePattern(
        snapshot: snapshot,
        humanPatternId: pattern.id,
      );

      expect(trace, isNotEmpty);
      expect(trace.every((row) => row.fusionFindingId.isNotEmpty), isTrue);
      expect(trace.every((row) => row.mirrorFindingId.isNotEmpty), isTrue);
      expect(trace.every((row) => row.sourceThemeId.isNotEmpty), isTrue);
    });

    test('codec round-trip preserves structural fields', () {
      final original = HumanModelFoundationBuilder.build(
        HumanModelTestFixtures.humanModelInput(seed: 7),
      );
      final restored = HumanModelSnapshot.fromMap(original.toMap());

      expect(restored.snapshotId, original.snapshotId);
      expect(restored.profile.patternCount, original.profile.patternCount);
    });
  });

  group('HM7 Validation', () {
    test('audit passes for foundation-built snapshot', () {
      final snapshot = HumanModelFoundationBuilder.build(
        HumanModelTestFixtures.humanModelInput(seed: 8),
      );
      final report = HumanModelValidation.audit(snapshot);

      expect(report.invalidCoverage, isFalse);
      expect(report.duplicatePatterns, isFalse);
      if (snapshot.patterns.isNotEmpty) {
        expect(report.orphanPatterns, isFalse);
        expect(report.incompleteLineage, isFalse);
      }
    });

    test('validation harness passes determinism and lineage checks', () {
      final result = HumanModelValidationHarness.run(
        HumanModelTestFixtures.humanModelInput(seed: 8),
      );

      expect(result.passed, isTrue, reason: result.issues.join('; '));
    });
  });

  group('HM8 Snapshot', () {
    test('snapshot is immutable narrative-ready foundation output', () {
      final snapshot = HumanModelFoundationBuilder.build(
        HumanModelTestFixtures.humanModelInput(seed: 2),
      );

      expect(snapshot.identity.sourceGlobalFusionSnapshotId, isNotEmpty);
      expect(snapshot.lineage.foundationVersion, isNotEmpty);
      expect(snapshot.profile.dimensions.length, 8);
    });
  });
}
