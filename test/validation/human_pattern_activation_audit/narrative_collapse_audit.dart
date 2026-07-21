import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';

import '../synthetic_population/pipeline/synthetic_human_run_record.dart';

enum NarrativeCollapseStage {
  mirror('mirror'),
  fusion('fusion'),
  humanModel('human_model'),
  humanPattern('human_pattern'),
  narrative('narrative');

  const NarrativeCollapseStage(this.key);
  final String key;
}

/// Audit C — where 200 humans compress into 82 narratives.
class NarrativeCollapseReport {
  const NarrativeCollapseReport({
    required this.populationSize,
    required this.layerUniques,
    required this.layerCompressionRatios,
    required this.collapseZones,
    required this.primaryCollapseStage,
  });

  final int populationSize;
  final Map<String, int> layerUniques;
  final Map<String, double> layerCompressionRatios;
  final List<NarrativeCollapseZone> collapseZones;
  final String primaryCollapseStage;

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'layerUniques': layerUniques,
      'layerCompressionRatios': layerCompressionRatios,
      'collapseZoneCount': collapseZones.length,
      'primaryCollapseStage': primaryCollapseStage,
      'collapseZones': collapseZones.map((item) => item.toJson()).toList(),
    };
  }
}

class NarrativeCollapseZone {
  const NarrativeCollapseZone({
    required this.clusterSize,
    required this.profileIds,
    required this.uniqueMirrorFingerprints,
    required this.uniqueFusionFingerprints,
    required this.uniqueHumanModelHashes,
    required this.uniquePatternSets,
    required this.narrativeFingerprintSample,
    required this.collapseStage,
    required this.compressionRatio,
  });

  final int clusterSize;
  final List<String> profileIds;
  final int uniqueMirrorFingerprints;
  final int uniqueFusionFingerprints;
  final int uniqueHumanModelHashes;
  final int uniquePatternSets;
  final String narrativeFingerprintSample;
  final String collapseStage;
  final double compressionRatio;

  Map<String, dynamic> toJson() {
    return {
      'clusterSize': clusterSize,
      'profileIds': profileIds,
      'uniqueMirrorFingerprints': uniqueMirrorFingerprints,
      'uniqueFusionFingerprints': uniqueFusionFingerprints,
      'uniqueHumanModelHashes': uniqueHumanModelHashes,
      'uniquePatternSets': uniquePatternSets,
      'collapseStage': collapseStage,
      'compressionRatio': compressionRatio,
      'narrativeFingerprintSample': narrativeFingerprintSample.length > 120
          ? '${narrativeFingerprintSample.substring(0, 120)}...'
          : narrativeFingerprintSample,
    };
  }
}

abstract final class NarrativeCollapseAudit {
  static NarrativeCollapseReport analyze(List<SyntheticHumanRunRecord> records) {
    final populationSize = records.length;

    final mirrorSet = records.map((r) => r.mirrorFingerprint).toSet();
    final fusionSet = records.map((r) => r.fusionFingerprint).toSet();
    final humanModelSet = <String>{};
    final patternSet = records.map((r) => r.patternFingerprint).toSet();
    final narrativeSet = records.map((r) => r.narrativeFingerprint).toSet();

    for (final record in records) {
      final humanModel = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
        createdAt: record.generatedAt,
      );
      humanModelSet.add(humanModel.structuralHash);
    }

    final uniques = {
      'mirror': mirrorSet.length,
      'fusion': fusionSet.length,
      'human_model': humanModelSet.length,
      'human_pattern': patternSet.length,
      'narrative': narrativeSet.length,
    };

    final compression = {
      for (final entry in uniques.entries)
        entry.key: populationSize == 0
            ? 0.0
            : entry.value / populationSize,
    };

    final grouped = <String, List<SyntheticHumanRunRecord>>{};
    for (final record in records) {
      grouped
          .putIfAbsent(record.narrativeFingerprint, () => [])
          .add(record);
    }

    final zones = grouped.entries
        .where((entry) => entry.value.length >= 3)
        .map((entry) => _zone(entry.value))
        .toList()
      ..sort((a, b) => b.clusterSize.compareTo(a.clusterSize));

    final primaryStage = _primaryStage(compression);

    return NarrativeCollapseReport(
      populationSize: populationSize,
      layerUniques: uniques,
      layerCompressionRatios: compression,
      collapseZones: zones,
      primaryCollapseStage: primaryStage,
    );
  }

  static NarrativeCollapseZone _zone(List<SyntheticHumanRunRecord> cluster) {
    final mirrors = cluster.map((r) => r.mirrorFingerprint).toSet();
    final fusions = cluster.map((r) => r.fusionFingerprint).toSet();
    final patterns = cluster.map((r) => r.patternFingerprint).toSet();
    final humanModels = <String>{};
    for (final record in cluster) {
      final humanModel = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
        createdAt: record.generatedAt,
      );
      humanModels.add(humanModel.structuralHash);
    }

    final stage = _zoneCollapseStage(
      uniqueMirrors: mirrors.length,
      uniqueFusions: fusions.length,
      uniqueHumanModels: humanModels.length,
      uniquePatterns: patterns.length,
      clusterSize: cluster.length,
    );

    return NarrativeCollapseZone(
      clusterSize: cluster.length,
      profileIds: cluster.map((r) => r.profile.profileId).toList()..sort(),
      uniqueMirrorFingerprints: mirrors.length,
      uniqueFusionFingerprints: fusions.length,
      uniqueHumanModelHashes: humanModels.length,
      uniquePatternSets: patterns.length,
      narrativeFingerprintSample: cluster.first.narrativeFingerprint,
      collapseStage: stage,
      compressionRatio: cluster.length == 0 ? 0 : 1 / cluster.length,
    );
  }

  static String _zoneCollapseStage({
    required int uniqueMirrors,
    required int uniqueFusions,
    required int uniqueHumanModels,
    required int uniquePatterns,
    required int clusterSize,
  }) {
    if (uniqueMirrors < clusterSize &&
        uniqueFusions < clusterSize &&
        uniqueHumanModels < clusterSize &&
        uniquePatterns < clusterSize) {
      return 'multi_layer';
    }
    if (uniquePatterns == 1 && uniqueHumanModels > 1) {
      return NarrativeCollapseStage.narrative.key;
    }
    if (uniqueHumanModels == 1 && uniquePatterns > 1) {
      return NarrativeCollapseStage.humanPattern.key;
    }
    if (uniqueFusions == 1 && uniqueHumanModels > 1) {
      return NarrativeCollapseStage.humanModel.key;
    }
    if (uniqueMirrors == 1 && uniqueFusions > 1) {
      return NarrativeCollapseStage.fusion.key;
    }
    if (uniquePatterns < clusterSize) {
      return NarrativeCollapseStage.humanPattern.key;
    }
    return NarrativeCollapseStage.narrative.key;
  }

  static String _primaryStage(Map<String, double> compression) {
    final ordered = [
      'mirror',
      'fusion',
      'human_model',
      'human_pattern',
      'narrative',
    ];
    var maxDrop = 0.0;
    var stage = 'human_pattern→narrative';
    for (var i = 1; i < ordered.length; i++) {
      final drop = (compression[ordered[i - 1]] ?? 0) -
          (compression[ordered[i]] ?? 0);
      if (drop > maxDrop) {
        maxDrop = drop;
        stage = '${ordered[i - 1]}→${ordered[i]}';
      }
    }
    return stage;
  }
}
