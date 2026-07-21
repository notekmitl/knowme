import 'dart:convert';

import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_evidence.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';

import '../domain/human_pattern.dart';
import '../mapping/fusion_to_human_mapper.dart';
import 'runtime_theme_meaning_catalog.dart';

/// HPC4 — maps fusion evidence themes to human meaning patterns.
abstract final class FusionEvidenceToHumanMapper {
  static FusionToHumanMappingResult map(GlobalFusionSnapshot fusionSnapshot) {
    final patterns = <HumanPattern>[];
    final fusionFindingByPatternId = <String, String>{};
    final usedPatternKeys = <String>{};

    final themeEvidence = _groupEvidenceByTheme(fusionSnapshot.evidence);

    for (final entry in themeEvidence.entries) {
      final definition = RuntimeThemeMeaningCatalog.byThemeId(entry.key);
      if (definition == null) continue;
      if (usedPatternKeys.contains(definition.patternKey)) continue;

      final rows = entry.value;
      if (rows.isEmpty) continue;

      final strength = _themeStrength(rows, definition.baseStrength);
      final mirrorKeys = rows.map((row) => row.mirrorKey).toSet().toList()..sort();
      final fusionFindingIds =
          rows.map((row) => row.globalFindingId).toSet().toList()..sort();

      final patternId = _patternId(definition.patternKey, entry.key);
      patterns.add(
        HumanPattern(
          id: patternId,
          patternKey: definition.patternKey,
          label: definition.label,
          primaryDimension: definition.primaryDimension,
          secondaryDimensions: definition.secondaryDimensions,
          fusionFindingIds: fusionFindingIds,
          fusionFindingType: 'theme_evidence',
          supportingMirrorKeys: mirrorKeys,
          patternStrength: strength,
        ),
      );

      fusionFindingByPatternId[patternId] = fusionFindingIds.first;
      usedPatternKeys.add(definition.patternKey);
    }

    patterns.sort((a, b) => a.patternKey.compareTo(b.patternKey));
    return FusionToHumanMappingResult(
      patterns: List.unmodifiable(patterns),
      fusionFindingByPatternId: Map.unmodifiable(fusionFindingByPatternId),
    );
  }

  static Map<String, List<GlobalFusionEvidence>> _groupEvidenceByTheme(
    List<GlobalFusionEvidence> evidence,
  ) {
    final grouped = <String, List<GlobalFusionEvidence>>{};
    for (final row in evidence) {
      final themeId = row.sourceThemeId;
      if (themeId.startsWith('fusion_finding:')) continue;
      grouped.putIfAbsent(themeId, () => []).add(row);
    }
    return grouped;
  }

  static double _themeStrength(
    List<GlobalFusionEvidence> rows,
    double baseStrength,
  ) {
    if (rows.isEmpty) return baseStrength;
    final avgWeight =
        rows.map((row) => row.weight).reduce((a, b) => a + b) / rows.length;
    return ((baseStrength + avgWeight) / 2).clamp(0.35, 0.75);
  }

  static String _patternId(String patternKey, String themeId) {
    final payload = '$patternKey|$themeId';
    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(payload)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return 'hm_theme_${hash.toRadixString(16).padLeft(8, '0')}';
  }
}
