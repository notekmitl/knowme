import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';

import '../domain/pattern_activation.dart';
import '../domain/pattern_evidence.dart';

/// HP6 — preserves full lineage on pattern evidence rows.
abstract final class PatternEvidencePreserver {
  static List<PatternEvidence> preserve({
    required HumanModelSnapshot humanModelSnapshot,
    required List<PatternActivation> activations,
  }) {
    final rows = <PatternEvidence>[];

    for (final activation in activations) {
      final humanEvidence = humanModelSnapshot.evidence.where(
        (row) => row.humanPatternId == activation.sourceHumanPatternId,
      );

      for (final row in humanEvidence) {
        rows.add(
          PatternEvidence(
            registryPatternId: activation.patternId,
            activationId: activation.activationId,
            humanModelPatternId: activation.sourceHumanPatternId,
            humanModelSnapshotId: humanModelSnapshot.snapshotId,
            fusionFindingId: row.fusionFindingId,
            mirrorFindingId: row.mirrorFindingId,
            mirrorSnapshotId: row.mirrorSnapshotId,
            mirrorRoleId: row.mirrorRoleId,
            sourceThemeId: row.sourceThemeId,
            mirrorKey: row.mirrorKey,
            systemId: row.systemId,
            themeIds: List<String>.from(row.themeIds),
            signalIds: List<String>.from(row.signalIds),
            weight: row.weight,
          ),
        );
      }
    }

    rows.sort((a, b) {
      final patternCompare =
          a.registryPatternId.compareTo(b.registryPatternId);
      if (patternCompare != 0) return patternCompare;
      return a.sourceThemeId.compareTo(b.sourceThemeId);
    });

    return rows;
  }
}
