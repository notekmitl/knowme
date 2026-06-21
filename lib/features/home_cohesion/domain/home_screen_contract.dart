import 'home_experience_blueprint.dart';

/// Screen fold placement — product meaning only (HX-F1, not Flutter layout).
enum HomeScreenRegion {
  aboveFold,
  belowFold,
}

/// Home user maturity on the MVP surface (HX-F1).
enum HomeUserStateMode {
  emptyUser,
  partialUser,
  advancedUser,
}

/// Section readiness on the Home MVP surface (HX-F1).
enum HomeSectionSurfaceState {
  hidden,
  empty,
  partial,
  ready,
}

/// Product contract for one Home section slot (HX-F1).
class HomeSectionSurfaceContract {
  const HomeSectionSurfaceContract({
    required this.type,
    required this.purpose,
    required this.requiredData,
    required this.visible,
    required this.surfaceState,
    required this.region,
    required this.priority,
    required this.experienceSectionId,
    required this.visibleChildCount,
  });

  final HomeExperienceSectionType type;
  final String purpose;
  final String requiredData;
  final bool visible;
  final HomeSectionSurfaceState surfaceState;
  final HomeScreenRegion region;
  final HomeExperienceSectionPriority priority;
  final String experienceSectionId;
  final int visibleChildCount;
}

/// Home MVP screen contract — product surface before widgets (HX-F1).
class HomeScreenContract {
  const HomeScreenContract({
    required this.version,
    required this.stateMode,
    required this.sectionContracts,
    required this.aboveFoldSections,
    required this.belowFoldSections,
    required this.visibleSectionTypes,
    required this.hiddenSectionTypes,
  });

  static const String versionId = 'home_screen_contract.v1';

  final String version;
  final HomeUserStateMode stateMode;
  final List<HomeSectionSurfaceContract> sectionContracts;
  final List<HomeExperienceSectionType> aboveFoldSections;
  final List<HomeExperienceSectionType> belowFoldSections;
  final List<HomeExperienceSectionType> visibleSectionTypes;
  final List<HomeExperienceSectionType> hiddenSectionTypes;

  HomeSectionSurfaceContract contract(HomeExperienceSectionType type) {
    return sectionContracts.firstWhere((entry) => entry.type == type);
  }
}
