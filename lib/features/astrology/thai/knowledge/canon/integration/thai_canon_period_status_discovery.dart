import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

import 'thai_canon_period_status_runtime_mapping.dart';

/// Discovers exact period-status labels already present on runtime/report output.
///
/// Does not infer rise/fall from planet, position, or prediction copy.
abstract final class ThaiCanonPeriodStatusDiscovery {
  /// Period index → exact Thai label (`ดวงขึ้น` or `ดวงตก`).
  static Map<int, String> discover(
    ThaiMirrorPipelineResult pipelineResult, {
    Map<int, String>? labelsByPeriodIndex,
  }) {
    if (labelsByPeriodIndex != null) {
      return _validatedLabels(labelsByPeriodIndex);
    }
    return _labelsFromMetadataAudit(audit(pipelineResult));
  }

  /// Full metadata audit for trace / QA (production path).
  static LifePeriodStatusMetadataAudit audit(
    ThaiMirrorPipelineResult pipelineResult,
  ) {
    if (!pipelineResult.isSuccess) {
      return const LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.absentOnRuntime,
        blocker: LifePeriodStatusMetadataBlocker.noLifeTimeline,
      );
    }
    return LifePeriodStatusMetadataResolver.audit(pipelineResult.lifePeriods);
  }

  static Map<int, String> _labelsFromMetadataAudit(
    LifePeriodStatusMetadataAudit metadataAudit,
  ) {
    if (!metadataAudit.isAvailable) return const {};
    final out = <int, String>{};
    for (final entry in metadataAudit.byPeriodIndex.entries) {
      final label = ThaiCanonPeriodStatusRuntimeMapping.runtimeLabelForCanonId(
        entry.value,
      );
      if (label != null) {
        out[entry.key] = label;
      }
    }
    return out;
  }

  static Map<int, String> _validatedLabels(Map<int, String> labels) {
    final out = <int, String>{};
    for (final entry in labels.entries) {
      if (ThaiCanonPeriodStatusRuntimeMapping.isAllowedRuntimeLabel(entry.value)) {
        out[entry.key] = entry.value;
      }
    }
    return out;
  }
}
