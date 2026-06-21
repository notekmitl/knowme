import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/engines/pattern_activation_engine.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

import '../../synthetic_population/pipeline/synthetic_human_mirror_input_builder.dart';
import '../../synthetic_population_v2/simulation/validation_v2_recovery_simulator.dart';
import '../factory/synthetic_human_profile_factory_v3.dart';
import '../pipeline/synthetic_human_pipeline_runner_v3.dart';

/// Read-only end-to-end trace for stable_orientation ownership isolation.
void main() {
  stdout.writeln('stable_orientation trace — building V3 population...');
  final profiles = SyntheticHumanProfileFactoryV3.buildAll();
  const lifeKey = 'MIRROR_LIFE_DIRECTION';
  const patternId = 'stable_orientation';

  final stageCounts = <String, int>{
    'totalProfiles': profiles.length,
    'lensLifeSignal': 0,
    'mirrorSignalEligible': 0,
    'mirrorReinforcementFinding': 0,
    'mp001Promotion': 0,
    'gf2R002Agreement': 0,
    'gf2R004Recovery': 0,
    'gf2ComposedLifeReinforcement': 0,
    'humanModelReinforcementPattern': 0,
    'hpSourceResolved': 0,
    'hpSourceIsReinforcementType': 0,
    'hpRuleMatches': 0,
    'hpLineageEvidence': 0,
    'hpActivated': 0,
  };

  final terminationCounts = <String, int>{};
  final eligibleProfiles = <Map<String, dynamic>>[];
  final sampleTraces = <Map<String, dynamic>>[];

  for (var i = 0; i < profiles.length; i++) {
    final record = SyntheticHumanPipelineRunnerV3.run(
      profiles[i],
      generatedAt: DateTime.utc(2026, 6, 21, i % 24, i % 60),
    );
    final rawAstrology = SyntheticHumanMirrorInputBuilder.buildAstrologyInput(
      record.profile,
      generatedAt: record.generatedAt,
    );
    final sim = ValidationV2RecoverySimulator.simulateRecord(record);
    final afterHuman = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: sim.composedFusion),
      createdAt: record.generatedAt,
    );

    final rule = HumanPatternRegistry.byId(patternId)!.activationRule;
    final resolvedSource = PatternActivationEngine.resolveSourceForAudit(
      afterHuman,
      rule,
    );
    final activated = sim.humanPatternSnapshot.activations
        .any((a) => a.patternId == patternId);

    final trace = _TraceStage(
      profileId: record.profile.profileId,
      lensLifeSignal: rawAstrology.signals.any((s) => s.mirrorKey == lifeKey),
      mirrorSignalEligible: record.astrologyInput.signals.any(
        (s) => s.mirrorKey == lifeKey && s.evidenceCount >= 2,
      ),
      mirrorReinforcementFinding: record.astrologyMirrorSnapshot.reinforcements
          .any((r) => r.mirrorKey == lifeKey),
      mp001Promotion: sim.mp001AgreementCount > 0,
      gf2R002Agreement: sim.gf2AgreementCount > 0 &&
          sim.composedFusion.agreements.any((a) => a.mirrorKey == lifeKey),
      gf2R004Recovery: sim.r004ReinforcementCount > 0,
      gf2ComposedLifeReinforcement: sim.composedFusion.reinforcements
          .any((r) => r.mirrorKey == lifeKey),
      humanModelReinforcementPattern: afterHuman.patterns.any(
        (p) =>
            p.fusionFindingType == 'reinforcement' &&
            p.supportingMirrorKeys.contains(lifeKey),
      ),
      hpSourceResolved: resolvedSource != null,
      hpSourceFusionFindingType: resolvedSource?.fusionFindingType,
      hpSourcePatternKey: resolvedSource?.patternKey,
      hpSourceIsReinforcementType:
          resolvedSource?.fusionFindingType == 'reinforcement',
      hpRuleMatches: resolvedSource != null &&
          _ruleMatchesAudit(afterHuman, rule, resolvedSource),
      hpLineageEvidence: resolvedSource != null &&
          afterHuman.evidence.any((e) => e.humanPatternId == resolvedSource.id),
      hpActivated: activated,
      humanModelLifePatterns: afterHuman.patterns
          .where((p) => p.supportingMirrorKeys.contains(lifeKey))
          .map(
            (p) => {
              'patternKey': p.patternKey,
              'fusionFindingType': p.fusionFindingType,
              'patternStrength': p.patternStrength,
            },
          )
          .toList(),
    );

    _increment(stageCounts, trace);
    final termination = trace.terminationPoint;
    terminationCounts[termination] = (terminationCounts[termination] ?? 0) + 1;

    if (trace.gf2ComposedLifeReinforcement) {
      eligibleProfiles.add(trace.toJson());
      if (sampleTraces.length < 5) sampleTraces.add(trace.toJson());
    }
  }

  final report = {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'patternId': patternId,
    'mirrorKey': lifeKey,
    'stageCounts': stageCounts,
    'terminationCounts': terminationCounts,
    'eligibleProfileCount': eligibleProfiles.length,
    'eligibleTerminationCounts': _countField(
      eligibleProfiles,
      'terminationPoint',
    ),
    'sampleTraces': sampleTraces,
    'layerOwnership': _layerOwnership(stageCounts, eligibleProfiles.length),
    'vg002Scope': _vg002Scope(stageCounts, eligibleProfiles.length),
  };

  const outJson =
      'test/validation/synthetic_population_v3/output/stable_orientation_trace.json';
  File(outJson)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));

  stdout.writeln('Wrote $outJson');
  stdout.writeln(jsonEncode(report['layerOwnership']));
  stdout.writeln('Eligible profiles: ${eligibleProfiles.length}');
  stdout.writeln('Termination (eligible): ${report['eligibleTerminationCounts']}');
}

class _TraceStage {
  _TraceStage({
    required this.profileId,
    required this.lensLifeSignal,
    required this.mirrorSignalEligible,
    required this.mirrorReinforcementFinding,
    required this.mp001Promotion,
    required this.gf2R002Agreement,
    required this.gf2R004Recovery,
    required this.gf2ComposedLifeReinforcement,
    required this.humanModelReinforcementPattern,
    required this.hpSourceResolved,
    required this.hpSourceFusionFindingType,
    required this.hpSourcePatternKey,
    required this.hpSourceIsReinforcementType,
    required this.hpRuleMatches,
    required this.hpLineageEvidence,
    required this.hpActivated,
    required this.humanModelLifePatterns,
  });

  final String profileId;
  final bool lensLifeSignal;
  final bool mirrorSignalEligible;
  final bool mirrorReinforcementFinding;
  final bool mp001Promotion;
  final bool gf2R002Agreement;
  final bool gf2R004Recovery;
  final bool gf2ComposedLifeReinforcement;
  final bool humanModelReinforcementPattern;
  final bool hpSourceResolved;
  final String? hpSourceFusionFindingType;
  final String? hpSourcePatternKey;
  final bool hpSourceIsReinforcementType;
  final bool hpRuleMatches;
  final bool hpLineageEvidence;
  final bool hpActivated;
  final List<Map<String, dynamic>> humanModelLifePatterns;

  String get terminationPoint {
    if (!lensLifeSignal) return 'LENS_NO_LIFE_SIGNAL';
    if (!mirrorSignalEligible) return 'MIRROR_SIGNAL_EVIDENCE_LT_2';
    if (!mirrorReinforcementFinding) return 'MV1_NO_MIRROR_REINFORCEMENT';
    if (!gf2R002Agreement) return 'GF2_NO_LIFE_AGREEMENT';
    if (!gf2ComposedLifeReinforcement) {
      return 'GF2_NO_COMPOSED_LIFE_REINFORCEMENT';
    }
    if (!humanModelReinforcementPattern) {
      return 'HUMAN_MODEL_NO_REINFORCEMENT_PATTERN';
    }
    if (!hpSourceResolved) return 'HP_SOURCE_NOT_RESOLVED';
    if (!hpSourceIsReinforcementType) {
      return 'HP_SOURCE_WRONG_FUSION_FINDING_TYPE';
    }
    if (!hpRuleMatches) return 'HP_RULE_MISMATCH';
    if (!hpLineageEvidence) return 'HP_NO_LINEAGE_EVIDENCE';
    if (!hpActivated) return 'HP_ACTIVATION_BLOCKED_UNKNOWN';
    return 'ACTIVATED';
  }

  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'terminationPoint': terminationPoint,
        'lensLifeSignal': lensLifeSignal,
        'mirrorSignalEligible': mirrorSignalEligible,
        'mirrorReinforcementFinding': mirrorReinforcementFinding,
        'mp001Promotion': mp001Promotion,
        'gf2R002Agreement': gf2R002Agreement,
        'gf2R004Recovery': gf2R004Recovery,
        'gf2ComposedLifeReinforcement': gf2ComposedLifeReinforcement,
        'humanModelReinforcementPattern': humanModelReinforcementPattern,
        'hpSourceResolved': hpSourceResolved,
        'hpSourceFusionFindingType': hpSourceFusionFindingType,
        'hpSourcePatternKey': hpSourcePatternKey,
        'hpSourceIsReinforcementType': hpSourceIsReinforcementType,
        'hpRuleMatches': hpRuleMatches,
        'hpLineageEvidence': hpLineageEvidence,
        'hpActivated': hpActivated,
        'humanModelLifePatterns': humanModelLifePatterns,
      };
}

void _increment(Map<String, int> counts, _TraceStage trace) {
  if (trace.lensLifeSignal) counts['lensLifeSignal'] = counts['lensLifeSignal']! + 1;
  if (trace.mirrorSignalEligible) {
    counts['mirrorSignalEligible'] = counts['mirrorSignalEligible']! + 1;
  }
  if (trace.mirrorReinforcementFinding) {
    counts['mirrorReinforcementFinding'] =
        counts['mirrorReinforcementFinding']! + 1;
  }
  if (trace.mp001Promotion) counts['mp001Promotion'] = counts['mp001Promotion']! + 1;
  if (trace.gf2R002Agreement) {
    counts['gf2R002Agreement'] = counts['gf2R002Agreement']! + 1;
  }
  if (trace.gf2R004Recovery) {
    counts['gf2R004Recovery'] = counts['gf2R004Recovery']! + 1;
  }
  if (trace.gf2ComposedLifeReinforcement) {
    counts['gf2ComposedLifeReinforcement'] =
        counts['gf2ComposedLifeReinforcement']! + 1;
  }
  if (trace.humanModelReinforcementPattern) {
    counts['humanModelReinforcementPattern'] =
        counts['humanModelReinforcementPattern']! + 1;
  }
  if (trace.hpSourceResolved) {
    counts['hpSourceResolved'] = counts['hpSourceResolved']! + 1;
  }
  if (trace.hpSourceIsReinforcementType) {
    counts['hpSourceIsReinforcementType'] =
        counts['hpSourceIsReinforcementType']! + 1;
  }
  if (trace.hpRuleMatches) counts['hpRuleMatches'] = counts['hpRuleMatches']! + 1;
  if (trace.hpLineageEvidence) {
    counts['hpLineageEvidence'] = counts['hpLineageEvidence']! + 1;
  }
  if (trace.hpActivated) counts['hpActivated'] = counts['hpActivated']! + 1;
}

bool _ruleMatchesAudit(
  dynamic snapshot,
  dynamic rule,
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

Map<String, int> _countField(List<Map<String, dynamic>> rows, String field) {
  final counts = <String, int>{};
  for (final row in rows) {
    final key = row[field] as String;
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

List<Map<String, dynamic>> _layerOwnership(
  Map<String, int> stages,
  int eligible,
) {
  return [
    _layer(
      name: 'MV1 Mirror Engine',
      source: stages['mirrorReinforcementFinding']! > 0,
      evidence: stages['mirrorSignalEligible']! > 0,
      lineage: stages['mirrorReinforcementFinding']! > 0,
      output: stages['mirrorReinforcementFinding']! > 0,
    ),
    _layer(
      name: 'MV2 Promotion (MP-001)',
      source: true,
      evidence: true,
      lineage: true,
      output: stages['mp001Promotion']! > 0,
      note: 'Not LIFE target — N/A for stable_orientation',
    ),
    _layer(
      name: 'GF1 Foundation',
      source: true,
      evidence: true,
      lineage: true,
      output: true,
      note: 'Frozen pass-through — LIFE blocked at GF1 by design',
    ),
    _layer(
      name: 'GF2 Recovery',
      source: stages['gf2R002Agreement']! > 0,
      evidence: stages['gf2R004Recovery']! > 0,
      lineage: stages['gf2ComposedLifeReinforcement']! == eligible,
      output: stages['gf2ComposedLifeReinforcement']! > 0,
    ),
    _layer(
      name: 'Human Model',
      source: stages['humanModelReinforcementPattern']! > 0,
      evidence: stages['humanModelReinforcementPattern']! > 0,
      lineage: stages['humanModelReinforcementPattern']! == eligible,
      output: stages['humanModelReinforcementPattern']! > 0,
    ),
    _layer(
      name: 'Human Pattern Activation',
      source: stages['humanModelReinforcementPattern']! > 0,
      evidence: stages['hpLineageEvidence']! > 0,
      lineage: stages['hpLineageEvidence']! > 0,
      output: stages['hpActivated']! > 0,
    ),
  ];
}

Map<String, dynamic> _layer({
  required String name,
  required bool source,
  required bool evidence,
  required bool lineage,
  required bool output,
  String? note,
}) {
  final pass = source && evidence && lineage && output;
  return {
    'layer': name,
    'sourceExists': source,
    'evidenceExists': evidence,
    'lineageExists': lineage,
    'outputExists': output,
    'verdict': pass ? 'PASS' : 'FAIL',
    if (note != null) 'note': note,
  };
}

Map<String, dynamic> _vg002Scope(
  Map<String, int> stages,
  int eligible,
) {
  final gf2Delivered = stages['gf2ComposedLifeReinforcement']! > 0;
  final hmDelivered = stages['humanModelReinforcementPattern']! > 0;
  final hpActivated = stages['hpActivated']! > 0;
  return {
    'gf2SourceFindingsCreated': gf2Delivered,
    'gf2RecoveriesCreated': stages['gf2R004Recovery']! > 0,
    'gf2LineageComplete': eligible > 0 && hmDelivered,
    'downstreamEligibilityCreated': hmDelivered,
    'patternActivated': hpActivated,
    'conclusion':
        gf2Delivered && hmDelivered && !hpActivated
            ? 'VG-002 measures Human Pattern activation consumption, not GF2 recovery failure'
            : 'GF2 did not deliver downstream eligibility',
  };
}
