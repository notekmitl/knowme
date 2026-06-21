import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/human_pattern/engines/pattern_activation_engine.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_activation_rule.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';

import '../../human_pattern_activation_audit/pattern_activation_forensics.dart';
import '../../synthetic_population_v2/simulation/validation_v2_recovery_simulator.dart';
import '../../synthetic_population/models/synthetic_human_profile.dart';
import '../../synthetic_population/pipeline/synthetic_human_run_record.dart';
import '../factory/synthetic_human_profile_factory_v3.dart';
import '../pipeline/synthetic_human_pipeline_runner_v3.dart';

/// Read-only forensic audit for all V1-dead human patterns.
void main() {
  stdout.writeln('Dead zone forensics — building V3 population...');
  const v1DeadPatterns = [
    'adaptive_creator',
    'adaptive_growth',
    'asymmetric_identity_development',
    'belief_architect',
    'belief_meaning',
    'emotional_depth',
    'identity_dual_signal',
    'internal_conflict_thinker',
    'meaning_seeker',
    'progressive_builder',
    'purpose_driven_motivation',
    'reflective_builder',
    'reinforced_strength',
    'relationship_stabilizer',
    'resource_oriented_motivation',
    'stable_orientation',
    'structured_explorer',
    'structured_operator',
    'transformation_seeker',
    'visible_identity',
  ];

  final profiles = SyntheticHumanProfileFactoryV3.buildAll();
  final forensics = {
    for (final id in v1DeadPatterns) id: _PatternForensic(id),
  };

  final baselineNarratives = <String>[];
  final gf2Narratives = <String>[];
  final cachedRecords = <SyntheticHumanRunRecord>[];
  final cachedSims = <ValidationV2SimulationResult>[];

  for (var i = 0; i < profiles.length; i++) {
    final record = SyntheticHumanPipelineRunnerV3.run(
      profiles[i],
      generatedAt: DateTime.utc(2026, 6, 21, i % 24, i % 60),
    );
    final sim = ValidationV2RecoverySimulator.simulateRecord(record);
    cachedRecords.add(record);
    cachedSims.add(sim);
    baselineNarratives.add(record.narrativeFingerprint);
    gf2Narratives.add(sim.narrativeFingerprint);

    final afterHuman = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: sim.composedFusion),
      createdAt: record.generatedAt,
    );

    for (final patternId in v1DeadPatterns) {
      forensics[patternId]!.inspect(
        record: record,
        sim: sim,
        afterHuman: afterHuman,
      );
    }
  }

  final baselineQuality = _narrativeQuality(baselineNarratives);
  final gf2Quality = _narrativeQuality(gf2Narratives);

  final classified = <Map<String, dynamic>>[];
  for (final patternId in v1DeadPatterns) {
    final f = forensics[patternId]!;
    final entry = HumanPatternRegistry.byId(patternId)!;
    final category = f.classify();
    classified.add({
      ...f.toJson(),
      'category': category,
      'categoryLabel': _categoryLabel(category),
      'rootCause': f.rootCause(category),
      'ownershipLayer': f.ownershipLayer(category),
      'activationRule': entry.activationRule.toMap(),
    });
  }

  final recoverable = classified
      .where((p) => ['B', 'C', 'D', 'E'].contains(p['category']))
      .toList();
  final diversityImpact = <Map<String, dynamic>>[];
  for (final pattern in recoverable) {
    diversityImpact.add(
      _counterfactualImpact(
        patternId: pattern['patternId'] as String,
        category: pattern['category'] as String,
        records: cachedRecords,
        sims: cachedSims,
        baselineQuality: baselineQuality,
        gf2BaselineQuality: gf2Quality,
      ),
    );
  }
  diversityImpact.sort((a, b) {
    final deltaA = (a['deltaUniqueNarratives'] as int).abs() +
        (a['additionalActivationsEstimate'] as int);
    final deltaB = (b['deltaUniqueNarratives'] as int).abs() +
        (b['additionalActivationsEstimate'] as int);
    return deltaB.compareTo(deltaA);
  });

  final summary = _summaryCounts(classified);

  final report = {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'populationSize': profiles.length,
    'registryPatternCount': 41,
    'v1DeadPatternCount': v1DeadPatterns.length,
    'baselineNarrativeQuality': baselineQuality,
    'gf2NarrativeQuality': gf2Quality,
    'patterns': classified,
    'diversityImpact': diversityImpact,
    'top10RecoveryPriority': diversityImpact.take(10).toList(),
    'summary': summary,
  };

  const outPath =
      'test/validation/synthetic_population_v3/output/dead_zone_forensics.json';
  File(outPath)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));

  stdout.writeln('Wrote $outPath');
  stdout.writeln(jsonEncode(summary));
}

class _PatternForensic {
  _PatternForensic(this.patternId);

  final String patternId;
  var baselineActivations = 0;
  var gf2Activations = 0;
  var profilesWithMirrorSignal = 0;
  var profilesWithMirrorFinding = 0;
  var profilesWithGf1FusionFinding = 0;
  var profilesWithGf2ComposedFinding = 0;
  var profilesWithHmPattern = 0;
  var profilesWithHmCorrectType = 0;
  var profilesWithHpSourceResolved = 0;
  var profilesWithHpWrongFindingType = 0;
  var profilesWithHpRuleMatch = 0;
  var profilesWithHpLineageEvidence = 0;
  var profilesActivationBlocked = 0;

  var profilesWithCorrectSource = 0;
  var profilesWouldActivateWithCorrectSource = 0;
  final outcomeCounts = <String, int>{};

  HumanPatternActivationRule get rule =>
      HumanPatternRegistry.byId(patternId)!.activationRule;

  void inspect({
    required SyntheticHumanRunRecord record,
    required ValidationV2SimulationResult sim,
    required HumanModelSnapshot afterHuman,
  }) {
    if (record.humanPatternSnapshot.activations
        .any((a) => a.patternId == patternId)) {
      baselineActivations++;
    }
    if (sim.humanPatternSnapshot.activations
        .any((a) => a.patternId == patternId)) {
      gf2Activations++;
    }

    final mirrorKey = rule.requiredMirrorKey;
    final requiredType = rule.requiredFusionFindingType;
    final sourceKey = rule.sourceHumanPatternKey;

    if (mirrorKey != null) {
      final hasSignal = [
        ...record.astrologyInput.signals,
        ...record.personalityInput.signals,
      ].any((s) => s.mirrorKey == mirrorKey);
      if (hasSignal) profilesWithMirrorSignal++;

      final hasMirrorFinding = _mirrorHasKey(record, mirrorKey);
      if (hasMirrorFinding) profilesWithMirrorFinding++;
    } else if (sourceKey != null) {
      if (afterHuman.patterns.any((p) => p.patternKey == sourceKey)) {
        profilesWithMirrorSignal++;
      }
    }

    if (mirrorKey != null && requiredType != null) {
      if (_fusionHas(record.globalFusionSnapshot, mirrorKey, requiredType)) {
        profilesWithGf1FusionFinding++;
      }
      if (_fusionHas(sim.composedFusion, mirrorKey, requiredType)) {
        profilesWithGf2ComposedFinding++;
      }
    } else if (requiredType != null) {
      if (_fusionHasType(record.globalFusionSnapshot, requiredType)) {
        profilesWithGf1FusionFinding++;
      }
      if (_fusionHasType(sim.composedFusion, requiredType)) {
        profilesWithGf2ComposedFinding++;
      }
    } else if (mirrorKey != null) {
      if (_fusionHasKey(record.globalFusionSnapshot, mirrorKey)) {
        profilesWithGf1FusionFinding++;
      }
      if (_fusionHasKey(sim.composedFusion, mirrorKey)) {
        profilesWithGf2ComposedFinding++;
      }
    }

    if (mirrorKey != null && requiredType != null) {
      if (afterHuman.patterns.any(
        (p) =>
            p.supportingMirrorKeys.contains(mirrorKey) &&
            p.fusionFindingType == requiredType,
      )) {
        profilesWithHmCorrectType++;
      }
      if (afterHuman.patterns
          .any((p) => p.supportingMirrorKeys.contains(mirrorKey))) {
        profilesWithHmPattern++;
      }
    } else if (sourceKey != null) {
      if (afterHuman.patterns.any((p) => p.patternKey == sourceKey)) {
        profilesWithHmPattern++;
        profilesWithHmCorrectType++;
      }
    } else if (requiredType != null) {
      if (afterHuman.patterns
          .any((p) => p.fusionFindingType == requiredType)) {
        profilesWithHmCorrectType++;
        profilesWithHmPattern++;
      }
    }

    final resolved = PatternActivationEngine.resolveSourceForAudit(
      afterHuman,
      rule,
    );
    if (resolved != null) {
      profilesWithHpSourceResolved++;
      if (requiredType != null &&
          resolved.fusionFindingType != requiredType) {
        profilesWithHpWrongFindingType++;
      }
      if (_ruleMatches(afterHuman, rule, resolved)) {
        profilesWithHpRuleMatch++;
      } else {
        profilesActivationBlocked++;
      }
      if (afterHuman.evidence.any((e) => e.humanPatternId == resolved.id)) {
        profilesWithHpLineageEvidence++;
      }
    }

    final correctSource = _findCorrectSource(afterHuman, rule);
    if (correctSource != null) {
      profilesWithCorrectSource++;
      final diagnosis = PatternActivationForensics.diagnose(
        snapshot: afterHuman,
        patternId: patternId,
      );
      outcomeCounts[diagnosis.outcome.key] =
          (outcomeCounts[diagnosis.outcome.key] ?? 0) + 1;
      if (diagnosis.outcome == PatternActivationOutcome.activated ||
          (diagnosis.outcome ==
                  PatternActivationOutcome.fusionFindingTypeMismatch &&
              correctSource.fusionFindingType == rule.requiredFusionFindingType &&
              correctSource.patternStrength >= rule.minPatternStrength)) {
        profilesWouldActivateWithCorrectSource++;
      }
    } else {
      final diagnosis = PatternActivationForensics.diagnose(
        snapshot: afterHuman,
        patternId: patternId,
      );
      outcomeCounts[diagnosis.outcome.key] =
          (outcomeCounts[diagnosis.outcome.key] ?? 0) + 1;
    }
  }

  String classify() {
    if (gf2Activations > 0 && baselineActivations == 0) {
      return 'B';
    }
    if (rule.requiredMirrorKey == null &&
        rule.sourceHumanPatternKey == null &&
        rule.requiredFusionFindingType != null &&
        profilesWithHmCorrectType > 0 &&
        profilesWithHpSourceResolved == 0) {
      return 'B';
    }
    if (profilesWouldActivateWithCorrectSource > 0 && gf2Activations == 0) {
      if ((outcomeCounts['fusion_finding_type_mismatch'] ?? 0) > 0 ||
          profilesWithHpWrongFindingType > 0) {
        return 'E';
      }
      return 'C';
    }
    if (profilesWithMirrorSignal == 0 && profilesWithGf2ComposedFinding == 0) {
      return 'A';
    }
    if (profilesWithMirrorSignal > 0 &&
        profilesWithGf2ComposedFinding == 0 &&
        profilesWithGf1FusionFinding == 0) {
      return 'A';
    }
    if (gf2Activations > 0 && !_hasNarrativeCopy(patternId)) {
      return 'D';
    }
    return 'A';
  }

  String rootCause(String category) => switch (category) {
        'A' =>
          'No fusion finding of required type reaches Human Model at V1; GF2 does not recover on this population slice',
        'B' =>
          'Lens/mirror source exists; GF1 blocks until GF2 recovery — pattern activates after GF2 simulation',
        'C' => 'Higher-priority human-model source consumes evaluation order',
        'D' => 'Pattern activates but narrative has no dedicated copy consumption',
        'E' =>
          'HP resolves agreement-type source before reinforcement-type source on same mirror key',
        _ => 'Unknown',
      };

  String ownershipLayer(String category) => switch (category) {
        'A' when profilesWithMirrorSignal == 0 => 'Mirror',
        'A' => 'GF1',
        'B' => 'GF1',
        'C' => 'Human Pattern',
        'D' => 'Narrative',
        'E' => 'Human Pattern',
        _ => 'Human Pattern',
      };

  Map<String, dynamic> toJson() => {
        'patternId': patternId,
        'baselineActivations': baselineActivations,
        'gf2SimActivations': gf2Activations,
        'profilesWithMirrorSignal': profilesWithMirrorSignal,
        'profilesWithMirrorFinding': profilesWithMirrorFinding,
        'profilesWithGf1FusionFinding': profilesWithGf1FusionFinding,
        'profilesWithGf2ComposedFinding': profilesWithGf2ComposedFinding,
        'profilesWithHmPattern': profilesWithHmPattern,
        'profilesWithHmCorrectType': profilesWithHmCorrectType,
        'profilesWithHpSourceResolved': profilesWithHpSourceResolved,
        'profilesWithHpWrongFindingType': profilesWithHpWrongFindingType,
        'profilesWithHpRuleMatch': profilesWithHpRuleMatch,
        'profilesWithHpLineageEvidence': profilesWithHpLineageEvidence,
        'profilesActivationBlocked': profilesActivationBlocked,
        'profilesWithCorrectSource': profilesWithCorrectSource,
        'profilesWouldActivateWithCorrectSource':
            profilesWouldActivateWithCorrectSource,
        'outcomeCounts': outcomeCounts,
        'narrativeCopyExists': _hasNarrativeCopy(patternId),
        'ownershipAudit': _ownershipAudit(),
      };

  Map<String, String> _ownershipAudit() {
    final category = classify();
    return {
      'Mirror': profilesWithMirrorSignal > 0 ? 'PASS' : 'FAIL',
      'GF1': profilesWithGf1FusionFinding > 0 ? 'PASS' : 'FAIL',
      'GF2': profilesWithGf2ComposedFinding > 0 ? 'PASS' : 'FAIL',
      'Human Model': profilesWithHmCorrectType > 0 ? 'PASS' : 'FAIL',
      'Human Pattern':
          gf2Activations > 0 || profilesWouldActivateWithCorrectSource > 0
              ? 'PASS'
              : 'FAIL',
      'Narrative': gf2Activations > 0 && _hasNarrativeCopy(patternId)
          ? 'PASS'
          : (gf2Activations > 0 ? 'FAIL' : 'FAIL'),
    };
  }
}

bool _mirrorHasKey(SyntheticHumanRunRecord record, String mirrorKey) {
  return record.astrologyMirrorSnapshot.agreements
          .any((f) => f.mirrorKey == mirrorKey) ||
      record.astrologyMirrorSnapshot.reinforcements
          .any((f) => f.mirrorKey == mirrorKey) ||
      record.personalityMirrorSnapshot.agreements
          .any((f) => f.mirrorKey == mirrorKey) ||
      record.personalityMirrorSnapshot.reinforcements
          .any((f) => f.mirrorKey == mirrorKey);
}

bool _fusionHas(dynamic fusion, String mirrorKey, String type) {
  return switch (type) {
    'agreement' => fusion.agreements.any((f) => f.mirrorKey == mirrorKey),
    'reinforcement' =>
      fusion.reinforcements.any((f) => f.mirrorKey == mirrorKey),
    'tension' => fusion.tensions.any((f) => f.mirrorKey == mirrorKey),
    'blind_spot' => fusion.blindSpots.any((f) => f.mirrorKey == mirrorKey),
    _ => false,
  };
}

bool _fusionHasType(dynamic fusion, String type) {
  return switch (type) {
    'agreement' => fusion.agreements.isNotEmpty,
    'reinforcement' => fusion.reinforcements.isNotEmpty,
    'tension' => fusion.tensions.isNotEmpty,
    'blind_spot' => fusion.blindSpots.isNotEmpty,
    _ => false,
  };
}

bool _fusionHasKey(dynamic fusion, String mirrorKey) {
  return fusion.agreements.any((f) => f.mirrorKey == mirrorKey) ||
      fusion.reinforcements.any((f) => f.mirrorKey == mirrorKey) ||
      fusion.tensions.any((f) => f.mirrorKey == mirrorKey) ||
      fusion.blindSpots.any((f) => f.mirrorKey == mirrorKey);
}

bool _ruleMatches(
  HumanModelSnapshot snapshot,
  HumanPatternActivationRule rule,
  dynamic source,
) {
  if (source.patternStrength < rule.minPatternStrength) return false;
  if (rule.requiredFusionFindingType != null &&
      source.fusionFindingType != rule.requiredFusionFindingType) {
    return false;
  }
  if (rule.requiredMirrorKey != null &&
      !source.supportingMirrorKeys.contains(rule.requiredMirrorKey)) {
    final evidenceMatch = snapshot.evidence.any(
      (row) =>
          row.humanPatternId == source.id &&
          row.mirrorKey == rule.requiredMirrorKey,
    );
    if (!evidenceMatch) return false;
  }
  if (rule.requiredDimensionKey != null) {
    final dimensionActivation = snapshot.profile.dimensions
        .where((item) => item.dimensionKey == rule.requiredDimensionKey)
        .map((item) => item.activation)
        .fold(0.0, (max, value) => value > max ? value : max);
    if (dimensionActivation < rule.minDimensionActivation) return false;
  }
  return true;
}

bool _hasNarrativeCopy(String patternId) {
  const withCopy = {
    'visible_identity',
    'meaning_seeker',
    'relationship_stabilizer',
    'structured_operator',
    'progressive_builder',
    'transformation_seeker',
    'adaptive_growth',
  };
  return withCopy.contains(patternId);
}

String _categoryLabel(String code) => switch (code) {
      'A' => 'TRUE DEAD',
      'B' => 'SOURCE EXISTS',
      'C' => 'SHADOWED',
      'D' => 'ACTIVATES BUT UNUSED',
      'E' => 'WRONG FINDING TYPE',
      _ => code,
    };

Map<String, dynamic> _narrativeQuality(List<String> fps) {
  final counts = <String, int>{};
  for (final fp in fps) {
    counts[fp] = (counts[fp] ?? 0) + 1;
  }
  final clusterSizes = counts.values.toList()..sort();
  return {
    'uniqueNarratives': counts.length,
    'profilesInCollapse':
        counts.values.where((c) => c >= 3).fold(0, (s, c) => s + c),
    'maxClusterSize': clusterSizes.isEmpty ? 0 : clusterSizes.last,
  };
}

Map<String, dynamic> _counterfactualImpact({
  required String patternId,
  required String category,
  required List<SyntheticHumanRunRecord> records,
  required List<ValidationV2SimulationResult> sims,
  required Map<String, dynamic> baselineQuality,
  required Map<String, dynamic> gf2BaselineQuality,
}) {
  final counterNarratives = <String>[];
  final counterPatternSets = <String>{};
  var additionalActivations = 0;
  final referenceQuality =
      category == 'B' ? baselineQuality : gf2BaselineQuality;

  for (var i = 0; i < records.length; i++) {
    final record = records[i];
    final sim = sims[i];
    final baselineFp = record.narrativeFingerprint;
    final gf2Fp = sim.narrativeFingerprint;

    if (category == 'B') {
      final activatesInGf2 = sim.humanPatternSnapshot.activations
          .any((a) => a.patternId == patternId);
      if (activatesInGf2) {
        additionalActivations++;
        counterNarratives.add(gf2Fp);
        final patternSet = sim.humanPatternSnapshot.activations
            .map((a) => a.patternId)
            .toList()
          ..sort();
        counterPatternSets.add(patternSet.join('|'));
      } else {
        counterNarratives.add(baselineFp);
        final patternSet = record.humanPatternSnapshot.activations
            .map((a) => a.patternId)
            .toList()
          ..sort();
        counterPatternSets.add(patternSet.join('|'));
      }
      continue;
    }

    // Category C/D/E — recover on GF2 baseline
    if (sim.humanPatternSnapshot.activations
        .any((a) => a.patternId == patternId)) {
      counterNarratives.add(gf2Fp);
      continue;
    }

    final afterHuman = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: sim.composedFusion),
      createdAt: record.generatedAt,
    );
    final rule = HumanPatternRegistry.byId(patternId)!.activationRule;
    final correctSource = _findCorrectSource(afterHuman, rule);
    if (correctSource == null ||
        !_ruleMatches(afterHuman, rule, correctSource) ||
        !afterHuman.evidence
            .any((row) => row.humanPatternId == correctSource.id)) {
      counterNarratives.add(gf2Fp);
      continue;
    }

    additionalActivations++;
    final entry = HumanPatternRegistry.byId(patternId)!;
    final patchedSnapshot = HumanPatternSnapshot(
      identity: sim.humanPatternSnapshot.identity,
      activations: [
        ...sim.humanPatternSnapshot.activations,
        PatternActivation(
          activationId: 'cf_${patternId}_${correctSource.id}',
          patternId: patternId,
          label: entry.label,
          patternFamilyId: entry.patternFamilyId,
          dimension: entry.dimension,
          activationStrength: correctSource.patternStrength,
          sourceHumanPatternId: correctSource.id,
          sourceHumanPatternKey: correctSource.patternKey,
          confidence: sim.humanPatternSnapshot.confidence,
        ),
      ],
      confidence: sim.humanPatternSnapshot.confidence,
      coverage: sim.humanPatternSnapshot.coverage,
      evidence: sim.humanPatternSnapshot.evidence,
      lineage: sim.humanPatternSnapshot.lineage,
      structuralHash: sim.humanPatternSnapshot.structuralHash,
      createdAt: record.generatedAt,
    );
    final narrative = NarrativeRuntimeService.generate(
      patternSnapshot: patchedSnapshot,
      createdAt: record.generatedAt,
    );
    counterNarratives.add(_fingerprint(narrative));
  }

  final counterQuality = _narrativeQuality(counterNarratives);
  final baselinePatternSets = category == 'B'
      ? records
          .map((r) {
            final ids =
                r.humanPatternSnapshot.activations.map((a) => a.patternId).toList()
                  ..sort();
            return ids.join('|');
          })
          .toSet()
          .length
      : sims
          .map((s) {
            final ids =
                s.humanPatternSnapshot.activations.map((a) => a.patternId).toList()
                  ..sort();
            return ids.join('|');
          })
          .toSet()
          .length;
  return {
    'patternId': patternId,
    'category': category,
    'additionalActivationsEstimate': additionalActivations,
    'deltaUniqueNarratives': (counterQuality['uniqueNarratives'] as int) -
        (referenceQuality['uniqueNarratives'] as int),
    'deltaProfilesInCollapse': (counterQuality['profilesInCollapse'] as int) -
        (referenceQuality['profilesInCollapse'] as int),
    'deltaMaxClusterSize': (counterQuality['maxClusterSize'] as int) -
        (referenceQuality['maxClusterSize'] as int),
    'deltaUniquePatternSets':
        counterPatternSets.length - baselinePatternSets,
    'referenceBaseline': category == 'B' ? 'v1_baseline' : 'gf2_baseline',
  };
}

dynamic _findCorrectSource(
  HumanModelSnapshot snapshot,
  HumanPatternActivationRule rule,
) {
  final requiredType = rule.requiredFusionFindingType;
  final mirrorKey = rule.requiredMirrorKey;
  final sourceKey = rule.sourceHumanPatternKey;

  if (sourceKey != null) {
    for (final pattern in snapshot.patterns) {
      if (pattern.patternKey == sourceKey) return pattern;
    }
    return null;
  }
  if (mirrorKey != null && requiredType != null) {
    for (final pattern in snapshot.patterns) {
      if (pattern.supportingMirrorKeys.contains(mirrorKey) &&
          pattern.fusionFindingType == requiredType) {
        return pattern;
      }
    }
  }
  if (requiredType != null) {
    for (final pattern in snapshot.patterns) {
      if (pattern.fusionFindingType == requiredType) return pattern;
    }
  }
  if (mirrorKey != null) {
    for (final pattern in snapshot.patterns) {
      if (pattern.supportingMirrorKeys.contains(mirrorKey)) return pattern;
    }
  }
  return null;
}

String _fingerprint(dynamic narrativeResult) {
  final parts = <String>[];
  for (final section in narrativeResult.sections) {
    for (final paragraph in section.paragraphs) {
      parts.add(paragraph.text.trim().toLowerCase());
    }
  }
  return parts.join('\n');
}

Map<String, dynamic> _summaryCounts(List<Map<String, dynamic>> patterns) {
  final counts = <String, int>{'A': 0, 'B': 0, 'C': 0, 'D': 0, 'E': 0};
  for (final p in patterns) {
    counts[p['category'] as String] = counts[p['category'] as String]! + 1;
  }
  return {
    'categoryA_trueDead': counts['A'],
    'categoryB_sourceExists': counts['B'],
    'categoryC_shadowed': counts['C'],
    'categoryD_activatesButUnused': counts['D'],
    'categoryE_wrongFindingType': counts['E'],
    'gf2RecoveredFromV1Dead': patterns
        .where((p) => (p['gf2SimActivations'] as int) > 0)
        .length,
    'stillDeadAfterGf2Sim': patterns
        .where((p) => (p['gf2SimActivations'] as int) == 0)
        .length,
  };
}
