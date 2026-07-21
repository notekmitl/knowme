import '../../domain/global_core_themes.dart';

/// Curated cross-mirror tension pairs (GF-F1 — deterministic only).
class GlobalTensionPair {
  const GlobalTensionPair({
    required this.themeA,
    required this.themeB,
    required this.reason,
  });

  final String themeA;
  final String themeB;
  final String reason;
}

abstract final class GlobalTensionPairRegistry {
  static const pairs = <GlobalTensionPair>[
    GlobalTensionPair(
      themeA: GlobalThemeIds.structure,
      themeB: GlobalThemeIds.adaptability,
      reason: 'structure_adaptability_divergence',
    ),
    GlobalTensionPair(
      themeA: GlobalThemeIds.relationships,
      themeB: GlobalThemeIds.reflection,
      reason: 'relationships_reflection_divergence',
    ),
    GlobalTensionPair(
      themeA: GlobalThemeIds.growth,
      themeB: GlobalThemeIds.structure,
      reason: 'growth_structure_divergence',
    ),
  ];
}
