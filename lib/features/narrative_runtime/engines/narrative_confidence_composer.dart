import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';

import '../domain/narrative_confidence.dart';
import '../domain/narrative_paragraph.dart';
import '../intelligence/narrative_insight_plan.dart';
import '../intelligence/narrative_interaction_type.dart';

/// Composes per-paragraph and aggregate narrative confidence.
abstract final class NarrativeConfidenceComposer {
  static NarrativeConfidence forInsightPlan({
    required NarrativeInsightPlan plan,
    required List<PatternEvidence> evidenceRows,
    required HumanPatternSnapshot snapshot,
  }) {
    final base = forParagraph(
      activation: plan.primaryActivation,
      evidenceRows: evidenceRows,
      snapshot: snapshot,
    );

    if (plan.contributingActivations.isEmpty ||
        plan.interactionType == NarrativeInteractionType.single) {
      return base;
    }

    final interactionBoost = switch (plan.interactionType) {
      NarrativeInteractionType.agreement => 0.06,
      NarrativeInteractionType.tension => 0.04,
      NarrativeInteractionType.growthEdge => 0.05,
      NarrativeInteractionType.blindSpot => 0.03,
      NarrativeInteractionType.compressed => 0.07,
      NarrativeInteractionType.single => 0.0,
    };

    return NarrativeConfidence(
      composite: _clamp(base.composite + interactionBoost),
      patternConfidence: base.patternConfidence,
      evidenceDepthScore: base.evidenceDepthScore,
      activationStrengthScore: base.activationStrengthScore,
      coverageScore: base.coverageScore,
    );
  }

  static NarrativeConfidence forParagraph({
    required PatternActivation activation,
    required List<PatternEvidence> evidenceRows,
    required HumanPatternSnapshot snapshot,
  }) {
    final patternConfidence = activation.confidence.composite;
    final evidenceDepth = _evidenceDepth(evidenceRows);
    final activationStrength = activation.activationStrength.clamp(0.0, 1.0);
    final coverage = snapshot.coverage.weightedCoverage.clamp(0.0, 1.0);

    final composite = _clamp(
      patternConfidence * 0.45 +
          evidenceDepth * 0.25 +
          activationStrength * 0.2 +
          coverage * 0.1,
    );

    return NarrativeConfidence(
      composite: composite,
      patternConfidence: patternConfidence,
      evidenceDepthScore: evidenceDepth,
      activationStrengthScore: activationStrength,
      coverageScore: coverage,
    );
  }

  static NarrativeConfidence forSection(List<NarrativeParagraph> paragraphs) {
    if (paragraphs.isEmpty) {
      return const NarrativeConfidence(
        composite: 0,
        patternConfidence: 0,
        evidenceDepthScore: 0,
        activationStrengthScore: 0,
        coverageScore: 0,
      );
    }

    double sumComposite = 0;
    double sumPattern = 0;
    double sumEvidence = 0;
    double sumActivation = 0;
    double sumCoverage = 0;

    for (final paragraph in paragraphs) {
      sumComposite += paragraph.confidence.composite;
      sumPattern += paragraph.confidence.patternConfidence;
      sumEvidence += paragraph.confidence.evidenceDepthScore;
      sumActivation += paragraph.confidence.activationStrengthScore;
      sumCoverage += paragraph.confidence.coverageScore;
    }

    final count = paragraphs.length.toDouble();
    return NarrativeConfidence(
      composite: _clamp(sumComposite / count),
      patternConfidence: _clamp(sumPattern / count),
      evidenceDepthScore: _clamp(sumEvidence / count),
      activationStrengthScore: _clamp(sumActivation / count),
      coverageScore: _clamp(sumCoverage / count),
    );
  }

  static NarrativeConfidence forResult(
    List<NarrativeSectionConfidenceInput> sections,
  ) {
    final nonEmpty = sections.where((item) => item.paragraphCount > 0).toList();
    if (nonEmpty.isEmpty) {
      return const NarrativeConfidence(
        composite: 0,
        patternConfidence: 0,
        evidenceDepthScore: 0,
        activationStrengthScore: 0,
        coverageScore: 0,
      );
    }

    double weightedComposite = 0;
    double weightedPattern = 0;
    double weightedEvidence = 0;
    double weightedActivation = 0;
    double weightedCoverage = 0;
    var totalWeight = 0.0;

    for (final section in nonEmpty) {
      final weight = section.paragraphCount.toDouble();
      totalWeight += weight;
      weightedComposite += section.confidence.composite * weight;
      weightedPattern += section.confidence.patternConfidence * weight;
      weightedEvidence += section.confidence.evidenceDepthScore * weight;
      weightedActivation += section.confidence.activationStrengthScore * weight;
      weightedCoverage += section.confidence.coverageScore * weight;
    }

    return NarrativeConfidence(
      composite: _clamp(weightedComposite / totalWeight),
      patternConfidence: _clamp(weightedPattern / totalWeight),
      evidenceDepthScore: _clamp(weightedEvidence / totalWeight),
      activationStrengthScore: _clamp(weightedActivation / totalWeight),
      coverageScore: _clamp(weightedCoverage / totalWeight),
    );
  }

  static double _evidenceDepth(List<PatternEvidence> rows) {
    if (rows.isEmpty) return 0;
    final weights = rows.map((row) => row.weight.clamp(0.0, 1.0));
    final avgWeight = weights.reduce((a, b) => a + b) / rows.length;
    final themeDiversity =
        rows.expand((row) => row.themeIds).toSet().length / (rows.length * 2);
    return _clamp(avgWeight * 0.7 + themeDiversity.clamp(0.0, 1.0) * 0.3);
  }

  static double _clamp(double value) => value.clamp(0.0, 1.0);
}

class NarrativeSectionConfidenceInput {
  const NarrativeSectionConfidenceInput({
    required this.paragraphCount,
    required this.confidence,
  });

  final int paragraphCount;
  final NarrativeConfidence confidence;
}
