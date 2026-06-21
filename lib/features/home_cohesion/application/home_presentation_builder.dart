import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';

import '../domain/home_presentation_model.dart';
import '../domain/home_section.dart';
import '../domain/home_section_group.dart';
import '../domain/home_snapshot.dart';
import 'home_presentation_registry.dart';

/// Maps [HomeSnapshot] into Home IA groups and sections (HC-F1).
abstract final class HomePresentationBuilder {
  static HomePresentationModel build(HomeSnapshot snapshot) {
    final overviewSection = _overviewSection(snapshot);
    final reflectionSections = _reflectionSections(snapshot);
    final discoverySections = _discoverySections(snapshot);

    final sections = <HomeSection>[
      overviewSection,
      ...reflectionSections,
      ...discoverySections,
    ];

    final groups = <HomeSectionGroup>[
      HomeSectionGroup(
        id: HomeSectionGroupId.yourJourney,
        title: HomePresentationRegistry.yourJourneyTitle,
        description: HomePresentationRegistry.yourJourneyDescription,
        sections: [overviewSection],
      ),
      HomeSectionGroup(
        id: HomeSectionGroupId.yourReflections,
        title: HomePresentationRegistry.yourReflectionsTitle,
        description: HomePresentationRegistry.yourReflectionsDescription,
        sections: reflectionSections,
      ),
      HomeSectionGroup(
        id: HomeSectionGroupId.exploreMore,
        title: HomePresentationRegistry.exploreMoreTitle,
        description: HomePresentationRegistry.exploreMoreDescription,
        sections: discoverySections,
      ),
    ];

    return HomePresentationModel(
      version: HomePresentationModel.versionId,
      groups: List.unmodifiable(groups),
      sections: List.unmodifiable(sections),
    );
  }

  static HomeSection _overviewSection(HomeSnapshot snapshot) {
    final overviewItem = _discoveryItem(
      snapshot,
      DiscoveryCatalogIds.explorationOverview,
    );

    return HomeSection(
      id: HomeSectionIds.overview,
      type: HomeSectionType.overview,
      groupId: HomeSectionGroupId.yourJourney,
      title: HomePresentationRegistry.overviewSectionTitle,
      description: HomePresentationRegistry.overviewSectionDescription,
      referenceId: DiscoveryCatalogIds.explorationOverview,
      visible: overviewItem?.availability != DiscoveryAvailability.locked,
    );
  }

  static List<HomeSection> _reflectionSections(HomeSnapshot snapshot) {
    final astrologyItem = _discoveryItem(
      snapshot,
      DiscoveryCatalogIds.astrologyMirror,
    );
    final personalityItem = _discoveryItem(
      snapshot,
      DiscoveryCatalogIds.personalityMirror,
    );
    final fusionItem = _discoveryItem(
      snapshot,
      DiscoveryCatalogIds.globalFusion,
    );

    return [
      HomeSection(
        id: HomeSectionIds.astrologyMirror,
        type: HomeSectionType.mirror,
        groupId: HomeSectionGroupId.yourReflections,
        title: HomePresentationRegistry.astrologyMirrorSectionTitle,
        description: HomePresentationRegistry.astrologyMirrorSectionDescription,
        referenceId: DiscoveryCatalogIds.astrologyMirror,
        visible: snapshot.mirrorSummary.astrology.available,
      ),
      HomeSection(
        id: HomeSectionIds.personalityMirror,
        type: HomeSectionType.mirror,
        groupId: HomeSectionGroupId.yourReflections,
        title: HomePresentationRegistry.personalityMirrorSectionTitle,
        description:
            HomePresentationRegistry.personalityMirrorSectionDescription,
        referenceId: DiscoveryCatalogIds.personalityMirror,
        visible: snapshot.mirrorSummary.personality.available,
      ),
      HomeSection(
        id: HomeSectionIds.globalFusion,
        type: HomeSectionType.fusion,
        groupId: HomeSectionGroupId.yourReflections,
        title: HomePresentationRegistry.globalFusionSectionTitle,
        description: HomePresentationRegistry.globalFusionSectionDescription,
        referenceId: DiscoveryCatalogIds.globalFusion,
        visible: snapshot.fusionSummary.available,
      ),
    ];
  }

  static List<HomeSection> _discoverySections(HomeSnapshot snapshot) {
    final lensItems = snapshot.discoveryItems
        .where((item) => item.sourceType == DiscoverySourceType.lens)
        .toList();

    final byCatalogId = {
      for (final item in lensItems) item.id: item,
    };

    return [
      for (final sectionId in HomeSectionIds.discoveryLensSectionOrder)
        _discoveryLensSection(
          sectionId: sectionId,
          item: byCatalogId[_catalogIdForSection(sectionId)],
        ),
    ];
  }

  static HomeSection _discoveryLensSection({
    required String sectionId,
    required DiscoveryItem? item,
  }) {
    return HomeSection(
      id: sectionId,
      type: HomeSectionType.discovery,
      groupId: HomeSectionGroupId.exploreMore,
      title: item?.title ?? HomePresentationRegistry.fallbackLensTitle,
      description: item?.description ??
          HomePresentationRegistry.fallbackLensDescription,
      referenceId: item?.id ?? sectionId,
      visible: item != null && item.availability != DiscoveryAvailability.locked,
    );
  }

  static String _catalogIdForSection(String sectionId) {
    return switch (sectionId) {
      HomeSectionIds.lensWesternNatal => DiscoveryCatalogIds.westernNatal,
      HomeSectionIds.lensChineseBazi => DiscoveryCatalogIds.chineseBazi,
      HomeSectionIds.lensThaiAstrology => DiscoveryCatalogIds.thaiAstrology,
      HomeSectionIds.lensMbti => DiscoveryCatalogIds.mbti,
      HomeSectionIds.lensEq => DiscoveryCatalogIds.eq,
      HomeSectionIds.lensBigFive => DiscoveryCatalogIds.bigFive,
      _ => sectionId,
    };
  }

  static DiscoveryItem? _discoveryItem(
    HomeSnapshot snapshot,
    String catalogId,
  ) {
    for (final item in snapshot.discoveryItems) {
      if (item.id == catalogId) return item;
    }
    return null;
  }
}
