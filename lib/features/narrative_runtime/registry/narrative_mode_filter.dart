import 'package:knowme/features/human_model/domain/human_dimension.dart';

import '../domain/narrative_mode.dart';

/// Maps activated patterns to narrative modes using family + dimension keys.
abstract final class NarrativeModeFilter {
  static const _identityFamilies = {
    'identity_style',
    'meaning_style',
  };

  static const _relationshipFamilies = {
    'relationship_style',
    'blind_spot_pattern',
  };

  static const _decisionFamilies = {
    'decision_style',
    'conflict_pattern',
    'theme_coverage_pattern',
  };

  static const _growthFamilies = {
    'growth_style',
    'growth_edge_pattern',
  };

  static NarrativeMode primaryMode({
    required String patternFamilyId,
    required HumanDimensionId dimension,
  }) {
    if (_identityFamilies.contains(patternFamilyId) ||
        dimension == HumanDimensionId.identity ||
        dimension == HumanDimensionId.meaning) {
      return NarrativeMode.identity;
    }
    if (_relationshipFamilies.contains(patternFamilyId) ||
        dimension == HumanDimensionId.relationship ||
        dimension == HumanDimensionId.emotion) {
      return NarrativeMode.relationship;
    }
    if (_decisionFamilies.contains(patternFamilyId) ||
        dimension == HumanDimensionId.action ||
        dimension == HumanDimensionId.thinking) {
      return NarrativeMode.decision;
    }
    if (_growthFamilies.contains(patternFamilyId) ||
        dimension == HumanDimensionId.growth ||
        dimension == HumanDimensionId.motivation) {
      return NarrativeMode.growth;
    }

    return switch (dimension) {
      HumanDimensionId.identity || HumanDimensionId.meaning =>
        NarrativeMode.identity,
      HumanDimensionId.relationship || HumanDimensionId.emotion =>
        NarrativeMode.relationship,
      HumanDimensionId.action || HumanDimensionId.thinking =>
        NarrativeMode.decision,
      HumanDimensionId.growth || HumanDimensionId.motivation =>
        NarrativeMode.growth,
    };
  }

  static List<NarrativeMode> allModes() => NarrativeMode.values;
}
