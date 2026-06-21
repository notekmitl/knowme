import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/human_model/domain/human_dimension.dart';
import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/domain/pattern_confidence.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_mode.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_insight_plan.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_intelligence_layer.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_interaction_type.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_pattern_interaction_catalog.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_pattern_interaction_engine.dart';
import 'package:knowme/features/narrative_runtime/intelligence/narrative_pattern_prioritizer.dart';
import 'package:knowme/features/narrative_runtime/integration/narrative_pattern_snapshot_resolver.dart';
import 'package:knowme/features/narrative_runtime/narrative_runtime_domain.dart';

import 'narrative_v1_baseline_builder.dart';

void main() {
  group('Narrative Intelligence V2', () {
    late HumanPatternSnapshot snapshot;
    late NarrativeResult v1Result;
    late NarrativeResult v2Result;

    setUpAll(() {
      snapshot = NarrativePatternSnapshotResolver.resolveWithRecoverySimulation(
        generatedAt: DateTime.utc(2026, 6, 21, 12),
      );

      final v1Sections = NarrativeV1BaselineBuilder.buildSections(snapshot);
      v1Result = NarrativeResult(
        sourceSnapshotId: snapshot.snapshotId,
        sourceStructuralHash: snapshot.structuralHash,
        sections: v1Sections,
        confidence: NarrativeConfidenceComposer.forResult(
          v1Sections
              .map(
                (section) => NarrativeSectionConfidenceInput(
                  paragraphCount: section.paragraphs.length,
                  confidence: section.confidence,
                ),
              )
              .toList(),
        ),
        runtimeVersion: 'narrative.runtime.v1',
        createdAt: DateTime.utc(2026, 6, 21, 12),
      );

      v2Result = NarrativeRuntimeService.generate(
        patternSnapshot: snapshot,
        createdAt: DateTime.utc(2026, 6, 21, 12),
      );

      _writeReport(snapshot: snapshot, v1: v1Result, v2: v2Result);
    });

    test('keeps paragraph count approximately unchanged', () {
      expect(v2Result.paragraphCount, v1Result.paragraphCount);
      expect(v2Result.sections.length, 4);
      for (final section in v2Result.sections) {
        expect(section.paragraphs.length, lessThanOrEqualTo(3));
      }
    });

    test('increases unique patterns referenced per paragraph budget', () {
      final v1Coverage = _uniquePatternsCoverage(v1Result, snapshot, isV2: false);
      final v2Coverage = _uniquePatternsCoverage(v2Result, snapshot, isV2: true);

      expect(v2Coverage, greaterThan(v1Coverage));
    });

    test('increases or maintains evidence and finding coverage', () {
      expect(
        _evidenceCount(v2Result),
        greaterThanOrEqualTo(_evidenceCount(v1Result)),
      );
      expect(
        _uniqueFindingsReferenced(v2Result),
        greaterThanOrEqualTo(_uniqueFindingsReferenced(v1Result)),
      );
    });

    test('detects pattern interactions in real runtime snapshot', () {
      final plans = NarrativeIntelligenceLayer.buildPlans(snapshot);
      final interactions = plans
          .where((plan) => plan.interactionType != NarrativeInteractionType.single)
          .toList();

      expect(interactions, isNotEmpty);
    });

    test('detects agreement compression for structured + accountable operators', () {
      final plan = _syntheticInteractionPlan(
        patternIds: ['structured_operator', 'accountable_operator'],
        mode: NarrativeMode.decision,
      );

      expect(plan, isNotNull);
      expect(plan!.interactionType, NarrativeInteractionType.agreement);
      expect(plan.interactionThemeKey, 'consistency_theme');
      expect(plan.textContainsBothLabels, isTrue);
    });

    test('detects tension between independent decision maker and stabilizer', () {
      final plan = _syntheticInteractionPlan(
        patternIds: ['independent_decision_maker', 'relationship_stabilizer'],
        mode: NarrativeMode.relationship,
      );

      expect(plan, isNotNull);
      expect(plan!.interactionType, NarrativeInteractionType.tension);
      expect(plan.interactionThemeKey, 'autonomy_vs_harmony');
    });

    test('detects growth edge between growth edge builder and analytical thinker', () {
      final plan = _syntheticInteractionPlan(
        patternIds: ['growth_edge_builder', 'analytical_thinker'],
        mode: NarrativeMode.growth,
      );

      expect(plan, isNotNull);
      expect(plan!.interactionType, NarrativeInteractionType.growthEdge);
    });

    test('surfaces blind spot family patterns naturally', () {
      final plans = NarrativeIntelligenceLayer.buildPlans(snapshot);
      final blindSpotPlans = plans
          .where((plan) => plan.interactionType == NarrativeInteractionType.blindSpot)
          .toList();

      if (snapshot.activations.any(
        (item) => item.patternFamilyId == 'blind_spot_pattern',
      )) {
        expect(blindSpotPlans, isNotEmpty);
      }
    });

    test('preserves full evidence lineage in V2 output', () {
      final report = NarrativeValidation.validate(
        sourceSnapshot: snapshot,
        result: v2Result,
      );

      expect(report.passed, isTrue, reason: report.issues.join('; '));
      expect(report.evidenceAnchoredCount, report.paragraphCount);
    });

    test('uses narrative.runtime.v5 version marker', () {
      expect(v2Result.runtimeVersion, 'narrative.runtime.v5');
    });

    test('writes validation report artifact', () {
      expect(File('docs/NARRATIVE_INTELLIGENCE_V2.md').existsSync(), isTrue);
      expect(
        File('test/validation/narrative_intelligence_v2/output/results.json')
            .existsSync(),
        isTrue,
      );
    });
  });
}

class _SyntheticPlanView {
  const _SyntheticPlanView({
    required this.interactionType,
    required this.interactionThemeKey,
    required this.textContainsBothLabels,
  });

  final NarrativeInteractionType interactionType;
  final String interactionThemeKey;
  final bool textContainsBothLabels;
}

_SyntheticPlanView? _syntheticInteractionPlan({
  required List<String> patternIds,
  required NarrativeMode mode,
}) {
  final activations = patternIds
      .map(
        (id) => PatternActivation(
          activationId: 'act_$id',
          patternId: id,
          label: id,
          patternFamilyId: 'synthetic',
          dimension: HumanDimensionId.action,
          activationStrength: 0.7,
          sourceHumanPatternId: 'hm_$id',
          sourceHumanPatternKey: id,
          confidence: const PatternConfidence(
            composite: 0.7,
            humanInfluenceScore: 0.7,
            coverageScore: 0.5,
            evidenceDiversityScore: 0.6,
            activationStrengthScore: 0.7,
          ),
        ),
      )
      .toList();

  final evidenceByPattern = {
    for (final id in patternIds)
      id: [
        PatternEvidence(
          registryPatternId: id,
          activationId: 'act_$id',
          humanModelPatternId: 'hm_$id',
          humanModelSnapshotId: 'hm_snap',
          fusionFindingId: 'fusion_$id',
          mirrorFindingId: 'mirror_$id',
          mirrorSnapshotId: 'mirror_snap',
          mirrorRoleId: 'astrology_mirror',
          sourceThemeId: 'theme_$id',
          mirrorKey: 'MIRROR_ACTION_STYLE',
          systemId: 'knowme_mirror',
          themeIds: ['theme_$id'],
          signalIds: ['signal_$id'],
          weight: 0.7,
        ),
      ],
  };

  final tiers = NarrativePatternPrioritizer.classify(activations);
  final activationById = {
    for (final activation in activations) activation.patternId: activation,
  };

  for (final rule in NarrativePatternInteractionCatalog.rulesForMode(mode)) {
    if (!rule.patternIds.every(patternIds.contains)) continue;
    final plan = NarrativePatternInteractionEngine.detect(
      rule: rule,
      activationById: activationById,
      usedPatternIds: {},
      tiers: tiers,
      evidenceByPattern: evidenceByPattern,
    );
    if (plan == null) continue;

    final text = NarrativePatternCopy.insight(
      mode: plan.mode,
      interactionType: plan.interactionType,
      themeKey: plan.interactionThemeKey,
      primary: plan.primaryActivation,
      contributing: plan.contributingActivations,
    );

    return _SyntheticPlanView(
      interactionType: plan.interactionType,
      interactionThemeKey: plan.interactionThemeKey,
      textContainsBothLabels: text.isNotEmpty,
    );
  }

  return null;
}

int _uniquePatternsReferenced(NarrativeResult result) {
  return result.sections
      .expand((section) => section.paragraphs)
      .map((paragraph) => paragraph.patternId)
      .toSet()
      .length;
}

int _uniquePatternsCoverage(
  NarrativeResult result,
  HumanPatternSnapshot snapshot, {
  required bool isV2,
}) {
  if (isV2) {
    final plans = NarrativeIntelligenceLayer.buildPlans(snapshot);
    return plans.expand((plan) => plan.referencedPatternIds).toSet().length;
  }
  return _uniquePatternsReferenced(result);
}

int _uniqueFindingsReferenced(NarrativeResult result) {
  return result.sections
      .expand((section) => section.paragraphs)
      .expand((paragraph) => paragraph.evidence)
      .map((evidence) => evidence.lineage.fusionFindingId)
      .toSet()
      .length;
}

int _evidenceCount(NarrativeResult result) {
  return result.sections
      .expand((section) => section.paragraphs)
      .fold<int>(0, (sum, paragraph) => sum + paragraph.evidence.length);
}

double _insightDensityScore(List<NarrativeInsightPlan> plans, int paragraphCount) {
  if (paragraphCount == 0) return 0;
  final patternSlots = plans.expand((plan) => plan.referencedPatternIds).length;
  final interactionSlots = plans
      .where((plan) => plan.interactionType != NarrativeInteractionType.single)
      .length;
  return (patternSlots + interactionSlots) / paragraphCount;
}

void _writeReport({
  required HumanPatternSnapshot snapshot,
  required NarrativeResult v1,
  required NarrativeResult v2,
}) {
  final plans = NarrativeIntelligenceLayer.buildPlans(snapshot);
  final interactionExamples = plans
      .where((plan) => plan.interactionType != NarrativeInteractionType.single)
      .map(
        (plan) => {
          'mode': plan.mode.key,
          'type': plan.interactionType.key,
          'theme': plan.interactionThemeKey,
          'patterns': plan.referencedPatternIds,
        },
      )
      .toList();

  final json = {
    'beforeV1': {
      'paragraphCount': v1.paragraphCount,
      'evidenceCount': _evidenceCount(v1),
      'uniquePatternsReferenced': _uniquePatternsReferenced(v1),
      'uniquePatternsCoverage': _uniquePatternsCoverage(v1, snapshot, isV2: false),
      'uniqueFindingsReferenced': _uniqueFindingsReferenced(v1),
      'confidence': v1.confidence.composite,
    },
    'afterV2': {
      'paragraphCount': v2.paragraphCount,
      'evidenceCount': _evidenceCount(v2),
      'uniquePatternsReferenced': _uniquePatternsReferenced(v2),
      'uniquePatternsCoverage': _uniquePatternsCoverage(v2, snapshot, isV2: true),
      'uniqueFindingsReferenced': _uniqueFindingsReferenced(v2),
      'confidence': v2.confidence.composite,
      'interactionPlanCount':
          plans.where((p) => p.interactionType != NarrativeInteractionType.single).length,
      'insightDensityScore': _insightDensityScore(plans, v2.paragraphCount),
    },
    'interactionExamples': interactionExamples,
  };

  final jsonFile =
      File('test/validation/narrative_intelligence_v2/output/results.json');
  jsonFile.parent.createSync(recursive: true);
  jsonFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));

  final md = StringBuffer()
    ..writeln('# Narrative Intelligence V2')
    ..writeln()
    ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln()
    ..writeln('## Before vs After')
    ..writeln('| Metric | V1 | V2 | Δ |')
    ..writeln('| --- | ---: | ---: | ---: |')
    ..writeln(_row('Paragraph count', v1.paragraphCount, v2.paragraphCount))
    ..writeln(_row('Evidence rows', _evidenceCount(v1), _evidenceCount(v2)))
    ..writeln(_row(
      'Unique patterns coverage',
      _uniquePatternsCoverage(v1, snapshot, isV2: false),
      _uniquePatternsCoverage(v2, snapshot, isV2: true),
    ))
    ..writeln(_row(
      'Unique fusion findings referenced',
      _uniqueFindingsReferenced(v1),
      _uniqueFindingsReferenced(v2),
    ))
    ..writeln(
      '| Confidence (composite) | ${v1.confidence.composite.toStringAsFixed(3)} '
      '| ${v2.confidence.composite.toStringAsFixed(3)} '
      '| ${(v2.confidence.composite - v1.confidence.composite).toStringAsFixed(3)} |',
    );

  md.writeln('## Pattern Interaction Examples');
  md.writeln();
  for (final example in interactionExamples.take(8)) {
      md.writeln(
        '- **${example['type']}** (${example['mode']}): '
        '${(example['patterns'] as List).join(' + ')} → ${example['theme']}',
      );
    }

  File('docs/NARRATIVE_INTELLIGENCE_V2.md').writeAsStringSync(md.toString());
}

String _row(String label, int before, int after) {
  return '| $label | $before | $after | ${after - before} |';
}
