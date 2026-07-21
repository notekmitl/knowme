import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_mirror_id.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_overview.dart';
import 'package:knowme/features/global_fusion/application/narrative/global_narrative_builder.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';

import '../domain/home_fusion_summary.dart';
import '../domain/home_mirror_summary.dart';
import '../domain/home_snapshot.dart';

/// Builds [HomeSnapshot] from overview, discovery, and mirror snapshots (HC-F0).
abstract final class HomeSnapshotBuilder {
  static HomeSnapshot build({
    required ExplorationOverview overview,
    required List<DiscoveryItem> discoveryItems,
    AstrologyFusionSnapshot? astrologySnapshot,
    PersonalityMirrorSnapshot? personalitySnapshot,
    GlobalFusionSnapshot? globalFusionSnapshot,
  }) {
    return HomeSnapshot(
      version: HomeSnapshot.versionId,
      overview: overview,
      discoveryItems: List.unmodifiable(discoveryItems),
      mirrorSummary: _buildMirrorSummary(
        overview: overview,
        astrologySnapshot: astrologySnapshot,
        personalitySnapshot: personalitySnapshot,
      ),
      fusionSummary: _buildFusionSummary(
        overview: overview,
        globalFusionSnapshot: globalFusionSnapshot,
      ),
    );
  }

  static HomeMirrorSummary _buildMirrorSummary({
    required ExplorationOverview overview,
    required AstrologyFusionSnapshot? astrologySnapshot,
    required PersonalityMirrorSnapshot? personalitySnapshot,
  }) {
    final astrologyMirror = overview.mirror(ExplorationMirrorId.astrologyMirror);
    final personalityMirror =
        overview.mirror(ExplorationMirrorId.personalityMirror);

    return HomeMirrorSummary(
      astrology: HomeMirrorEntrySummary(
        available: astrologyMirror.readiness !=
            ExplorationMirrorReadiness.unavailable,
        ready: astrologyMirror.readiness == ExplorationMirrorReadiness.ready,
        reflectionCount: _astrologyReflectionCount(astrologySnapshot),
      ),
      personality: HomeMirrorEntrySummary(
        available: personalityMirror.readiness !=
            ExplorationMirrorReadiness.unavailable,
        ready: personalityMirror.readiness == ExplorationMirrorReadiness.ready,
        reflectionCount: _personalityReflectionCount(personalitySnapshot),
      ),
    );
  }

  static HomeFusionSummary _buildFusionSummary({
    required ExplorationOverview overview,
    required GlobalFusionSnapshot? globalFusionSnapshot,
  }) {
    final readiness = overview.fusionStatus.readiness;
    final available = readiness != ExplorationFusionReadiness.unavailable;
    final ready =
        readiness == ExplorationFusionReadiness.ready &&
            globalFusionSnapshot != null;

    return HomeFusionSummary(
      available: available,
      ready: ready,
      reflectionCount: globalFusionSnapshot == null
          ? 0
          : GlobalNarrativeBuilder.fromSnapshot(globalFusionSnapshot).length,
      confidenceBand: globalFusionSnapshot?.confidence.band,
    );
  }

  static int _astrologyReflectionCount(AstrologyFusionSnapshot? snapshot) {
    if (snapshot == null) return 0;

    var count = 0;
    if (snapshot.reflection.summary.trim().isNotEmpty) {
      count++;
    }
    count += snapshot.reflection.keyInsights.length;
    count += snapshot.agreements.length;
    return count;
  }

  static int _personalityReflectionCount(PersonalityMirrorSnapshot? snapshot) {
    if (snapshot == null) return 0;

    var count = snapshot.agreements.length + snapshot.tensions.length;
    for (final lens in snapshot.lensSnapshots) {
      if (lens.available) {
        count += lens.themes.length;
      }
    }
    return count;
  }
}
