import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/v2/config/global_fusion_recovery_config.dart';
import 'package:knowme/features/human_model/lineage/human_lineage_trace.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';
import 'package:knowme/features/human_pattern/lineage/pattern_lineage_trace.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_system_id.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_mode.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_evidence_brancher.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_intelligence_layer.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_interaction_type.dart';

import '../models/real_user_export_record.dart';
import '../pipeline/real_user_pipeline_runner.dart';

/// Real User Runtime Validation V1 — Firestore export audit + pipeline replay.
void main() {
  stdout.writeln('Real User Runtime Validation V1...');

  final exportPath =
      'test/validation/real_user_runtime_v1/output/firestore_user_export.json';
  final exportFile = File(exportPath);
  if (!exportFile.existsSync()) {
    stderr.writeln('Missing export: $exportPath');
    stderr.writeln(
      'Run: python test/validation/real_user_runtime_v1/export/firestore_user_export.py',
    );
    exit(1);
  }

  final export = RealUserExportExportFile.parseFile(exportFile.readAsStringSync());
  final users = export.users;

  final previousEnabled = GlobalFusionRecoveryConfig.enabled;
  final previousPromotion = GlobalFusionRecoveryConfig.promotionEnabled;
  final previousSupplemental = GlobalFusionRecoveryConfig.supplementalEnabled;
  GlobalFusionRecoveryConfig.enabled = true;
  GlobalFusionRecoveryConfig.promotionEnabled = true;
  GlobalFusionRecoveryConfig.supplementalEnabled = true;

  try {
    final funnel = _emptyCounts([
      'totalUsers',
      'withProfile',
      'withThaiBirthInput',
      'withBaziChart',
      'withWesternChart',
      'withMbti',
      'withBigFive',
      'withEq',
      'reachingMirror',
      'reachingGf1',
      'reachingGf2',
      'reachingHumanModel',
      'reachingHumanPattern',
      'reachingNarrative',
    ]);

    final patternCounts = <String, int>{
      for (final id in HumanPatternRegistry.allPatternIds) id: 0,
    };
    final familyCounts = <String, int>{};
    final narrativeCounts = <String, int>{};
    final evidenceFingerprintCounts = <String, int>{};
    final topologyFingerprintCounts = <String, int>{};
    final lensContribution = _emptyLensContribution();
    final failures = _emptyFailureCounts();
    final perUser = <Map<String, dynamic>>[];

    var determinismPass = 0;
    var pipelineRuns = 0;

    for (var i = 0; i < users.length; i++) {
      final user = users[i];
      funnel['totalUsers'] = funnel['totalUsers']! + 1;
      if (user.hasProfile) funnel['withProfile'] = funnel['withProfile']! + 1;
      if (user.hasThaiBirthInput) {
        funnel['withThaiBirthInput'] = funnel['withThaiBirthInput']! + 1;
      }
      if (user.hasBaziChart) funnel['withBaziChart'] = funnel['withBaziChart']! + 1;
      if (user.hasWesternChart) {
        funnel['withWesternChart'] = funnel['withWesternChart']! + 1;
      }
      if (user.hasMbti) funnel['withMbti'] = funnel['withMbti']! + 1;
      if (user.hasBigFive) funnel['withBigFive'] = funnel['withBigFive']! + 1;
      if (user.hasEq) funnel['withEq'] = funnel['withEq']! + 1;

      final generatedAt = DateTime.utc(2026, 6, 21, i % 24, i % 60);
      final result = RealUserPipelineRunner.run(
        user,
        generatedAt: generatedAt,
      );
      pipelineRuns++;

      if (result.reachedMirror) funnel['reachingMirror'] = funnel['reachingMirror']! + 1;
      if (result.reachedGf1) funnel['reachingGf1'] = funnel['reachingGf1']! + 1;
      if (result.reachedGf2) funnel['reachingGf2'] = funnel['reachingGf2']! + 1;
      if (result.reachedHumanModel) {
        funnel['reachingHumanModel'] = funnel['reachingHumanModel']! + 1;
      }
      if (result.reachedHumanPattern) {
        funnel['reachingHumanPattern'] = funnel['reachingHumanPattern']! + 1;
      }
      if (result.reachedNarrative) {
        funnel['reachingNarrative'] = funnel['reachingNarrative']! + 1;
      }

      _accumulateLensContribution(lensContribution, result);
      _auditFailures(failures, user, result);

      final replay = RealUserPipelineRunner.run(
        user,
        generatedAt: generatedAt,
      );
      if (replay.narrativeFingerprint == result.narrativeFingerprint) {
        determinismPass++;
      }

      if (!result.reachedHumanPattern) {
        perUser.add({
          'uid': user.uid,
          'automationAccount': user.looksLikeAutomationAccount,
          'reachedNarrative': false,
          'errors': result.pipelineErrors,
        });
        continue;
      }

      final snapshot = result.humanPatternSnapshot!;
      for (final activation in snapshot.activations) {
        patternCounts[activation.patternId] =
            (patternCounts[activation.patternId] ?? 0) + 1;
        familyCounts[activation.patternFamilyId] =
            (familyCounts[activation.patternFamilyId] ?? 0) + 1;
      }

      final narrativeFingerprint = result.narrativeFingerprint;
      if (narrativeFingerprint.isEmpty) {
        failures['emptyNarrative'] = failures['emptyNarrative']! + 1;
      } else {
        narrativeCounts[narrativeFingerprint] =
            (narrativeCounts[narrativeFingerprint] ?? 0) + 1;
      }

      final plans = NarrativeIntelligenceLayer.buildPlans(snapshot);
      final evidenceFingerprint =
          NarrativeEvidenceBrancher.evidenceFingerprintForPlans(plans);
      evidenceFingerprintCounts[evidenceFingerprint] =
          (evidenceFingerprintCounts[evidenceFingerprint] ?? 0) + 1;

      final topologyByMode =
          NarrativeIntelligenceLayer.topologyForSnapshot(snapshot);
      final topologyFingerprint = plans
          .map(
            (plan) =>
                '${plan.mode.key}:${topologyByMode[plan.mode]?.name ?? "standard"}:${plan.interactionType.key}:${plan.referencedPatternIds.join("+")}',
          )
          .join('|');
      topologyFingerprintCounts[topologyFingerprint] =
          (topologyFingerprintCounts[topologyFingerprint] ?? 0) + 1;

      if (snapshot.activations.length < 8) {
        failures['lowPatternCoverage'] = failures['lowPatternCoverage']! + 1;
      }
      if (result.gf2AgreementCount == 0 && result.gf2ReinforcementCount == 0) {
        failures['noGf2Benefit'] = failures['noGf2Benefit']! + 1;
      }

      if (!HumanLineageTrace.hasCompleteLineage(result.humanModelSnapshot!) ||
          (!PatternLineageTrace.hasCompleteLineage(snapshot) &&
              snapshot.activations.isNotEmpty)) {
        failures['missingLineage'] = failures['missingLineage']! + 1;
      }

      final topPatternShare = _topPatternShare(snapshot.activations);
      if (topPatternShare >= 0.45) {
        failures['abnormalConcentration'] =
            failures['abnormalConcentration']! + 1;
      }

      perUser.add({
        'uid': user.uid,
        'automationAccount': user.looksLikeAutomationAccount,
        'reachedNarrative': result.reachedNarrative,
        'activatedPatternCount': snapshot.activations.length,
        'narrativeParagraphCount': result.narrativeResult?.paragraphCount ?? 0,
        'gf2Agreements': result.gf2AgreementCount,
        'gf2Reinforcements': result.gf2ReinforcementCount,
        'errors': result.pipelineErrors,
      });
    }

    final activePatternIds = patternCounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();
    final deadPatternIds = patternCounts.entries
        .where((entry) => entry.value == 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();

    final narrativeClusterSizes = narrativeCounts.values.toList()..sort();
    final maxCluster =
        narrativeClusterSizes.isEmpty ? 0 : narrativeClusterSizes.last;
    final profilesInCollapse =
        narrativeCounts.values.where((count) => count >= 3).fold<int>(
              0,
              (sum, count) => sum + count,
            );
    final duplicateNarratives = users.length - narrativeCounts.length;

    final syntheticBaseline = _loadSyntheticBaseline();
    final report = {
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'exportSource': exportPath,
      'exportMetadata': {
        'exportedAt': export.exportedAt,
        'populationSize': export.populationSize,
      },
      'runtimeFunnel': funnel,
      'patternDistribution': {
        'totalActivations': patternCounts.values.fold<int>(0, (s, c) => s + c),
        'activePatternCount': activePatternIds.length,
        'deadPatternCount': deadPatternIds.length,
        'patternFamilyDistribution': familyCounts,
        'patternConcentration': _patternConcentration(patternCounts),
        'topPatterns': _topEntries(patternCounts, 10),
      },
      'narrativeDiversity': {
        'pipelineRunsWithNarrative': narrativeCounts.length,
        'uniqueNarratives': narrativeCounts.length,
        'duplicateNarratives': duplicateNarratives,
        'profilesInCollapse': profilesInCollapse,
        'maxClusterSize': maxCluster,
        'uniqueEvidenceFingerprints': evidenceFingerprintCounts.length,
        'uniqueTopologyFingerprints': topologyFingerprintCounts.length,
        'deterministicReplayRate':
            pipelineRuns == 0 ? 0 : determinismPass / pipelineRuns,
      },
      'lensContribution': lensContribution,
      'failureAudit': failures,
      'syntheticComparison': _compareSyntheticReal(
        synthetic: syntheticBaseline,
        realPopulation: users.length,
        realFunnel: funnel,
        realNarrative: {
          'uniqueNarratives': narrativeCounts.length,
          'profilesInCollapse': profilesInCollapse,
          'maxClusterSize': maxCluster,
          'uniqueEvidenceFingerprints': evidenceFingerprintCounts.length,
        },
        realPatterns: {
          'activePatternCount': activePatternIds.length,
          'totalActivations': patternCounts.values.fold<int>(0, (s, c) => s + c),
        },
      ),
      'perUserSummary': perUser,
    };

    const outJson =
        'test/validation/real_user_runtime_v1/output/real_user_runtime_validation_v1.json';
    File(outJson)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));

    stdout.writeln('Wrote $outJson');
    stdout.writeln(jsonEncode({
      'funnel': funnel,
      'narrative': report['narrativeDiversity'],
      'failures': failures,
    }));
  } finally {
    GlobalFusionRecoveryConfig.enabled = previousEnabled;
    GlobalFusionRecoveryConfig.promotionEnabled = previousPromotion;
    GlobalFusionRecoveryConfig.supplementalEnabled = previousSupplemental;
  }
}

Map<String, int> _emptyCounts(List<String> keys) {
  return {for (final key in keys) key: 0};
}

Map<String, int> _emptyFailureCounts() {
  return {
    'pipelineBlockedMissingInputs': 0,
    'emptyNarrative': 0,
    'lowPatternCoverage': 0,
    'noGf2Benefit': 0,
    'missingLineage': 0,
    'abnormalConcentration': 0,
  };
}

Map<String, dynamic> _emptyLensContribution() {
  const layers = ['mirror', 'fusion', 'humanModel', 'humanPattern', 'narrative'];
  const lenses = [
    'thaiAstrology',
    'bazi',
    'chineseZodiac',
    'mbti',
    'bigFive',
    'eq',
  ];
  return {
    for (final layer in layers)
      layer: {for (final lens in lenses) lens: 0},
  };
}

void _accumulateLensContribution(
  Map<String, dynamic> contribution,
  RealUserPipelineResult result,
) {
  final astrologyInput = result.astrologyInput;
  final personalityInput = result.personalityInput;
  if (astrologyInput != null) {
    for (final signal in astrologyInput.signals) {
      final lens = _lensFromMirrorSignal(signal.systemId, signal.sourceLensKey);
      _inc(contribution, 'mirror', lens);
    }
    if (result.user.hasBaziChart) {
      _inc(contribution, 'mirror', 'chineseZodiac');
    }
  }
  if (personalityInput != null) {
    for (final signal in personalityInput.signals) {
      final lens = _lensFromMirrorSignal(signal.systemId, signal.sourceLensKey);
      _inc(contribution, 'mirror', lens);
    }
  }

  final fusion = result.effectiveFusion;
  final humanModel = result.humanModelSnapshot;
  final humanPattern = result.humanPatternSnapshot;
  final narrative = result.narrativeResult;

  if (fusion != null) {
    for (final agreement in fusion.agreements) {
      for (final roleId in agreement.mirrorRoleIds) {
        final lens = _lensFromMirrorRoleAndKey(roleId, agreement.mirrorKey);
        _inc(contribution, 'fusion', lens);
      }
    }
    for (final tension in fusion.tensions) {
      _inc(
        contribution,
        'fusion',
        _lensFromMirrorRoleAndKey(
          tension.positiveMirrorRoleId,
          tension.mirrorKey,
        ),
      );
      _inc(
        contribution,
        'fusion',
        _lensFromMirrorRoleAndKey(
          tension.tensionMirrorRoleId,
          tension.mirrorKey,
        ),
      );
    }
    for (final reinforcement in fusion.reinforcements) {
      for (final roleId in reinforcement.mirrorRoleIds) {
        _inc(
          contribution,
          'fusion',
          _lensFromMirrorRoleAndKey(roleId, reinforcement.mirrorKey),
        );
      }
    }
    for (final blindSpot in fusion.blindSpots) {
      _inc(
        contribution,
        'fusion',
        _lensFromMirrorRoleAndKey(
          blindSpot.reflectingMirrorRoleId,
          blindSpot.mirrorKey,
        ),
      );
      _inc(
        contribution,
        'fusion',
        _lensFromMirrorRoleAndKey(
          blindSpot.blindMirrorRoleId,
          blindSpot.mirrorKey,
        ),
      );
    }
  }

  if (humanModel != null) {
    for (final pattern in humanModel.patterns) {
      for (final mirrorKey in pattern.supportingMirrorKeys) {
        final lens = _lensFromMirrorKey(mirrorKey);
        _inc(contribution, 'humanModel', lens);
      }
    }
  }

  if (humanPattern != null) {
    for (final activation in humanPattern.activations) {
      for (final evidence in humanPattern.evidence) {
        if (evidence.activationId != activation.activationId) continue;
        final lens = _lensFromEvidence(evidence);
        _inc(contribution, 'humanPattern', lens);
      }
    }
  }

  if (narrative != null) {
    for (final section in narrative.sections) {
      for (final paragraph in section.paragraphs) {
        for (final evidence in paragraph.evidence) {
          final lens = _lensFromMirrorRoleAndKey(
            evidence.lineage.mirrorRoleId,
            evidence.lineage.sourceThemeId,
          );
          _inc(contribution, 'narrative', lens);
        }
      }
    }
  }
}

void _auditFailures(
  Map<String, int> failures,
  RealUserExportRecord user,
  RealUserPipelineResult result,
) {
  if (result.pipelineErrors.isNotEmpty) {
    failures['pipelineBlockedMissingInputs'] =
        failures['pipelineBlockedMissingInputs']! + 1;
  }
}

String _lensFromMirrorSignal(
  KnowMeMirrorSystemId systemId,
  String sourceLensKey,
) {
  if (sourceLensKey == 'chinese_bazi') return 'bazi';
  return switch (systemId) {
    KnowMeMirrorSystemId.thaiAstrology => 'thaiAstrology',
    KnowMeMirrorSystemId.mbti => 'mbti',
    KnowMeMirrorSystemId.bigFive => 'bigFive',
    KnowMeMirrorSystemId.eq => 'eq',
    KnowMeMirrorSystemId.knowMeMirror => 'bazi',
  };
}

String _lensFromMirrorRoleAndKey(String mirrorRoleId, String keyOrTheme) {
  final normalizedKey = keyOrTheme.toLowerCase();
  if (normalizedKey.contains('bazi') ||
      normalizedKey.contains('zodiac') ||
      normalizedKey.contains('day_master')) {
    return 'bazi';
  }
  if (mirrorRoleId.contains('personality')) {
    if (normalizedKey.contains('mbti')) return 'mbti';
    if (normalizedKey.contains('big') || normalizedKey.contains('five')) {
      return 'bigFive';
    }
    if (normalizedKey.contains('eq')) return 'eq';
    return 'mbti';
  }
  return 'thaiAstrology';
}

String _lensFromMirrorKey(String mirrorKey) {
  final normalized = mirrorKey.toLowerCase();
  if (normalized.contains('bazi') || normalized.contains('zodiac')) {
    return 'bazi';
  }
  if (normalized.contains('mbti')) return 'mbti';
  if (normalized.contains('big') || normalized.contains('five')) {
    return 'bigFive';
  }
  if (normalized.contains('eq')) return 'eq';
  return 'thaiAstrology';
}

String _lensFromFusionSource(String mirrorRoleId, String systemId) {
  if (mirrorRoleId.contains('astrology')) {
    if (systemId.contains('bazi') || systemId == 'knowme_mirror') {
      return 'bazi';
    }
    return 'thaiAstrology';
  }
  if (systemId.contains('mbti')) return 'mbti';
  if (systemId.contains('big_five') || systemId.contains('bigfive')) {
    return 'bigFive';
  }
  if (systemId.contains('eq')) return 'eq';
  return 'thaiAstrology';
}

String _lensFromEvidence(PatternEvidence evidence) {
  if (evidence.mirrorKey.contains('BAZI') ||
      evidence.sourceThemeId.contains('bazi') ||
      evidence.fusionFindingId.contains('bazi')) {
    return 'bazi';
  }
  return _lensFromEvidenceLineage(evidence.systemId);
}

String _lensFromEvidenceLineage(String systemId) {
  final normalized = systemId.toLowerCase();
  if (normalized.contains('mbti')) return 'mbti';
  if (normalized.contains('big_five') || normalized.contains('bigfive')) {
    return 'bigFive';
  }
  if (normalized.contains('eq')) return 'eq';
  if (normalized.contains('bazi') || normalized.contains('knowme_mirror')) {
    return 'bazi';
  }
  return 'thaiAstrology';
}

void _inc(Map<String, dynamic> contribution, String layer, String lens) {
  final layerMap = contribution[layer] as Map<String, dynamic>;
  layerMap[lens] = (layerMap[lens] as int? ?? 0) + 1;
}

double _topPatternShare(List<dynamic> activations) {
  if (activations.isEmpty) return 0;
  final counts = <String, int>{};
  for (final activation in activations) {
    counts[activation.patternId as String] =
        (counts[activation.patternId as String] ?? 0) + 1;
  }
  final maxCount = counts.values.fold<int>(0, max);
  return maxCount / activations.length;
}

Map<String, dynamic> _patternConcentration(Map<String, int> patternCounts) {
  final values = patternCounts.values.where((count) => count > 0).toList()
    ..sort();
  if (values.isEmpty) {
    return {'giniApprox': 0.0, 'topPatternShare': 0.0};
  }
  final total = values.fold<int>(0, (sum, count) => sum + count);
  final top = values.last / total;
  return {'topPatternShare': top, 'activePatternSlots': values.length};
}

List<Map<String, dynamic>> _topEntries(Map<String, int> counts, int limit) {
  final entries = counts.entries.where((entry) => entry.value > 0).toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries
      .take(limit)
      .map((entry) => {'id': entry.key, 'count': entry.value})
      .toList();
}

Map<String, dynamic> _loadSyntheticBaseline() {
  const path =
      'test/validation/synthetic_population_v3/output/narrative_evidence_branching_v5.json';
  final file = File(path);
  if (!file.existsSync()) {
    return {
      'populationSize': 1000,
      'uniqueNarratives': 1000,
      'profilesInCollapse': 0,
      'maxClusterSize': 1,
      'uniqueEvidenceFingerprints': 999,
      'activePatterns': 30,
      'totalActivations': 13732,
    };
  }
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final metrics = decoded['metrics'] as Map<String, dynamic>;
  return {
    'populationSize': decoded['populationSize'],
    'uniqueNarratives': metrics['uniqueNarratives'],
    'profilesInCollapse': metrics['profilesInCollapse'],
    'maxClusterSize': metrics['maxClusterSize'],
    'uniqueEvidenceFingerprints': metrics['uniqueEvidenceFingerprints'],
    'activePatterns': metrics['activePatterns'],
    'totalActivations': metrics['totalActivations'],
  };
}

Map<String, dynamic> _compareSyntheticReal({
  required Map<String, dynamic> synthetic,
  required int realPopulation,
  required Map<String, int> realFunnel,
  required Map<String, dynamic> realNarrative,
  required Map<String, dynamic> realPatterns,
}) {
  final syntheticSize = synthetic['populationSize'] as int? ?? 1000;
  final realReachNarrative = realFunnel['reachingNarrative'] ?? 0;
  final realReachPattern = realFunnel['reachingHumanPattern'] ?? 0;

  return {
    'syntheticPopulation': syntheticSize,
    'realPopulation': realPopulation,
    'narrativeReachRateReal':
        realPopulation == 0 ? 0 : realReachNarrative / realPopulation,
    'patternReachRateReal':
        realPopulation == 0 ? 0 : realReachPattern / realPopulation,
    'uniqueNarrativesPerCapitaSynthetic':
        (synthetic['uniqueNarratives'] as num? ?? 0) / syntheticSize,
    'uniqueNarrativesPerCapitaReal': realPopulation == 0
        ? 0
        : (realNarrative['uniqueNarratives'] as num? ?? 0) / realPopulation,
    'synthetic': synthetic,
    'real': {
      ...realNarrative,
      ...realPatterns,
      'reachingNarrative': realReachNarrative,
      'reachingHumanPattern': realReachPattern,
    },
    'delta': {
      'uniqueNarratives':
          (realNarrative['uniqueNarratives'] as num? ?? 0) -
              (synthetic['uniqueNarratives'] as num? ?? 0),
      'profilesInCollapse':
          (realNarrative['profilesInCollapse'] as num? ?? 0) -
              (synthetic['profilesInCollapse'] as num? ?? 0),
      'maxClusterSize':
          (realNarrative['maxClusterSize'] as num? ?? 0) -
              (synthetic['maxClusterSize'] as num? ?? 0),
    },
  };
}
