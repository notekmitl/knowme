import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';

import '../domain/narrative_mode.dart';
import 'narrative_plan_topology.dart';

/// Deterministic selection signals for Narrative Intelligence V3.
class NarrativeSelectionSignals {
  const NarrativeSelectionSignals({
    required this.evidenceDensity,
    required this.sourceDiversity,
    required this.confidenceSpread,
    required this.activationBalance,
    required this.fusionFindingDiversity,
    required this.profileTieBreak,
    required this.compositeScore,
  });

  final double evidenceDensity;
  final double sourceDiversity;
  final double confidenceSpread;
  final double activationBalance;
  final double fusionFindingDiversity;
  final double profileTieBreak;
  final double compositeScore;
}

/// Ranks activations and interaction candidates using evidence-aware scoring.
abstract final class NarrativeSelectionScorer {
  static List<PatternActivation> rankActivations({
    required List<PatternActivation> activations,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required int slotBias,
    Set<String> excludePatternIds = const {},
    NarrativePlanTopology? topology,
  }) {
    final eligible = activations
        .where((item) => !excludePatternIds.contains(item.patternId))
        .toList();
    if (eligible.isEmpty) return const [];

    final strengthSorted = List<PatternActivation>.from(eligible)
      ..sort((a, b) => b.activationStrength.compareTo(a.activationStrength));
    final strengthRank = {
      for (var i = 0; i < strengthSorted.length; i++)
        strengthSorted[i].patternId: i,
    };

    eligible.sort((a, b) {
      final scoreA = scoreActivation(
        activation: a,
        evidenceRows: evidenceByPattern[a.patternId] ?? const [],
        snapshot: snapshot,
        mode: mode,
        strengthRank: strengthRank[a.patternId] ?? eligible.length,
        slotBias: slotBias,
        topology: topology,
      );
      final scoreB = scoreActivation(
        activation: b,
        evidenceRows: evidenceByPattern[b.patternId] ?? const [],
        snapshot: snapshot,
        mode: mode,
        strengthRank: strengthRank[b.patternId] ?? eligible.length,
        slotBias: slotBias,
        topology: topology,
      );
      final compare = scoreB.compositeScore.compareTo(scoreA.compositeScore);
      if (compare != 0) return compare;
      return a.patternId.compareTo(b.patternId);
    });

    return eligible;
  }

  static NarrativeSelectionSignals scoreActivation({
    required PatternActivation activation,
    required List<PatternEvidence> evidenceRows,
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required int strengthRank,
    required int slotBias,
    NarrativePlanTopology? topology,
  }) {
    final evidenceDensity = _evidenceDensity(evidenceRows);
    final sourceDiversity = _sourceDiversity(evidenceRows);
    final confidenceSpread = _confidenceSpread(activation, evidenceRows);
    final fusionFindingDiversity = _fusionFindingDiversity(evidenceRows);
    final activationBalance = _activationBalance(strengthRank);
    final profileTieBreak = _profileTieBreak(
      snapshot.structuralHash,
      topology == null
          ? activation.patternId
          : '${activation.patternId}|${topology.name}',
      mode,
      slotBias,
    );

    final weights = _weightsForSlot(slotBias);
    final compositeScore =
        activation.activationStrength * weights.strength +
            activation.confidence.evidenceDiversityScore * weights.diversity +
            activation.confidence.composite * weights.confidence +
            evidenceDensity * weights.density +
            sourceDiversity * weights.source +
            fusionFindingDiversity * weights.fusion +
            activationBalance * weights.balance +
            profileTieBreak * weights.tieBreak;

    return NarrativeSelectionSignals(
      evidenceDensity: evidenceDensity,
      sourceDiversity: sourceDiversity,
      confidenceSpread: confidenceSpread,
      activationBalance: activationBalance,
      fusionFindingDiversity: fusionFindingDiversity,
      profileTieBreak: profileTieBreak,
      compositeScore: compositeScore,
    );
  }

  static double scoreInteractionRule({
    required List<String> patternIds,
    required Map<String, PatternActivation> activationById,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required String ruleThemeKey,
  }) {
    var total = 0.0;
    for (var i = 0; i < patternIds.length; i++) {
      final activation = activationById[patternIds[i]];
      if (activation == null) continue;
      total += scoreActivation(
        activation: activation,
        evidenceRows: evidenceByPattern[patternIds[i]] ?? const [],
        snapshot: snapshot,
        mode: mode,
        strengthRank: i,
        slotBias: 0,
      ).compositeScore;
    }
    total += _profileTieBreak(
          snapshot.structuralHash,
          ruleThemeKey,
          mode,
          patternIds.length,
        ) *
        0.08;
    return total;
  }

  static double scoreFamilyCluster({
    required String familyId,
    required List<PatternActivation> cluster,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
  }) {
    if (cluster.isEmpty) return 0;

    var densitySum = 0.0;
    var diversitySum = 0.0;
    for (final activation in cluster) {
      final rows = evidenceByPattern[activation.patternId] ?? const [];
      densitySum += _evidenceDensity(rows);
      diversitySum += activation.confidence.evidenceDiversityScore;
    }

    final avgDensity = densitySum / cluster.length;
    final avgDiversity = diversitySum / cluster.length;
    final sizeBonus = (cluster.length.clamp(3, 6) - 2) * 0.05;

    return avgDensity * 0.35 +
        avgDiversity * 0.35 +
        sizeBonus +
        _profileTieBreak(snapshot.structuralHash, familyId, mode, 9) * 0.12;
  }

  static String selectionFingerprint({
    required List<({
      NarrativeMode mode,
      String interactionType,
      List<String> patternIds,
    })> plans,
  }) {
    final parts = <String>[];
    for (final plan in plans) {
      parts.add(
        '${plan.mode.key}:${plan.interactionType}:${plan.patternIds.join("+")}',
      );
    }
    return parts.join('|');
  }

  static double _evidenceDensity(List<PatternEvidence> rows) {
    if (rows.isEmpty) return 0;
    final weightSum = rows.fold<double>(0, (sum, row) => sum + row.weight);
    final countNorm = (rows.length / 6).clamp(0.0, 1.0);
    final weightNorm = (weightSum / 3).clamp(0.0, 1.0);
    return (countNorm * 0.55 + weightNorm * 0.45).clamp(0.0, 1.0);
  }

  static double _sourceDiversity(List<PatternEvidence> rows) {
    if (rows.isEmpty) return 0;
    final mirrors = rows.map((row) => row.mirrorRoleId).toSet().length;
    final keys = rows.map((row) => row.mirrorKey).toSet().length;
    final systems = rows.map((row) => row.systemId).toSet().length;
    final themes = rows.expand((row) => row.themeIds).toSet().length;
    final raw = mirrors + keys + systems + (themes / 2);
    return (raw / 10).clamp(0.0, 1.0);
  }

  static double _fusionFindingDiversity(List<PatternEvidence> rows) {
    if (rows.isEmpty) return 0;
    final findings = rows.map((row) => row.fusionFindingId).toSet().length;
    final hmPatterns = rows.map((row) => row.humanModelPatternId).toSet().length;
    return ((findings + hmPatterns) / 8).clamp(0.0, 1.0);
  }

  static double _confidenceSpread(
    PatternActivation activation,
    List<PatternEvidence> rows,
  ) {
    if (rows.length < 2) {
      return activation.confidence.composite.clamp(0.0, 1.0);
    }
    final weights = rows.map((row) => row.weight).toList();
    final mean = weights.fold<double>(0, (s, w) => s + w) / weights.length;
    var variance = 0.0;
    for (final weight in weights) {
      variance += (weight - mean) * (weight - mean);
    }
    variance /= weights.length;
    return (variance * 4).clamp(0.0, 1.0);
  }

  static double _activationBalance(int strengthRank) {
    if (strengthRank <= 0) return 0.02;
    return (0.06 * strengthRank.clamp(1, 5)).clamp(0.0, 0.30);
  }

  static double _profileTieBreak(
    String structuralHash,
    String key,
    NarrativeMode mode,
    int slotBias,
  ) {
    final seed = '$structuralHash|$key|${mode.key}|$slotBias';
    var hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = (hash * 31 + seed.codeUnitAt(i)) & 0x7fffffff;
    }
    return (hash % 10000) / 10000.0;
  }

  static _SlotWeights _weightsForSlot(int slotBias) {
    return switch (slotBias % 3) {
      0 => const _SlotWeights(
          strength: 0.38,
          diversity: 0.16,
          confidence: 0.14,
          density: 0.14,
          source: 0.08,
          fusion: 0.05,
          balance: 0.02,
          tieBreak: 0.03,
        ),
      1 => const _SlotWeights(
          strength: 0.18,
          diversity: 0.24,
          confidence: 0.14,
          density: 0.18,
          source: 0.12,
          fusion: 0.06,
          balance: 0.05,
          tieBreak: 0.03,
        ),
      _ => const _SlotWeights(
          strength: 0.12,
          diversity: 0.18,
          confidence: 0.10,
          density: 0.14,
          source: 0.22,
          fusion: 0.10,
          balance: 0.08,
          tieBreak: 0.06,
        ),
    };
  }
}

class _SlotWeights {
  const _SlotWeights({
    required this.strength,
    required this.diversity,
    required this.confidence,
    required this.density,
    required this.source,
    required this.fusion,
    required this.balance,
    required this.tieBreak,
  });

  final double strength;
  final double diversity;
  final double confidence;
  final double density;
  final double source;
  final double fusion;
  final double balance;
  final double tieBreak;
}
