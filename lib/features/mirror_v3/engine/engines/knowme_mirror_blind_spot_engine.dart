import '../../enums/knowme_mirror_dimension_id.dart';
import '../../enums/knowme_mirror_pattern_type.dart';
import '../../enums/knowme_mirror_system_id.dart';
import '../models/knowme_mirror_blind_spot.dart';
import '../models/knowme_mirror_theme_signal.dart';

/// Detects dimension coverage gaps and single-source blind spots.
abstract final class KnowMeMirrorBlindSpotEngine {
  static const observedDimensions = KnowMeMirrorDimensionId.values;

  static List<KnowMeMirrorBlindSpot> detect({
    required List<KnowMeMirrorThemeSignal> signals,
    required Set<KnowMeMirrorSystemId> availableSystems,
  }) {
    if (signals.isEmpty && availableSystems.isEmpty) return const [];

    final blindSpots = <KnowMeMirrorBlindSpot>[];
    final dimensionsWithSignals = <KnowMeMirrorDimensionId>{};
    final systemsByDimension = <KnowMeMirrorDimensionId, Set<KnowMeMirrorSystemId>>{};
    final keysByDimension = <KnowMeMirrorDimensionId, Set<String>>{};

    for (final signal in signals) {
      dimensionsWithSignals.add(signal.mirrorDimension);
      systemsByDimension
          .putIfAbsent(signal.mirrorDimension, () => {})
          .add(signal.systemId);
      keysByDimension
          .putIfAbsent(signal.mirrorDimension, () => {})
          .add(signal.mirrorKey);
    }

    for (final dimension in observedDimensions) {
      if (!dimensionsWithSignals.contains(dimension)) {
        blindSpots.add(
          KnowMeMirrorBlindSpot(
            id: 'blind_spot:dimension_gap:${dimension.id}',
            patternType: KnowMeMirrorPatternType.dimensionCoverageGap,
            mirrorDimension: dimension,
            mirrorKey: null,
            reasonCode: 'dimension_coverage_gap',
            availableSystems:
                availableSystems.map((system) => system.id).toList()..sort(),
          ),
        );
      }
    }

    if (availableSystems.length >= 2) {
      for (final entry in systemsByDimension.entries) {
        if (entry.value.length >= 2) continue;

        final keys = keysByDimension[entry.key]?.toList() ?? const <String>[];
        keys.sort();
        blindSpots.add(
          KnowMeMirrorBlindSpot(
            id: 'blind_spot:single_source:${entry.key.id}',
            patternType: KnowMeMirrorPatternType.singleSourceBlindSpot,
            mirrorDimension: entry.key,
            mirrorKey: keys.isNotEmpty ? keys.first : null,
            reasonCode: 'single_source_dimension',
            availableSystems:
                availableSystems.map((system) => system.id).toList()..sort(),
          ),
        );
      }
    }

    blindSpots.sort((a, b) => a.id.compareTo(b.id));
    return blindSpots;
  }
}
