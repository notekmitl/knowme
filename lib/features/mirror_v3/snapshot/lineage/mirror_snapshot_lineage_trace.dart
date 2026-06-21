import '../models/knowme_mirror_snapshot.dart';
import '../models/knowme_mirror_snapshot_evidence.dart';

/// MV3.5 finding → evidence trace index for Global Fusion explainability.
abstract final class MirrorSnapshotLineageTrace {
  static Map<String, List<KnowMeMirrorSnapshotEvidenceRow>> evidenceByMirrorKey(
    KnowMeMirrorSnapshot snapshot,
  ) {
    final grouped = <String, List<KnowMeMirrorSnapshotEvidenceRow>>{};

    for (final row in snapshot.evidence) {
      grouped.putIfAbsent(row.mirrorKey, () => []).add(row);
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        final themeCompare = a.sourceThemeId.compareTo(b.sourceThemeId);
        if (themeCompare != 0) return themeCompare;
        return a.mirrorObjectId.compareTo(b.mirrorObjectId);
      });
    }

    return grouped;
  }

  static List<KnowMeMirrorSnapshotEvidenceRow> evidenceForFinding({
    required KnowMeMirrorSnapshot snapshot,
    required String findingId,
    required List<String> themeIds,
    String? mirrorKey,
  }) {
    final themeSet = themeIds.toSet();
    return snapshot.evidence.where((row) {
      if (mirrorKey != null && row.mirrorKey != mirrorKey) return false;
      return themeSet.contains(row.sourceThemeId) ||
          row.themeIds.any(themeSet.contains);
    }).toList(growable: false);
  }

  static Map<String, String> lensBySystem(KnowMeMirrorSnapshot snapshot) {
    final lenses = <String, String>{};
    for (final row in snapshot.evidence) {
      lenses.putIfAbsent(row.systemId, () => row.sourceSnapshotId);
    }
    return Map<String, String>.unmodifiable(lenses);
  }
}
