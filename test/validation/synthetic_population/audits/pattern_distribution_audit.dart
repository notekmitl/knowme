import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

import '../pipeline/synthetic_human_run_record.dart';

/// Distribution of activated, dominant, and family-level human patterns.
class PatternDistributionAudit {
  const PatternDistributionAudit({
    required this.populationSize,
    required this.registryPatternCount,
    required this.everActivatedPatternCount,
    required this.neverActivatedPatternIds,
    required this.activationFrequency,
    required this.dominantPatternFrequency,
    required this.patternFamilyFrequency,
    required this.deadZonePatternIds,
  });

  final int populationSize;
  final int registryPatternCount;
  final int everActivatedPatternCount;
  final List<String> neverActivatedPatternIds;
  final Map<String, int> activationFrequency;
  final Map<String, int> dominantPatternFrequency;
  final Map<String, int> patternFamilyFrequency;
  final List<String> deadZonePatternIds;

  static PatternDistributionAudit analyze(List<SyntheticHumanRunRecord> records) {
    final registryIds = HumanPatternRegistry.allPatternIds;
    final activationCounts = <String, int>{};
    final dominantCounts = <String, int>{};
    final familyCounts = <String, int>{};

    for (final record in records) {
      final activations = record.humanPatternSnapshot.activations;
      for (final activation in activations) {
        activationCounts[activation.patternId] =
            (activationCounts[activation.patternId] ?? 0) + 1;

        final entry = HumanPatternRegistry.byId(activation.patternId);
        if (entry != null) {
          familyCounts[entry.patternFamilyId] =
              (familyCounts[entry.patternFamilyId] ?? 0) + 1;
        }
      }

      if (activations.isNotEmpty) {
        final dominant = activations.first.patternId;
        dominantCounts[dominant] = (dominantCounts[dominant] ?? 0) + 1;
      }
    }

    final neverActivated = registryIds
        .where((id) => !(activationCounts.containsKey(id)))
        .toList();

    final deadZones = neverActivated;

    return PatternDistributionAudit(
      populationSize: records.length,
      registryPatternCount: registryIds.length,
      everActivatedPatternCount: activationCounts.length,
      neverActivatedPatternIds: neverActivated,
      activationFrequency: _sortedCounts(activationCounts),
      dominantPatternFrequency: _sortedCounts(dominantCounts),
      patternFamilyFrequency: _sortedCounts(familyCounts),
      deadZonePatternIds: deadZones,
    );
  }

  static Map<String, int> _sortedCounts(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map<String, int>.fromEntries(entries);
  }

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'registryPatternCount': registryPatternCount,
      'everActivatedPatternCount': everActivatedPatternCount,
      'neverActivatedCount': neverActivatedPatternIds.length,
      'neverActivatedPatternIds': neverActivatedPatternIds,
      'deadZonePatternIds': deadZonePatternIds,
      'topActivatedPatterns': activationFrequency.entries
          .take(15)
          .map(
            (entry) => {'patternId': entry.key, 'count': entry.value},
          )
          .toList(),
      'patternFamilyFrequency': patternFamilyFrequency,
      'dominantPatternFrequency': dominantPatternFrequency.entries
          .take(10)
          .map(
            (entry) => {'patternId': entry.key, 'count': entry.value},
          )
          .toList(),
    };
  }
}
