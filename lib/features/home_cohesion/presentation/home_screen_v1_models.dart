import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';

import '../domain/home_screen_contract.dart';

/// Journey section display payload (Home MVP V1).
class HomeJourneySectionData {
  const HomeJourneySectionData({
    required this.section,
    required this.headline,
    required this.body,
    required this.hint,
  });

  final HomeSectionSurfaceContract section;
  final String headline;
  final String body;
  final String hint;
}

/// One reflection tile on Home MVP V1.
class HomeReflectionTileData {
  const HomeReflectionTileData({
    required this.title,
    required this.description,
    required this.surfaceState,
  });

  final String title;
  final String description;
  final HomeSectionSurfaceState surfaceState;
}

/// Reflections section display payload (Home MVP V1).
class HomeReflectionsSectionData {
  const HomeReflectionsSectionData({
    required this.section,
    required this.tiles,
  });

  final HomeSectionSurfaceContract section;
  final List<HomeReflectionTileData> tiles;
}

/// One explore item in a semantic group (Home MVP V1).
class HomeExploreItemData {
  const HomeExploreItemData({
    required this.title,
    required this.description,
    required this.availability,
  });

  final String title;
  final String description;
  final DiscoveryAvailability availability;
}

/// Grouped explore surface (HC-F1.5 on Home MVP V1).
class HomeExploreGroupData {
  const HomeExploreGroupData({
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<HomeExploreItemData> items;
}

/// Explore section display payload (Home MVP V1).
class HomeExploreSectionData {
  const HomeExploreSectionData({
    required this.section,
    required this.groups,
  });

  final HomeSectionSurfaceContract section;
  final List<HomeExploreGroupData> groups;
}

/// Full Home MVP V1 bundle — UI reads [contract] for visibility rules.
class HomeScreenV1Data {
  const HomeScreenV1Data({
    required this.contract,
    required this.journey,
    required this.reflections,
    required this.explore,
  });

  final HomeScreenContract contract;
  final HomeJourneySectionData journey;
  final HomeReflectionsSectionData reflections;
  final HomeExploreSectionData explore;
}
