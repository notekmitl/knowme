/// HPC1 — per-layer coverage loss metrics.
class HumanCoverageLayerAudit {
  const HumanCoverageLayerAudit({
    required this.themeCount,
    required this.themesInMirrorEvidence,
    required this.themesInFusionEvidence,
    required this.themesWithHumanMeaning,
    required this.themesActivatedInRegistry,
    required this.themeToMirrorLossRate,
    required this.mirrorToFusionLossRate,
    required this.fusionToMeaningLossRate,
    required this.meaningToPatternLossRate,
  });

  final int themeCount;
  final int themesInMirrorEvidence;
  final int themesInFusionEvidence;
  final int themesWithHumanMeaning;
  final int themesActivatedInRegistry;
  final double themeToMirrorLossRate;
  final double mirrorToFusionLossRate;
  final double fusionToMeaningLossRate;
  final double meaningToPatternLossRate;
}

/// HPC2 — theme mapping audit result.
class ThemeMappingAuditReport {
  const ThemeMappingAuditReport({
    required this.totalThemeIds,
    required this.themesInFusionEvidence,
    required this.themesWithMeaningSupport,
    required this.themesWithoutMeaningSupport,
    required this.unusedThemeIds,
    required this.meaningGapThemeIds,
  });

  final int totalThemeIds;
  final List<String> themesInFusionEvidence;
  final List<String> themesWithMeaningSupport;
  final List<String> themesWithoutMeaningSupport;
  final List<String> unusedThemeIds;
  final List<String> meaningGapThemeIds;
}

/// HPC1 + HPC2 combined layer audit builder inputs.
class HumanCoverageAuditInput {
  const HumanCoverageAuditInput({
    required this.allThemeIds,
    required this.mirrorEvidenceThemeIds,
    required this.fusionEvidenceThemeIds,
    required this.humanMeaningThemeIds,
    required this.activatedThemeIds,
    required this.supportedMeaningThemeIds,
  });

  final Set<String> allThemeIds;
  final Set<String> mirrorEvidenceThemeIds;
  final Set<String> fusionEvidenceThemeIds;
  final Set<String> humanMeaningThemeIds;
  final Set<String> activatedThemeIds;
  final Set<String> supportedMeaningThemeIds;
}

abstract final class HumanCoverageLayerAuditBuilder {
  static HumanCoverageLayerAudit buildLayerAudit(HumanCoverageAuditInput input) {
    final themeCount = input.allThemeIds.length;
    final inMirror = input.mirrorEvidenceThemeIds.length;
    final inFusion = input.fusionEvidenceThemeIds.length;
    final withMeaning = input.humanMeaningThemeIds.length;
    final activated = input.activatedThemeIds.length;

    double loss(int from, int to) => from == 0 ? 0.0 : 1.0 - (to / from);

    return HumanCoverageLayerAudit(
      themeCount: themeCount,
      themesInMirrorEvidence: inMirror,
      themesInFusionEvidence: inFusion,
      themesWithHumanMeaning: withMeaning,
      themesActivatedInRegistry: activated,
      themeToMirrorLossRate: loss(themeCount, inMirror),
      mirrorToFusionLossRate: loss(inMirror, inFusion),
      fusionToMeaningLossRate: loss(inFusion, withMeaning),
      meaningToPatternLossRate: loss(withMeaning, activated),
    );
  }

  static ThemeMappingAuditReport buildThemeAudit(HumanCoverageAuditInput input) {
    final unused = input.allThemeIds
        .where((id) => !input.humanMeaningThemeIds.contains(id))
        .toList()
      ..sort();

    final meaningGap = input.fusionEvidenceThemeIds
        .where((id) => !input.supportedMeaningThemeIds.contains(id))
        .toList()
      ..sort();

    final withoutSupport = input.allThemeIds
        .where((id) => !input.supportedMeaningThemeIds.contains(id))
        .toList()
      ..sort();

    final fusionThemes = input.fusionEvidenceThemeIds.toList()..sort();
    final withSupport = input.supportedMeaningThemeIds
        .where(input.allThemeIds.contains)
        .toList()
      ..sort();

    return ThemeMappingAuditReport(
      totalThemeIds: input.allThemeIds.length,
      themesInFusionEvidence: fusionThemes,
      themesWithMeaningSupport: withSupport,
      themesWithoutMeaningSupport: withoutSupport,
      unusedThemeIds: unused,
      meaningGapThemeIds: meaningGap,
    );
  }
}
