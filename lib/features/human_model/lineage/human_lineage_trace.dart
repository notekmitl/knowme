import '../domain/human_evidence.dart';
import '../domain/human_model_snapshot.dart';

/// HM6 lineage trace helpers.
abstract final class HumanLineageTrace {
  static Map<String, List<HumanEvidence>> evidenceByPattern(
    HumanModelSnapshot snapshot,
  ) {
    final grouped = <String, List<HumanEvidence>>{};
    for (final row in snapshot.evidence) {
      grouped.putIfAbsent(row.humanPatternId, () => []).add(row);
    }
    return grouped;
  }

  static List<HumanEvidence> tracePattern({
    required HumanModelSnapshot snapshot,
    required String humanPatternId,
  }) {
    return snapshot.evidence
        .where((row) => row.humanPatternId == humanPatternId)
        .toList(growable: false);
  }

  static bool hasCompleteLineage(HumanModelSnapshot snapshot) {
    if (snapshot.patterns.isEmpty) return true;

    final grouped = evidenceByPattern(snapshot);
    for (final pattern in snapshot.patterns) {
      final rows = grouped[pattern.id];
      if (rows == null || rows.isEmpty) return false;

      for (final row in rows) {
        if (row.fusionFindingId.isEmpty ||
            row.mirrorFindingId.isEmpty ||
            row.sourceThemeId.isEmpty) {
          return false;
        }
      }
    }

    return true;
  }
}
