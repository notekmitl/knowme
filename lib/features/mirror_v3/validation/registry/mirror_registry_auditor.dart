import '../../engine/knowme_mirror_engine.dart';
import '../../enums/knowme_mirror_dimension_id.dart';
import '../../registry/knowme_mirror_registry_v0_1.dart';
import '../fixtures/mirror_synthetic_bundle_factory.dart';
import '../models/mirror_registry_audit_report.dart';

/// MV2.5 registry coverage audit — report only, no registry mutation.
abstract final class MirrorRegistryAuditor {
  static MirrorRegistryAuditReport audit({required int populationCaseCount}) {
    final usageCounts = <String, int>{
      for (final key in MirrorSyntheticBundleFactory.allRegistryKeys()) key: 0,
    };

    final cases = MirrorSyntheticBundleFactory.buildCases(populationCaseCount);
    for (final input in cases) {
      final result = KnowMeMirrorEngine.reflect(input);

      for (final agreement in result.agreements) {
        _increment(usageCounts, agreement.mirrorKey);
      }
      for (final reinforcement in result.reinforcements) {
        _increment(usageCounts, reinforcement.mirrorKey);
      }
      for (final mirror in result.bundle.mirrors) {
        _increment(usageCounts, mirror.mirrorKey);
      }
      for (final blindSpot in result.blindSpots) {
        final key = blindSpot.mirrorKey;
        if (key != null) {
          _increment(usageCounts, key);
        }
      }
    }

    final usedKeys = usageCounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();
    final unusedKeys = usageCounts.entries
        .where((entry) => entry.value == 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();

    final semanticDuplicates = _findSemanticDuplicates();

    return MirrorRegistryAuditReport(
      totalRegistryKeys: KnowMeMirrorRegistryV01.entries.length,
      usedKeys: usedKeys,
      unusedKeys: unusedKeys,
      orphanKeys: unusedKeys,
      keyUsageCounts: Map<String, int>.unmodifiable(usageCounts),
      semanticDuplicates: semanticDuplicates,
      passed: true,
    );
  }

  static void _increment(Map<String, int> counts, String key) {
    if (!counts.containsKey(key)) return;
    counts[key] = counts[key]! + 1;
  }

  static List<MirrorRegistrySemanticDuplicate> _findSemanticDuplicates() {
    final duplicates = <MirrorRegistrySemanticDuplicate>[];

    final byPatternFamily = <String, List<(String key, String dimension)>>{};
    for (final entry in KnowMeMirrorRegistryV01.entries) {
      byPatternFamily
          .putIfAbsent(entry.patternFamily, () => [])
          .add((entry.mirrorKey, entry.mirrorDimension.id));
    }

    for (final entry in byPatternFamily.entries) {
      if (entry.value.length < 2) continue;
      duplicates.add(_duplicateFromEntries(entry.key, entry.value));
    }

    final byDimension = <String, List<String>>{};
    for (final entry in KnowMeMirrorRegistryV01.entries) {
      byDimension
          .putIfAbsent(entry.mirrorDimension.id, () => [])
          .add(entry.mirrorKey);
    }

    for (final entry in byDimension.entries) {
      if (entry.value.length < 2) continue;
      final keys = entry.value.toList()..sort();
      duplicates.add(
        MirrorRegistrySemanticDuplicate(
          patternFamily: 'dimension:${entry.key}',
          mirrorKeys: keys,
          mirrorDimensions: [entry.key],
        ),
      );
    }

    duplicates.sort((a, b) => a.patternFamily.compareTo(b.patternFamily));
    return duplicates;
  }

  static MirrorRegistrySemanticDuplicate _duplicateFromEntries(
    String patternFamily,
    List<(String key, String dimension)> entries,
  ) {
    final keys = entries.map((item) => item.$1).toList()..sort();
    final dimensions = entries.map((item) => item.$2).toSet().toList()..sort();
    return MirrorRegistrySemanticDuplicate(
      patternFamily: patternFamily,
      mirrorKeys: keys,
      mirrorDimensions: dimensions,
    );
  }
}
