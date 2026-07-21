import '../domain/human_pattern_snapshot.dart';
import '../domain/pattern_evidence.dart';

abstract final class PatternLineageTrace {
  static Map<String, List<PatternEvidence>> evidenceByPattern(
    HumanPatternSnapshot snapshot,
  ) {
    final grouped = <String, List<PatternEvidence>>{};
    for (final row in snapshot.evidence) {
      grouped.putIfAbsent(row.registryPatternId, () => []).add(row);
    }
    return grouped;
  }

  static List<PatternEvidence> tracePattern({
    required HumanPatternSnapshot snapshot,
    required String registryPatternId,
  }) {
    return snapshot.evidence
        .where((row) => row.registryPatternId == registryPatternId)
        .toList(growable: false);
  }

  static bool hasCompleteLineage(HumanPatternSnapshot snapshot) {
    if (snapshot.activations.isEmpty) return true;

    final grouped = evidenceByPattern(snapshot);
    for (final activation in snapshot.activations) {
      final rows = grouped[activation.patternId];
      if (rows == null || rows.isEmpty) return false;

      for (final row in rows) {
        if (row.fusionFindingId.isEmpty ||
            row.mirrorFindingId.isEmpty ||
            row.sourceThemeId.isEmpty ||
            row.humanModelSnapshotId.isEmpty) {
          return false;
        }
      }
    }

    return true;
  }
}
