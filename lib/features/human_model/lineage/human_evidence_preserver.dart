import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';

import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_evidence.dart';

import '../coverage/runtime_theme_meaning_catalog.dart';
import '../domain/human_evidence.dart';
import '../domain/human_pattern.dart';
import '../mapping/fusion_to_human_mapper.dart';

/// HM6 — preserves full lineage chain on human evidence rows.
abstract final class HumanEvidencePreserver {
  static List<HumanEvidence> preserve({
    required GlobalFusionSnapshot fusionSnapshot,
    required List<HumanPattern> patterns,
  }) {
    final rows = <HumanEvidence>[];

    for (final pattern in patterns) {
      for (final fusionFindingId in pattern.fusionFindingIds) {
        final fusionEvidence = FusionToHumanMapper.fusionEvidenceForFinding(
          fusionSnapshot,
          fusionFindingId,
        );

        if (fusionEvidence.isEmpty) {
          rows.addAll(
            _fallbackEvidence(
              fusionSnapshot: fusionSnapshot,
              pattern: pattern,
              fusionFindingId: fusionFindingId,
            ),
          );
          continue;
        }

        for (final evidence in fusionEvidence) {
          if (_shouldIncludeThemeRow(pattern, evidence)) {
            rows.add(_humanEvidence(pattern, fusionFindingId, evidence));
          }
        }
      }
    }

    rows.sort((a, b) {
      final patternCompare = a.humanPatternId.compareTo(b.humanPatternId);
      if (patternCompare != 0) return patternCompare;
      return a.sourceThemeId.compareTo(b.sourceThemeId);
    });

    return rows;
  }

  static bool _shouldIncludeThemeRow(
    HumanPattern pattern,
    GlobalFusionEvidence evidence,
  ) {
    if (pattern.fusionFindingType != 'theme_evidence') return true;
    final themeId = _themeIdForPattern(pattern.patternKey);
    if (themeId == null) return true;
    return evidence.sourceThemeId == themeId;
  }

  static String? _themeIdForPattern(String patternKey) {
    for (final entry in RuntimeThemeMeaningCatalog.entries) {
      if (entry.patternKey == patternKey) return entry.themeId;
    }
    return null;
  }

  static HumanEvidence _humanEvidence(
    HumanPattern pattern,
    String fusionFindingId,
    GlobalFusionEvidence evidence,
  ) {
    return HumanEvidence(
      humanPatternId: pattern.id,
      fusionFindingId: fusionFindingId,
      mirrorFindingId: evidence.mirrorFindingId,
      mirrorSnapshotId: evidence.mirrorSnapshotId,
      mirrorRoleId: evidence.mirrorRoleId,
      sourceThemeId: evidence.sourceThemeId,
      mirrorKey: evidence.mirrorKey,
      systemId: evidence.systemId,
      sourceSnapshotId: evidence.sourceSnapshotId,
      themeIds: List<String>.from(evidence.themeIds),
      signalIds: List<String>.from(evidence.signalIds),
      weight: evidence.weight,
    );
  }

  static List<HumanEvidence> _fallbackEvidence({
    required GlobalFusionSnapshot fusionSnapshot,
    required HumanPattern pattern,
    required String fusionFindingId,
  }) {
    for (final blindSpot in fusionSnapshot.blindSpots) {
      if (blindSpot.id != fusionFindingId) continue;
      return [
        _findingEvidence(
          fusionSnapshot: fusionSnapshot,
          pattern: pattern,
          fusionFindingId: fusionFindingId,
          mirrorKey: blindSpot.mirrorKey,
          mirrorRoleId: blindSpot.reflectingMirrorRoleId,
          mirrorFindingId: blindSpot.reflectingMirrorFindingId,
          sourceThemeId: 'fusion_finding:$fusionFindingId',
        ),
      ];
    }

    for (final tension in fusionSnapshot.tensions) {
      if (tension.id != fusionFindingId) continue;
      return [
        _findingEvidence(
          fusionSnapshot: fusionSnapshot,
          pattern: pattern,
          fusionFindingId: fusionFindingId,
          mirrorKey: tension.mirrorKey,
          mirrorRoleId: tension.positiveMirrorRoleId,
          mirrorFindingId: tension.positiveMirrorFindingId,
          sourceThemeId: tension.themeIds.isNotEmpty
              ? tension.themeIds.first
              : 'fusion_finding:$fusionFindingId',
          themeIds: tension.themeIds,
        ),
      ];
    }

    for (final agreement in fusionSnapshot.agreements) {
      if (agreement.id != fusionFindingId) continue;
      return [
        _findingEvidence(
          fusionSnapshot: fusionSnapshot,
          pattern: pattern,
          fusionFindingId: fusionFindingId,
          mirrorKey: agreement.mirrorKey,
          mirrorRoleId: agreement.mirrorRoleIds.first,
          mirrorFindingId: agreement.mirrorFindingIds.first,
          sourceThemeId: agreement.themeIds.isNotEmpty
              ? agreement.themeIds.first
              : 'fusion_finding:$fusionFindingId',
          themeIds: agreement.themeIds,
        ),
      ];
    }

    for (final reinforcement in fusionSnapshot.reinforcements) {
      if (reinforcement.id != fusionFindingId) continue;
      return [
        _findingEvidence(
          fusionSnapshot: fusionSnapshot,
          pattern: pattern,
          fusionFindingId: fusionFindingId,
          mirrorKey: reinforcement.mirrorKey,
          mirrorRoleId: reinforcement.mirrorRoleIds.first,
          mirrorFindingId: reinforcement.mirrorFindingIds.first,
          sourceThemeId: reinforcement.themeIds.isNotEmpty
              ? reinforcement.themeIds.first
              : 'fusion_finding:$fusionFindingId',
          themeIds: reinforcement.themeIds,
        ),
      ];
    }

    return const [];
  }

  static HumanEvidence _findingEvidence({
    required GlobalFusionSnapshot fusionSnapshot,
    required HumanPattern pattern,
    required String fusionFindingId,
    required String mirrorKey,
    required String mirrorRoleId,
    required String mirrorFindingId,
    required String sourceThemeId,
    List<String> themeIds = const [],
  }) {
    return HumanEvidence(
      humanPatternId: pattern.id,
      fusionFindingId: fusionFindingId,
      mirrorFindingId: mirrorFindingId,
      mirrorSnapshotId: _snapshotIdForRole(fusionSnapshot, mirrorRoleId),
      mirrorRoleId: mirrorRoleId,
      sourceThemeId: sourceThemeId,
      mirrorKey: mirrorKey,
      systemId: 'global_fusion',
      sourceSnapshotId: fusionSnapshot.snapshotId,
      themeIds: themeIds,
      signalIds: const [],
      weight: pattern.patternStrength,
    );
  }

  static String _snapshotIdForRole(
    GlobalFusionSnapshot fusionSnapshot,
    String mirrorRoleId,
  ) {
    for (final entry in fusionSnapshot.lineage.mirrorRoleBySnapshotId.entries) {
      if (entry.value == mirrorRoleId) return entry.key;
    }
    if (fusionSnapshot.lineage.sourceMirrorSnapshotIds.isNotEmpty) {
      return fusionSnapshot.lineage.sourceMirrorSnapshotIds.first;
    }
    return fusionSnapshot.snapshotId;
  }
}
