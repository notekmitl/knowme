import '../enums/knowme_mirror_dimension_id.dart';

/// Frozen registry entry for a mirror pattern family.
class KnowMeMirrorRegistryEntry {
  const KnowMeMirrorRegistryEntry({
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.patternFamily,
    required this.registryVersion,
  });

  final String mirrorKey;
  final KnowMeMirrorDimensionId mirrorDimension;
  final String patternFamily;
  final String registryVersion;
}

/// Frozen mirror registry v0.1 — system/content/fusion independent.
abstract final class KnowMeMirrorRegistryV01 {
  static const version = 'v0.1.0';

  static const entries = <KnowMeMirrorRegistryEntry>[
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_SELF_IDENTITY',
      mirrorDimension: KnowMeMirrorDimensionId.identity,
      patternFamily: 'self_identity',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_SELF_EXPRESSION',
      mirrorDimension: KnowMeMirrorDimensionId.expression,
      patternFamily: 'self_expression',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_RELATIONAL_PATTERN',
      mirrorDimension: KnowMeMirrorDimensionId.relationships,
      patternFamily: 'relational_pattern',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_RESOURCE_ORIENTATION',
      mirrorDimension: KnowMeMirrorDimensionId.resources,
      patternFamily: 'resource_orientation',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_ACTION_STYLE',
      mirrorDimension: KnowMeMirrorDimensionId.action,
      patternFamily: 'action_style',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_GROWTH_ORIENTATION',
      mirrorDimension: KnowMeMirrorDimensionId.growth,
      patternFamily: 'growth_orientation',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_PUBLIC_VISIBILITY',
      mirrorDimension: KnowMeMirrorDimensionId.visibility,
      patternFamily: 'public_visibility',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_TRANSFORMATION_PATTERN',
      mirrorDimension: KnowMeMirrorDimensionId.transformation,
      patternFamily: 'transformation_pattern',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_BELIEF_STRUCTURE',
      mirrorDimension: KnowMeMirrorDimensionId.beliefs,
      patternFamily: 'belief_structure',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_INNER_WORLD',
      mirrorDimension: KnowMeMirrorDimensionId.innerWorld,
      patternFamily: 'inner_world',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_LIFE_DIRECTION',
      mirrorDimension: KnowMeMirrorDimensionId.lifeDirection,
      patternFamily: 'life_direction',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_THINKING_PATTERN',
      mirrorDimension: KnowMeMirrorDimensionId.beliefs,
      patternFamily: 'thinking_pattern',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_EMOTIONAL_PATTERN',
      mirrorDimension: KnowMeMirrorDimensionId.innerWorld,
      patternFamily: 'emotional_pattern',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_SUPPORT_PATTERN',
      mirrorDimension: KnowMeMirrorDimensionId.relationships,
      patternFamily: 'support_pattern',
      registryVersion: version,
    ),
    KnowMeMirrorRegistryEntry(
      mirrorKey: 'MIRROR_STRUCTURE_PATTERN',
      mirrorDimension: KnowMeMirrorDimensionId.action,
      patternFamily: 'structure_pattern',
      registryVersion: version,
    ),
  ];

  static final Map<String, KnowMeMirrorRegistryEntry> byKey = {
    for (final entry in entries) entry.mirrorKey: entry,
  };

  static bool contains(String mirrorKey) => byKey.containsKey(mirrorKey);

  static KnowMeMirrorRegistryEntry? get(String mirrorKey) => byKey[mirrorKey];
}
