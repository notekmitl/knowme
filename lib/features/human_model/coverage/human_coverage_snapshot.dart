import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';

import '../domain/human_model_snapshot.dart';
import 'human_coverage_layer_audit.dart';
import 'runtime_theme_meaning_catalog.dart';

/// HPC6 — immutable coverage tracking snapshot.
class HumanCoverageSnapshot {
  const HumanCoverageSnapshot({
    required this.generatedAt,
    required this.activationRate,
    required this.activatedPatternCount,
    required this.registryPatternCount,
    required this.humanModelPatternCount,
    required this.fusionFindingCount,
    required this.layerAudit,
    required this.themeAudit,
    required this.activatedPatternIds,
    required this.humanMeaningPatternKeys,
    required this.version,
  });

  final DateTime generatedAt;
  final double activationRate;
  final int activatedPatternCount;
  final int registryPatternCount;
  final int humanModelPatternCount;
  final int fusionFindingCount;
  final HumanCoverageLayerAudit layerAudit;
  final ThemeMappingAuditReport themeAudit;
  final List<String> activatedPatternIds;
  final List<String> humanMeaningPatternKeys;
  final String version;

  Map<String, dynamic> toMap() {
    return {
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'activationRate': activationRate,
      'activatedPatternCount': activatedPatternCount,
      'registryPatternCount': registryPatternCount,
      'humanModelPatternCount': humanModelPatternCount,
      'fusionFindingCount': fusionFindingCount,
      'layerAudit': {
        'themeCount': layerAudit.themeCount,
        'themesInMirrorEvidence': layerAudit.themesInMirrorEvidence,
        'themesInFusionEvidence': layerAudit.themesInFusionEvidence,
        'themesWithHumanMeaning': layerAudit.themesWithHumanMeaning,
        'themesActivatedInRegistry': layerAudit.themesActivatedInRegistry,
        'themeToMirrorLossRate': layerAudit.themeToMirrorLossRate,
        'mirrorToFusionLossRate': layerAudit.mirrorToFusionLossRate,
        'fusionToMeaningLossRate': layerAudit.fusionToMeaningLossRate,
        'meaningToPatternLossRate': layerAudit.meaningToPatternLossRate,
      },
      'themeAudit': {
        'totalThemeIds': themeAudit.totalThemeIds,
        'themesInFusionEvidence': themeAudit.themesInFusionEvidence,
        'themesWithMeaningSupport': themeAudit.themesWithMeaningSupport,
        'themesWithoutMeaningSupport': themeAudit.themesWithoutMeaningSupport,
        'unusedThemeIds': themeAudit.unusedThemeIds,
        'meaningGapThemeIds': themeAudit.meaningGapThemeIds,
      },
      'activatedPatternIds': activatedPatternIds,
      'humanMeaningPatternKeys': humanMeaningPatternKeys,
      'version': version,
    };
  }
}

abstract final class HumanCoverageSnapshotBuilder {
  static const version = 'human_coverage.snapshot.v1';

  static HumanCoverageSnapshot build({
    required List<KnowMeMirrorSnapshot> mirrorSnapshots,
    required GlobalFusionSnapshot fusionSnapshot,
    required HumanModelSnapshot humanModelSnapshot,
    required HumanPatternSnapshot humanPatternSnapshot,
    DateTime? generatedAt,
  }) {
    final allThemes = <String>{};
    final mirrorThemes = <String>{};
    for (final snapshot in mirrorSnapshots) {
      for (final row in snapshot.evidence) {
        allThemes.add(row.sourceThemeId);
        allThemes.addAll(row.themeIds);
        mirrorThemes.add(row.sourceThemeId);
        mirrorThemes.addAll(row.themeIds);
      }
    }

    final fusionThemes = fusionSnapshot.evidence
        .map((row) => row.sourceThemeId)
        .where((id) => !id.startsWith('fusion_finding:'))
        .toSet();

    final humanMeaningThemes = humanModelSnapshot.evidence
        .map((row) => row.sourceThemeId)
        .where((id) => !id.startsWith('fusion_finding:'))
        .toSet();

    final activatedThemes = <String>{};
    for (final activation in humanPatternSnapshot.activations) {
      final sourceKey = activation.sourceHumanPatternKey;
      for (final entry in RuntimeThemeMeaningCatalog.entries) {
        if (entry.patternKey == sourceKey) {
          activatedThemes.add(entry.themeId);
        }
      }
    }

    final auditInput = HumanCoverageAuditInput(
      allThemeIds: allThemes,
      mirrorEvidenceThemeIds: mirrorThemes,
      fusionEvidenceThemeIds: fusionThemes,
      humanMeaningThemeIds: humanMeaningThemes,
      activatedThemeIds: activatedThemes,
      supportedMeaningThemeIds: RuntimeThemeMeaningCatalog.supportedThemeIds.toSet(),
    );

    final registryCount = humanPatternSnapshot.coverage.registryPatternCount;
    final activatedCount = humanPatternSnapshot.activations.length;

    return HumanCoverageSnapshot(
      generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
      activationRate:
          registryCount == 0 ? 0.0 : activatedCount / registryCount,
      activatedPatternCount: activatedCount,
      registryPatternCount: registryCount,
      humanModelPatternCount: humanModelSnapshot.patterns.length,
      fusionFindingCount: fusionSnapshot.agreements.length +
          fusionSnapshot.tensions.length +
          fusionSnapshot.reinforcements.length +
          fusionSnapshot.blindSpots.length,
      layerAudit: HumanCoverageLayerAuditBuilder.buildLayerAudit(auditInput),
      themeAudit: HumanCoverageLayerAuditBuilder.buildThemeAudit(auditInput),
      activatedPatternIds: humanPatternSnapshot.activations
          .map((item) => item.patternId)
          .toList()
        ..sort(),
      humanMeaningPatternKeys: humanModelSnapshot.patterns
          .map((item) => item.patternKey)
          .toList()
        ..sort(),
      version: version,
    );
  }
}
