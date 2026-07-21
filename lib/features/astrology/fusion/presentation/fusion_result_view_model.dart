import 'package:flutter/material.dart';

import '../domain/entities/fusion_signal.dart';

import 'fusion_result_v21_copy.dart';

/// Presentation-only view models for Astrology Fusion Result UI.
class FusionResultViewModel {
  const FusionResultViewModel({
    required this.hero,
    this.lifeChapter,
    required this.lensAgreements,
    this.consensusNarrative,
    this.lifePattern,
    required this.strengths,
    this.lifeTest,
    this.lifeLesson,
    required this.growthPaths,
    this.futureDirection,
    this.surprisingInsight,
    required this.knowMeMoment,
    this.finalMessage,
  });

  final FusionHeroViewModel hero;
  final FusionLifeChapterViewModel? lifeChapter;
  final List<FusionLensAgreementViewModel> lensAgreements;
  final FusionConsensusNarrativeViewModel? consensusNarrative;
  final FusionLifePatternViewModel? lifePattern;
  final List<FusionStrengthViewModel> strengths;
  final FusionLifeTestViewModel? lifeTest;
  final FusionLifeLessonViewModel? lifeLesson;
  final List<FusionGrowthPathViewModel> growthPaths;
  final FusionDirectionViewModel? futureDirection;
  final FusionSurprisingInsightViewModel? surprisingInsight;
  final FusionKnowMeMomentViewModel knowMeMoment;
  final FusionFinalMessageViewModel? finalMessage;
}

class FusionLifeChapterViewModel {
  const FusionLifeChapterViewModel({
    required this.title,
    required this.chapterTitle,
    required this.body,
  });

  final String title;
  final String chapterTitle;
  final String body;
}

class FusionLifeTestViewModel {
  const FusionLifeTestViewModel({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class FusionDirectionViewModel {
  const FusionDirectionViewModel({
    required this.title,
    required this.directionALabel,
    required this.directionA,
    required this.directionBLabel,
    required this.directionB,
    required this.reflectionQuestionLabel,
    required this.reflectionQuestion,
  });

  final String title;
  final String directionALabel;
  final String directionA;
  final String directionBLabel;
  final String directionB;
  final String reflectionQuestionLabel;
  final String reflectionQuestion;
}

class FusionFinalMessageViewModel {
  const FusionFinalMessageViewModel({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}

class FusionSurprisingInsightViewModel {
  const FusionSurprisingInsightViewModel({
    required this.title,
    required this.headline,
    required this.body,
    required this.reflection,
  });

  final String title;
  final String headline;
  final String body;
  final String reflection;

  String get formattedBody => '$headline\n\n$body\n\n$reflection';
}

class FusionConsensusNarrativeViewModel {
  const FusionConsensusNarrativeViewModel({
    required this.sectionLabel,
    required this.lensNarratives,
    required this.themeConclusion,
  });

  final String sectionLabel;
  final List<FusionLensNarrativeViewModel> lensNarratives;
  final String themeConclusion;
}

class FusionLensNarrativeViewModel {
  const FusionLensNarrativeViewModel({
    required this.lensTitle,
    required this.narrative,
  });

  final String lensTitle;
  final String narrative;
}

class FusionLifePatternViewModel {
  const FusionLifePatternViewModel({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class FusionLifeLessonViewModel {
  const FusionLifeLessonViewModel({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class FusionKnowMeMomentViewModel {
  const FusionKnowMeMomentViewModel({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class FusionHeroViewModel {
  const FusionHeroViewModel({
    required this.label,
    required this.headline,
    required this.supportingReflection,
    required this.themeChips,
  });

  final String label;
  final String headline;
  final String supportingReflection;
  final List<FusionThemeChipViewModel> themeChips;
}

class FusionThemeChipViewModel {
  const FusionThemeChipViewModel({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

class FusionLensAgreementViewModel {
  const FusionLensAgreementViewModel({
    required this.lensId,
    required this.title,
    required this.meaning,
    required this.icon,
    required this.checkColor,
  });

  final String lensId;
  final String title;
  final String meaning;
  final IconData icon;
  final Color checkColor;
}

class FusionStrengthViewModel {
  const FusionStrengthViewModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.signalType,
  });

  final String title;
  final String description;
  final IconData icon;
  final FusionSignalType signalType;
}

class FusionGrowthPathViewModel {
  const FusionGrowthPathViewModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.visualStyle,
  });

  final String title;
  final String description;
  final IconData icon;
  final FusionGrowthVisualStyle visualStyle;
}

/// Closing reflection card fields for FusionFooterReflectionSection.
class FusionFooterReflectionViewModel {
  const FusionFooterReflectionViewModel({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

/// Future-possibility reflection fields for FusionFuturePossibilitySection.
class FusionFuturePossibilityViewModel {
  const FusionFuturePossibilityViewModel({
    required this.title,
    required this.opportunityLabel,
    required this.opportunity,
    required this.challengeLabel,
    required this.challenge,
    required this.futureQuestionLabel,
    required this.futureReflection,
  });

  final String title;
  final String opportunityLabel;
  final String opportunity;
  final String challengeLabel;
  final String challenge;
  final String futureQuestionLabel;
  final String futureReflection;
}
