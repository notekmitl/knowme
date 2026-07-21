import '../pipeline/synthetic_human_run_record.dart';

/// Detects narrative collapse — many profiles producing identical narrative text.
class NarrativeDuplicationAudit {
  const NarrativeDuplicationAudit({
    required this.populationSize,
    required this.uniqueNarratives,
    required this.duplicatedNarrativeGroups,
    required this.collapseZones,
    required this.maxDuplicationClusterSize,
    required this.duplicationRate,
  });

  final int populationSize;
  final int uniqueNarratives;
  final List<NarrativeDuplicationGroup> duplicatedNarrativeGroups;
  final List<NarrativeCollapseZone> collapseZones;
  final int maxDuplicationClusterSize;
  final double duplicationRate;

  static NarrativeDuplicationAudit analyze(List<SyntheticHumanRunRecord> records) {
    final grouped = <String, List<String>>{};
    for (final record in records) {
      grouped
          .putIfAbsent(record.narrativeFingerprint, () => [])
          .add(record.profile.profileId);
    }

    final duplicateGroups = grouped.entries
        .where((entry) => entry.value.length > 1)
        .map(
          (entry) => NarrativeDuplicationGroup(
            profileIds: List<String>.from(entry.value)..sort(),
            clusterSize: entry.value.length,
          ),
        )
        .toList()
      ..sort((a, b) => b.clusterSize.compareTo(a.clusterSize));

    final collapseZones = duplicateGroups
        .where((group) => group.clusterSize >= 3)
        .map(
          (group) => NarrativeCollapseZone(
            profileIds: group.profileIds,
            clusterSize: group.clusterSize,
          ),
        )
        .toList();

    final duplicatedProfiles = duplicateGroups.fold<int>(
      0,
      (sum, group) => sum + group.clusterSize,
    );

    return NarrativeDuplicationAudit(
      populationSize: records.length,
      uniqueNarratives: grouped.length,
      duplicatedNarrativeGroups: duplicateGroups,
      collapseZones: collapseZones,
      maxDuplicationClusterSize:
          duplicateGroups.isEmpty ? 1 : duplicateGroups.first.clusterSize,
      duplicationRate:
          records.isEmpty ? 0 : duplicatedProfiles / records.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'uniqueNarratives': uniqueNarratives,
      'maxDuplicationClusterSize': maxDuplicationClusterSize,
      'duplicationRate': duplicationRate,
      'collapseZoneCount': collapseZones.length,
      'topDuplicateClusters': duplicatedNarrativeGroups
          .take(10)
          .map((item) => item.toJson())
          .toList(),
    };
  }
}

class NarrativeDuplicationGroup {
  const NarrativeDuplicationGroup({
    required this.profileIds,
    required this.clusterSize,
  });

  final List<String> profileIds;
  final int clusterSize;

  Map<String, dynamic> toJson() {
    return {
      'clusterSize': clusterSize,
      'profileIds': profileIds,
    };
  }
}

class NarrativeCollapseZone {
  const NarrativeCollapseZone({
    required this.profileIds,
    required this.clusterSize,
  });

  final List<String> profileIds;
  final int clusterSize;
}
