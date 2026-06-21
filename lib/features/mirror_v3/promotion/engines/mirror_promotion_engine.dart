import 'dart:convert';

import '../../enums/knowme_mirror_dimension_id.dart';
import '../../enums/knowme_mirror_system_id.dart';
import '../../engine/models/knowme_mirror_engine_input.dart';
import '../../engine/models/knowme_mirror_engine_result.dart';
import '../../models/knowme_mirror_object.dart';
import '../domain/knowme_mirror_promoted_finding.dart';
import '../registry/mirror_promotion_registry.dart';

/// MV2 — additive mirror promotion after MV1, before snapshot serialization.
abstract final class MirrorPromotionEngine {
  static List<KnowMeMirrorPromotedFinding> apply({
    required KnowMeMirrorEngineResult engineResult,
    required KnowMeMirrorEngineInput input,
  }) {
    final results = <KnowMeMirrorPromotedFinding>[];

    for (final rule in MirrorPromotionRegistry.v1Rules) {
      if (!rule.enabled) continue;
      for (final mirrorKey in rule.targetMirrorKeys) {
        final finding = _evaluateMp001(
          rule: rule,
          mirrorKey: mirrorKey,
          engineResult: engineResult,
          input: input,
        );
        if (finding != null) results.add(finding);
      }
    }

    results.sort((a, b) => a.id.compareTo(b.id));
    return results;
  }

  static KnowMeMirrorPromotedFinding? _evaluateMp001({
    required MirrorPromotionRuleDefinition rule,
    required String mirrorKey,
    required KnowMeMirrorEngineResult engineResult,
    required KnowMeMirrorEngineInput input,
  }) {
    if (engineResult.agreements.any((a) => a.mirrorKey == mirrorKey)) {
      return null;
    }
    if (engineResult.reinforcements.any((r) => r.mirrorKey == mirrorKey)) {
      return null;
    }

    final evidenceRows = _evidenceRowsForKey(
      engineResult.bundle.mirrors,
      mirrorKey,
    );
    if (evidenceRows.isEmpty) return null;

    final matchingSignals =
        input.signals.where((s) => s.mirrorKey == mirrorKey).toList();
    if (matchingSignals.isEmpty) return null;
    if (matchingSignals.map((s) => s.systemId).toSet().length != 1) {
      return null;
    }

    final meanConfidence = matchingSignals.fold<double>(
          0,
          (sum, signal) => sum + signal.confidence,
        ) /
        matchingSignals.length;
    if (meanConfidence < rule.minConfidence) return null;

    final themeIds = matchingSignals.map((s) => s.themeId).toSet().toList()
      ..sort();
    final sourceSignalIds = matchingSignals
        .expand((s) => [s.themeId, ...s.signalIds])
        .toSet()
        .toList()
      ..sort();
    final sourceEvidenceRowIds = evidenceRows
        .map((row) => '${row.mirrorObjectId}|${row.sourceThemeId}')
        .toList()
      ..sort();

    final scopeHash = _fnv1aHex(engineResult.bundle.mirrorScopeId);
    final confidence =
        meanConfidence.clamp(0.0, rule.maxPromotedConfidence).toDouble();

    return KnowMeMirrorPromotedFinding(
      id: 'promotion:${rule.ruleId}:$mirrorKey:$scopeHash',
      promotionRuleId: rule.ruleId,
      findingType: 'promoted_agreement',
      patternType: 'promoted_single_system_agreement',
      mirrorKey: mirrorKey,
      mirrorDimension: matchingSignals.first.mirrorDimension.id,
      themeIds: themeIds,
      supportingSystems: [matchingSignals.first.systemId.id],
      supportingLensKeys:
          matchingSignals.map((s) => s.sourceLensKey).toSet().toList()..sort(),
      confidence: confidence,
      sourceSignalIds: sourceSignalIds,
      sourceEvidenceRowIds: sourceEvidenceRowIds,
      riskLevel: 'medium',
    );
  }

  static List<_EvidenceRef> _evidenceRowsForKey(
    List<KnowMeMirrorObject> mirrors,
    String mirrorKey,
  ) {
    final rows = <_EvidenceRef>[];
    for (final mirror in mirrors) {
      if (mirror.mirrorKey != mirrorKey) continue;
      for (final evidenceRef in mirror.evidenceRefs.evidenceRefs) {
        rows.add(
          _EvidenceRef(
            mirrorObjectId: mirror.mirrorId,
            sourceThemeId: evidenceRef.sourceThemeId,
          ),
        );
      }
    }
    return rows;
  }

  static String _fnv1aHex(String payload) {
    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(payload)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

class _EvidenceRef {
  const _EvidenceRef({
    required this.mirrorObjectId,
    required this.sourceThemeId,
  });

  final String mirrorObjectId;
  final String sourceThemeId;
}
