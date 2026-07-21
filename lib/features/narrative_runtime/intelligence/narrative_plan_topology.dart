import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';

import '../domain/narrative_mode.dart';
import '../registry/narrative_mode_filter.dart';
import 'narrative_insight_plan.dart';
import 'narrative_interaction_type.dart';
import 'narrative_pattern_interaction_catalog.dart';

/// Deterministic plan phase ordering for Narrative Intelligence V4.
enum NarrativePlanPhase {
  blindSpot,
  interaction,
  compression,
  singles,
}

/// Topology preset — controls phase execution order within a mode.
enum NarrativePlanTopology {
  standard,
  interactionFirst,
  evidenceDense,
  anchorSingles,
  tensionAnchor,
  blindSpotAnchor,
  growthFirst,
}

/// Per-mode evidence summary for topology resolution.
class NarrativeModeEvidenceProfile {
  const NarrativeModeEvidenceProfile({
    required this.mode,
    required this.evidenceDensity,
    required this.sourceDiversity,
    required this.fusionDiversity,
    required this.activationCount,
    required this.hasBlindSpot,
    required this.hasTensionRule,
    required this.hasGrowthEdgeRule,
    required this.hasCompressionCluster,
  });

  final NarrativeMode mode;
  final double evidenceDensity;
  final double sourceDiversity;
  final double fusionDiversity;
  final int activationCount;
  final bool hasBlindSpot;
  final bool hasTensionRule;
  final bool hasGrowthEdgeRule;
  final bool hasCompressionCluster;

  double get compositeScore =>
      evidenceDensity * 0.40 +
      sourceDiversity * 0.25 +
      fusionDiversity * 0.20 +
      (activationCount / 12).clamp(0.0, 1.0) * 0.15;
}

/// Resolves deterministic topology per mode from evidence profiles.
abstract final class NarrativeTopologyPlanner {
  static Map<NarrativeMode, NarrativeModeEvidenceProfile> analyzeProfiles({
    required HumanPatternSnapshot snapshot,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
  }) {
    final profiles = <NarrativeMode, NarrativeModeEvidenceProfile>{};

    for (final mode in NarrativeModeFilter.allModes()) {
      profiles[mode] = _profileForMode(
        mode: mode,
        snapshot: snapshot,
        evidenceByPattern: evidenceByPattern,
      );
    }

    return profiles;
  }

  static NarrativePlanTopology resolveTopology({
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required NarrativeModeEvidenceProfile profile,
    required int evidenceRank,
    required List<NarrativeMode> rankedModes,
  }) {
    if (profile.activationCount == 0) {
      return NarrativePlanTopology.standard;
    }

    final candidates = _candidateTopologies(
      mode: mode,
      profile: profile,
      evidenceRank: evidenceRank,
      rankedModes: rankedModes,
    );

    return _pickFromPool(snapshot.structuralHash, mode, candidates);
  }

  static List<NarrativePlanTopology> _candidateTopologies({
    required NarrativeMode mode,
    required NarrativeModeEvidenceProfile profile,
    required int evidenceRank,
    required List<NarrativeMode> rankedModes,
  }) {
    final isStrongestMode = rankedModes.isNotEmpty && rankedModes.first == mode;
    final isWeakestMode =
        rankedModes.isNotEmpty && rankedModes.last == mode;

    final pool = <NarrativePlanTopology>{NarrativePlanTopology.standard};

    pool.add(NarrativePlanTopology.interactionFirst);
    pool.add(NarrativePlanTopology.anchorSingles);

    if (profile.hasBlindSpot) {
      pool.add(NarrativePlanTopology.blindSpotAnchor);
    }
    if (profile.hasTensionRule) {
      pool.add(NarrativePlanTopology.tensionAnchor);
    }
    if (profile.hasCompressionCluster) {
      pool.add(NarrativePlanTopology.evidenceDense);
      pool.add(NarrativePlanTopology.growthFirst);
    }

    if (mode == NarrativeMode.identity && profile.evidenceDensity >= 0.35) {
      pool.add(NarrativePlanTopology.anchorSingles);
    }
    if (mode == NarrativeMode.growth) {
      pool.add(NarrativePlanTopology.growthFirst);
    }
    if (mode == NarrativeMode.decision && profile.hasTensionRule) {
      pool.add(NarrativePlanTopology.tensionAnchor);
    }
    if (mode == NarrativeMode.relationship && profile.hasBlindSpot) {
      pool.add(NarrativePlanTopology.blindSpotAnchor);
    }

    if (isStrongestMode) {
      pool.add(NarrativePlanTopology.evidenceDense);
      pool.add(NarrativePlanTopology.interactionFirst);
    }
    if (isWeakestMode) {
      pool.add(NarrativePlanTopology.anchorSingles);
    }

    if (evidenceRank == 0) {
      pool.add(NarrativePlanTopology.interactionFirst);
    } else if (evidenceRank >= 2) {
      pool.add(NarrativePlanTopology.blindSpotAnchor);
    }

    // Spread variants using profile signals
    if (profile.sourceDiversity >= 0.25) {
      pool.add(NarrativePlanTopology.evidenceDense);
    }
    if (profile.fusionDiversity >= 0.20) {
      pool.add(NarrativePlanTopology.tensionAnchor);
    }

    return pool.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static List<NarrativePlanPhase> phasesFor(NarrativePlanTopology topology) {
    return switch (topology) {
      NarrativePlanTopology.standard => const [
          NarrativePlanPhase.blindSpot,
          NarrativePlanPhase.interaction,
          NarrativePlanPhase.compression,
          NarrativePlanPhase.singles,
        ],
      NarrativePlanTopology.interactionFirst => const [
          NarrativePlanPhase.interaction,
          NarrativePlanPhase.singles,
          NarrativePlanPhase.blindSpot,
          NarrativePlanPhase.compression,
        ],
      NarrativePlanTopology.evidenceDense => const [
          NarrativePlanPhase.compression,
          NarrativePlanPhase.interaction,
          NarrativePlanPhase.singles,
          NarrativePlanPhase.blindSpot,
        ],
      NarrativePlanTopology.anchorSingles => const [
          NarrativePlanPhase.singles,
          NarrativePlanPhase.blindSpot,
          NarrativePlanPhase.interaction,
          NarrativePlanPhase.compression,
        ],
      NarrativePlanTopology.tensionAnchor => const [
          NarrativePlanPhase.interaction,
          NarrativePlanPhase.blindSpot,
          NarrativePlanPhase.singles,
          NarrativePlanPhase.compression,
        ],
      NarrativePlanTopology.blindSpotAnchor => const [
          NarrativePlanPhase.blindSpot,
          NarrativePlanPhase.singles,
          NarrativePlanPhase.interaction,
          NarrativePlanPhase.compression,
        ],
      NarrativePlanTopology.growthFirst => const [
          NarrativePlanPhase.compression,
          NarrativePlanPhase.singles,
          NarrativePlanPhase.interaction,
          NarrativePlanPhase.blindSpot,
        ],
    };
  }

  static bool tensionInteractionsFirst(NarrativePlanTopology topology) {
    return topology == NarrativePlanTopology.tensionAnchor;
  }

  static List<NarrativeMode> rankModesByEvidence(
    Map<NarrativeMode, NarrativeModeEvidenceProfile> profiles,
  ) {
    final modes = NarrativeModeFilter.allModes().toList()
      ..sort((a, b) {
        final scoreA = profiles[a]?.compositeScore ?? 0;
        final scoreB = profiles[b]?.compositeScore ?? 0;
        final compare = scoreB.compareTo(scoreA);
        if (compare != 0) return compare;
        return a.key.compareTo(b.key);
      });
    return modes;
  }

  static Map<NarrativeMode, NarrativePlanTopology> resolveAllTopologies({
    required HumanPatternSnapshot snapshot,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
  }) {
    final profiles = analyzeProfiles(
      snapshot: snapshot,
      evidenceByPattern: evidenceByPattern,
    );
    final rankedModes = rankModesByEvidence(profiles);
    final rankByMode = {
      for (var i = 0; i < rankedModes.length; i++) rankedModes[i]: i,
    };

    return {
      for (final mode in NarrativeModeFilter.allModes())
        mode: resolveTopology(
          snapshot: snapshot,
          mode: mode,
          profile: profiles[mode]!,
          evidenceRank: rankByMode[mode] ?? 3,
          rankedModes: rankedModes,
        ),
    };
  }

  static String topologyFingerprint({
    required Map<NarrativeMode, NarrativePlanTopology> topologyByMode,
    required List<NarrativeInsightPlan> plans,
  }) {
    final parts = <String>[];
    for (final mode in NarrativeModeFilter.allModes()) {
      final topology = topologyByMode[mode] ?? NarrativePlanTopology.standard;
      final modePlans = plans.where((plan) => plan.mode == mode).toList();
      final segments = modePlans
          .map(
            (plan) =>
                '${topology.name}:${plan.interactionType.key}:${plan.referencedPatternIds.join("+")}',
          )
          .join(',');
      parts.add('${mode.key}:$segments');
    }
    return parts.join('|');
  }

  static String topologyShapeFingerprint({
    required Map<NarrativeMode, NarrativePlanTopology> topologyByMode,
    required List<NarrativeInsightPlan> plans,
  }) {
    final parts = <String>[];
    for (final mode in NarrativeModeFilter.allModes()) {
      final topology = topologyByMode[mode] ?? NarrativePlanTopology.standard;
      final modePlans = plans.where((plan) => plan.mode == mode).toList();
      final shape = modePlans.map((plan) => plan.interactionType.key).join('+');
      parts.add('${mode.key}:${topology.name}:$shape');
    }
    return parts.join('|');
  }

  static bool shouldSkipCompression({
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required NarrativePlanTopology topology,
  }) {
    if (topology != NarrativePlanTopology.evidenceDense &&
        topology != NarrativePlanTopology.growthFirst) {
      return false;
    }
    return _topologyHash(snapshot.structuralHash, mode) >= 0.82;
  }

  static bool shouldSkipInteractions({
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required NarrativePlanTopology topology,
  }) {
    if (topology == NarrativePlanTopology.interactionFirst ||
        topology == NarrativePlanTopology.tensionAnchor) {
      return false;
    }
    return _topologyHash(snapshot.structuralHash, mode) >= 0.875;
  }

  static int maxInteractionPlans(NarrativePlanTopology topology) {
    return switch (topology) {
      NarrativePlanTopology.interactionFirst => 2,
      NarrativePlanTopology.tensionAnchor => 1,
      _ => 1,
    };
  }

  static int singlePickIndex({
    required HumanPatternSnapshot snapshot,
    required NarrativeMode mode,
    required NarrativePlanTopology topology,
    required int slotIndex,
    required int candidateCount,
  }) {
    if (candidateCount <= 1) return 0;

    if (slotIndex >= 1) {
      final seed = '${snapshot.structuralHash}|slot$slotIndex|${topology.name}';
      var hash = 0;
      for (var i = 0; i < seed.length; i++) {
        hash = (hash * 31 + seed.codeUnitAt(i)) & 0x7fffffff;
      }
      final normalized = (hash % 10000) / 10000.0;
      return (normalized * candidateCount).floor().clamp(0, candidateCount - 1);
    }

    final hash = _topologyHash(snapshot.structuralHash, mode);

    if (candidateCount > 1 && hash >= 0.712 && hash < 0.738) {
      return 1;
    }

    if (candidateCount > 2 && hash >= 0.553 && hash < 0.581) {
      return 2;
    }

    return 0;
  }

  static NarrativePlanTopology _pickFromPool(
    String structuralHash,
    NarrativeMode mode,
    List<NarrativePlanTopology> pool,
  ) {
    if (pool.length == 1) return pool.first;
    final hash = _topologyHash(structuralHash, mode);
    final index = (hash * pool.length).floor().clamp(0, pool.length - 1);
    return pool[index];
  }

  static NarrativeModeEvidenceProfile _profileForMode({
    required NarrativeMode mode,
    required HumanPatternSnapshot snapshot,
    required Map<String, List<PatternEvidence>> evidenceByPattern,
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

    if (activations.isEmpty) {
      return NarrativeModeEvidenceProfile(
        mode: mode,
        evidenceDensity: 0,
        sourceDiversity: 0,
        fusionDiversity: 0,
        activationCount: 0,
        hasBlindSpot: false,
        hasTensionRule: false,
        hasGrowthEdgeRule: false,
        hasCompressionCluster: false,
      );
    }

    var densitySum = 0.0;
    var sourceSum = 0.0;
    var fusionSum = 0.0;
    var hasBlindSpot = false;
    var familyCounts = <String, int>{};

    for (final activation in activations) {
      final rows = evidenceByPattern[activation.patternId] ?? const [];
      densitySum += _evidenceDensity(rows);
      sourceSum += _sourceDiversity(rows);
      fusionSum += _fusionFindingDiversity(rows);
      if (activation.patternFamilyId == 'blind_spot_pattern') {
        hasBlindSpot = true;
      }
      familyCounts.update(
        activation.patternFamilyId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    final count = activations.length;
    final hasCompressionCluster = familyCounts.values.any((c) => c >= 3);

    var hasTensionRule = false;
    var hasGrowthEdgeRule = false;
    for (final rule in NarrativePatternInteractionCatalog.rulesForMode(mode)) {
      if (rule.type == NarrativeInteractionType.tension) hasTensionRule = true;
      if (rule.type == NarrativeInteractionType.growthEdge) {
        hasGrowthEdgeRule = true;
      }
    }

    return NarrativeModeEvidenceProfile(
      mode: mode,
      evidenceDensity: (densitySum / count).clamp(0.0, 1.0),
      sourceDiversity: (sourceSum / count).clamp(0.0, 1.0),
      fusionDiversity: (fusionSum / count).clamp(0.0, 1.0),
      activationCount: count,
      hasBlindSpot: hasBlindSpot,
      hasTensionRule: hasTensionRule,
      hasGrowthEdgeRule: hasGrowthEdgeRule,
      hasCompressionCluster: hasCompressionCluster,
    );
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
    return ((mirrors + keys + systems + (themes / 2)) / 10).clamp(0.0, 1.0);
  }

  static double _fusionFindingDiversity(List<PatternEvidence> rows) {
    if (rows.isEmpty) return 0;
    final findings = rows.map((row) => row.fusionFindingId).toSet().length;
    final hmPatterns = rows.map((row) => row.humanModelPatternId).toSet().length;
    return ((findings + hmPatterns) / 8).clamp(0.0, 1.0);
  }

  static double _topologyHash(String structuralHash, NarrativeMode mode) {
    final seed = '$structuralHash|topology|${mode.key}';
    var hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = (hash * 31 + seed.codeUnitAt(i)) & 0x7fffffff;
    }
    return (hash % 10000) / 10000.0;
  }
}
