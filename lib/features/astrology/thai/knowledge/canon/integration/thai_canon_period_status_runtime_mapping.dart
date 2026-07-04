import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_data.dart';

import 'thai_canon_ontology_runtime_mapping.dart';

/// Exact runtime/report Thai labels for Canon period rise/fall status.
///
/// Only these two strings are valid — no synonyms, no inference.
abstract final class ThaiCanonPeriodStatusRuntimeMapping {
  static const duengKhuenLabel = 'ดวงขึ้น';
  static const duengTokLabel = 'ดวงตก';

  static const allowedLabels = {duengKhuenLabel, duengTokLabel};

  static const _labelToCanonId = {
    duengKhuenLabel: 'periodStatus.duengKhuen',
    duengTokLabel: 'periodStatus.duengTok',
  };

  static const _canonIdToLabel = {
    'periodStatus.duengKhuen': duengKhuenLabel,
    'periodStatus.duengTok': duengTokLabel,
  };

  /// Runtime/report label → frozen Canon entity id.
  static String? canonIdForRuntimeLabel(String runtimeLabel) {
    if (!allowedLabels.contains(runtimeLabel)) return null;
    return _labelToCanonId[runtimeLabel];
  }

  /// Canon entity id → exact runtime/report label.
  static String? runtimeLabelForCanonId(String canonEntityId) =>
      _canonIdToLabel[canonEntityId];

  static bool isAllowedRuntimeLabel(String? label) =>
      label != null && allowedLabels.contains(label);

  /// Deterministic mapping table for QA documentation.
  static List<ThaiCanonRuntimeMappingEntry> runtimeMappings() {
    return [
      for (final entity in CanonOntologyData.periodStatuses)
        ThaiCanonRuntimeMappingEntry(
          canonEntityId: entity.id,
          runtimeKey: runtimeLabelForCanonId(entity.id),
          kind: ThaiCanonRuntimeKeyKind.periodStatusLabel,
          note: 'Exact Thai report/timeline label only',
        ),
    ];
  }
}
