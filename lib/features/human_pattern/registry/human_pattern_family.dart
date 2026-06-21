/// HP3 — structural pattern family grouping.
class HumanPatternFamily {
  const HumanPatternFamily({
    required this.familyId,
    required this.label,
    required this.primaryDimensionKey,
  });

  final String familyId;
  final String label;
  final String primaryDimensionKey;

  Map<String, dynamic> toMap() {
    return {
      'familyId': familyId,
      'label': label,
      'primaryDimensionKey': primaryDimensionKey,
    };
  }
}

/// Frozen v1 pattern families.
abstract final class HumanPatternFamilyCatalog {
  static const families = <HumanPatternFamily>[
    HumanPatternFamily(
      familyId: 'identity_style',
      label: 'Identity Style',
      primaryDimensionKey: 'identity',
    ),
    HumanPatternFamily(
      familyId: 'motivation_style',
      label: 'Motivation Style',
      primaryDimensionKey: 'motivation',
    ),
    HumanPatternFamily(
      familyId: 'thinking_style',
      label: 'Thinking Style',
      primaryDimensionKey: 'thinking',
    ),
    HumanPatternFamily(
      familyId: 'emotional_style',
      label: 'Emotional Style',
      primaryDimensionKey: 'emotion',
    ),
    HumanPatternFamily(
      familyId: 'relationship_style',
      label: 'Relationship Style',
      primaryDimensionKey: 'relationship',
    ),
    HumanPatternFamily(
      familyId: 'decision_style',
      label: 'Decision Style',
      primaryDimensionKey: 'action',
    ),
    HumanPatternFamily(
      familyId: 'growth_style',
      label: 'Growth Style',
      primaryDimensionKey: 'growth',
    ),
    HumanPatternFamily(
      familyId: 'meaning_style',
      label: 'Meaning Style',
      primaryDimensionKey: 'meaning',
    ),
    HumanPatternFamily(
      familyId: 'conflict_pattern',
      label: 'Conflict Pattern',
      primaryDimensionKey: 'action',
    ),
    HumanPatternFamily(
      familyId: 'growth_edge_pattern',
      label: 'Growth Edge Pattern',
      primaryDimensionKey: 'growth',
    ),
    HumanPatternFamily(
      familyId: 'blind_spot_pattern',
      label: 'Blind Spot Pattern',
      primaryDimensionKey: 'relationship',
    ),
    HumanPatternFamily(
      familyId: 'theme_coverage_pattern',
      label: 'Theme Coverage Pattern',
      primaryDimensionKey: 'action',
    ),
  ];

  static HumanPatternFamily? byId(String familyId) {
    for (final family in families) {
      if (family.familyId == familyId) return family;
    }
    return null;
  }
}
