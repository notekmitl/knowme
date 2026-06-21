import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/engines/cross_mirror_agreement_engine.dart';
import 'package:knowme/features/global_fusion/v2/builder/global_fusion_coverage_recovery_builder.dart';
import 'package:knowme/features/global_fusion/v2/domain/fusion_recovery_enums.dart';
import 'package:knowme/features/global_fusion/v2/domain/global_fusion_recovered_snapshot.dart';
import 'package:knowme/features/global_fusion/v2/domain/global_fusion_supplemental_findings.dart';
import 'package:knowme/features/global_fusion/v2/engines/global_fusion_recovery_composer.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_dimension_id.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_theme_signal.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';

import '../../synthetic_population/pipeline/synthetic_human_pipeline_runner.dart';
import '../../synthetic_population/pipeline/synthetic_human_run_record.dart';
import '../factory/synthetic_human_profile_factory_v2.dart';

/// Read-only collapse investigation — no production changes.
void main() {
  stdout.writeln('Collapse zone analysis — building 1000 profiles...');
  final profiles = SyntheticHumanProfileFactoryV2.buildAll();
  final records = <SyntheticHumanRunRecord>[];
  for (var i = 0; i < profiles.length; i++) {
    records.add(
      SyntheticHumanPipelineRunner.run(
        profiles[i],
        generatedAt: DateTime.utc(2026, 6, 21, i % 24, i % 60),
      ),
    );
  }

  final baselineFps = records.map((r) => r.narrativeFingerprint).toList();
  final gf2OnlyFps = <String>[];
  final currentSimFps = <String>[];
  final fixedR004Fps = <String>[];

  var r004Broken = 0;
  var r004CorrectedWouldApply = 0;
  var mp001Total = 0;
  var gf2AgreementTotal = 0;

  final recoveryPatternCounts = <String, int>{};
  final convergenceByRecovery = <String, int>{
    'gf2_growth_life_only': 0,
    'mp001_structure': 0,
    'both': 0,
    'neither_changed_narrative': 0,
  };

  for (final record in records) {
    final input = _fusionInput(record);
    final foundation = record.globalFusionSnapshot;

    final gf2 = GlobalFusionCoverageRecoveryBuilder.build(
      input: input,
      foundationSnapshot: foundation,
      createdAt: record.generatedAt,
    );
    gf2AgreementTotal += gf2.recoveredSnapshot.supplementalAgreements.length;

    final mp001 = _mp001(record);
    mp001Total += mp001.length;

    r004Broken += _r004BrokenCount(
      input: input,
      supplementalAgreements: [...gf2.recoveredSnapshot.supplementalAgreements, ...mp001],
    );
    r004CorrectedWouldApply += _r004CorrectedCount(
      input: input,
      foundation: foundation,
      supplementalAgreements: [...gf2.recoveredSnapshot.supplementalAgreements, ...mp001],
    );

    // GF2-only path (matches 200-human fusion_dead_zone_trace_runner).
    gf2OnlyFps.add(
      _narrativeAfter(
        input: input,
        recovered: gf2.recoveredSnapshot,
        createdAt: record.generatedAt,
      ),
    );

    // Current V2 validation sim (GF2 + MP-001 + broken R004).
    currentSimFps.add(
      _narrativeAfter(
        input: input,
        recovered: GlobalFusionRecoveredSnapshot(
          foundationSnapshot: foundation,
          supplementalAgreements: [
            ...gf2.recoveredSnapshot.supplementalAgreements,
            ...mp001,
          ],
          supplementalReinforcements: gf2.recoveredSnapshot.supplementalReinforcements,
          supplementalThemeSignals: gf2.recoveredSnapshot.supplementalThemeSignals,
          recoveryVersion: 'analysis.current',
          createdAt: record.generatedAt,
        ),
        createdAt: record.generatedAt,
        onPatternSnapshot: (snap) {
          for (final id in const [
            'progressive_builder',
            'meaning_seeker',
            'purpose_driven_motivation',
            'structured_operator',
            'adaptive_creator',
            'stable_orientation',
          ]) {
            if (snap.activations.any((a) => a.patternId == id)) {
              recoveryPatternCounts[id] = (recoveryPatternCounts[id] ?? 0) + 1;
            }
          }
        },
      ),
    );

    // Counterfactual: GF2 + MP-001 + corrected R004.
    final fixedR004 = _r004Corrected(
      input: input,
      foundation: foundation,
      supplementalAgreements: [...gf2.recoveredSnapshot.supplementalAgreements, ...mp001],
    );
    fixedR004Fps.add(
      _narrativeAfter(
        input: input,
        recovered: GlobalFusionRecoveredSnapshot(
          foundationSnapshot: foundation,
          supplementalAgreements: [
            ...gf2.recoveredSnapshot.supplementalAgreements,
            ...mp001,
          ],
          supplementalReinforcements: [
            ...gf2.recoveredSnapshot.supplementalReinforcements,
            ...fixedR004,
          ],
          supplementalThemeSignals: gf2.recoveredSnapshot.supplementalThemeSignals,
          recoveryVersion: 'analysis.fixed_r004',
          createdAt: record.generatedAt,
        ),
        createdAt: record.generatedAt,
      ),
    );

    final baseline = record.narrativeFingerprint;
    final current = currentSimFps.last;
    if (baseline != current) {
      final hasGf2 = gf2.recoveredSnapshot.supplementalAgreements.any(
        (a) =>
            a.mirrorKey == 'MIRROR_GROWTH_ORIENTATION' ||
            a.mirrorKey == 'MIRROR_LIFE_DIRECTION',
      );
      final hasMp = mp001.isNotEmpty;
      if (hasGf2 && hasMp) {
        convergenceByRecovery['both'] = convergenceByRecovery['both']! + 1;
      } else if (hasGf2) {
        convergenceByRecovery['gf2_growth_life_only'] =
            convergenceByRecovery['gf2_growth_life_only']! + 1;
      } else if (hasMp) {
        convergenceByRecovery['mp001_structure'] =
            convergenceByRecovery['mp001_structure']! + 1;
      }
    } else {
      convergenceByRecovery['neither_changed_narrative'] =
          convergenceByRecovery['neither_changed_narrative']! + 1;
    }
  }

  final baselineStats = _stats(baselineFps);
  final gf2Stats = _stats(gf2OnlyFps);
  final currentStats = _stats(currentSimFps);
  final fixedR004Stats = _stats(fixedR004Fps);
  final transition = _transitionAnalysis(baselineFps, currentSimFps);

  final report = {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'populationSize': records.length,
    'collapseScenarios': {
      'baseline_v1': baselineStats,
      'gf2_only_no_mp001': gf2Stats,
      'current_validation_sim_gf2_mp001': currentStats,
      'counterfactual_fixed_r004': fixedR004Stats,
    },
    'collapseDelta': {
      'gf2_only_vs_baseline': gf2Stats['collapseZones'] - baselineStats['collapseZones'],
      'current_sim_vs_baseline':
          currentStats['collapseZones'] - baselineStats['collapseZones'],
      'current_sim_vs_gf2_only':
          currentStats['collapseZones'] - gf2Stats['collapseZones'],
      'fixed_r004_vs_current_sim':
          fixedR004Stats['collapseZones'] - currentStats['collapseZones'],
    },
    'r004Analysis': {
      'brokenHarnessApplications': r004Broken,
      'correctedWouldApply': r004CorrectedWouldApply,
      'brokenLogic':
          'fusedReinforcementIds collects ALL mirror reinforcement IDs, then skips any reinforcement whose id is in that set — always true, so R004 never fires.',
      'correctedLogic':
          'Skip only if reinforcement mirrorKey already has a GF1 foundation reinforcement finding.',
      'growthLifeMirrorReinforcementsEligible': _countEligibleReinforcements(records),
    },
    'mp001Analysis': {
      'totalPromotionsApplied': mp001Total,
      'profilesWithMp001': records.where((r) => _mp001(r).isNotEmpty).length,
    },
    'gf2Analysis': {
      'totalSupplementalAgreements': gf2AgreementTotal,
    },
    'recoveryPatternActivationsAfterCurrentSim': recoveryPatternCounts,
    'narrativeChangeAttribution': convergenceByRecovery,
    'collapseTransition': transition,
    'patternConcentration': {
      'baselineTopPattern': _topPattern(records, null),
      'simulatedTopPattern': _topPattern(records, currentSimFps),
    },
    'reference200Human': {
      'baselineCollapseZones': 22,
      'gf2OnlySimulatedCollapseZones': 14,
      'note':
          '200-human fusion_dead_zone_trace_runner uses GF2-only (no MP-001 validation sim).',
    },
  };

  const outPath =
      'test/validation/synthetic_population_v2/output/collapse_analysis.json';
  File(outPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
  stdout.writeln('Wrote $outPath');
  stdout.writeln(jsonEncode(report['collapseDelta']));
  stdout.writeln(jsonEncode(report['r004Analysis']));
}

GlobalFusionInput _fusionInput(SyntheticHumanRunRecord record) {
  return GlobalFusionInput(
    mirrors: [
      GlobalFusionMirrorRef(
        mirrorRoleId: GlobalFusionMirrorRoles.astrology,
        snapshot: record.astrologyMirrorSnapshot,
      ),
      GlobalFusionMirrorRef(
        mirrorRoleId: GlobalFusionMirrorRoles.personality,
        snapshot: record.personalityMirrorSnapshot,
      ),
    ],
  );
}

String _narrativeAfter({
  required GlobalFusionInput input,
  required GlobalFusionRecoveredSnapshot recovered,
  required DateTime createdAt,
  void Function(dynamic snap)? onPatternSnapshot,
}) {
  final composed = GlobalFusionRecoveryComposer.composeForSimulation(
    input: input,
    recovered: recovered,
  );
  final human = HumanModelFoundationBuilder.build(
    HumanModelInput(fusionSnapshot: composed),
    createdAt: createdAt,
  );
  final pattern = HumanPatternSnapshotBuilder.build(
    HumanPatternInput(humanModelSnapshot: human),
    createdAt: createdAt,
  );
  onPatternSnapshot?.call(pattern);
  final narrative = NarrativeRuntimeService.generate(
    patternSnapshot: pattern,
    createdAt: createdAt,
  );
  final parts = <String>[];
  for (final section in narrative.sections) {
    for (final paragraph in section.paragraphs) {
      parts.add(paragraph.text.trim().toLowerCase());
    }
  }
  return parts.join('\n');
}

Map<String, dynamic> _stats(List<String> fps) {
  final counts = <String, int>{};
  for (final fp in fps) {
    counts[fp] = (counts[fp] ?? 0) + 1;
  }
  final collapseSizes = counts.values.where((c) => c >= 3).toList()..sort();
  final profilesInCollapse =
      counts.values.where((c) => c >= 3).fold<int>(0, (s, c) => s + c);
  return {
    'uniqueNarratives': counts.length,
    'collapseZones': collapseSizes.length,
    'profilesInCollapseZones': profilesInCollapse,
    'maxClusterSize': collapseSizes.isEmpty ? 0 : collapseSizes.last,
    'duplicationRate': 1 - counts.length / fps.length,
  };
}

Map<String, dynamic> _transitionAnalysis(
  List<String> baseline,
  List<String> simulated,
) {
  final baselineCounts = <String, int>{};
  final simulatedCounts = <String, int>{};
  for (final fp in baseline) {
    baselineCounts[fp] = (baselineCounts[fp] ?? 0) + 1;
  }
  for (final fp in simulated) {
    simulatedCounts[fp] = (simulatedCounts[fp] ?? 0) + 1;
  }

  var newCollapseZones = 0;
  var resolvedCollapseZones = 0;
  var profilesMergedIntoExistingCluster = 0;
  var profilesSplitFromCluster = 0;

  for (final entry in simulatedCounts.entries) {
    final before = baselineCounts[entry.key] ?? 0;
    if (entry.value >= 3 && before < 3) newCollapseZones++;
  }
  for (final entry in baselineCounts.entries) {
    final after = simulatedCounts[entry.key] ?? 0;
    if (entry.value >= 3 && after < 3) resolvedCollapseZones++;
    if (entry.value >= 3 && after > entry.value) {
      profilesMergedIntoExistingCluster += after - entry.value;
    }
    if (entry.value >= 3 && after < entry.value) {
      profilesSplitFromCluster += entry.value - after;
    }
  }

  var profilesWithNarrativeChange = 0;
  for (var i = 0; i < baseline.length; i++) {
    if (baseline[i] != simulated[i]) profilesWithNarrativeChange++;
  }

  return {
    'profilesWithNarrativeChange': profilesWithNarrativeChange,
    'newCollapseZones_crossedThreshold3': newCollapseZones,
    'resolvedCollapseZones_droppedBelow3': resolvedCollapseZones,
    'netCollapseZoneChange':
        newCollapseZones - resolvedCollapseZones,
    'profilesMergedIntoExistingClusters': profilesMergedIntoExistingCluster,
    'profilesSplitFromClusters': profilesSplitFromCluster,
  };
}

int _r004BrokenCount({
  required GlobalFusionInput input,
  required List<GlobalFusionSupplementalAgreement> supplementalAgreements,
}) {
  final agreementKeys =
      supplementalAgreements.map((a) => a.mirrorKey).toSet();
  final fusedReinforcementIds = input.mirrors
      .expand((ref) => ref.snapshot.reinforcements)
      .map((r) => r.id)
      .toSet();
  var count = 0;
  for (final ref in input.mirrors) {
    for (final reinforcement in ref.snapshot.reinforcements) {
      if (!agreementKeys.contains(reinforcement.mirrorKey)) continue;
      if (fusedReinforcementIds.contains(reinforcement.id)) continue;
      count++;
    }
  }
  return count;
}

int _r004CorrectedCount({
  required GlobalFusionInput input,
  required dynamic foundation,
  required List<GlobalFusionSupplementalAgreement> supplementalAgreements,
}) {
  return _r004Corrected(
    input: input,
    foundation: foundation,
    supplementalAgreements: supplementalAgreements,
  ).length;
}

List<GlobalFusionSupplementalReinforcement> _r004Corrected({
  required GlobalFusionInput input,
  required dynamic foundation,
  required List<GlobalFusionSupplementalAgreement> supplementalAgreements,
}) {
  const r004RuleId = 'filtered_mirror_reinforcement_recovery';
  final agreementKeys =
      supplementalAgreements.map((a) => a.mirrorKey).toSet();
  final foundationReinforcementKeys = foundation.reinforcements
      .map((r) => r.mirrorKey as String)
      .toSet();

  final results = <GlobalFusionSupplementalReinforcement>[];
  for (final ref in input.mirrors) {
    for (final reinforcement in ref.snapshot.reinforcements) {
      if (!agreementKeys.contains(reinforcement.mirrorKey)) continue;
      if (foundationReinforcementKeys.contains(reinforcement.mirrorKey)) {
        continue;
      }
      results.add(
        GlobalFusionSupplementalReinforcement(
          id:
              'analysis_r004_${CrossMirrorAgreementEngine.sha256Hex('${reinforcement.mirrorKey}|${ref.mirrorRoleId}|${reinforcement.id}')}',
          mirrorKey: reinforcement.mirrorKey,
          mirrorDimension: reinforcement.mirrorDimension,
          mirrorRoleIds: [ref.mirrorRoleId],
          mirrorFindingIds: [reinforcement.id],
          themeIds: List<String>.from(reinforcement.themeIds)..sort(),
          evidenceCount: reinforcement.evidenceCount,
          reinforcementBoost:
              reinforcement.structuralWeight.clamp(0.15, 0.35),
          riskLevel: FusionRecoveryRiskLevel.medium,
          recoveryRuleId: r004RuleId,
          sourceFindingIds: [reinforcement.id],
        ),
      );
    }
  }
  return results;
}

List<GlobalFusionSupplementalAgreement> _mp001(SyntheticHumanRunRecord record) {
  const structureKey = 'MIRROR_STRUCTURE_PATTERN';
  const mp001RuleId = 'single_system_evidence_promotion';
  const mp001MinConfidence = 0.55;
  final results = <GlobalFusionSupplementalAgreement>[];

  void evaluateRole({
    required String roleId,
    required List<KnowMeMirrorThemeSignal> signals,
    required KnowMeMirrorSnapshot snapshot,
  }) {
    if (snapshot.agreements.any((a) => a.mirrorKey == structureKey)) return;
    if (snapshot.reinforcements.any((r) => r.mirrorKey == structureKey)) return;
    final evidenceRows =
        snapshot.evidence.where((e) => e.mirrorKey == structureKey).toList();
    if (evidenceRows.isEmpty) return;
    final matching = signals.where((s) => s.mirrorKey == structureKey).toList();
    if (matching.isEmpty) return;
    if (matching.map((s) => s.systemId).toSet().length != 1) return;
    final mean =
        matching.fold<double>(0, (sum, s) => sum + s.confidence) / matching.length;
    if (mean < mp001MinConfidence) return;
    final themes = matching.map((s) => s.themeId).toSet().toList()..sort();
    final evidenceIds = evidenceRows
        .map((e) => '${e.mirrorObjectId}|${e.sourceThemeId}')
        .toList()
      ..sort();
    results.add(
      GlobalFusionSupplementalAgreement(
        id:
            'analysis_mp001_${CrossMirrorAgreementEngine.sha256Hex('$roleId|$structureKey|${evidenceIds.join(',')}')}',
        mirrorKey: structureKey,
        mirrorDimension: matching.first.mirrorDimension.id,
        mirrorRoleIds: [roleId],
        mirrorFindingIds: evidenceIds,
        themeIds: themes,
        agreementStrength: mean.clamp(0.0, 0.75),
        riskLevel: FusionRecoveryRiskLevel.medium,
        recoveryRuleId: mp001RuleId,
        sourceFindingIds: evidenceIds,
      ),
    );
  }

  evaluateRole(
    roleId: GlobalFusionMirrorRoles.astrology,
    signals: record.astrologyInput.signals,
    snapshot: record.astrologyMirrorSnapshot,
  );
  evaluateRole(
    roleId: GlobalFusionMirrorRoles.personality,
    signals: record.personalityInput.signals,
    snapshot: record.personalityMirrorSnapshot,
  );
  return results;
}

Map<String, int> _countEligibleReinforcements(
  List<SyntheticHumanRunRecord> records,
) {
  var growth = 0;
  var life = 0;
  for (final record in records) {
    for (final snap in [
      record.astrologyMirrorSnapshot,
      record.personalityMirrorSnapshot,
    ]) {
      growth += snap.reinforcements
          .where((r) => r.mirrorKey == 'MIRROR_GROWTH_ORIENTATION')
          .length;
      life += snap.reinforcements
          .where((r) => r.mirrorKey == 'MIRROR_LIFE_DIRECTION')
          .length;
    }
  }
  return {'MIRROR_GROWTH_ORIENTATION': growth, 'MIRROR_LIFE_DIRECTION': life};
}

Map<String, dynamic> _topPattern(
  List<SyntheticHumanRunRecord> records,
  List<String>? simulatedFps,
) {
  if (simulatedFps == null) {
    final counts = <String, int>{};
    for (final r in records) {
      for (final a in r.humanPatternSnapshot.activations) {
        counts[a.patternId] = (counts[a.patternId] ?? 0) + 1;
      }
    }
    final top = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {
      'directional_meaning': counts['directional_meaning'] ?? 0,
      'top5': top.take(5).map((e) => {'id': e.key, 'count': e.value}).toList(),
    };
  }

  final counts = <String, int>{};
  for (var i = 0; i < records.length; i++) {
    final input = _fusionInput(records[i]);
    final gf2 = GlobalFusionCoverageRecoveryBuilder.build(
      input: input,
      foundationSnapshot: records[i].globalFusionSnapshot,
      createdAt: records[i].generatedAt,
    );
    final mp001 = _mp001(records[i]);
    final composed = GlobalFusionRecoveryComposer.composeForSimulation(
      input: input,
      recovered: GlobalFusionRecoveredSnapshot(
        foundationSnapshot: records[i].globalFusionSnapshot,
        supplementalAgreements: [
          ...gf2.recoveredSnapshot.supplementalAgreements,
          ...mp001,
        ],
        supplementalReinforcements: gf2.recoveredSnapshot.supplementalReinforcements,
        supplementalThemeSignals: gf2.recoveredSnapshot.supplementalThemeSignals,
        recoveryVersion: 'analysis',
        createdAt: records[i].generatedAt,
      ),
    );
    final human = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: composed),
      createdAt: records[i].generatedAt,
    );
    final pattern = HumanPatternSnapshotBuilder.build(
      HumanPatternInput(humanModelSnapshot: human),
      createdAt: records[i].generatedAt,
    );
    for (final a in pattern.activations) {
      counts[a.patternId] = (counts[a.patternId] ?? 0) + 1;
    }
  }
  final top = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return {
    'directional_meaning': counts['directional_meaning'] ?? 0,
    'progressive_builder': counts['progressive_builder'] ?? 0,
    'meaning_seeker': counts['meaning_seeker'] ?? 0,
    'structured_operator': counts['structured_operator'] ?? 0,
    'top5': top.take(5).map((e) => {'id': e.key, 'count': e.value}).toList(),
  };
}
