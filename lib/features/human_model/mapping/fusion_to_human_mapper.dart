import 'dart:convert';

import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_evidence.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_findings.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';

import '../domain/human_pattern.dart';
import '../semantics/human_semantic_pattern_catalog.dart';
import 'mirror_dimension_to_human_dimension.dart';

/// HM4/HS3 — maps global fusion findings to canonical human patterns.
class FusionToHumanMappingResult {
  const FusionToHumanMappingResult({
    required this.patterns,
    required this.fusionFindingByPatternId,
  });

  final List<HumanPattern> patterns;
  final Map<String, String> fusionFindingByPatternId;
}

abstract final class FusionToHumanMapper {
  static FusionToHumanMappingResult map(GlobalFusionSnapshot fusionSnapshot) {
    final patterns = <HumanPattern>[];
    final fusionFindingByPatternId = <String, String>{};
    final usedPatternKeys = <String>{};
    final mappedFindingIds = <String>{};

    _mapFindings(
      fusionSnapshot: fusionSnapshot,
      findingType: 'agreement',
      findings: fusionSnapshot.agreements,
      patterns: patterns,
      fusionFindingByPatternId: fusionFindingByPatternId,
      usedPatternKeys: usedPatternKeys,
      mappedFindingIds: mappedFindingIds,
      mirrorKey: (finding) => (finding as GlobalFusionCrossMirrorAgreement).mirrorKey,
      mirrorDimension: (finding) =>
          (finding as GlobalFusionCrossMirrorAgreement).mirrorDimension,
      findingId: (finding) => (finding as GlobalFusionCrossMirrorAgreement).id,
      strength: (finding) =>
          (finding as GlobalFusionCrossMirrorAgreement).agreementStrength,
    );

    _mapFindings(
      fusionSnapshot: fusionSnapshot,
      findingType: 'tension',
      findings: fusionSnapshot.tensions,
      patterns: patterns,
      fusionFindingByPatternId: fusionFindingByPatternId,
      usedPatternKeys: usedPatternKeys,
      mappedFindingIds: mappedFindingIds,
      mirrorKey: (finding) => (finding as GlobalFusionCrossMirrorTension).mirrorKey,
      mirrorDimension: (finding) =>
          (finding as GlobalFusionCrossMirrorTension).mirrorDimension,
      findingId: (finding) => (finding as GlobalFusionCrossMirrorTension).id,
      strength: (finding) => _tensionStrength(finding as GlobalFusionCrossMirrorTension),
    );

    _mapFindings(
      fusionSnapshot: fusionSnapshot,
      findingType: 'reinforcement',
      findings: fusionSnapshot.reinforcements,
      patterns: patterns,
      fusionFindingByPatternId: fusionFindingByPatternId,
      usedPatternKeys: usedPatternKeys,
      mappedFindingIds: mappedFindingIds,
      mirrorKey: (finding) =>
          (finding as GlobalFusionCrossMirrorReinforcement).mirrorKey,
      mirrorDimension: (finding) =>
          (finding as GlobalFusionCrossMirrorReinforcement).mirrorDimension,
      findingId: (finding) =>
          (finding as GlobalFusionCrossMirrorReinforcement).id,
      strength: (finding) =>
          (finding as GlobalFusionCrossMirrorReinforcement).reinforcementBoost,
    );

    _mapFindings(
      fusionSnapshot: fusionSnapshot,
      findingType: 'blind_spot',
      findings: fusionSnapshot.blindSpots,
      patterns: patterns,
      fusionFindingByPatternId: fusionFindingByPatternId,
      usedPatternKeys: usedPatternKeys,
      mappedFindingIds: mappedFindingIds,
      mirrorKey: (finding) => (finding as GlobalFusionCrossMirrorBlindSpot).mirrorKey,
      mirrorDimension: (finding) =>
          (finding as GlobalFusionCrossMirrorBlindSpot).mirrorDimension,
      findingId: (finding) => (finding as GlobalFusionCrossMirrorBlindSpot).id,
      strength: (finding) => _blindSpotStrength(finding as GlobalFusionCrossMirrorBlindSpot),
    );

    patterns.sort((a, b) => a.patternKey.compareTo(b.patternKey));
    return FusionToHumanMappingResult(
      patterns: List.unmodifiable(patterns),
      fusionFindingByPatternId: Map.unmodifiable(fusionFindingByPatternId),
    );
  }

  static void _mapFindings({
    required GlobalFusionSnapshot fusionSnapshot,
    required String findingType,
    required List<dynamic> findings,
    required List<HumanPattern> patterns,
    required Map<String, String> fusionFindingByPatternId,
    required Set<String> usedPatternKeys,
    required Set<String> mappedFindingIds,
    required String Function(dynamic finding) mirrorKey,
    required String Function(dynamic finding) mirrorDimension,
    required String Function(dynamic finding) findingId,
    required double Function(dynamic finding) strength,
  }) {
    for (final finding in findings) {
      final id = findingId(finding);
      if (mappedFindingIds.contains(id)) continue;

      final key = mirrorKey(finding);
      final definition = HumanSemanticPatternCatalog.byMirrorKeyAndType(
        mirrorKey: key,
        fusionFindingType: findingType,
      );
      if (definition == null) continue;
      if (usedPatternKeys.contains(definition.patternKey)) continue;

      final dimension = MirrorDimensionToHumanDimension.map(
        mirrorDimension(finding),
      );

      final patternId = _patternId(definition.patternKey, id);
      final pattern = HumanPattern(
        id: patternId,
        patternKey: definition.patternKey,
        label: definition.label,
        primaryDimension: dimension ?? definition.primaryDimension,
        secondaryDimensions: definition.secondaryDimensions,
        fusionFindingIds: [id],
        fusionFindingType: findingType,
        supportingMirrorKeys: [key],
        patternStrength: strength(finding).clamp(0.0, 1.0),
      );

      patterns.add(pattern);
      fusionFindingByPatternId[patternId] = id;
      usedPatternKeys.add(definition.patternKey);
      mappedFindingIds.add(id);
    }
  }

  static double _tensionStrength(GlobalFusionCrossMirrorTension tension) {
    return switch (tension.reasonCode) {
      'cross_mirror_polarity_divergence' => 0.55,
      'cross_mirror_signal_conflict' => 0.50,
      _ => 0.45,
    };
  }

  static double _blindSpotStrength(GlobalFusionCrossMirrorBlindSpot blindSpot) {
    return switch (blindSpot.reasonCode) {
      'single_source_dimension' => 0.42,
      'mirror_coverage_gap' => 0.40,
      _ => 0.38,
    };
  }

  static String _patternId(String patternKey, String fusionFindingId) {
    final payload = '$patternKey|$fusionFindingId';
    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(payload)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return 'hm_pattern_${hash.toRadixString(16).padLeft(8, '0')}';
  }

  static List<GlobalFusionEvidence> fusionEvidenceForFinding(
    GlobalFusionSnapshot fusionSnapshot,
    String fusionFindingId,
  ) {
    return fusionSnapshot.evidence
        .where((row) => row.globalFindingId == fusionFindingId)
        .toList(growable: false);
  }
}
