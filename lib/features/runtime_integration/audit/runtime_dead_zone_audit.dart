import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/mirror_v3/registry/knowme_mirror_registry_v0_1.dart';

import '../pipeline/knowme_runtime_pipeline.dart';

/// RT5 — dead zone audit for unmapped findings and unused signals.
class RuntimeDeadZoneReport {
  const RuntimeDeadZoneReport({
    required this.unmappedFusionFindingIds,
    required this.neverActivatedPatternIds,
    required this.unusedMirrorKeys,
    required this.unusedThemeIds,
  });

  final List<String> unmappedFusionFindingIds;
  final List<String> neverActivatedPatternIds;
  final List<String> unusedMirrorKeys;
  final List<String> unusedThemeIds;
}

abstract final class RuntimeDeadZoneAudit {
  static RuntimeDeadZoneReport analyze(KnowMeRuntimePipelineResult result) {
    final fusionFindingIds = <String>{
      ...result.globalFusionSnapshot.agreements.map((item) => item.id),
      ...result.globalFusionSnapshot.tensions.map((item) => item.id),
      ...result.globalFusionSnapshot.reinforcements.map((item) => item.id),
      ...result.globalFusionSnapshot.blindSpots.map((item) => item.id),
    };

    final mappedHumanPatternKeys =
        result.humanModelSnapshot.patterns.map((item) => item.patternKey).toSet();

    final unmappedFusion = fusionFindingIds.where((findingId) {
      return !result.humanModelSnapshot.evidence.any(
        (row) => row.fusionFindingId == findingId,
      );
    }).toList()
      ..sort();

    final activatedPatternIds =
        result.humanPatternSnapshot.activations.map((item) => item.patternId).toSet();

    final neverActivated = HumanPatternRegistry.allPatternIds
        .where((id) => !activatedPatternIds.contains(id))
        .toList();

    final usedMirrorKeys = <String>{};
    for (final snapshot
        in [result.astrologyMirrorSnapshot, result.personalityMirrorSnapshot]) {
      for (final row in snapshot.evidence) {
        usedMirrorKeys.add(row.mirrorKey);
      }
      for (final agreement in snapshot.agreements) {
        usedMirrorKeys.add(agreement.mirrorKey);
      }
    }

    final unusedMirrorKeys = KnowMeMirrorRegistryV01.entries
        .map((entry) => entry.mirrorKey)
        .where((key) => !usedMirrorKeys.contains(key))
        .toList()
      ..sort();

    final usedThemeIds = result.humanModelSnapshot.evidence
        .map((row) => row.sourceThemeId)
        .toSet();

    final allThemeIds = <String>{};
    for (final snapshot
        in [result.astrologyMirrorSnapshot, result.personalityMirrorSnapshot]) {
      for (final row in snapshot.evidence) {
        allThemeIds.add(row.sourceThemeId);
        allThemeIds.addAll(row.themeIds);
      }
    }

    final unusedThemeIds = allThemeIds
        .where((themeId) => !usedThemeIds.contains(themeId))
        .toList()
      ..sort();

    return RuntimeDeadZoneReport(
      unmappedFusionFindingIds: unmappedFusion,
      neverActivatedPatternIds: neverActivated,
      unusedMirrorKeys: unusedMirrorKeys,
      unusedThemeIds: unusedThemeIds,
    );
  }
}
