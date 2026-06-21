import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';

import '../domain/narrative_mode.dart';
import 'narrative_pattern_tier.dart';
import 'narrative_selection_scorer.dart';

/// Classifies activations into dominant, supporting, and background tiers.
abstract final class NarrativePatternPrioritizer {
  static const _dominantThreshold = 0.55;
  static const _supportingThreshold = 0.3;

  static Map<String, NarrativePatternTier> classify(
    List<PatternActivation> activations, {
    Map<String, List<PatternEvidence>> evidenceByPattern = const {},
    HumanPatternSnapshot? snapshot,
    NarrativeMode? mode,
  }) {
    if (activations.isEmpty) return const {};

    final ranked = snapshot != null && mode != null
        ? NarrativeSelectionScorer.rankActivations(
            activations: activations,
            evidenceByPattern: evidenceByPattern,
            snapshot: snapshot,
            mode: mode,
            slotBias: 0,
          )
        : (List<PatternActivation>.from(activations)
          ..sort((a, b) => b.activationStrength.compareTo(a.activationStrength)));

    final tiers = <String, NarrativePatternTier>{};
    var dominantAssigned = false;

    for (final activation in ranked) {
      final strength = activation.activationStrength.clamp(0.0, 1.0);
      if (!dominantAssigned &&
          strength >= _dominantThreshold &&
          tiers.length < 1) {
        tiers[activation.patternId] = NarrativePatternTier.dominant;
        dominantAssigned = true;
        continue;
      }

      if (strength >= _supportingThreshold) {
        tiers[activation.patternId] = NarrativePatternTier.supporting;
      } else {
        tiers[activation.patternId] = NarrativePatternTier.background;
      }
    }

    if (!dominantAssigned && ranked.isNotEmpty) {
      tiers[ranked.first.patternId] = NarrativePatternTier.dominant;
    }

    return tiers;
  }

  static NarrativePatternTier tierFor({
    required Map<String, NarrativePatternTier> tiers,
    required String patternId,
  }) {
    return tiers[patternId] ?? NarrativePatternTier.background;
  }
}
