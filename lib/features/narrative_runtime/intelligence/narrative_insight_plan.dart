import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';

import '../domain/narrative_mode.dart';
import 'narrative_interaction_type.dart';
import 'narrative_pattern_tier.dart';

/// One planned narrative insight — may synthesize multiple activations.
class NarrativeInsightPlan {
  const NarrativeInsightPlan({
    required this.mode,
    required this.interactionType,
    required this.interactionThemeKey,
    required this.primaryActivation,
    required this.contributingActivations,
    required this.evidenceRows,
    required this.primaryTier,
    this.evidenceBranchKey = '',
    this.lineageFingerprint = '',
  });

  final NarrativeMode mode;
  final NarrativeInteractionType interactionType;
  final String interactionThemeKey;
  final PatternActivation primaryActivation;
  final List<PatternActivation> contributingActivations;
  final List<PatternEvidence> evidenceRows;
  final NarrativePatternTier primaryTier;
  final String evidenceBranchKey;
  final String lineageFingerprint;

  List<PatternActivation> get allActivations {
    if (contributingActivations.isEmpty) {
      return [primaryActivation];
    }
    return [primaryActivation, ...contributingActivations];
  }

  List<String> get referencedPatternIds {
    return allActivations.map((item) => item.patternId).toSet().toList()..sort();
  }

  List<String> get referencedFindingIds {
    return evidenceRows.map((row) => row.fusionFindingId).toSet().toList()..sort();
  }
}
