import '../adapters/lens_theme_output.dart';
import '../application/three_tradition_consensus.dart';

/// A reviewed opposition in a main life-area claim. The original adapter
/// observations stay attached for audit, but are not shown on the report page.
class ThreeTraditionCoreConflict {
  const ThreeTraditionCoreConflict({
    required this.title,
    required this.axis,
    required this.sources,
  });

  final String title;
  final String axis;
  final Map<String, LensThemeOutput> sources;
}

/// Vetoes only a direct, reviewed contradiction on the same life-area axis.
/// General differences such as preferring space and remaining loyal, or
/// balancing routine with variety, are not contradictory predictions.
abstract final class ThreeTraditionCoreConflictGuard {
  static ThreeTraditionCoreConflict? find({
    required String title,
    required ThreeTraditionReading reading,
  }) {
    // The current registered outputs contain just one defensible opposing
    // pair relevant to a main topic: how openly feelings are disclosed in a
    // relationship. No reviewed opposite pair exists yet for work, money, or
    // wellbeing, so those topics are never vetoed by broad theme families.
    if (title != 'ความสัมพันธ์') return null;

    final sources = <String, LensThemeOutput>{};
    for (final lens in ThreeTraditionConsensus.lensOrder) {
      final candidates = (reading.byLens[lens] ?? const <LensThemeOutput>[])
          .where(
            (item) =>
                (item.themeId == 'expressive' || item.themeId == 'reserved') &&
                item.confidence >=
                    ThreeTraditionConsensus.minimumAgreementConfidence &&
                item.evidence.any((fact) => fact.trim().isNotEmpty),
          )
          .toList();
      // A lens with no observation, or with both directions, cannot establish
      // a clear three-lens contradiction on this axis.
      if (candidates.length != 1) return null;
      sources[lens] = candidates.single;
    }
    if (sources.values.map((item) => item.themeId).toSet().length != 2) {
      return null;
    }
    return ThreeTraditionCoreConflict(
      title: title,
      axis: 'relationship_disclosure',
      sources: Map.unmodifiable(sources),
    );
  }
}
