import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/human_pattern/registry/human_pattern_registry.dart';

import '../engines/pattern_activation_engine.dart';
import '../registry/human_pattern_activation_rule.dart';

/// HPC3 — registry pattern reachability classification.
enum PatternReachability {
  activated('activated'),
  partiallyReachable('partially_reachable'),
  unreachable('unreachable');

  const PatternReachability(this.key);

  final String key;
}

class PatternReachabilityEntry {
  const PatternReachabilityEntry({
    required this.patternId,
    required this.reachability,
    required this.blockReason,
  });

  final String patternId;
  final PatternReachability reachability;
  final String blockReason;
}

class PatternActivationReachabilityReport {
  const PatternActivationReachabilityReport({
    required this.totalRegistryPatterns,
    required this.activated,
    required this.partiallyReachable,
    required this.unreachable,
    required this.entries,
  });

  final int totalRegistryPatterns;
  final List<String> activated;
  final List<String> partiallyReachable;
  final List<String> unreachable;
  final List<PatternReachabilityEntry> entries;
}

abstract final class PatternActivationReachabilityAudit {
  static PatternActivationReachabilityReport analyze({
    required HumanModelSnapshot humanModelSnapshot,
    required HumanPatternSnapshot humanPatternSnapshot,
  }) {
    final activatedIds =
        humanPatternSnapshot.activations.map((item) => item.patternId).toSet();
    final activated = <String>[];
    final partial = <String>[];
    final unreachable = <String>[];
    final entries = <PatternReachabilityEntry>[];

    for (final entry in HumanPatternRegistry.allEntries) {
      if (activatedIds.contains(entry.patternId)) {
        activated.add(entry.patternId);
        entries.add(
          PatternReachabilityEntry(
            patternId: entry.patternId,
            reachability: PatternReachability.activated,
            blockReason: '',
          ),
        );
        continue;
      }

      final diagnosis = _diagnose(humanModelSnapshot, entry.activationRule);
      if (diagnosis.reachability == PatternReachability.partiallyReachable) {
        partial.add(entry.patternId);
      } else {
        unreachable.add(entry.patternId);
      }
      entries.add(diagnosis);
    }

    activated.sort();
    partial.sort();
    unreachable.sort();

    return PatternActivationReachabilityReport(
      totalRegistryPatterns: HumanPatternRegistry.allEntries.length,
      activated: activated,
      partiallyReachable: partial,
      unreachable: unreachable,
      entries: entries,
    );
  }

  static PatternReachabilityEntry _diagnose(
    HumanModelSnapshot snapshot,
    HumanPatternActivationRule rule,
  ) {
    final source = PatternActivationEngine.resolveSourceForAudit(snapshot, rule);
    if (source == null) {
      return PatternReachabilityEntry(
        patternId: _patternIdForRule(rule),
        reachability: PatternReachability.unreachable,
        blockReason: _missingSourceReason(rule),
      );
    }

    if (source.patternStrength < rule.minPatternStrength) {
      return PatternReachabilityEntry(
        patternId: _patternIdForRule(rule),
        reachability: PatternReachability.partiallyReachable,
        blockReason: 'pattern_strength_below_threshold',
      );
    }

    if (!_hasEvidence(snapshot, source)) {
      return PatternReachabilityEntry(
        patternId: _patternIdForRule(rule),
        reachability: PatternReachability.partiallyReachable,
        blockReason: 'missing_lineage_evidence',
      );
    }

    if (rule.requiredFusionFindingType != null &&
        source.fusionFindingType != rule.requiredFusionFindingType) {
      return PatternReachabilityEntry(
        patternId: _patternIdForRule(rule),
        reachability: PatternReachability.partiallyReachable,
        blockReason: 'fusion_finding_type_mismatch',
      );
    }

    if (rule.requiredMirrorKey != null &&
        !source.supportingMirrorKeys.contains(rule.requiredMirrorKey)) {
      final evidenceMatch = snapshot.evidence.any(
        (row) =>
            row.humanPatternId == source.id &&
            row.mirrorKey == rule.requiredMirrorKey,
      );
      if (!evidenceMatch) {
        return PatternReachabilityEntry(
          patternId: _patternIdForRule(rule),
          reachability: PatternReachability.partiallyReachable,
          blockReason: 'mirror_key_not_present',
        );
      }
    }

    if (rule.requiredDimensionKey != null) {
      final dimensionActivation = snapshot.profile.dimensions
          .where((item) => item.dimensionKey == rule.requiredDimensionKey)
          .map((item) => item.activation)
          .fold(0.0, (max, value) => value > max ? value : max);
      if (dimensionActivation < rule.minDimensionActivation) {
        return PatternReachabilityEntry(
          patternId: _patternIdForRule(rule),
          reachability: PatternReachability.partiallyReachable,
          blockReason: 'dimension_activation_below_threshold',
        );
      }
    }

    return PatternReachabilityEntry(
      patternId: _patternIdForRule(rule),
      reachability: PatternReachability.partiallyReachable,
      blockReason: 'rule_not_matched',
    );
  }

  static bool _hasEvidence(HumanModelSnapshot snapshot, dynamic source) {
    return snapshot.evidence.any((row) => row.humanPatternId == source.id);
  }

  static String _patternIdForRule(HumanPatternActivationRule rule) {
    return HumanPatternRegistry.allEntries
            .where((entry) => entry.activationRule.ruleId == rule.ruleId)
            .map((entry) => entry.patternId)
            .firstOrNull ??
        rule.ruleId;
  }

  static String _missingSourceReason(HumanPatternActivationRule rule) {
    if (rule.sourceHumanPatternKey != null) {
      return 'missing_source_pattern:${rule.sourceHumanPatternKey}';
    }
    if (rule.requiredMirrorKey != null) {
      return 'missing_mirror_pattern:${rule.requiredMirrorKey}';
    }
    if (rule.requiredDimensionKey != null) {
      return 'missing_dimension_pattern:${rule.requiredDimensionKey}';
    }
    return 'missing_source';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
