import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/human_model/domain/human_dimension.dart';
import 'package:knowme/features/human_pattern/human_pattern_domain.dart';

import 'human_pattern_test_fixtures.dart';

void main() {
  group('HP1 Pattern Taxonomy', () {
    test('registry spans all eight canonical dimensions', () {
      final dimensions = HumanDimensionId.values.map((item) => item.key).toSet();
      final registryDimensions =
          HumanPatternRegistry.allEntries.map((item) => item.dimension.key).toSet();

      expect(registryDimensions, containsAll(dimensions));
      for (final dimension in HumanDimensionId.values) {
        expect(
          HumanPatternRegistry.byDimension(dimension).length,
          greaterThanOrEqualTo(2),
        );
      }
    });

    test('taxonomy groups pattern ids by dimension', () {
      final grouped = HumanPatternTaxonomy.groupByDimension(
        HumanPatternRegistry.allPatternIds,
        (patternId) => HumanPatternRegistry.byId(patternId)?.dimension.key,
      );

      expect(grouped.length, 8);
      expect(grouped.values.every((items) => items.isNotEmpty), isTrue);
    });
  });

  group('HP2 Registry Stability', () {
    test('registry is versioned and deterministic', () {
      expect(HumanPatternRegistry.version, isNotEmpty);
      expect(HumanPatternRegistry.allEntries.length, greaterThanOrEqualTo(24));
      expect(
        HumanPatternRegistry.allPatternIds,
        equals(HumanPatternRegistry.allPatternIds.toList()..sort()),
      );
    });

    test('each entry has structural fields without prose narrative', () {
      for (final entry in HumanPatternRegistry.allEntries) {
        expect(entry.patternId, isNotEmpty);
        expect(entry.label, isNotEmpty);
        expect(entry.description, isNotEmpty);
        expect(entry.activationRule.ruleId, isNotEmpty);
        expect(entry.patternFamilyId, isNotEmpty);
      }
    });
  });

  group('HP4 Pattern Activation', () {
    test('activates registry patterns deterministically from human model', () {
      final input = HumanPatternTestFixtures.patternInput(seed: 4);
      final a = HumanPatternSnapshotBuilder.build(
        input,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final b = HumanPatternSnapshotBuilder.build(
        input,
        createdAt: DateTime.utc(2026, 12, 31),
      );

      expect(a.snapshotId, b.snapshotId);
      expect(a.activations.map((item) => item.patternId).toList(),
          b.activations.map((item) => item.patternId).toList());
    });
  });

  group('HP5 Pattern Confidence', () {
    test('confidence is composed not human model passthrough', () {
      final input = HumanPatternTestFixtures.patternInput(seed: 5);
      final snapshot = HumanPatternSnapshotBuilder.build(input);

      expect(
        snapshot.confidence.composite,
        isNot(input.humanModelSnapshot.confidence.composite),
      );

      if (snapshot.activations.isNotEmpty) {
        final activation = snapshot.activations.first;
        expect(activation.confidence.humanInfluenceScore, greaterThanOrEqualTo(0));
        expect(activation.confidence.activationStrengthScore, greaterThan(0));
      }
    });
  });

  group('HP6 Pattern Evidence Lineage', () {
    test('traces registry pattern to fusion mirror and theme', () {
      final snapshot = HumanPatternSnapshotBuilder.build(
        HumanPatternTestFixtures.patternInput(seed: 6),
      );

      if (snapshot.activations.isEmpty) return;

      final activation = snapshot.activations.first;
      final trace = PatternLineageTrace.tracePattern(
        snapshot: snapshot,
        registryPatternId: activation.patternId,
      );

      expect(trace, isNotEmpty);
      expect(trace.every((row) => row.humanModelSnapshotId.isNotEmpty), isTrue);
      expect(trace.every((row) => row.fusionFindingId.isNotEmpty), isTrue);
      expect(trace.every((row) => row.mirrorFindingId.isNotEmpty), isTrue);
      expect(trace.every((row) => row.sourceThemeId.isNotEmpty), isTrue);
    });

    test('codec round-trip preserves structural fields', () {
      final original = HumanPatternSnapshotBuilder.build(
        HumanPatternTestFixtures.patternInput(seed: 7),
      );
      final restored = HumanPatternSnapshot.fromMap(original.toMap());

      expect(restored.snapshotId, original.snapshotId);
      expect(restored.activations.length, original.activations.length);
    });
  });

  group('HP7 Pattern Validation', () {
    test('audit passes for foundation-built snapshot', () {
      final snapshot = HumanPatternSnapshotBuilder.build(
        HumanPatternTestFixtures.patternInput(seed: 8),
      );
      final report = HumanPatternValidation.audit(snapshot);

      expect(report.duplicatePatterns, isFalse);
      if (snapshot.activations.isNotEmpty) {
        expect(report.orphanPatterns, isFalse);
      }
    });

    test('validation harness passes determinism lineage and registry checks', () {
      final result = HumanPatternValidationHarness.run(
        HumanPatternTestFixtures.patternInput(seed: 8),
      );

      expect(result.passed, isTrue, reason: result.issues.join('; '));
    });
  });

  group('HP8 Pattern Snapshot', () {
    test('snapshot is narrative-ready immutable output', () {
      final snapshot = HumanPatternSnapshotBuilder.build(
        HumanPatternTestFixtures.patternInput(seed: 2),
      );

      expect(snapshot.identity.registryVersion, HumanPatternRegistry.version);
      expect(snapshot.lineage.sourceGlobalFusionSnapshotId, isNotEmpty);
      expect(
        snapshot.coverage.registryPatternCount,
        HumanPatternRegistry.allEntries.length,
      );
    });
  });
}
