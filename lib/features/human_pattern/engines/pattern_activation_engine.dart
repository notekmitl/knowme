import 'dart:convert';

import 'package:knowme/features/human_model/domain/human_dimension.dart';
import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_model/domain/human_pattern.dart';

import '../domain/pattern_activation.dart';
import '../domain/pattern_confidence.dart';
import '../registry/human_pattern_activation_rule.dart';
import '../registry/human_pattern_registry.dart';

/// HP4 — activates registry patterns from human model snapshot.
abstract final class PatternActivationEngine {
  static List<PatternActivation> activate(HumanModelSnapshot snapshot) {
    final activations = <PatternActivation>[];
    final activatedIds = <String>{};

    for (final entry in HumanPatternRegistry.allEntries) {
      final source = _resolveSourcePattern(snapshot, entry.activationRule);
      if (source == null) continue;
      if (!_ruleMatches(snapshot, entry.activationRule, source)) continue;
      if (!_hasLineageEvidence(snapshot, source)) continue;
      if (activatedIds.contains(entry.patternId)) continue;

      final strength = _activationStrength(snapshot, entry.activationRule, source);
      activations.add(
        PatternActivation(
          activationId: _activationId(entry.patternId, source.id),
          patternId: entry.patternId,
          label: entry.label,
          patternFamilyId: entry.patternFamilyId,
          dimension: entry.dimension,
          activationStrength: strength,
          sourceHumanPatternId: source.id,
          sourceHumanPatternKey: source.patternKey,
          confidence: PatternConfidenceComposer.forActivation(
            snapshot: snapshot,
            activationStrength: strength,
            sourcePattern: source,
          ),
        ),
      );
      activatedIds.add(entry.patternId);
    }

    activations.sort((a, b) => a.patternId.compareTo(b.patternId));
    return activations;
  }

  static HumanPattern? resolveSourceForAudit(
    HumanModelSnapshot snapshot,
    HumanPatternActivationRule rule,
  ) {
    return _resolveSourcePattern(snapshot, rule);
  }

  static HumanPattern? _resolveSourcePattern(
    HumanModelSnapshot snapshot,
    HumanPatternActivationRule rule,
  ) {
    final sourceKey = rule.sourceHumanPatternKey;
    if (sourceKey != null) {
      for (final pattern in snapshot.patterns) {
        if (pattern.patternKey == sourceKey) return pattern;
      }
      return null;
    }

    final requiredType = rule.requiredFusionFindingType;
    final mirrorKey = rule.requiredMirrorKey;
    if (mirrorKey != null) {
      if (requiredType != null) {
        for (final pattern in snapshot.patterns) {
          if (pattern.supportingMirrorKeys.contains(mirrorKey) &&
              pattern.fusionFindingType == requiredType) {
            return pattern;
          }
        }
        for (final pattern in snapshot.patterns) {
          if (pattern.fusionFindingType != requiredType) continue;
          final hasEvidence = snapshot.evidence.any(
            (row) =>
                row.humanPatternId == pattern.id && row.mirrorKey == mirrorKey,
          );
          if (hasEvidence) return pattern;
        }
        return null;
      }

      for (final pattern in snapshot.patterns) {
        if (pattern.supportingMirrorKeys.contains(mirrorKey)) return pattern;
      }
      for (final pattern in snapshot.patterns) {
        final hasEvidence = snapshot.evidence.any(
          (row) =>
              row.humanPatternId == pattern.id && row.mirrorKey == mirrorKey,
        );
        if (hasEvidence) return pattern;
      }
      return null;
    }

    if (requiredType != null && rule.requiredDimensionKey == null) {
      return _strongestPatternByFusionFindingType(snapshot, requiredType);
    }

    final dimensionKey = rule.requiredDimensionKey;
    if (dimensionKey != null) {
      final dimension = parseHumanDimensionId(dimensionKey);
      if (dimension != null) {
        for (final pattern in snapshot.patterns) {
          if (pattern.primaryDimension == dimension) return pattern;
        }
        for (final pattern in snapshot.patterns) {
          if (pattern.secondaryDimensions.contains(dimension)) return pattern;
        }
      }
      return null;
    }

    return null;
  }

  static HumanPattern? _strongestPatternByFusionFindingType(
    HumanModelSnapshot snapshot,
    String fusionFindingType,
  ) {
    HumanPattern? best;
    for (final pattern in snapshot.patterns) {
      if (pattern.fusionFindingType != fusionFindingType) continue;
      if (best == null || pattern.patternStrength > best.patternStrength) {
        best = pattern;
      }
    }
    return best;
  }

  static bool _hasLineageEvidence(
    HumanModelSnapshot snapshot,
    HumanPattern source,
  ) {
    return snapshot.evidence.any((row) => row.humanPatternId == source.id);
  }

  static bool _ruleMatches(
    HumanModelSnapshot snapshot,
    HumanPatternActivationRule rule,
    HumanPattern source,
  ) {
    if (source.patternStrength < rule.minPatternStrength) return false;

    if (rule.requiredFusionFindingType != null &&
        source.fusionFindingType != rule.requiredFusionFindingType) {
      return false;
    }

    if (rule.requiredMirrorKey != null &&
        !source.supportingMirrorKeys.contains(rule.requiredMirrorKey)) {
      final evidenceMatch = snapshot.evidence.any(
        (row) =>
            row.humanPatternId == source.id &&
            row.mirrorKey == rule.requiredMirrorKey,
      );
      if (!evidenceMatch) return false;
    }

    if (rule.requiredDimensionKey != null) {
      final dimensionActivation = snapshot.profile.dimensions
          .where((item) => item.dimensionKey == rule.requiredDimensionKey)
          .map((item) => item.activation)
          .fold(0.0, (max, value) => value > max ? value : max);
      if (dimensionActivation < rule.minDimensionActivation) return false;
    }

    return true;
  }

  static double _activationStrength(
    HumanModelSnapshot snapshot,
    HumanPatternActivationRule rule,
    HumanPattern source,
  ) {
    var strength = source.patternStrength;

    if (rule.requiredDimensionKey != null) {
      for (final dimension in snapshot.profile.dimensions) {
        if (dimension.dimensionKey == rule.requiredDimensionKey) {
          strength = ((strength + dimension.activation) / 2).clamp(0.0, 1.0);
          break;
        }
      }
    }

    return strength.clamp(0.0, 1.0);
  }

  static String _activationId(String patternId, String sourcePatternId) {
    final payload = '$patternId|$sourcePatternId';
    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(payload)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return 'hp_activation_${hash.toRadixString(16).padLeft(8, '0')}';
  }
}

/// HP5 — per-activation and aggregate confidence composition.
abstract final class PatternConfidenceComposer {
  static const _humanWeight = 0.30;
  static const _coverageWeight = 0.25;
  static const _diversityWeight = 0.25;
  static const _activationWeight = 0.20;

  static PatternConfidence forActivation({
    required HumanModelSnapshot snapshot,
    required double activationStrength,
    required HumanPattern sourcePattern,
  }) {
    final humanInfluence = _humanInfluence(snapshot);
    final coverageScore = snapshot.coverage.weightedCoverage.clamp(0.0, 1.0);
    final diversityScore = _evidenceDiversity(snapshot, sourcePattern.id);
    final activationScore = activationStrength.clamp(0.0, 1.0);

    final composite = (
      humanInfluence * _humanWeight +
      coverageScore * _coverageWeight +
      diversityScore * _diversityWeight +
      activationScore * _activationWeight
    ).clamp(0.0, 1.0);

    return PatternConfidence(
      composite: composite,
      humanInfluenceScore: humanInfluence,
      coverageScore: coverageScore,
      evidenceDiversityScore: diversityScore,
      activationStrengthScore: activationScore,
    );
  }

  static PatternConfidence aggregate(List<PatternActivation> activations) {
    if (activations.isEmpty) {
      return const PatternConfidence(
        composite: 0,
        humanInfluenceScore: 0,
        coverageScore: 0,
        evidenceDiversityScore: 0,
        activationStrengthScore: 0,
      );
    }

    double avg(double Function(PatternConfidence item) selector) {
      return activations
              .map((item) => selector(item.confidence))
              .reduce((a, b) => a + b) /
          activations.length;
    }

    final composite = avg((item) => item.composite);
    return PatternConfidence(
      composite: composite.clamp(0.0, 1.0),
      humanInfluenceScore: avg((item) => item.humanInfluenceScore),
      coverageScore: avg((item) => item.coverageScore),
      evidenceDiversityScore: avg((item) => item.evidenceDiversityScore),
      activationStrengthScore: avg((item) => item.activationStrengthScore),
    );
  }

  static double _humanInfluence(HumanModelSnapshot snapshot) {
    final human = snapshot.confidence;
    return (
      human.fusionInfluenceScore * 0.35 +
      human.coverageScore * 0.30 +
      human.evidenceDiversityScore * 0.20 +
      human.patternStrengthScore * 0.15
    ).clamp(0.0, 1.0);
  }

  static double _evidenceDiversity(
    HumanModelSnapshot snapshot,
    String humanPatternId,
  ) {
    final rows =
        snapshot.evidence.where((row) => row.humanPatternId == humanPatternId);
    if (rows.isEmpty) return 0.0;

    final systems = rows.map((row) => row.systemId).toSet();
    final mirrors = rows.map((row) => row.mirrorRoleId).toSet();
    final themes = rows.map((row) => row.sourceThemeId).toSet();

    return ((systems.length / 4) * 0.4 +
            (mirrors.length / 3) * 0.3 +
            (themes.length / 6) * 0.3)
        .clamp(0.0, 1.0);
  }
}
