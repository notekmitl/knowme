import 'dart:convert';

import 'package:knowme/features/mirror_v3/snapshot/lineage/mirror_snapshot_lineage_trace.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';

import '../contracts/global_fusion_input.dart';
import '../domain/global_fusion_evidence.dart';
import '../domain/global_fusion_findings.dart';

/// GF8 — preserves 100% traceability from global findings to mirror evidence.
abstract final class GlobalFusionEvidencePreserver {
  static List<GlobalFusionEvidence> preserve({
    required GlobalFusionInput input,
    required List<GlobalFusionCrossMirrorAgreement> agreements,
    required List<GlobalFusionCrossMirrorTension> tensions,
    required List<GlobalFusionCrossMirrorReinforcement> reinforcements,
    required List<GlobalFusionCrossMirrorBlindSpot> blindSpots,
  }) {
    final rows = <GlobalFusionEvidence>[];

    for (final agreement in agreements) {
      rows.addAll(
        _forFinding(
          input: input,
          globalFindingId: agreement.id,
          mirrorRoleIds: agreement.mirrorRoleIds,
          mirrorFindingIds: agreement.mirrorFindingIds,
          mirrorKey: agreement.mirrorKey,
          themeIds: agreement.themeIds,
        ),
      );
    }

    for (final tension in tensions) {
      rows.addAll(
        _forFinding(
          input: input,
          globalFindingId: tension.id,
          mirrorRoleIds: [
            tension.positiveMirrorRoleId,
            tension.tensionMirrorRoleId,
          ],
          mirrorFindingIds: [
            tension.positiveMirrorFindingId,
            tension.tensionMirrorFindingId,
          ],
          mirrorKey: tension.mirrorKey,
          themeIds: tension.themeIds,
        ),
      );
    }

    for (final reinforcement in reinforcements) {
      rows.addAll(
        _forFinding(
          input: input,
          globalFindingId: reinforcement.id,
          mirrorRoleIds: reinforcement.mirrorRoleIds,
          mirrorFindingIds: reinforcement.mirrorFindingIds,
          mirrorKey: reinforcement.mirrorKey,
          themeIds: reinforcement.themeIds,
        ),
      );
    }

    for (final blindSpot in blindSpots) {
      rows.addAll(
        _forFinding(
          input: input,
          globalFindingId: blindSpot.id,
          mirrorRoleIds: [
            blindSpot.reflectingMirrorRoleId,
            blindSpot.blindMirrorRoleId,
          ],
          mirrorFindingIds: [
            blindSpot.reflectingMirrorFindingId,
            blindSpot.blindMirrorFindingId,
          ],
          mirrorKey: blindSpot.mirrorKey,
          themeIds: const [],
        ),
      );
    }

    rows.sort((a, b) {
      final findingCompare =
          a.globalFindingId.compareTo(b.globalFindingId);
      if (findingCompare != 0) return findingCompare;
      return a.sourceThemeId.compareTo(b.sourceThemeId);
    });

    return rows;
  }

  static List<GlobalFusionEvidence> _forFinding({
    required GlobalFusionInput input,
    required String globalFindingId,
    required List<String> mirrorRoleIds,
    required List<String> mirrorFindingIds,
    required String mirrorKey,
    required List<String> themeIds,
  }) {
    final rows = <GlobalFusionEvidence>[];
    final roleSet = mirrorRoleIds.toSet();

    for (final ref in input.mirrors) {
      if (!roleSet.contains(ref.mirrorRoleId)) continue;

      final traced = MirrorSnapshotLineageTrace.evidenceForFinding(
        snapshot: ref.snapshot,
        findingId: mirrorFindingIds.firstWhere(
          (id) => _findingBelongsToMirror(id, ref.snapshot),
          orElse: () => mirrorFindingIds.first,
        ),
        themeIds: themeIds,
        mirrorKey: mirrorKey,
      );

      for (final row in traced) {
        rows.add(
          GlobalFusionEvidence(
            globalFindingId: globalFindingId,
            mirrorRoleId: ref.mirrorRoleId,
            mirrorSnapshotId: ref.snapshot.snapshotId,
            mirrorFindingId: _mirrorFindingIdForRow(
              row,
              ref.snapshot,
              mirrorFindingIds,
            ),
            mirrorObjectId: row.mirrorObjectId,
            mirrorKey: row.mirrorKey,
            sourceThemeId: row.sourceThemeId,
            systemId: row.systemId,
            sourceSnapshotId: row.sourceSnapshotId,
            themeIds: List<String>.from(row.themeIds),
            signalIds: List<String>.from(row.signalIds),
            weight: row.weight,
          ),
        );
      }
    }

    return rows;
  }

  static bool _findingBelongsToMirror(
    String findingId,
    KnowMeMirrorSnapshot snapshot,
  ) {
    return snapshot.agreements.any((item) => item.id == findingId) ||
        snapshot.tensions.any((item) => item.id == findingId) ||
        snapshot.reinforcements.any((item) => item.id == findingId) ||
        snapshot.blindSpots.any((item) => item.id == findingId);
  }

  static String _mirrorFindingIdForRow(
    dynamic row,
    KnowMeMirrorSnapshot snapshot,
    List<String> candidateIds,
  ) {
    for (final id in candidateIds) {
      if (_findingBelongsToMirror(id, snapshot)) return id;
    }
    return candidateIds.isEmpty ? row.mirrorObjectId : candidateIds.first;
  }
}

/// Structural hash for global fusion snapshot identity.
abstract final class GlobalFusionStructuralHash {
  static String compute({
    required List<String> sourceMirrorSnapshotIds,
    required List<String> agreementIds,
    required List<String> tensionIds,
    required List<String> reinforcementIds,
    required List<String> blindSpotIds,
  }) {
    final payload = jsonEncode({
      'sourceMirrorSnapshotIds':
          (List<String>.from(sourceMirrorSnapshotIds)..sort()),
      'agreementIds': (List<String>.from(agreementIds)..sort()),
      'tensionIds': (List<String>.from(tensionIds)..sort()),
      'reinforcementIds': (List<String>.from(reinforcementIds)..sort()),
      'blindSpotIds': (List<String>.from(blindSpotIds)..sort()),
    });

    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(payload)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
