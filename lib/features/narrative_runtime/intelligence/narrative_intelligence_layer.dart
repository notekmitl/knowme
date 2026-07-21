import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';

import '../domain/narrative_mode.dart';
import '../registry/narrative_mode_filter.dart';
import 'narrative_evidence_brancher.dart';
import 'narrative_insight_plan.dart';
import 'narrative_interaction_type.dart';
import 'narrative_pattern_interaction_catalog.dart';
import 'narrative_pattern_interaction_engine.dart';
import 'narrative_pattern_prioritizer.dart';
import 'narrative_pattern_tier.dart';
import 'narrative_plan_topology.dart';
import 'narrative_selection_scorer.dart';

/// Narrative Intelligence V5 — evidence-aware branching before copy generation.
abstract final class NarrativeIntelligenceLayer {
  static const maxParagraphsPerMode = 3;

  static List<NarrativeInsightPlan> buildPlans(HumanPatternSnapshot snapshot) {
    final evidenceByPattern = _groupEvidence(snapshot.evidence);
    final topologyByMode = NarrativeTopologyPlanner.resolveAllTopologies(
      snapshot: snapshot,
      evidenceByPattern: evidenceByPattern,
    );
    final plans = <NarrativeInsightPlan>[];

    for (final mode in NarrativeModeFilter.allModes()) {
      plans.addAll(
        _plansForMode(
          mode: mode,
          snapshot: snapshot,
          evidenceByPattern: evidenceByPattern,
          topology: topologyByMode[mode] ?? NarrativePlanTopology.standard,
        ),
      );
    }

    return NarrativeEvidenceBrancher.enrichAll(plans);
  }

  static Map<NarrativeMode, NarrativePlanTopology> topologyForSnapshot(
    HumanPatternSnapshot snapshot,
  ) {
    return NarrativeTopologyPlanner.resolveAllTopologies(
      snapshot: snapshot,
      evidenceByPattern: _groupEvidence(snapshot.evidence),
    );
  }

  static List<NarrativeInsightPlan> plansForMode(
    NarrativeMode mode,
    HumanPatternSnapshot snapshot,
  ) {
    final evidenceByPattern = _groupEvidence(snapshot.evidence);
    final topologyByMode = NarrativeTopologyPlanner.resolveAllTopologies(
      snapshot: snapshot,
      evidenceByPattern: evidenceByPattern,
    );
    return _plansForMode(
      mode: mode,
      snapshot: snapshot,
      evidenceByPattern: evidenceByPattern,
      topology: topologyByMode[mode] ?? NarrativePlanTopology.standard,
    );
  }

  static List<NarrativeInsightPlan> _plansForMode({
    required NarrativeMode mode,
    required HumanPatternSnapshot snapshot,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
    required NarrativePlanTopology topology,
  }) {
    final activations = snapshot.activations
        .where(
          (activation) =>
              NarrativeModeFilter.primaryMode(
                patternFamilyId: activation.patternFamilyId,
                dimension: activation.dimension,
              ) ==
              mode,
        )
        .where(
          (activation) =>
              (evidenceByPattern[activation.patternId] ?? const []).isNotEmpty,
        )
        .toList();

    if (activations.isEmpty) return const [];

    final tiers = NarrativePatternPrioritizer.classify(
      activations,
      evidenceByPattern: evidenceByPattern,
      snapshot: snapshot,
      mode: mode,
    );
    final activationById = {
      for (final activation in activations) activation.patternId: activation,
    };
    final usedPatternIds = <String>{};
    final plans = <NarrativeInsightPlan>[];
    final phases = NarrativeTopologyPlanner.phasesFor(topology);
    final tensionFirst =
        NarrativeTopologyPlanner.tensionInteractionsFirst(topology);

    for (final phase in phases) {
      if (plans.length >= maxParagraphsPerMode) break;

      switch (phase) {
        case NarrativePlanPhase.blindSpot:
          _appendBlindSpotPlans(
            plans: plans,
            activations: activations,
            usedPatternIds: usedPatternIds,
            evidenceByPattern: evidenceByPattern,
            snapshot: snapshot,
            mode: mode,
            tiers: tiers,
            topology: topology,
          );
        case NarrativePlanPhase.interaction:
          _appendInteractionPlans(
            plans: plans,
            activationById: activationById,
            usedPatternIds: usedPatternIds,
            evidenceByPattern: evidenceByPattern,
            snapshot: snapshot,
            mode: mode,
            tiers: tiers,
            tensionFirst: tensionFirst,
            topology: topology,
          );
        case NarrativePlanPhase.compression:
          _appendCompressionPlans(
            plans: plans,
            activations: activations,
            usedPatternIds: usedPatternIds,
            evidenceByPattern: evidenceByPattern,
            snapshot: snapshot,
            mode: mode,
            tiers: tiers,
            topology: topology,
          );
        case NarrativePlanPhase.singles:
          _appendSinglePlans(
            plans: plans,
            activations: activations,
            usedPatternIds: usedPatternIds,
            evidenceByPattern: evidenceByPattern,
            snapshot: snapshot,
            mode: mode,
            tiers: tiers,
            topology: topology,
          );
      }
    }

    return plans;
  }

  static void _appendBlindSpotPlans({
    required List<NarrativeInsightPlan> plans,
    required List<PatternActivation> activations,
    required Set<String> usedPatternIds,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required Map<String, NarrativePatternTier> tiers,
    required NarrativePlanTopology topology,
  }) {
    final blindSpots = activations
        .where((item) => item.patternFamilyId == 'blind_spot_pattern')
        .toList();
    final rankedBlindSpots = NarrativeSelectionScorer.rankActivations(
      activations: blindSpots,
      evidenceByPattern: evidenceByPattern,
      snapshot: snapshot,
      mode: mode,
      slotBias: plans.length,
      excludePatternIds: usedPatternIds,
      topology: topology,
    );

    for (final activation in rankedBlindSpots) {
      if (plans.length >= maxParagraphsPerMode) break;
      if (usedPatternIds.contains(activation.patternId)) continue;

      plans.add(
        _singlePlan(
          mode: mode,
          activation: activation,
          evidenceRows: evidenceByPattern[activation.patternId]!,
          tiers: tiers,
          interactionType: NarrativeInteractionType.blindSpot,
          themeKey: 'blind_spot_${activation.patternId}',
        ),
      );
      usedPatternIds.add(activation.patternId);
    }
  }

  static void _appendInteractionPlans({
    required List<NarrativeInsightPlan> plans,
    required Map<String, PatternActivation> activationById,
    required Set<String> usedPatternIds,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required Map<String, NarrativePatternTier> tiers,
    required bool tensionFirst,
    required NarrativePlanTopology topology,
  }) {
    if (NarrativeTopologyPlanner.shouldSkipInteractions(
      snapshot: snapshot,
      mode: mode,
      topology: topology,
    )) {
      return;
    }

    final rules = List<NarrativeInteractionRule>.from(
      NarrativePatternInteractionCatalog.rulesForMode(mode),
    )..sort((a, b) {
        if (tensionFirst) {
          final aTension = a.type == NarrativeInteractionType.tension ? 1 : 0;
          final bTension = b.type == NarrativeInteractionType.tension ? 1 : 0;
          final tensionCompare = bTension.compareTo(aTension);
          if (tensionCompare != 0) return tensionCompare;
        }

        final scoreA = NarrativeSelectionScorer.scoreInteractionRule(
          patternIds: a.patternIds,
          activationById: activationById,
          evidenceByPattern: evidenceByPattern,
          snapshot: snapshot,
          mode: mode,
          ruleThemeKey: a.themeKey,
        );
        final scoreB = NarrativeSelectionScorer.scoreInteractionRule(
          patternIds: b.patternIds,
          activationById: activationById,
          evidenceByPattern: evidenceByPattern,
          snapshot: snapshot,
          mode: mode,
          ruleThemeKey: b.themeKey,
        );
        final compare = scoreB.compareTo(scoreA);
        if (compare != 0) return compare;
        return a.themeKey.compareTo(b.themeKey);
      });

    var interactionCount = 0;
    final maxInteractions = NarrativeTopologyPlanner.maxInteractionPlans(topology);

    for (final rule in rules) {
      if (plans.length >= maxParagraphsPerMode) break;
      if (interactionCount >= maxInteractions) break;
      final plan = NarrativePatternInteractionEngine.detect(
        rule: rule,
        activationById: activationById,
        usedPatternIds: usedPatternIds,
        tiers: tiers,
        evidenceByPattern: evidenceByPattern,
      );
      if (plan == null) continue;
      plans.add(plan);
      usedPatternIds.addAll(plan.referencedPatternIds);
      interactionCount++;
    }
  }

  static void _appendCompressionPlans({
    required List<NarrativeInsightPlan> plans,
    required List<PatternActivation> activations,
    required Set<String> usedPatternIds,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required Map<String, NarrativePatternTier> tiers,
    required NarrativePlanTopology topology,
  }) {
    if (NarrativeTopologyPlanner.shouldSkipCompression(
      snapshot: snapshot,
      mode: mode,
      topology: topology,
    )) {
      return;
    }

    final familyIds = activations.map((item) => item.patternFamilyId).toSet().toList()
      ..sort((a, b) {
        final clusterA = activations
            .where(
              (item) =>
                  item.patternFamilyId == a &&
                  !usedPatternIds.contains(item.patternId),
            )
            .toList();
        final clusterB = activations
            .where(
              (item) =>
                  item.patternFamilyId == b &&
                  !usedPatternIds.contains(item.patternId),
            )
            .toList();
        final scoreA = NarrativeSelectionScorer.scoreFamilyCluster(
          familyId: a,
          cluster: clusterA,
          evidenceByPattern: evidenceByPattern,
          snapshot: snapshot,
          mode: mode,
        );
        final scoreB = NarrativeSelectionScorer.scoreFamilyCluster(
          familyId: b,
          cluster: clusterB,
          evidenceByPattern: evidenceByPattern,
          snapshot: snapshot,
          mode: mode,
        );
        final compare = scoreB.compareTo(scoreA);
        if (compare != 0) return compare;
        return a.compareTo(b);
      });

    for (final familyId in familyIds) {
      if (plans.length >= maxParagraphsPerMode) break;
      final plan = NarrativeInsightCompressor.compressFamilyCluster(
        mode: mode,
        familyId: familyId,
        activations: activations,
        usedPatternIds: usedPatternIds,
        tiers: tiers,
        evidenceByPattern: evidenceByPattern,
      );
      if (plan == null) continue;
      plans.add(plan);
      usedPatternIds.addAll(plan.referencedPatternIds);
    }
  }

  static void _appendSinglePlans({
    required List<NarrativeInsightPlan> plans,
    required List<PatternActivation> activations,
    required Set<String> usedPatternIds,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required Map<String, NarrativePatternTier> tiers,
    required NarrativePlanTopology topology,
  }) {
    while (plans.length < maxParagraphsPerMode) {
      final rankedSingles = NarrativeSelectionScorer.rankActivations(
        activations: activations,
        evidenceByPattern: evidenceByPattern,
        snapshot: snapshot,
        mode: mode,
        slotBias: plans.length,
        excludePatternIds: usedPatternIds,
        topology: topology,
      );
      if (rankedSingles.isEmpty) break;

      final pickIndex = NarrativeTopologyPlanner.singlePickIndex(
        snapshot: snapshot,
        mode: mode,
        topology: topology,
        slotIndex: plans.length,
        candidateCount: rankedSingles.length,
      );

      final activation = rankedSingles[pickIndex];
      plans.add(
        _singlePlan(
          mode: mode,
          activation: activation,
          evidenceRows: evidenceByPattern[activation.patternId]!,
          tiers: tiers,
          interactionType: NarrativeInteractionType.single,
          themeKey: activation.patternId,
        ),
      );
      usedPatternIds.add(activation.patternId);
    }
  }

  static NarrativeInsightPlan _singlePlan({
    required NarrativeMode mode,
    required PatternActivation activation,
    required List<PatternEvidence> evidenceRows,
    required Map<String, NarrativePatternTier> tiers,
    required NarrativeInteractionType interactionType,
    required String themeKey,
  }) {
    return NarrativeInsightPlan(
      mode: mode,
      interactionType: interactionType,
      interactionThemeKey: themeKey,
      primaryActivation: activation,
      contributingActivations: const [],
      evidenceRows: evidenceRows,
      primaryTier: NarrativePatternPrioritizer.tierFor(
        tiers: tiers,
        patternId: activation.patternId,
      ),
    );
  }

  static Map<String, List<PatternEvidence>> _groupEvidence(
    List<PatternEvidence> evidence,
  ) {
    final grouped = <String, List<PatternEvidence>>{};
    for (final row in evidence) {
      grouped.putIfAbsent(row.registryPatternId, () => []).add(row);
    }
    return grouped;
  }
}
