import '../contracts/knowme_mirror_identity_contract.dart';
import '../enums/knowme_mirror_source_type.dart';
import '../models/knowme_mirror_evidence_ref.dart';
import '../models/knowme_mirror_evidence_refs.dart';
import '../models/knowme_mirror_lineage_chain.dart';
import '../models/knowme_mirror_metadata.dart';
import '../models/knowme_mirror_object.dart';
import 'models/knowme_mirror_agreement.dart';
import 'models/knowme_mirror_theme_signal.dart';

/// Builds mirror objects with preserved evidence lineage.
abstract final class KnowMeMirrorEvidencePreserver {
  static List<KnowMeMirrorObject> buildMirrorObjects({
    required KnowMeMirrorLineageChain lineage,
    required List<KnowMeMirrorThemeSignal> signals,
    required List<KnowMeMirrorAgreement> agreements,
    required double compositeConfidence,
  }) {
    if (signals.isEmpty) return const [];

    final grouped = <String, List<KnowMeMirrorThemeSignal>>{};
    for (final signal in signals) {
      grouped.putIfAbsent(signal.mirrorKey, () => []).add(signal);
    }

    final agreementCounts = _agreementCountByMirrorKey(agreements);
    final mirrors = <KnowMeMirrorObject>[];

    for (final entry in grouped.entries) {
      final group = entry.value;
      final themeIds = group.map((signal) => signal.themeId).toSet().toList()
        ..sort();
      final systems = group.map((signal) => signal.systemId).toSet().toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      final sourceTypes =
          group.map((signal) => signal.sourceType).toSet().toList()
            ..sort((a, b) => a.index.compareTo(b.index));
      final sample = group.first;

      final evidenceRefs = group
          .map(
            (signal) => KnowMeMirrorEvidenceRef(
              systemId: signal.systemId,
              sourceType: signal.sourceType,
              sourceThemeId: signal.themeId,
              sourceSnapshotId: signal.sourceSnapshotId,
              ruleId: signal.mappingRuleId,
              weight: signal.prominence.clamp(0.0, 1.0),
            ),
          )
          .toList(growable: false);

      final interpretationIds = group
          .expand((signal) => signal.interpretationIds)
          .toSet()
          .toList()
        ..sort();
      final signalIds =
          group.expand((signal) => signal.signalIds).toSet().toList()..sort();
      final meaningIds =
          group.expand((signal) => signal.meaningIds).toSet().toList()..sort();

      final prominence = group.fold<double>(
        0,
        (total, signal) => total + signal.prominence,
      );

      final confidence = group.fold<double>(
            0,
            (total, signal) => total + signal.confidence,
          ) /
          group.length;

      final agreementCount = agreementCounts[entry.key] ?? systems.length;
      final composite = systems.length >= 2 ||
          sourceTypes.contains(KnowMeMirrorSourceType.compositeTheme);

      mirrors.add(
        KnowMeMirrorObject(
          mirrorId: KnowMeMirrorIdentityContract.mirrorId(
            mirrorScopeId: lineage.mirrorScopeId,
            mirrorKey: entry.key,
            themeIds: themeIds,
          ),
          mirrorKey: entry.key,
          mirrorDimension: sample.mirrorDimension,
          sourceThemeIds: themeIds,
          sourceSystems: systems,
          sourceTypes: sourceTypes,
          evidenceRefs: KnowMeMirrorEvidenceRefs(
            themeIds: themeIds,
            interpretationIds: interpretationIds,
            signalIds: signalIds,
            meaningIds: meaningIds,
            evidenceRefs: evidenceRefs,
            lineage: lineage,
          ),
          metadata: KnowMeMirrorMetadata(
            prominence: prominence,
            confidence: confidence.clamp(0.0, 1.0),
            agreementCount: agreementCount,
            sourceCount: themeIds.length,
            composite: composite,
          ),
        ),
      );
    }

    mirrors.sort((a, b) => a.mirrorKey.compareTo(b.mirrorKey));
    return mirrors;
  }

  static Map<String, int> _agreementCountByMirrorKey(
    List<KnowMeMirrorAgreement> agreements,
  ) {
    final counts = <String, int>{};
    for (final agreement in agreements) {
      counts[agreement.mirrorKey] = agreement.supportingSystems.length;
    }
    return counts;
  }
}
