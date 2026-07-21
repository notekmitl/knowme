import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

import 'thai_canon_period_status_runtime_mapping.dart';
import 'thai_canon_evidence_index.dart';

/// Discovers exact period-status labels already present on runtime/report output.
///
/// Does not infer rise/fall from planet, position, or prediction copy.
abstract final class ThaiCanonPeriodStatusDiscovery {
  /// Period index → exact Thai label (`ดวงขึ้น` or `ดวงตก`).
  static Map<int, String> discover(
    ThaiMirrorPipelineResult pipelineResult, {
    Map<int, String>? labelsByPeriodIndex,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (labelsByPeriodIndex != null) {
      return _validatedLabels(labelsByPeriodIndex);
    }
    if (pipelineResult.isSuccess && canonIndex != null) {
      return LifePeriodStatusMetadataResolver.runtimeLabelsByPeriodIndex(
        pipelineResult.lifePeriods,
        profile: pipelineResult.profile,
        birthData: pipelineResult.birthData,
        canonIndex: canonIndex,
      );
    }
    return _labelsFromMetadataAudit(
      audit(pipelineResult, canonIndex: canonIndex),
    );
  }

  /// Full metadata audit for trace / QA (production path).
  static LifePeriodStatusMetadataAudit audit(
    ThaiMirrorPipelineResult pipelineResult, {
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (!pipelineResult.isSuccess) {
      final positionFeasibility =
          ThaiLifePeriodPositionMetadataFeasibility.audit(
        timeline: null,
        profile: null,
      );
      final feasibility = ThaiLifePeriodRiseFallFeasibility.audit(
        timeline: null,
        profile: null,
      );
      return LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.absentOnRuntime,
        blocker: LifePeriodStatusMetadataBlocker.noLifeTimeline,
        feasibility: feasibility,
        positionFeasibility: positionFeasibility,
      );
    }
    return LifePeriodStatusMetadataResolver.audit(
      pipelineResult.lifePeriods,
      profile: pipelineResult.profile,
      birthData: pipelineResult.birthData,
      canonIndex: canonIndex,
    );
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
