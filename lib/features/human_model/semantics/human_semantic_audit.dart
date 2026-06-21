import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';

import '../mapping/fusion_to_human_mapper.dart';
import 'human_semantic_source_type.dart';

/// HS6 — semantic coverage audit for fusion → human meaning mapping.
class HumanSemanticAuditReport {
  const HumanSemanticAuditReport({
    required this.totalFusionFindings,
    required this.mappedFusionFindings,
    required this.unmappedFusionFindingIds,
    required this.meaningCoverageRate,
    required this.bySourceType,
  });

  final int totalFusionFindings;
  final int mappedFusionFindings;
  final List<String> unmappedFusionFindingIds;
  final double meaningCoverageRate;
  final Map<String, SemanticSourceTypeAudit> bySourceType;
}

class SemanticSourceTypeAudit {
  const SemanticSourceTypeAudit({
    required this.sourceType,
    required this.totalFindings,
    required this.mappedFindings,
    required this.coverageRate,
  });

  final String sourceType;
  final int totalFindings;
  final int mappedFindings;
  final double coverageRate;
}

abstract final class HumanSemanticAudit {
  static HumanSemanticAuditReport analyze(GlobalFusionSnapshot fusionSnapshot) {
    final mapping = FusionToHumanMapper.map(fusionSnapshot);
    final mappedFindingIds =
        mapping.patterns.expand((item) => item.fusionFindingIds).toSet();

    final buckets = <HumanSemanticSourceType, _Bucket>{
      for (final type in HumanSemanticSourceType.values) type: _Bucket(type),
    };

    void count(HumanSemanticSourceType type, String findingId) {
      if (!buckets[type]!.seen.add(findingId)) return;
      buckets[type]!.total++;
      if (mappedFindingIds.contains(findingId)) {
        buckets[type]!.mapped++;
      } else {
        buckets[type]!.unmapped.add(findingId);
      }
    }

    for (final finding in fusionSnapshot.agreements) {
      count(HumanSemanticSourceType.agreement, finding.id);
    }
    for (final finding in fusionSnapshot.tensions) {
      count(HumanSemanticSourceType.tension, finding.id);
    }
    for (final finding in fusionSnapshot.reinforcements) {
      count(HumanSemanticSourceType.reinforcement, finding.id);
    }
    for (final finding in fusionSnapshot.blindSpots) {
      count(HumanSemanticSourceType.blindSpot, finding.id);
    }

    final total = buckets.values.fold<int>(0, (sum, item) => sum + item.total);
    final mapped = buckets.values.fold<int>(0, (sum, item) => sum + item.mapped);
    final unmapped = buckets.values
        .expand((item) => item.unmapped)
        .toSet()
        .toList()
      ..sort();

    final bySourceType = {
      for (final bucket in buckets.values)
        bucket.type.key: SemanticSourceTypeAudit(
          sourceType: bucket.type.key,
          totalFindings: bucket.total,
          mappedFindings: bucket.mapped,
          coverageRate: bucket.total == 0 ? 1.0 : bucket.mapped / bucket.total,
        ),
    };

    return HumanSemanticAuditReport(
      totalFusionFindings: total,
      mappedFusionFindings: mapped,
      unmappedFusionFindingIds: unmapped,
      meaningCoverageRate: total == 0 ? 1.0 : mapped / total,
      bySourceType: bySourceType,
    );
  }
}

class _Bucket {
  _Bucket(this.type);

  final HumanSemanticSourceType type;
  final seen = <String>{};
  var total = 0;
  var mapped = 0;
  final unmapped = <String>{};
}
