import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';

import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';



import '../domain/narrative_evidence.dart';

import '../domain/narrative_lineage.dart';

import '../domain/narrative_mode.dart';

import '../domain/narrative_paragraph.dart';

import '../domain/narrative_section.dart';

import '../engines/narrative_confidence_composer.dart';

import '../intelligence/narrative_evidence_brancher.dart';
import '../intelligence/narrative_interaction_type.dart';
import '../intelligence/narrative_insight_plan.dart';

import '../intelligence/narrative_intelligence_layer.dart';

import '../registry/narrative_mode_filter.dart';

import '../registry/narrative_pattern_copy.dart';



/// Builds evidence-anchored narrative paragraphs from activated patterns.

abstract final class NarrativeParagraphBuilder {

  static const maxParagraphsPerMode = NarrativeIntelligenceLayer.maxParagraphsPerMode;



  static List<NarrativeSection> buildSections(HumanPatternSnapshot snapshot) {

    final plans = NarrativeIntelligenceLayer.buildPlans(snapshot);

    final plansByMode = <NarrativeMode, List<NarrativeInsightPlan>>{};



    for (final mode in NarrativeModeFilter.allModes()) {

      plansByMode[mode] = [];

    }

    for (final plan in plans) {

      plansByMode[plan.mode]!.add(plan);

    }



    final sections = <NarrativeSection>[];

    for (final mode in NarrativeModeFilter.allModes()) {

      final modePlans = plansByMode[mode]!;

      final paragraphs = <NarrativeParagraph>[];



      for (var index = 0; index < modePlans.length; index++) {

        if (paragraphs.length >= maxParagraphsPerMode) break;

        paragraphs.add(

          _paragraphFromPlan(

            snapshot: snapshot,

            plan: modePlans[index],

            index: index,

          ),

        );

      }



      sections.add(

        NarrativeSection(

          mode: mode,

          title: mode.sectionTitle,

          paragraphs: paragraphs,

          confidence: NarrativeConfidenceComposer.forSection(paragraphs),

        ),

      );

    }



    return sections;

  }



  static NarrativeParagraph _paragraphFromPlan({

    required HumanPatternSnapshot snapshot,

    required NarrativeInsightPlan plan,

    required int index,

  }) {

    final activation = plan.primaryActivation;

    final mode = plan.mode;

    final paragraphId =

        'nar_${mode.key}_${activation.patternId}_${plan.interactionType.key}_$index';



    final narrativeEvidence = plan.evidenceRows

        .map(

          (row) => NarrativeEvidence(

            evidenceId: 'nar_ev_${paragraphId}_${row.activationId}',

            lineage: NarrativeLineage(

              narrativeParagraphId: paragraphId,

              patternId: activation.patternId,

              activationId: activation.activationId,

              humanModelPatternId: row.humanModelPatternId,

              humanModelSnapshotId: row.humanModelSnapshotId,

              fusionFindingId: row.fusionFindingId,

              mirrorFindingId: row.mirrorFindingId,

              mirrorSnapshotId: row.mirrorSnapshotId,

              mirrorRoleId: row.mirrorRoleId,

              sourceThemeId: row.sourceThemeId,

              themeIds: row.themeIds,

            ),

            mirrorKey: row.mirrorKey,

            systemId: row.systemId,

            weight: row.weight,

            signalIds: row.signalIds,

          ),

        )

        .toList(growable: false);



    final baseText = NarrativePatternCopy.insight(

        mode: mode,

        interactionType: plan.interactionType,

        themeKey: plan.interactionThemeKey,

        primary: activation,

        contributing: plan.contributingActivations,

      );

    final lineageProfile = NarrativeEvidenceBrancher.analyze(plan.evidenceRows);

    return NarrativeParagraph(

      paragraphId: paragraphId,

      mode: mode,

      text: NarrativeEvidenceBrancher.applyLineageModifier(

        baseText: baseText,

        profile: lineageProfile,

        mode: mode,

        patternId: activation.patternId,

      ),

      patternId: activation.patternId,

      patternLabel: activation.label,

      activationId: activation.activationId,

      activationStrength: activation.activationStrength,

      evidence: narrativeEvidence,

      confidence: NarrativeConfidenceComposer.forInsightPlan(

        plan: plan,

        evidenceRows: plan.evidenceRows,

        snapshot: snapshot,

      ),

    );

  }

}


