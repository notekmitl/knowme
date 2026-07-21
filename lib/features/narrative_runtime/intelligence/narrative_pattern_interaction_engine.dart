import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';

import '../domain/narrative_mode.dart';
import 'narrative_insight_plan.dart';
import 'narrative_interaction_type.dart';
import 'narrative_pattern_interaction_catalog.dart';
import 'narrative_pattern_prioritizer.dart';
import 'narrative_pattern_tier.dart';

/// Detects agreement, tension, and growth-edge pattern interactions.
abstract final class NarrativePatternInteractionEngine {
  static NarrativeInsightPlan? detect({
    required NarrativeInteractionRule rule,
    required Map<String, PatternActivation> activationById,
    required Set<String> usedPatternIds,
    required Map<String, NarrativePatternTier> tiers,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
  }) {
    final activations = <PatternActivation>[];
    for (final patternId in rule.patternIds) {
      if (usedPatternIds.contains(patternId)) return null;
      final activation = activationById[patternId];
      if (activation == null) return null;
      if (activation.activationStrength < rule.minStrength) return null;
      if ((evidenceByPattern[patternId] ?? const []).isEmpty) return null;
      activations.add(activation);
    }

    activations.sort(
      (a, b) => b.activationStrength.compareTo(a.activationStrength),
    );

    final primary = activations.first;
    final supporting = activations.skip(1).toList(growable: false);

    return NarrativeInsightPlan(
      mode: rule.mode,
      interactionType: rule.type,
      interactionThemeKey: rule.themeKey,
      primaryActivation: primary,
      contributingActivations: supporting,
      evidenceRows: List.unmodifiable(evidenceByPattern[primary.patternId]!),
      primaryTier: NarrativePatternPrioritizer.tierFor(
        tiers: tiers,
        patternId: primary.patternId,
      ),
    );
  }
}

/// Compresses same-family activations into one stronger insight.
abstract final class NarrativeInsightCompressor {
  static NarrativeInsightPlan? compressFamilyCluster({
    required NarrativeMode mode,
    required String familyId,
    required List<PatternActivation> activations,
    required Set<String> usedPatternIds,
    required Map<String, NarrativePatternTier> tiers,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
  }) {
    final eligible = activations
        .where(
          (item) =>
              item.patternFamilyId == familyId &&
              !usedPatternIds.contains(item.patternId) &&
              (evidenceByPattern[item.patternId] ?? const []).isNotEmpty,
        )
        .toList()
      ..sort(
        (a, b) => b.activationStrength.compareTo(a.activationStrength),
      );

    if (eligible.length < NarrativeFamilyCompressionCatalog.minClusterSize) {
      return null;
    }

    final primary = eligible.first;
    final supporting = eligible.skip(1).take(2).toList(growable: false);

    return NarrativeInsightPlan(
      mode: mode,
      interactionType: NarrativeInteractionType.compressed,
      interactionThemeKey: 'family_$familyId',
      primaryActivation: primary,
      contributingActivations: supporting,
      evidenceRows: List.unmodifiable(evidenceByPattern[primary.patternId]!),
      primaryTier: NarrativePatternPrioritizer.tierFor(
        tiers: tiers,
        patternId: primary.patternId,
      ),
    );
  }
}
