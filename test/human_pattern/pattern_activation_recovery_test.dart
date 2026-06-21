import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/human_model/domain/human_dimension.dart';
import 'package:knowme/features/human_model/domain/human_evidence.dart';
import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_model/domain/human_pattern.dart';
import 'package:knowme/features/human_model/domain/human_profile.dart';
import 'package:knowme/features/human_pattern/engines/pattern_activation_engine.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

import 'human_pattern_test_fixtures.dart';

HumanModelSnapshot _snapshotWithPatterns({
  required List<HumanPattern> patterns,
  required List<HumanEvidence> evidence,
}) {
  final base = HumanPatternTestFixtures.humanModelSnapshot(seed: 1);
  return HumanModelSnapshot(
    identity: base.identity,
    profile: HumanProfile(
      dimensions: base.profile.dimensions,
      patterns: patterns,
      activePatternKeys: patterns.map((p) => p.patternKey).toList(),
    ),
    confidence: base.confidence,
    coverage: base.coverage,
    evidence: evidence,
    lineage: base.lineage,
    structuralHash: base.structuralHash,
    createdAt: base.createdAt,
  );
}

HumanPattern _pattern({
  required String id,
  required String key,
  required String fusionFindingType,
  required List<String> mirrorKeys,
  double strength = 0.5,
}) {
  return HumanPattern(
    id: id,
    patternKey: key,
    label: key,
    primaryDimension: HumanDimensionId.meaning,
    secondaryDimensions: const [],
    fusionFindingIds: ['fusion_$id'],
    fusionFindingType: fusionFindingType,
    supportingMirrorKeys: mirrorKeys,
    patternStrength: strength,
  );
}

HumanEvidence _evidence(String patternId, String mirrorKey) {
  return HumanEvidence(
    humanPatternId: patternId,
    fusionFindingId: 'fusion_$patternId',
    mirrorFindingId: 'mirror_$patternId',
    mirrorSnapshotId: 'mirror_snapshot_test',
    mirrorRoleId: 'astrology_mirror',
    sourceThemeId: 'theme_test',
    mirrorKey: mirrorKey,
    systemId: 'knowme_mirror',
    sourceSnapshotId: 'source_snapshot_test',
    themeIds: const ['theme_test'],
    signalIds: const ['signal_test'],
    weight: 0.5,
  );
}

void main() {
  group('HP activation recovery V2 — source selection', () {
    test('stable_orientation resolves reinforcement not agreement on LIFE key', () {
      const mirrorKey = 'MIRROR_LIFE_DIRECTION';
      final agreement = _pattern(
        id: 'hm_agreement',
        key: 'agreement_life_direction_shared_signal',
        fusionFindingType: 'agreement',
        mirrorKeys: [mirrorKey],
        strength: 0.55,
      );
      final reinforcement = _pattern(
        id: 'hm_reinforcement',
        key: 'reinforcement_life_direction_core_strength',
        fusionFindingType: 'reinforcement',
        mirrorKeys: [mirrorKey],
        strength: 0.35,
      );
      final snapshot = _snapshotWithPatterns(
        patterns: [agreement, reinforcement],
        evidence: [
          _evidence(agreement.id, mirrorKey),
          _evidence(reinforcement.id, mirrorKey),
        ],
      );

      final rule = HumanPatternRegistry.byId('stable_orientation')!.activationRule;
      final source = PatternActivationEngine.resolveSourceForAudit(snapshot, rule);

      expect(source?.patternKey, 'reinforcement_life_direction_core_strength');
      expect(source?.fusionFindingType, 'reinforcement');
    });

    test('identity_dual_signal resolves tension not agreement on identity key', () {
      const mirrorKey = 'MIRROR_SELF_IDENTITY';
      final agreement = _pattern(
        id: 'hm_agreement',
        key: 'agreement_identity',
        fusionFindingType: 'agreement',
        mirrorKeys: [mirrorKey],
        strength: 0.5,
      );
      final tension = _pattern(
        id: 'hm_tension',
        key: 'tension_identity',
        fusionFindingType: 'tension',
        mirrorKeys: [mirrorKey],
        strength: 0.4,
      );
      final snapshot = _snapshotWithPatterns(
        patterns: [agreement, tension],
        evidence: [
          _evidence(agreement.id, mirrorKey),
          _evidence(tension.id, mirrorKey),
        ],
      );

      final rule = HumanPatternRegistry.byId('identity_dual_signal')!.activationRule;
      final source = PatternActivationEngine.resolveSourceForAudit(snapshot, rule);

      expect(source?.fusionFindingType, 'tension');
    });

    test('reinforced_strength resolves strongest reinforcement pattern', () {
      final weak = _pattern(
        id: 'hm_weak',
        key: 'reinforcement_weak',
        fusionFindingType: 'reinforcement',
        mirrorKeys: const ['MIRROR_GROWTH_ORIENTATION'],
        strength: 0.25,
      );
      final strong = _pattern(
        id: 'hm_strong',
        key: 'reinforcement_strong',
        fusionFindingType: 'reinforcement',
        mirrorKeys: const ['MIRROR_ACTION_STYLE'],
        strength: 0.6,
      );
      final snapshot = _snapshotWithPatterns(
        patterns: [weak, strong],
        evidence: [
          _evidence(weak.id, 'MIRROR_GROWTH_ORIENTATION'),
          _evidence(strong.id, 'MIRROR_ACTION_STYLE'),
        ],
      );

      final rule = HumanPatternRegistry.byId('reinforced_strength')!.activationRule;
      final source = PatternActivationEngine.resolveSourceForAudit(snapshot, rule);

      expect(source?.id, 'hm_strong');
    });

    test('mirror-only rules still resolve first matching pattern', () {
      const mirrorKey = 'MIRROR_GROWTH_ORIENTATION';
      final pattern = _pattern(
        id: 'hm_growth',
        key: 'growth_pattern',
        fusionFindingType: 'agreement',
        mirrorKeys: [mirrorKey],
      );
      final snapshot = _snapshotWithPatterns(
        patterns: [pattern],
        evidence: [_evidence(pattern.id, mirrorKey)],
      );

      final rule = HumanPatternRegistry.byId('progressive_builder')!.activationRule;
      final source = PatternActivationEngine.resolveSourceForAudit(snapshot, rule);

      expect(source?.patternKey, 'growth_pattern');
    });
  });
}
