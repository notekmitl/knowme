import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/mirror_v3/engine/knowme_mirror_engine.dart';
import 'package:knowme/features/mirror_v3/snapshot/audit/mirror_snapshot_audit.dart';
import 'package:knowme/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart';
import 'package:knowme/features/mirror_v3/snapshot/codec/knowme_mirror_snapshot_codec.dart';
import 'package:knowme/features/mirror_v3/snapshot/consumers/ai_narrative_mirror_snapshot_consumer.dart';
import 'package:knowme/features/mirror_v3/snapshot/consumers/analytics_mirror_snapshot_consumer.dart';
import 'package:knowme/features/mirror_v3/snapshot/consumers/global_fusion_mirror_snapshot_consumer.dart';
import 'package:knowme/features/mirror_v3/snapshot/consumers/home_mirror_snapshot_consumer.dart';
import 'package:knowme/features/mirror_v3/snapshot/consumers/mirror_snapshot_consumer.dart';
import 'package:knowme/features/mirror_v3/snapshot/lineage/mirror_snapshot_lineage_trace.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot_identity.dart';
import 'package:knowme/features/mirror_v3/snapshot/regeneration/mirror_snapshot_regeneration_rules.dart';
import 'package:knowme/features/mirror_v3/validation/fixtures/mirror_synthetic_bundle_factory.dart';

KnowMeMirrorSnapshot _buildSnapshot(int caseIndex) {
  final input = MirrorSyntheticBundleFactory.buildCase(caseIndex);
  final result = KnowMeMirrorEngine.reflect(input);
  return KnowMeMirrorSnapshotBuilder.fromEngineResult(
    result,
    createdAt: DateTime.utc(2026, 6, 21, caseIndex),
  );
}

class _TestHomeConsumer extends HomeMirrorSnapshotConsumer {
  @override
  bool canConsume(KnowMeMirrorSnapshot snapshot) =>
      snapshot.metadata.mirrorCount > 0;

  @override
  List<String> topMirrorKeys(KnowMeMirrorSnapshot snapshot) {
    return snapshot.evidence.map((row) => row.mirrorKey).toSet().toList()
      ..sort();
  }

  @override
  String coverageTier(KnowMeMirrorSnapshot snapshot) {
    if (snapshot.coverage.weightedCoverage >= 0.85) return 'high';
    if (snapshot.coverage.weightedCoverage >= 0.6) return 'medium';
    return 'low';
  }
}

class _TestFusionConsumer extends GlobalFusionMirrorSnapshotConsumer {
  @override
  bool canConsume(KnowMeMirrorSnapshot snapshot) =>
      snapshot.agreements.isNotEmpty;

  @override
  List<String> fusionThemeCandidates(KnowMeMirrorSnapshot snapshot) {
    return snapshot.agreements.expand((item) => item.themeIds).toSet().toList()
      ..sort();
  }

  @override
  List<(String, String)> tensionThemePairs(KnowMeMirrorSnapshot snapshot) {
    return [
      for (final tension in snapshot.tensions)
        if (tension.themeIds.length >= 2)
          (tension.themeIds[0], tension.themeIds[1]),
    ];
  }
}

class _TestAnalyticsConsumer extends AnalyticsMirrorSnapshotConsumer {
  @override
  bool canConsume(KnowMeMirrorSnapshot snapshot) => true;

  @override
  Map<String, num> metricPayload(KnowMeMirrorSnapshot snapshot) {
    return {
      'mirrorCount': snapshot.metadata.mirrorCount,
      'findingCount': snapshot.metadata.findingCount,
      'confidence': snapshot.confidence.composite,
    };
  }
}

class _TestAiConsumer extends AiNarrativeMirrorSnapshotConsumer {
  @override
  bool canConsume(KnowMeMirrorSnapshot snapshot) =>
      snapshot.evidence.isNotEmpty;

  @override
  Map<String, List<String>> explainabilityIndex(
    KnowMeMirrorSnapshot snapshot,
  ) {
    return {
      for (final agreement in snapshot.agreements)
        agreement.id: agreement.themeIds,
    };
  }
}

void main() {
  group('MV3 Snapshot Identity', () {
    test('snapshotId is stable for same engine input', () {
      final a = _buildSnapshot(7);
      final b = _buildSnapshot(7);

      expect(a.snapshotId, b.snapshotId);
      expect(a.structuralHash, b.structuralHash);
      expect(a.mirrorBundleId, b.mirrorBundleId);
    });

    test('createdAt does not affect snapshotId', () {
      final input = MirrorSyntheticBundleFactory.buildCase(3);
      final result = KnowMeMirrorEngine.reflect(input);

      final early = KnowMeMirrorSnapshotBuilder.fromEngineResult(
        result,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final late = KnowMeMirrorSnapshotBuilder.fromEngineResult(
        result,
        createdAt: DateTime.utc(2026, 12, 31),
      );

      expect(early.snapshotId, late.snapshotId);
      expect(early.createdAt, isNot(late.createdAt));
    });
  });

  group('MV3 Snapshot Codec', () {
    test('map and json round-trip preserves structural fields', () {
      final original = _buildSnapshot(12);
      final restored = KnowMeMirrorSnapshotCodec.fromMap(
        KnowMeMirrorSnapshotCodec.toMap(original),
      );
      final jsonRestored = KnowMeMirrorSnapshotCodec.fromJson(
        KnowMeMirrorSnapshotCodec.toJson(original),
      );

      expect(restored.snapshotId, original.snapshotId);
      expect(restored.structuralHash, original.structuralHash);
      expect(restored.agreements.length, original.agreements.length);
      expect(jsonRestored.evidence.length, original.evidence.length);
    });
  });

  group('MV3 Snapshot Lineage', () {
    test('preserves source snapshot ids and evidence trace rows', () {
      final snapshot = _buildSnapshot(2);

      expect(snapshot.lineage.mirrorScopeId, isNotEmpty);
      expect(snapshot.lineage.sourceSnapshotVersions, isNotEmpty);
      expect(snapshot.evidence, isNotEmpty);
      expect(
        snapshot.evidence.every((row) => row.sourceSnapshotId.isNotEmpty),
        isTrue,
      );
    });

    test('finding trace resolves theme lens and mirror evidence', () {
      final snapshot = _buildSnapshot(5);
      final lenses = MirrorSnapshotLineageTrace.lensBySystem(snapshot);
      final byMirrorKey =
          MirrorSnapshotLineageTrace.evidenceByMirrorKey(snapshot);

      expect(lenses, isNotEmpty);
      expect(byMirrorKey, isNotEmpty);

      if (snapshot.agreements.isNotEmpty) {
        final agreement = snapshot.agreements.first;
        final trace = MirrorSnapshotLineageTrace.evidenceForFinding(
          snapshot: snapshot,
          findingId: agreement.id,
          themeIds: agreement.themeIds,
          mirrorKey: agreement.mirrorKey,
        );
        expect(trace, isNotEmpty);
      }
    });
  });

  group('MV3 Snapshot Audit', () {
    test('passes for engine-built snapshot', () {
      final snapshot = _buildSnapshot(9);
      final report = MirrorSnapshotAudit.audit(snapshot);

      expect(report.passed, isTrue);
      expect(report.issues, isEmpty);
      expect(report.invalidIdentity, isFalse);
    });

    test('detects invalid identity when snapshotId is corrupted', () {
      final snapshot = _buildSnapshot(9);
      final corrupted = KnowMeMirrorSnapshot(
        identity: KnowMeMirrorSnapshotIdentity(
          snapshotId: 'corrupted-id',
          mirrorId: snapshot.mirrorId,
          mirrorBundleId: snapshot.mirrorBundleId,
          mirrorScopeId: snapshot.identity.mirrorScopeId,
          mirrorObjectIds: snapshot.identity.mirrorObjectIds,
          snapshotVersion: snapshot.snapshotVersion,
        ),
        metadata: snapshot.metadata,
        coverage: snapshot.coverage,
        confidence: snapshot.confidence,
        agreements: snapshot.agreements,
        tensions: snapshot.tensions,
        reinforcements: snapshot.reinforcements,
        blindSpots: snapshot.blindSpots,
        evidence: snapshot.evidence,
        promotedFindings: snapshot.promotedFindings,
        lineage: snapshot.lineage,
        structuralHash: snapshot.structuralHash,
        createdAt: snapshot.createdAt,
        engineVersion: snapshot.engineVersion,
      );

      final report = MirrorSnapshotAudit.audit(corrupted);
      expect(report.invalidIdentity, isTrue);
      expect(report.passed, isFalse);
    });
  });

  group('MV3 Regeneration Rules', () {
    test('rejects when validation failed', () {
      final decision = MirrorSnapshotRegenerationRules.evaluate(
        currentSources: const MirrorSnapshotSourceFingerprint(
          mbtiLensSnapshotId: 'mbti-1',
        ),
        existingSources: null,
        currentEngineVersion: 'v0.1.0',
        existingEngineVersion: null,
        currentStructuralHash: 'hash-a',
        existingStructuralHash: null,
        validationPassed: false,
      );

      expect(decision.shouldReject, isTrue);
      expect(decision.reason, MirrorSnapshotRegenerationReason.validationFailure);
    });

    test('regenerates on theme change', () {
      final decision = MirrorSnapshotRegenerationRules.evaluate(
        currentSources: const MirrorSnapshotSourceFingerprint(
          mbtiLensSnapshotId: 'mbti-2',
        ),
        existingSources: const MirrorSnapshotSourceFingerprint(
          mbtiLensSnapshotId: 'mbti-1',
        ),
        currentEngineVersion: 'v0.1.0',
        existingEngineVersion: 'v0.1.0',
        currentStructuralHash: 'hash-a',
        existingStructuralHash: 'hash-a',
        validationPassed: true,
      );

      expect(decision.shouldRegenerate, isTrue);
      expect(decision.reason, MirrorSnapshotRegenerationReason.themeChange);
    });

    test('regenerates on structural hash change', () {
      final decision = MirrorSnapshotRegenerationRules.evaluate(
        currentSources: const MirrorSnapshotSourceFingerprint(
          mbtiLensSnapshotId: 'mbti-1',
        ),
        existingSources: const MirrorSnapshotSourceFingerprint(
          mbtiLensSnapshotId: 'mbti-1',
        ),
        currentEngineVersion: 'v0.1.0',
        existingEngineVersion: 'v0.1.0',
        currentStructuralHash: 'hash-b',
        existingStructuralHash: 'hash-a',
        validationPassed: true,
      );

      expect(decision.shouldRegenerate, isTrue);
      expect(
        decision.reason,
        MirrorSnapshotRegenerationReason.structuralHashChange,
      );
    });
  });

  group('MV3 Consumer Compatibility', () {
    test('consumer contracts accept structural snapshot payloads', () {
      final snapshot = _buildSnapshot(5);
      final consumers = <MirrorSnapshotConsumer>[
        _TestHomeConsumer(),
        _TestFusionConsumer(),
        _TestAnalyticsConsumer(),
        _TestAiConsumer(),
      ];

      for (final consumer in consumers) {
        expect(consumer.consumerId, isNotEmpty);
        if (consumer.canConsume(snapshot)) {
          switch (consumer) {
            case HomeMirrorSnapshotConsumer home:
              expect(home.topMirrorKeys(snapshot), isNotEmpty);
            case GlobalFusionMirrorSnapshotConsumer fusion:
              expect(fusion.fusionThemeCandidates(snapshot), isA<List<String>>());
            case AnalyticsMirrorSnapshotConsumer analytics:
              expect(analytics.metricPayload(snapshot)['confidence'], isA<num>());
            case AiNarrativeMirrorSnapshotConsumer ai:
              expect(ai.explainabilityIndex(snapshot), isA<Map>());
          }
        }
      }
    });
  });
}
