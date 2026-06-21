import 'dart:convert';

import '../constants/human_model_version.dart';
import '../contracts/human_model_identity_contract.dart';
import '../contracts/human_model_input.dart';
import '../coverage/fusion_evidence_to_human_mapper.dart';
import '../domain/human_lineage.dart';
import '../domain/human_model_identity.dart';
import '../domain/human_model_snapshot.dart';
import '../domain/human_pattern.dart';
import '../engines/human_confidence_composer.dart';
import '../lineage/human_evidence_preserver.dart';
import '../mapping/fusion_to_human_mapper.dart';

/// Assembles immutable [HumanModelSnapshot] from global fusion output.
abstract final class HumanModelFoundationBuilder {
  static HumanModelSnapshot build(
    HumanModelInput input, {
    DateTime? createdAt,
  }) {
    final fusionSnapshot = input.fusionSnapshot;
    final fusionMapping = FusionToHumanMapper.map(fusionSnapshot);
    final themeMapping = FusionEvidenceToHumanMapper.map(fusionSnapshot);
    final mapping = _mergeMappings(fusionMapping, themeMapping);
    final patterns = mapping.patterns;

    final dimensions = HumanConfidenceComposer.buildDimensionActivations(patterns);
    final profile = HumanConfidenceComposer.buildProfile(
      patterns: patterns,
      dimensions: dimensions,
    );
    final coverage = HumanConfidenceComposer.buildCoverage(
      patterns: patterns,
      dimensions: dimensions,
    );
    final evidence = HumanEvidencePreserver.preserve(
      fusionSnapshot: fusionSnapshot,
      patterns: patterns,
    );
    final confidence = HumanConfidenceComposer.compose(
      fusionSnapshot: fusionSnapshot,
      coverage: coverage,
      patterns: patterns,
      evidenceRows: evidence
          .map(
            (row) => HumanEvidenceRow(
              systemId: row.systemId,
              mirrorRoleId: row.mirrorRoleId,
              sourceThemeId: row.sourceThemeId,
            ),
          )
          .toList(growable: false),
    );

    final structuralHash = _structuralHash(
      sourceGlobalFusionSnapshotId: fusionSnapshot.snapshotId,
      patternIds: patterns.map((item) => item.id).toList(),
    );

    final identity = HumanModelIdentity(
      snapshotId: HumanModelIdentityContract.snapshotId(
        sourceGlobalFusionSnapshotId: fusionSnapshot.snapshotId,
        structuralHash: structuralHash,
      ),
      humanModelId: HumanModelIdentityContract.humanModelId(
        sourceGlobalFusionSnapshotId: fusionSnapshot.snapshotId,
      ),
      sourceGlobalFusionSnapshotId: fusionSnapshot.snapshotId,
      snapshotVersion: HumanModelFoundationVersion.snapshotVersion,
    );

    final lineage = HumanLineage(
      sourceGlobalFusionSnapshotId: fusionSnapshot.snapshotId,
      sourceGlobalFusionStructuralHash: fusionSnapshot.structuralHash,
      fusionFindingByPatternId: mapping.fusionFindingByPatternId,
      foundationVersion: HumanModelFoundationVersion.foundationVersion,
    );

    return HumanModelSnapshot(
      identity: identity,
      profile: profile,
      confidence: confidence,
      coverage: coverage,
      evidence: List.unmodifiable(evidence),
      lineage: lineage,
      structuralHash: structuralHash,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
    );
  }

  static FusionToHumanMappingResult _mergeMappings(
    FusionToHumanMappingResult fusionMapping,
    FusionToHumanMappingResult themeMapping,
  ) {
    final patterns = <HumanPattern>[
      ...fusionMapping.patterns,
      ...themeMapping.patterns,
    ]..sort((a, b) => a.patternKey.compareTo(b.patternKey));

    return FusionToHumanMappingResult(
      patterns: List.unmodifiable(patterns),
      fusionFindingByPatternId: Map.unmodifiable({
        ...fusionMapping.fusionFindingByPatternId,
        ...themeMapping.fusionFindingByPatternId,
      }),
    );
  }

  static String _structuralHash({
    required String sourceGlobalFusionSnapshotId,
    required List<String> patternIds,
  }) {
    final payload = jsonEncode({
      'sourceGlobalFusionSnapshotId': sourceGlobalFusionSnapshotId,
      'patternIds': (List<String>.from(patternIds)..sort()),
    });

    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(payload)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
