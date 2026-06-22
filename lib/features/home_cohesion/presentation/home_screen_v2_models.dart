/// Profile anchor — Section 1 (Home V2).
class HomeProfileSectionData {
  const HomeProfileSectionData({
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.completenessLabel,
    required this.completenessRatio,
    required this.isEmpty,
  });

  final String name;
  final String birthDate;
  final String birthTime;
  final String birthPlace;
  final String completenessLabel;
  final double completenessRatio;
  final bool isEmpty;
}

/// Astrology hero — Section 2 (Home V2).
class HomeAstrologySummarySectionData {
  const HomeAstrologySummarySectionData({
    required this.isAvailable,
    required this.identity,
    required this.summary,
    required this.reflectionSummary,
    required this.emptyHint,
    required this.canOpenFullResult,
  });

  final bool isAvailable;
  final String identity;
  final String summary;
  final String reflectionSummary;
  final String emptyHint;
  final bool canOpenFullResult;
}

/// One short combined reflection unit — Section 3 (Home V2).
class HomeCombinedReflectionUnitData {
  const HomeCombinedReflectionUnitData({
    required this.label,
    required this.text,
  });

  final String label;
  final String text;
}

/// Combined reflection — Section 3 (Home V2).
class HomeCombinedReflectionSectionData {
  const HomeCombinedReflectionSectionData({
    required this.units,
    required this.emptyHint,
    required this.canOpenFullResult,
  });

  final List<HomeCombinedReflectionUnitData> units;
  final String emptyHint;
  final bool canOpenFullResult;
}

/// Psychology test row — Section 4 (Home V2).
enum HomePsychologyTestStatus {
  notStarted,
  inProgress,
  completed,
}

class HomePsychologyTestItemData {
  const HomePsychologyTestItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.isNextStep = false,
  });

  final String id;
  final String title;
  final String description;
  final HomePsychologyTestStatus status;
  final bool isNextStep;
}

class HomePsychologyTestsSectionData {
  const HomePsychologyTestsSectionData({
    required this.tests,
  });

  final List<HomePsychologyTestItemData> tests;
}

/// More navigation row — Section 5 (Home V2).
class HomeMoreItemData {
  const HomeMoreItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.enabled,
  });

  final String id;
  final String title;
  final String description;
  final bool enabled;
}

class HomeMoreSectionData {
  const HomeMoreSectionData({
    required this.items,
  });

  final List<HomeMoreItemData> items;
}

/// Full Home V2 product surface bundle.
class HomeScreenV2Data {
  const HomeScreenV2Data({
    required this.profile,
    required this.astrologySummary,
    required this.combinedReflection,
    required this.psychologyTests,
    required this.more,
  });

  static HomeScreenV2Data empty() {
    return HomeScreenV2Data(
      profile: const HomeProfileSectionData(
        name: '',
        birthDate: '',
        birthTime: '',
        birthPlace: '',
        completenessLabel: '',
        completenessRatio: 0,
        isEmpty: true,
      ),
      astrologySummary: HomeAstrologySummarySectionData(
        isAvailable: false,
        identity: '',
        summary: '',
        reflectionSummary: '',
        emptyHint: '',
        canOpenFullResult: false,
      ),
      combinedReflection: HomeCombinedReflectionSectionData(
        units: const [],
        emptyHint: '',
        canOpenFullResult: false,
      ),
      psychologyTests: const HomePsychologyTestsSectionData(tests: []),
      more: const HomeMoreSectionData(items: []),
    );
  }

  final HomeProfileSectionData profile;
  final HomeAstrologySummarySectionData astrologySummary;
  final HomeCombinedReflectionSectionData combinedReflection;
  final HomePsychologyTestsSectionData psychologyTests;
  final HomeMoreSectionData more;
}

/// Navigation callbacks for Home V2 actions.
class HomeScreenV2Callbacks {
  const HomeScreenV2Callbacks({
    required this.onEditProfile,
    required this.onViewAstrologyResult,
    required this.onViewCombinedReflection,
    required this.onPsychologyTest,
    required this.onMoreItem,
  });

  final void Function() onEditProfile;
  final void Function() onViewAstrologyResult;
  final void Function() onViewCombinedReflection;
  final void Function(HomePsychologyTestItemData test) onPsychologyTest;
  final void Function(HomeMoreItemData item) onMoreItem;
}
