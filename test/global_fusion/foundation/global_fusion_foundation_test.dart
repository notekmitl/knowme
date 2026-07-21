import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/global_fusion/foundation/global_fusion_foundation_domain.dart';

import 'global_fusion_mirror_snapshot_fixtures.dart';

void main() {
  group('GF Foundation Identity', () {
    test('snapshotId is deterministic for same mirror snapshot inputs', () {
      final input = GlobalFusionMirrorSnapshotFixtures.dualMirrorInput(seed: 3);
      final a = GlobalFusionFoundationBuilder.build(
        input,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final b = GlobalFusionFoundationBuilder.build(
        input,
        createdAt: DateTime.utc(2026, 12, 31),
      );

      expect(a.snapshotId, b.snapshotId);
      expect(a.structuralHash, b.structuralHash);
      expect(a.createdAt, isNot(b.createdAt));
    });
  });

  group('GF Foundation Engines', () {
    test('detects cross-mirror agreements from mirror snapshots only', () {
      final input = GlobalFusionMirrorSnapshotFixtures.dualMirrorInput(seed: 4);
      final snapshot = GlobalFusionFoundationBuilder.build(input);

      expect(snapshot.coverage.mirrorCount, 2);
      expect(snapshot.lineage.sourceMirrorSnapshotIds.length, 2);
      if (snapshot.agreements.isNotEmpty) {
        final agreement = snapshot.agreements.first;
        expect(agreement.mirrorRoleIds.length, greaterThanOrEqualTo(2));
      }
    });

    test('supports N mirror inputs without hardcoded pair limit', () {
      final input = GlobalFusionMirrorSnapshotFixtures.nMirrorInput([0, 1, 5]);
      final snapshot = GlobalFusionFoundationBuilder.build(input);

      expect(snapshot.coverage.mirrorCount, 3);
      expect(snapshot.coverage.mirrorRoleIds, isNotEmpty);
    });
  });

  group('GF Foundation Confidence', () {
    test('composite is composed not averaged from mirror confidences', () {
      final input = GlobalFusionMirrorSnapshotFixtures.dualMirrorInput(seed: 2);
      final snapshot = GlobalFusionFoundationBuilder.build(input);

      final mirrorAverage = input.mirrors
              .map((ref) => ref.snapshot.confidence.composite)
              .reduce((a, b) => a + b) /
          input.mirrorCount;

      expect(snapshot.confidence.mirrorDiversityScore, greaterThan(0));
      expect(snapshot.confidence.evidenceDepthScore, greaterThanOrEqualTo(0));
      expect(snapshot.confidence.composite, isNot(mirrorAverage));
    });

    test('confidence monotonicity when adding mirrors', () {
      final dual = GlobalFusionMirrorSnapshotFixtures.dualMirrorInput(seed: 1);
      final partial = GlobalFusionInput(mirrors: [dual.mirrors.first]);
      final expanded = dual;

      final partialSnapshot = GlobalFusionFoundationBuilder.build(partial);
      final expandedSnapshot = GlobalFusionFoundationBuilder.build(expanded);

      expect(
        expandedSnapshot.confidence.composite,
        greaterThanOrEqualTo(partialSnapshot.confidence.composite),
      );
    });
  });

  group('GF Foundation Lineage', () {
    test('preserves global finding to mirror evidence trace', () {
      final input = GlobalFusionMirrorSnapshotFixtures.dualMirrorInput(seed: 6);
      final snapshot = GlobalFusionFoundationBuilder.build(input);

      if (snapshot.agreements.isEmpty) return;

      final agreement = snapshot.agreements.first;
      final trace = GlobalFusionLineageTrace.traceFinding(
        snapshot: snapshot,
        globalFindingId: agreement.id,
      );

      expect(trace, isNotEmpty);
      expect(trace.every((row) => row.mirrorSnapshotId.isNotEmpty), isTrue);
      expect(trace.every((row) => row.sourceThemeId.isNotEmpty), isTrue);
    });

    test('codec round-trip preserves structural fields', () {
      final input = GlobalFusionMirrorSnapshotFixtures.dualMirrorInput(seed: 7);
      final original = GlobalFusionFoundationBuilder.build(input);
      final restored = GlobalFusionSnapshot.fromMap(original.toMap());

      expect(restored.snapshotId, original.snapshotId);
      expect(restored.structuralHash, original.structuralHash);
      expect(restored.evidence.length, original.evidence.length);
    });
  });

  group('GF Foundation Validation Harness', () {
    test('passes determinism lineage and monotonicity checks', () {
      final input = GlobalFusionMirrorSnapshotFixtures.dualMirrorInput(seed: 8);
      final result = GlobalFusionValidationHarness.run(input);

      expect(result.passed, isTrue, reason: result.issues.join('; '));
      expect(result.snapshot.identity.sourceMirrorSnapshotIds.length, 2);
    });
  });
}
