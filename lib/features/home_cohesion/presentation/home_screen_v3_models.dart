import 'home_screen_v2_models.dart';

import '../domain/home_profile_completion.dart';



/// Visual icon family for insight / badge rendering (Home V3.5+).

enum HomeThemeVisualKind {

  autonomy,

  growth,

  adaptability,

  reflection,

  structure,

  relationships,

  expression,

  generic,

}



/// Astrology hero — Section 1 (Home V3.8 identity statement).

class HomeHeroSectionData {

  const HomeHeroSectionData({

    required this.isAvailable,

    required this.identity,

    required this.supportingReflection,

    required this.emptyHint,

    required this.canOpenFullResult,

    this.showUnlockCta = false,

    this.unlockCtaTitle = '',

    this.unlockCtaSubtitle = '',

    this.unlockProgressLabel = '',

    this.unlockEyebrow = '',

    this.unlockRewardLine = '',

    this.showSecondaryAstrologyLink = false,

  });



  final bool isAvailable;

  final String identity;

  final String supportingReflection;

  final String emptyHint;

  final bool canOpenFullResult;

  final bool showUnlockCta;

  final String unlockCtaTitle;

  final String unlockCtaSubtitle;

  final String unlockProgressLabel;

  final String unlockEyebrow;

  final String unlockRewardLine;

  final bool showSecondaryAstrologyLink;

}



/// Meaning-first insight card — Home V3.8.

class HomeInsightCardData {

  const HomeInsightCardData({

    required this.humanMeaning,

    required this.supportingExplanation,

    required this.visualKind,

  });



  final String humanMeaning;

  final String supportingExplanation;

  final HomeThemeVisualKind visualKind;

}



/// KnowMe Signature — Section 2 (Home V3.8).

class HomeKnowMeSignatureSectionData {

  const HomeKnowMeSignatureSectionData({

    required this.themeLabels,

    required this.emptyHint,

    required this.isVisible,

  });



  final List<String> themeLabels;

  final String emptyHint;

  final bool isVisible;

}



/// KnowMe insight cards — Section 3 (Home V3.8).

class HomeKnowMeInsightSectionData {

  const HomeKnowMeInsightSectionData({

    required this.cards,

    required this.emptyHint,

    required this.canOpenFullInsight,

  });



  final List<HomeInsightCardData> cards;

  final String emptyHint;

  final bool canOpenFullInsight;

}



/// Compact profile — Section 4 (Home V3).

class HomeCompactProfileSectionData {

  const HomeCompactProfileSectionData({

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



/// Narrative preview card — funnel recovery V2.
class HomeNarrativePreviewSectionData {
  const HomeNarrativePreviewSectionData({
    required this.isVisible,
    required this.previewText,
    required this.lockedSectionCount,
    required this.ctaLabel,
    this.rewardLine = '',
    this.title = '',
    this.lockedSectionLabels = const [],
  });

  final bool isVisible;
  final String previewText;
  final int lockedSectionCount;
  final String ctaLabel;
  final String rewardLine;
  final String title;
  final List<String> lockedSectionLabels;
}

/// Readiness of a single astrology system on Home.
enum HomeAstrologySystemState {
  hasResult,
  missingChart,
  missingProfile,
}

/// Single astrology system entry in the hub.
class HomeAstrologySystemItemData {
  const HomeAstrologySystemItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.state,
    required this.statusMessage,
    required this.actionLabel,
  });

  final String id;
  final String title;
  final String description;
  final HomeAstrologySystemState state;
  final String statusMessage;
  final String actionLabel;

  bool get isAvailable => state == HomeAstrologySystemState.hasResult;
}

/// Astrology-first hub — systems and cross-system fusion.
class HomeAstrologyHubSectionData {
  const HomeAstrologyHubSectionData({
    required this.systems,
    required this.fusionState,
    required this.fusionTitle,
    required this.fusionDescription,
    required this.fusionStatusMessage,
    required this.fusionActionLabel,
  });

  final List<HomeAstrologySystemItemData> systems;
  final HomeAstrologySystemState fusionState;
  final String fusionTitle;
  final String fusionDescription;
  final String fusionStatusMessage;
  final String fusionActionLabel;

  bool get fusionAvailable => fusionState == HomeAstrologySystemState.hasResult;
}

/// Full Home V3.8 emotional product bundle.
class HomeScreenV3Data {

  const HomeScreenV3Data({

    required this.hero,

    required this.signature,

    required this.insight,

    required this.profile,

    required this.psychologyTests,

    required this.astrologyHub,

    required this.more,

    required this.completion,

    required this.showRecoveryBanner,

    required this.narrativePreview,

  });



  static HomeScreenV3Data empty() {

    return HomeScreenV3Data(

      hero: const HomeHeroSectionData(

        isAvailable: false,

        identity: '',

        supportingReflection: '',

        emptyHint: '',

        canOpenFullResult: false,

      ),

      signature: const HomeKnowMeSignatureSectionData(

        themeLabels: [],

        emptyHint: '',

        isVisible: false,

      ),

      insight: const HomeKnowMeInsightSectionData(

        cards: [],

        emptyHint: '',

        canOpenFullInsight: false,

      ),

      profile: const HomeCompactProfileSectionData(

        name: '',

        birthDate: '',

        birthTime: '',

        birthPlace: '',

        completenessLabel: '',

        completenessRatio: 0,

        isEmpty: true,

      ),

      psychologyTests: const HomePsychologyTestsSectionData(tests: []),

      astrologyHub: const HomeAstrologyHubSectionData(
        systems: [],
        fusionState: HomeAstrologySystemState.missingProfile,
        fusionTitle: '',
        fusionDescription: '',
        fusionStatusMessage: '',
        fusionActionLabel: '',
      ),

      more: const HomeMoreSectionData(items: []),

      completion: HomeProfileCompletion.fromCoverage(
        astrologyComplete: false,
        coverage: null,
        narrativeUnlocked: false,
      ),

      showRecoveryBanner: false,

      narrativePreview: const HomeNarrativePreviewSectionData(
        isVisible: false,
        previewText: '',
        lockedSectionCount: 0,
        ctaLabel: '',
        rewardLine: '',
        title: '',
        lockedSectionLabels: [],
      ),

    );

  }



  final HomeHeroSectionData hero;

  final HomeKnowMeSignatureSectionData signature;

  final HomeKnowMeInsightSectionData insight;

  final HomeCompactProfileSectionData profile;

  final HomePsychologyTestsSectionData psychologyTests;

  final HomeAstrologyHubSectionData astrologyHub;

  final HomeMoreSectionData more;

  final HomeProfileCompletion completion;

  final bool showRecoveryBanner;

  final HomeNarrativePreviewSectionData narrativePreview;

}



/// Navigation callbacks for Home V3.

class HomeScreenV3Callbacks {

  const HomeScreenV3Callbacks({

    required this.onViewAstrologyResult,

    required this.onViewFullInsight,

    required this.onEditProfile,

    required this.onPsychologyTest,

    required this.onMoreItem,

    required this.onUnlockDeepProfile,

    required this.onContinueDiscovering,

    this.narrativeLoading = false,

    required this.onOpenAstrologySystem,

    required this.onOpenCrossSystemFusion,

  });



  final void Function() onViewAstrologyResult;

  final void Function() onViewFullInsight;

  final void Function() onEditProfile;

  final void Function(HomePsychologyTestItemData test) onPsychologyTest;

  final void Function(HomeMoreItemData item) onMoreItem;

  final void Function() onUnlockDeepProfile;

  final void Function() onContinueDiscovering;

  final bool narrativeLoading;

  final void Function(String systemId) onOpenAstrologySystem;

  final void Function() onOpenCrossSystemFusion;
}


