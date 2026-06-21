import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/global_fusion/foundation/builder/global_fusion_foundation_builder.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/v2/global_fusion_v2_domain.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';

import '../human_pattern_activation_audit/pattern_activation_forensics.dart';
import '../synthetic_population/pipeline/synthetic_human_run_record.dart';
import '../synthetic_population/synthetic_population_runner.dart';

/// Read-only Global Fusion Foundation Validation V2 — dead-zone trace + recovery sim.
abstract final class FusionDeadZoneTraceRunner {
  static const deadZoneKeys = [
    'MIRROR_LIFE_DIRECTION',
    'MIRROR_GROWTH_ORIENTATION',
    'MIRROR_STRUCTURE_PATTERN',
  ];

  static Map<String, dynamic> run() {
    final records = SyntheticPopulationRunner.runAll().records;
    final traces = <String, dynamic>{};
    for (final key in deadZoneKeys) {
      traces[key] = _traceKey(key, records);
    }

    final reachability = _reachabilityMatrix(records);
    final contractAudit = _contractAudit(traces);
    final recovery = _recoverySimulation(records);
    final severity = _severityRanking(traces, reachability, recovery);

    return {
      'version': 'global_fusion_foundation_validation_v2',
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'populationSize': records.length,
      'deadZoneTraceReport': traces,
      'reachabilityMatrix': reachability,
      'boundaryFailureAnalysis': contractAudit,
      'recoverySimulation': recovery,
      'severityRanking': severity,
    };
  }

  static Map<String, dynamic> _traceKey(
    String mirrorKey,
    List<SyntheticHumanRunRecord> records,
  ) {
    var inputSignals = 0;
    var astroMirrorAgreements = 0;
    var personalityMirrorAgreements = 0;
    var astroMirrorReinforcements = 0;
    var personalityMirrorReinforcements = 0;
    var astroMirrorEvidence = 0;
    var personalityMirrorEvidence = 0;
    var fusionAgreements = 0;
    var fusionReinforcements = 0;
    var fusionTensions = 0;
    var fusionBlindSpots = 0;
    var humanModelPatterns = 0;
    var humanModelEvidence = 0;
    var humanPatternActivations = 0;
    var narrativeReferences = 0;
    var profilesWithInputSignal = 0;
    var profilesWithAnyMirrorFinding = 0;
    var profilesWithFusionFinding = 0;
    var profilesWithHumanModel = 0;
    var profilesWithPatternActivation = 0;
    var profilesWithNarrativeRef = 0;

    final astroRoles = <String>{};
    final personalityRoles = <String>{};
    final fusionRoles = <String>{};

    for (final r in records) {
      final hasInput = [
        ...r.astrologyInput.signals,
        ...r.personalityInput.signals,
      ].any((s) => s.mirrorKey == mirrorKey);
      if (hasInput) {
        profilesWithInputSignal++;
        inputSignals += [
          ...r.astrologyInput.signals,
          ...r.personalityInput.signals,
        ].where((s) => s.mirrorKey == mirrorKey).length;
      }

      final astroAg = r.astrologyMirrorSnapshot.agreements
          .where((f) => f.mirrorKey == mirrorKey)
          .length;
      final persAg = r.personalityMirrorSnapshot.agreements
          .where((f) => f.mirrorKey == mirrorKey)
          .length;
      astroMirrorAgreements += astroAg;
      personalityMirrorAgreements += persAg;
      if (astroAg > 0) astroRoles.add('astrology');
      if (persAg > 0) personalityRoles.add('personality');

      astroMirrorReinforcements += r.astrologyMirrorSnapshot.reinforcements
          .where((f) => f.mirrorKey == mirrorKey)
          .length;
      personalityMirrorReinforcements += r.personalityMirrorSnapshot.reinforcements
          .where((f) => f.mirrorKey == mirrorKey)
          .length;

      astroMirrorEvidence += r.astrologyMirrorSnapshot.evidence
          .where((e) => e.mirrorKey == mirrorKey)
          .length;
      personalityMirrorEvidence += r.personalityMirrorSnapshot.evidence
          .where((e) => e.mirrorKey == mirrorKey)
          .length;

      final fusion = r.globalFusionSnapshot;
      final fAg = fusion.agreements.where((f) => f.mirrorKey == mirrorKey).length;
      final fRf = fusion.reinforcements.where((f) => f.mirrorKey == mirrorKey).length;
      final fTn = fusion.tensions.where((f) => f.mirrorKey == mirrorKey).length;
      final fBs = fusion.blindSpots.where((f) => f.mirrorKey == mirrorKey).length;
      fusionAgreements += fAg;
      fusionReinforcements += fRf;
      fusionTensions += fTn;
      fusionBlindSpots += fBs;
      if (fAg + fRf + fTn + fBs > 0) {
        profilesWithFusionFinding++;
        for (final item in fusion.agreements) {
          if (item.mirrorKey == mirrorKey) {
            fusionRoles.addAll(item.mirrorRoleIds);
          }
        }
      }

      final humanModel = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: fusion),
        createdAt: r.generatedAt,
      );
      final hmPatterns = humanModel.patterns
          .where((p) => p.supportingMirrorKeys.contains(mirrorKey))
          .length;
      final hmEvidence = humanModel.evidence
          .where((e) => e.mirrorKey == mirrorKey)
          .length;
      humanModelPatterns += hmPatterns;
      humanModelEvidence += hmEvidence;
      if (hmPatterns + hmEvidence > 0) profilesWithHumanModel++;

      final activated = r.humanPatternSnapshot.activations
          .where((a) {
            final entry = HumanPatternRegistry.byId(a.patternId);
            return entry?.activationRule.requiredMirrorKey == mirrorKey;
          })
          .length;
      humanPatternActivations += activated;
      if (activated > 0) profilesWithPatternActivation++;

      final narrativeText = r.narrativeResult.sections
          .expand((s) => s.paragraphs)
          .map((p) => p.text)
          .join('\n');
      final slug = mirrorKey.replaceFirst('MIRROR_', '').replaceAll('_', ' ');
      if (narrativeText.toLowerCase().contains(slug.toLowerCase()) ||
          narrativeText.contains(mirrorKey)) {
        narrativeReferences++;
        profilesWithNarrativeRef++;
      }

      if (astroAg + persAg + astroMirrorReinforcements +
              personalityMirrorReinforcements >
          0) {
        profilesWithAnyMirrorFinding++;
      }
    }

    String boundary = 'none';
    if (inputSignals > 0 && fusionAgreements + fusionReinforcements +
            fusionTensions + fusionBlindSpots ==
        0) {
      if (astroMirrorAgreements + personalityMirrorAgreements > 0) {
        boundary = 'mirror_snapshot→global_fusion';
      } else if (astroMirrorEvidence + personalityMirrorEvidence > 0) {
        boundary = 'mirror_input→mirror_findings';
      } else {
        boundary = 'mirror_input_only_no_findings';
      }
    } else if (fusionAgreements + fusionReinforcements > 0 &&
        humanModelPatterns + humanModelEvidence == 0) {
      boundary = 'global_fusion→human_model';
    } else if (humanModelPatterns + humanModelEvidence > 0 &&
        humanPatternActivations == 0) {
      boundary = 'human_model→human_pattern';
    } else if (humanPatternActivations > 0 && narrativeReferences == 0) {
      boundary = 'human_pattern→narrative';
    }

    return {
      'mirrorKey': mirrorKey,
      'layerCounts': {
        'mirror_input_signals': inputSignals,
        'astro_mirror_agreements': astroMirrorAgreements,
        'personality_mirror_agreements': personalityMirrorAgreements,
        'astro_mirror_reinforcements': astroMirrorReinforcements,
        'personality_mirror_reinforcements': personalityMirrorReinforcements,
        'astro_mirror_evidence': astroMirrorEvidence,
        'personality_mirror_evidence': personalityMirrorEvidence,
        'fusion_agreements': fusionAgreements,
        'fusion_reinforcements': fusionReinforcements,
        'fusion_tensions': fusionTensions,
        'fusion_blind_spots': fusionBlindSpots,
        'human_model_patterns': humanModelPatterns,
        'human_model_evidence': humanModelEvidence,
        'human_pattern_activations': humanPatternActivations,
        'narrative_references': narrativeReferences,
      },
      'profileReach': {
        'withInputSignal': profilesWithInputSignal,
        'withAnyMirrorFinding': profilesWithAnyMirrorFinding,
        'withFusionFinding': profilesWithFusionFinding,
        'withHumanModelSignal': profilesWithHumanModel,
        'withPatternActivation': profilesWithPatternActivation,
        'withNarrativeReference': profilesWithNarrativeRef,
      },
      'rolesObserved': {
        'astroMirrorAgreementRoles': astroRoles.toList()..sort(),
        'personalityMirrorAgreementRoles': personalityRoles.toList()..sort(),
        'fusionAgreementRoles': fusionRoles.toList()..sort(),
      },
      'exactBoundaryFailure': boundary,
      'fusionFindingCountTotal': fusionAgreements +
          fusionReinforcements +
          fusionTensions +
          fusionBlindSpots,
    };
  }

  static Map<String, dynamic> _reachabilityMatrix(
    List<SyntheticHumanRunRecord> records,
  ) {
    final dependentPatterns = HumanPatternRegistry.allEntries
        .where(
          (e) =>
              deadZoneKeys.contains(e.activationRule.requiredMirrorKey),
        )
        .map(
          (e) => {
            'patternId': e.patternId,
            'requiredMirrorKey': e.activationRule.requiredMirrorKey,
            'requiredFusionFindingType':
                e.activationRule.requiredFusionFindingType,
            'sourceHumanPatternKey': e.activationRule.sourceHumanPatternKey,
          },
        )
        .toList();

    final classifications = <Map<String, dynamic>>[];
    for (final dep in dependentPatterns) {
      final patternId = dep['patternId'] as String;
      var activated = 0;
      var noSource = 0;
      var typeMismatch = 0;
      var strengthFail = 0;
      for (final record in records) {
        final humanModel = HumanModelFoundationBuilder.build(
          HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
          createdAt: record.generatedAt,
        );
        final diagnosis = PatternActivationForensics.diagnose(
          snapshot: humanModel,
          patternId: patternId,
        );
        switch (diagnosis.outcome) {
          case PatternActivationOutcome.activated:
            activated++;
          case PatternActivationOutcome.noSourcePattern:
            noSource++;
          case PatternActivationOutcome.fusionFindingTypeMismatch:
            typeMismatch++;
          case PatternActivationOutcome.patternStrengthBelowMin:
          case PatternActivationOutcome.dimensionActivationBelowMin:
            strengthFail++;
          default:
            break;
        }
      }

      String status;
      if (activated > 0) {
        status = 'Reachable';
      } else if (noSource == records.length) {
        status = 'Structurally Blocked';
      } else {
        status = 'Conditionally Reachable';
      }

      classifications.add({
        ...dep,
        'status': status,
        'activatedProfiles': activated,
        'noSourceProfiles': noSource,
        'fusionTypeMismatchProfiles': typeMismatch,
        'strengthOrDimensionFailProfiles': strengthFail,
        'populationSize': records.length,
      });
    }

    return {
      'dependentPatternCount': dependentPatterns.length,
      'classifications': classifications,
    };
  }

  static Map<String, dynamic> _contractAudit(Map<String, dynamic> traces) {
    final causes = <String, dynamic>{};
    for (final key in deadZoneKeys) {
      final trace = traces[key] as Map<String, dynamic>;
      final counts = trace['layerCounts'] as Map<String, dynamic>;
      final reach = trace['profileReach'] as Map<String, dynamic>;
      final boundary = trace['exactBoundaryFailure'] as String;

      String primaryCause;
      if ((counts['mirror_input_signals'] as int) == 0) {
        primaryCause = 'mirror_emission_failure';
      } else if (boundary == 'mirror_snapshot→global_fusion') {
        primaryCause = 'fusion_filtering';
      } else if (boundary == 'mirror_input→mirror_findings') {
        primaryCause = 'mirror_emission_failure';
      } else if (boundary == 'global_fusion→human_model') {
        primaryCause = 'human_model_mapping_loss';
      } else if (boundary == 'human_model→human_pattern') {
        primaryCause = 'human_pattern_activation_dependency';
      } else if (boundary == 'human_pattern→narrative') {
        primaryCause = 'narrative_compression';
      } else {
        primaryCause = 'unknown';
      }

      causes[key] = {
        'primaryCauseCode': primaryCause,
        'exactBoundaryFailure': boundary,
        'evidence': {
          'inputSignals': counts['mirror_input_signals'],
          'mirrorAgreementTotal': (counts['astro_mirror_agreements'] as int) +
              (counts['personality_mirror_agreements'] as int),
          'fusionFindingsTotal': trace['fusionFindingCountTotal'],
          'profilesWithInput': reach['withInputSignal'],
          'profilesWithMirrorFinding': reach['withAnyMirrorFinding'],
          'profilesWithFusionFinding': reach['withFusionFinding'],
          'filterRule':
              'crossMirrorAgreementRequiresTwoRoles (GF3 CrossMirrorAgreementEngine)',
        },
      };
    }
    return causes;
  }

  static Map<String, dynamic> _recoverySimulation(
    List<SyntheticHumanRunRecord> records,
  ) {
    var baselineActivations = 0;
    var simulatedActivations = 0;
    var baselineUniquePatterns = <String>{};
    var simulatedUniquePatterns = <String>{};
    var baselineNarrativeList = <String>[];
    var simulatedNarrativeList = <String>[];
    var supplementalKeysRecovered = <String, int>{
      for (final k in deadZoneKeys) k: 0,
    };
    var profilesWithRecoveredKey = <String, int>{
      for (final k in deadZoneKeys) k: 0,
    };

    for (final record in records) {
      baselineActivations += record.humanPatternSnapshot.activations.length;
      baselineUniquePatterns.add(record.patternFingerprint);
      baselineNarrativeList.add(record.narrativeFingerprint);

      final input = GlobalFusionInput(
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

      final recovery = GlobalFusionCoverageRecoveryBuilder.build(
        input: input,
        foundationSnapshot: record.globalFusionSnapshot,
        createdAt: record.generatedAt,
      );

      final composed = GlobalFusionRecoveryComposer.composeForSimulation(
        input: input,
        recovered: recovery.recoveredSnapshot,
      );

      for (final key in deadZoneKeys) {
        final recovered = composed.agreements
                .where((f) => f.mirrorKey == key)
                .length +
            composed.reinforcements.where((f) => f.mirrorKey == key).length;
        if (recovered > 0) {
          supplementalKeysRecovered[key] =
              supplementalKeysRecovered[key]! + recovered;
          profilesWithRecoveredKey[key] = profilesWithRecoveredKey[key]! + 1;
        }
      }

      final afterHuman = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: composed),
        createdAt: record.generatedAt,
      );
      final afterPattern = HumanPatternSnapshotBuilder.build(
        HumanPatternInput(humanModelSnapshot: afterHuman),
        createdAt: record.generatedAt,
      );
      final afterNarrative = NarrativeRuntimeService.generate(
        patternSnapshot: afterPattern,
        createdAt: record.generatedAt,
      );

      simulatedActivations += afterPattern.activations.length;
      simulatedUniquePatterns.add(
        (afterPattern.activations.map((a) => a.patternId).toList()..sort())
            .join('|'),
      );

      final parts = <String>[];
      for (final section in afterNarrative.sections) {
        for (final paragraph in section.paragraphs) {
          parts.add(paragraph.text.trim().toLowerCase());
        }
      }
      simulatedNarrativeList.add(parts.join('\n'));
    }

    final baselineNarratives = baselineNarrativeList.toSet();
    final simulatedNarratives = simulatedNarrativeList.toSet();

    return {
      'simulationEngine': 'GlobalFusionCoverageRecoveryBuilder + RecoveryComposer (V2, read-only)',
      'populationSize': records.length,
      'baseline': {
        'totalActivations': baselineActivations,
        'uniquePatternSets': baselineUniquePatterns.length,
        'uniqueNarratives': baselineNarratives.length,
        'avgActivationsPerProfile':
            baselineActivations / records.length,
      },
      'simulatedAfterRecovery': {
        'totalActivations': simulatedActivations,
        'uniquePatternSets': simulatedUniquePatterns.length,
        'uniqueNarratives': simulatedNarratives.length,
        'avgActivationsPerProfile': simulatedActivations / records.length,
        'additionalActivations': simulatedActivations - baselineActivations,
        'additionalUniquePatternSets':
            simulatedUniquePatterns.length - baselineUniquePatterns.length,
        'additionalUniqueNarratives':
            simulatedNarratives.length - baselineNarratives.length,
      },
      'deadZoneKeyRecovery': {
        for (final key in deadZoneKeys)
          key: {
            'profilesWithRecoveredFusionFinding':
                profilesWithRecoveredKey[key],
            'totalRecoveredFusionFindings': supplementalKeysRecovered[key],
          },
      },
      'newlyActivatedPatterns': _newlyActivatedPatterns(records),
      'collapseZoneReduction': {
        'baselineUniqueNarratives': baselineNarratives.length,
        'simulatedUniqueNarratives': simulatedNarratives.length,
        'baselineCollapseZones': _countCollapseZones(baselineNarrativeList),
        'simulatedCollapseZones': _countCollapseZones(simulatedNarrativeList),
        'baselineDuplicationRate':
            1 - baselineNarratives.length / records.length,
        'simulatedDuplicationRate':
            1 - simulatedNarratives.length / records.length,
      },
    };
  }

  static int _countCollapseZones(List<String> fingerprints) {
    final counts = <String, int>{};
    for (final fp in fingerprints) {
      counts[fp] = (counts[fp] ?? 0) + 1;
    }
    return counts.values.where((c) => c >= 3).length;
  }

  static List<Map<String, dynamic>> _newlyActivatedPatterns(
    List<SyntheticHumanRunRecord> records,
  ) {
    final depIds = HumanPatternRegistry.allEntries
        .where(
          (e) => deadZoneKeys.contains(e.activationRule.requiredMirrorKey),
        )
        .map((e) => e.patternId)
        .toSet();

    final baselineCounts = <String, int>{};
    final simulatedCounts = <String, int>{};

    for (final record in records) {
      for (final id in depIds) {
        final baselineActive = record.humanPatternSnapshot.activations
            .any((a) => a.patternId == id);
        if (baselineActive) {
          baselineCounts[id] = (baselineCounts[id] ?? 0) + 1;
        }

        final input = GlobalFusionInput(
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
        final recovery = GlobalFusionCoverageRecoveryBuilder.build(
          input: input,
          foundationSnapshot: record.globalFusionSnapshot,
          createdAt: record.generatedAt,
        );
        final composed = GlobalFusionRecoveryComposer.composeForSimulation(
          input: input,
          recovered: recovery.recoveredSnapshot,
        );
        final afterHuman = HumanModelFoundationBuilder.build(
          HumanModelInput(fusionSnapshot: composed),
          createdAt: record.generatedAt,
        );
        final afterPattern = HumanPatternSnapshotBuilder.build(
          HumanPatternInput(humanModelSnapshot: afterHuman),
          createdAt: record.generatedAt,
        );
        final simActive =
            afterPattern.activations.any((a) => a.patternId == id);
        if (simActive) {
          simulatedCounts[id] = (simulatedCounts[id] ?? 0) + 1;
        }
      }
    }

    return [
      for (final id in depIds)
        {
          'patternId': id,
          'baselineActivations': baselineCounts[id] ?? 0,
          'simulatedActivations': simulatedCounts[id] ?? 0,
          'delta': (simulatedCounts[id] ?? 0) - (baselineCounts[id] ?? 0),
        },
    ]..sort((a, b) => (b['delta'] as int).compareTo(a['delta'] as int));
  }

  static List<Map<String, dynamic>> _severityRanking(
    Map<String, dynamic> traces,
    Map<String, dynamic> reachability,
    Map<String, dynamic> recovery,
  ) {
    final blockedPatterns = (reachability['classifications'] as List)
        .where((c) => c['status'] == 'Structurally Blocked')
        .length;

    return [
      for (final key in deadZoneKeys)
        () {
          final trace = traces[key] as Map<String, dynamic>;
          final reach = trace['profileReach'] as Map<String, dynamic>;
          final inputProfiles = reach['withInputSignal'] as int;
          final recoveryKey = recovery['deadZoneKeyRecovery'][key]
              as Map<String, dynamic>;
          final deltaPatterns = (recovery['newlyActivatedPatterns'] as List)
              .where(
                (p) =>
                    HumanPatternRegistry.byId(p['patternId'] as String)
                        ?.activationRule
                        .requiredMirrorKey ==
                    key,
              )
              .fold<int>(0, (sum, p) => sum + (p['delta'] as int));

          return {
            'mirrorKey': key,
            'severity': inputProfiles > 100 ? 'High' : 'Medium',
            'userImpact':
                'None today (validation pipeline only; not Home-integrated)',
            'architectureImpact':
                'Blocks $blockedPatterns dependent registry patterns at human-model source',
            'profilesWithMirrorInput': inputProfiles,
            'profilesWithFusionFinding': reach['withFusionFinding'],
            'simulatedProfilesRecovered':
                recoveryKey['profilesWithRecoveredFusionFinding'],
            'simulatedPatternActivationDelta': deltaPatterns,
            'shouldFixNow': 'No',
            'why':
                'Confirmed fusion contract gate (cross-mirror two-role requirement). Fix belongs to Global Fusion Foundation program, not V1 frozen surfaces.',
          };
        }(),
    ];
  }

  static void writeReport({String? outputPath}) {
    final result = run();
    final path = outputPath ??
        'test/validation/global_fusion_foundation_v2/output/results.json';
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(result));
  }
}

void main() {
  FusionDeadZoneTraceRunner.writeReport();
  stdout.writeln('Global Fusion Foundation Validation V2 report written.');
}
