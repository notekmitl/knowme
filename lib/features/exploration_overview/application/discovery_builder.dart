import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';

import '../domain/discovery_item.dart';
import '../domain/exploration_lens_id.dart';
import '../domain/exploration_mirror_id.dart';
import '../domain/exploration_overview.dart';
import 'discovery_registry.dart';

/// Builds discoverable surfaces from exploration overview (EO-F1).
abstract final class DiscoveryBuilder {
  static List<DiscoveryItem> build({
    required ExplorationOverview overview,
    AstrologyFusionSnapshot? astrologySnapshot,
    PersonalityMirrorSnapshot? personalitySnapshot,
    GlobalFusionSnapshot? globalFusionSnapshot,
  }) {
    final items = <DiscoveryItem>[
      for (final lensId in ExplorationLensId.all)
        _lensItem(overview.lens(lensId)),
      _mirrorItem(
        overview.mirror(ExplorationMirrorId.astrologyMirror),
      ),
      _mirrorItem(
        overview.mirror(ExplorationMirrorId.personalityMirror),
      ),
      _fusionItem(
        overview: overview,
        globalFusionSnapshot: globalFusionSnapshot,
      ),
      _overviewItem(
        overview: overview,
        globalFusionSnapshot: globalFusionSnapshot,
      ),
    ];

    return List.unmodifiable(items);
  }

  static DiscoveryItem _lensItem(ExplorationLensStatusEntry status) {
    return DiscoveryItem(
      id: _lensCatalogId(status.lensId),
      title: DiscoveryRegistry.lensTitle(status.lensId),
      description: DiscoveryRegistry.lensDescription(status.lensId),
      sourceType: DiscoverySourceType.lens,
      category: DiscoveryRegistry.lensCategory(status.lensId),
      availability: _lensAvailability(status),
    );
  }

  static DiscoveryItem _mirrorItem(ExplorationMirrorStatusEntry status) {
    return DiscoveryItem(
      id: _mirrorCatalogId(status.mirrorId),
      title: DiscoveryRegistry.mirrorTitle(status.mirrorId),
      description: DiscoveryRegistry.mirrorDescription(status.mirrorId),
      sourceType: DiscoverySourceType.mirror,
      category: DiscoveryRegistry.mirrorCategory(status.mirrorId),
      availability: _mirrorAvailability(status.readiness),
    );
  }

  static DiscoveryItem _fusionItem({
    required ExplorationOverview overview,
    required GlobalFusionSnapshot? globalFusionSnapshot,
  }) {
    return DiscoveryItem(
      id: DiscoveryCatalogIds.globalFusion,
      title: DiscoveryRegistry.globalFusionTitle,
      description: DiscoveryRegistry.globalFusionDescription,
      sourceType: DiscoverySourceType.fusion,
      category: DiscoveryCategory.fusion,
      availability: _fusionAvailability(
        overview.fusionStatus.readiness,
        globalFusionSnapshot: globalFusionSnapshot,
      ),
    );
  }

  static DiscoveryItem _overviewItem({
    required ExplorationOverview overview,
    required GlobalFusionSnapshot? globalFusionSnapshot,
  }) {
    return DiscoveryItem(
      id: DiscoveryCatalogIds.explorationOverview,
      title: DiscoveryRegistry.explorationOverviewTitle,
      description: DiscoveryRegistry.explorationOverviewDescription,
      sourceType: DiscoverySourceType.overview,
      category: DiscoveryCategory.exploration,
      availability: _overviewAvailability(
        overview,
        globalFusionSnapshot: globalFusionSnapshot,
      ),
    );
  }

  static DiscoveryAvailability _lensAvailability(
    ExplorationLensStatusEntry status,
  ) {
    if (status.completed) return DiscoveryAvailability.completed;
    if (status.available) return DiscoveryAvailability.available;
    return DiscoveryAvailability.locked;
  }

  static DiscoveryAvailability _mirrorAvailability(
    ExplorationMirrorReadiness readiness,
  ) {
    return switch (readiness) {
      ExplorationMirrorReadiness.ready => DiscoveryAvailability.completed,
      ExplorationMirrorReadiness.partial => DiscoveryAvailability.available,
      ExplorationMirrorReadiness.unavailable => DiscoveryAvailability.locked,
    };
  }

  static DiscoveryAvailability _fusionAvailability(
    ExplorationFusionReadiness readiness, {
    required GlobalFusionSnapshot? globalFusionSnapshot,
  }) {
    return switch (readiness) {
      ExplorationFusionReadiness.unavailable => DiscoveryAvailability.locked,
      ExplorationFusionReadiness.limited => DiscoveryAvailability.available,
      ExplorationFusionReadiness.ready =>
        globalFusionSnapshot != null
            ? DiscoveryAvailability.completed
            : DiscoveryAvailability.available,
    };
  }

  static DiscoveryAvailability _overviewAvailability(
    ExplorationOverview overview, {
    required GlobalFusionSnapshot? globalFusionSnapshot,
  }) {
    final allLensesCompleted =
        overview.coverage.unexploredLensCount == 0 &&
            overview.coverage.exploredLensCount ==
                ExplorationLensId.all.length;
    final fusionBuilt = globalFusionSnapshot != null &&
        overview.fusionStatus.readiness == ExplorationFusionReadiness.ready;

    if (allLensesCompleted && fusionBuilt) {
      return DiscoveryAvailability.completed;
    }

    final hasExplorationSurface = overview.profileStatus !=
            ExplorationProfileStatus.noBirthProfile ||
        overview.coverage.exploredLensCount > 0 ||
        overview.coverage.availableMirrorCount > 0 ||
        overview.fusionStatus.readiness !=
            ExplorationFusionReadiness.unavailable ||
        overview.lensStatuses.any(
          (entry) =>
              ExplorationLensId.personalityLenses.contains(entry.lensId) &&
              entry.available,
        );

    if (!hasExplorationSurface) {
      return DiscoveryAvailability.locked;
    }

    return DiscoveryAvailability.available;
  }

  static String _lensCatalogId(ExplorationLensId lensId) {
    return switch (lensId) {
      ExplorationLensId.westernNatal => DiscoveryCatalogIds.westernNatal,
      ExplorationLensId.chineseBazi => DiscoveryCatalogIds.chineseBazi,
      ExplorationLensId.thaiAstrology => DiscoveryCatalogIds.thaiAstrology,
      ExplorationLensId.mbti => DiscoveryCatalogIds.mbti,
      ExplorationLensId.eq => DiscoveryCatalogIds.eq,
      ExplorationLensId.bigFive => DiscoveryCatalogIds.bigFive,
    };
  }

  static String _mirrorCatalogId(ExplorationMirrorId mirrorId) {
    return switch (mirrorId) {
      ExplorationMirrorId.astrologyMirror =>
        DiscoveryCatalogIds.astrologyMirror,
      ExplorationMirrorId.personalityMirror =>
        DiscoveryCatalogIds.personalityMirror,
    };
  }
}
