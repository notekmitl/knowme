import '../domain/global_fusion_evidence.dart';
import '../domain/global_fusion_snapshot.dart';

/// GF8 lineage trace helpers for global fusion consumers.
abstract final class GlobalFusionLineageTrace {
  static Map<String, List<GlobalFusionEvidence>> evidenceByFinding(
    GlobalFusionSnapshot snapshot,
  ) {
    final grouped = <String, List<GlobalFusionEvidence>>{};
    for (final row in snapshot.evidence) {
      grouped.putIfAbsent(row.globalFindingId, () => []).add(row);
    }
    return grouped;
  }

  static List<GlobalFusionEvidence> traceFinding({
    required GlobalFusionSnapshot snapshot,
    required String globalFindingId,
  }) {
    return snapshot.evidence
        .where((row) => row.globalFindingId == globalFindingId)
        .toList(growable: false);
  }

  static bool hasCompleteLineage(GlobalFusionSnapshot snapshot) {
    final findingIds = <String>{
      ...snapshot.agreements.map((item) => item.id),
      ...snapshot.tensions.map((item) => item.id),
      ...snapshot.reinforcements.map((item) => item.id),
      ...snapshot.blindSpots.map((item) => item.id),
    };

    if (findingIds.isEmpty) return true;

    final grouped = evidenceByFinding(snapshot);
    for (final findingId in findingIds) {
      final rows = grouped[findingId];
      if (rows == null || rows.isEmpty) return false;
      if (rows.any((row) => row.mirrorSnapshotId.isEmpty)) return false;
      if (rows.any((row) => row.sourceThemeId.isEmpty)) return false;
    }

    return true;
  }
}
