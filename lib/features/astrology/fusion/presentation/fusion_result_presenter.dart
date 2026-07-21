import 'package:flutter/material.dart';

import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';
import '../engines/fusion_consensus_narrative_builder.dart';
import '../engines/fusion_contradiction_builder.dart';
import '../engines/fusion_direction_builder.dart';
import '../engines/fusion_final_message_builder.dart';
import '../engines/fusion_human_meaning_builder.dart';
import '../engines/fusion_life_chapter_builder.dart';
import '../engines/fusion_life_lesson_builder.dart';
import '../engines/fusion_life_pattern_builder.dart';
import '../engines/fusion_life_test_builder.dart';
import '../engines/fusion_surprising_insight_builder.dart';
import '../engines/fusion_wisdom_builder.dart';
import 'fusion_presentation_copy.dart';
import 'fusion_result_v21_copy.dart';
import 'fusion_result_v3_insight_copy.dart';
import 'fusion_result_v4_copy.dart';
import 'fusion_result_v5_copy.dart';
import 'fusion_result_v6_copy.dart';
import 'fusion_result_view_model.dart';

/// Maps fusion result data into premium presentation view models.
abstract final class FusionResultPresenter {
  static const _lensOrder = [
    'western_natal',
    'chinese_bazi',
    'thai_astrology',
  ];

  static FusionResultViewModel fromResult(AstrologyFusionResult result) {
    return FusionResultViewModel(
      hero: _hero(result),
      lifeChapter: _lifeChapter(result),
      lensAgreements: _lensAgreements(result),
      consensusNarrative: _consensusNarrative(result),
      lifePattern: _lifePattern(result),
      strengths: _strengths(result),
      lifeTest: _lifeTest(result),
      lifeLesson: _lifeLesson(result),
      growthPaths: _growthPaths(result),
      futureDirection: _futureDirection(result),
      surprisingInsight: _surprisingInsight(result),
      knowMeMoment: _knowMeMoment(result),
      finalMessage: _finalMessage(result),
    );
  }

  static FusionHeroViewModel _hero(AstrologyFusionResult result) {
    final primary = result.fusionInsight.primary;
    final headline = primary?.title.trim().isNotEmpty == true
        ? primary!.title.trim()
        : _shortHeadline(result.reflection.summary);

    final supporting = FusionHumanMeaningBuilder.buildHeroSupporting(result);

    return FusionHeroViewModel(
      label: 'ภาพรวมของคุณ',
      headline: headline,
      supportingReflection: supporting,
      themeChips: _themeChips(result),
    );
  }

  static List<FusionThemeChipViewModel> _themeChips(
    AstrologyFusionResult result,
  ) {
    final chips = <FusionThemeChipViewModel>[];
    final seen = <String>{};

    for (final themeId in result.topThemes) {
      final label = FusionPresentationCopy.themePhrase(themeId);
      if (label == themeId || seen.contains(label)) continue;
      seen.add(label);
      chips.add(
        FusionThemeChipViewModel(
          label: label,
          icon: _chipIconForTheme(themeId),
        ),
      );
      if (chips.length >= 3) break;
    }

    if (chips.length < 3) {
      for (final signal in _visibleSignals(result.signals)) {
        final label = FusionPresentationCopy.signalTitle(signal.type);
        if (seen.contains(label)) continue;
        seen.add(label);
        chips.add(
          FusionThemeChipViewModel(
            label: _shortChipLabel(label),
            icon: _iconForSignal(signal.type),
          ),
        );
        if (chips.length >= 3) break;
      }
    }

    return chips;
  }

  static List<FusionLensAgreementViewModel> _lensAgreements(
    AstrologyFusionResult result,
  ) {
    final byId = {
      for (final origin in result.lensOrigins) origin.lensId: origin,
    };

    return _lensOrder.map((lensId) {
      final origin = byId[lensId];
      final rawMeaning = origin?.summary ??
          _lensFallbackMeaning(lensId, result.signals);
      final meaning = FusionResultV21Copy.enrichedAgreementMeaning(
        lensId,
        rawMeaning,
      );
      return FusionLensAgreementViewModel(
        lensId: lensId,
        title: FusionPresentationCopy.lensTitle(lensId),
        meaning: meaning,
        icon: _iconForLens(lensId),
        checkColor: _checkColorForLens(lensId),
      );
    }).where((item) => item.meaning.isNotEmpty).toList();
  }

  static String _lensFallbackMeaning(
    String lensId,
    List<FusionSignal> signals,
  ) {
    for (final signal in _visibleSignals(signals)) {
      if (signal.supportingLenses.contains(lensId)) {
        return '';
      }
    }
    return '';
  }

  static FusionLifeChapterViewModel? _lifeChapter(AstrologyFusionResult result) {
    final centralTheme = _centralThemeLabel(result);
    final chapter = FusionLifeChapterBuilder.build(
      result,
      centralThemeLabel: centralTheme,
      alignedLensCount: result.lensOrigins.length,
    );
    if (chapter == null) return null;

    return FusionLifeChapterViewModel(
      title: FusionResultV6Copy.lifeChapterTitle,
      chapterTitle: chapter.chapterTitle,
      body: chapter.chapterNarrative,
    );
  }

  static FusionLifeTestViewModel? _lifeTest(AstrologyFusionResult result) {
    final test = FusionLifeTestBuilder.build(result);
    if (test == null) return null;

    return FusionLifeTestViewModel(
      title: FusionResultV6Copy.lifeTestTitle,
      body: test.body,
    );
  }

  static FusionDirectionViewModel? _futureDirection(
    AstrologyFusionResult result,
  ) {
    final direction = FusionDirectionBuilder.build(result);
    if (direction == null) return null;

    return FusionDirectionViewModel(
      title: FusionResultV6Copy.directionTitle,
      directionALabel: FusionResultV6Copy.directionALabel,
      directionA: direction.directionA,
      directionBLabel: FusionResultV6Copy.directionBLabel,
      directionB: direction.directionB,
      reflectionQuestionLabel: FusionResultV6Copy.directionQuestionLabel,
      reflectionQuestion: direction.reflectionQuestion,
    );
  }

  static FusionFinalMessageViewModel? _finalMessage(
    AstrologyFusionResult result,
  ) {
    final message = FusionFinalMessageBuilder.build(result);
    if (message == null) return null;

    return FusionFinalMessageViewModel(
      title: FusionResultV6Copy.finalMessageTitle,
      message: message.message,
    );
  }

  static List<FusionStrengthViewModel> _strengths(
    AstrologyFusionResult result,
  ) {
    return _visibleSignals(result.signals)
        .take(3)
        .map((signal) {
          final signalTitle = FusionPresentationCopy.signalTitle(signal.type);
          final insight = FusionResultV3InsightCopy.strengthForSignalKey(signalTitle);
          return FusionStrengthViewModel(
            title: insight.title,
            description: insight.description,
            icon: _iconForSignal(signal.type),
            signalType: signal.type,
          );
        })
        .toList();
  }

  static List<FusionGrowthPathViewModel> _growthPaths(
    AstrologyFusionResult result,
  ) {
    final paths = <FusionGrowthPathViewModel>[];
    final styles = [
      FusionGrowthVisualStyle.nightSky,
      FusionGrowthVisualStyle.nebulaFlow,
      FusionGrowthVisualStyle.moonReflection,
    ];
    final icons = [
      Icons.nightlight_round,
      Icons.theater_comedy_rounded,
      Icons.search_rounded,
    ];

    for (final opportunity in result.growthOpportunities) {
      final index = paths.length;
      paths.add(
        FusionGrowthPathViewModel(
          title: opportunity.title,
          description: opportunity.description,
          icon: icons[index % icons.length],
          visualStyle: styles[index % styles.length],
        ),
      );
      if (paths.length >= 3) return paths;
    }

    for (final tendency in result.futureTendencies) {
      final index = paths.length;
      paths.add(
        FusionGrowthPathViewModel(
          title: tendency.title,
          description: tendency.description,
          icon: icons[index % icons.length],
          visualStyle: styles[index % styles.length],
        ),
      );
      if (paths.length >= 3) break;
    }

    return paths;
  }

  static FusionConsensusNarrativeViewModel? _consensusNarrative(
    AstrologyFusionResult result,
  ) {
    final centralTheme = _centralThemeLabel(result);
    final narrative = FusionConsensusNarrativeBuilder.build(
      result,
      centralThemeLabel: centralTheme,
    );
    if (narrative == null) return null;

    return FusionConsensusNarrativeViewModel(
      sectionLabel: FusionResultV5Copy.consensusWhyLabel,
      lensNarratives: narrative.lensNarratives
          .map(
            (item) => FusionLensNarrativeViewModel(
              lensTitle: item.lensTitle,
              narrative: item.narrative,
            ),
          )
          .toList(),
      themeConclusion: narrative.themeConclusion,
    );
  }

  static FusionLifePatternViewModel? _lifePattern(
    AstrologyFusionResult result,
  ) {
    final pattern = FusionLifePatternBuilder.build(result);
    if (pattern == null) return null;

    return FusionLifePatternViewModel(
      title: FusionResultV5Copy.lifePatternTitle,
      body: pattern.formattedBody,
    );
  }

  static FusionLifeLessonViewModel? _lifeLesson(AstrologyFusionResult result) {
    final lesson = FusionLifeLessonBuilder.build(result);
    if (lesson == null) return null;

    return FusionLifeLessonViewModel(
      title: FusionResultV5Copy.lifeLessonTitle,
      body: lesson.body,
    );
  }

  static String _centralThemeLabel(AstrologyFusionResult result) {
    if (result.topThemes.isNotEmpty) {
      final phrase = FusionPresentationCopy.themePhrase(result.topThemes.first);
      if (phrase != result.topThemes.first) return phrase;
    }
    final signals = _visibleSignals(result.signals);
    if (signals.isNotEmpty) {
      return FusionPresentationCopy.signalTitle(signals.first.type);
    }
    return 'อิสระ';
  }

  static FusionSurprisingInsightViewModel? _surprisingInsight(
    AstrologyFusionResult result,
  ) {
    final insight = FusionSurprisingInsightBuilder.build(result);
    if (insight == null) return null;

    return FusionSurprisingInsightViewModel(
      title: FusionResultV4Copy.surprisingInsightTitle,
      headline: insight.headline,
      body: insight.body,
      reflection: insight.reflection,
    );
  }

  static FusionKnowMeMomentViewModel _knowMeMoment(
    AstrologyFusionResult result,
  ) {
    final contradiction = FusionContradictionBuilder.build(result);
    final wisdom = FusionWisdomBuilder.build(contradiction);
    final body = contradiction != null
        ? contradiction.formattedWithWisdom(wisdom)
        : FusionHumanMeaningBuilder.buildKnowMeMoment(result);

    return FusionKnowMeMomentViewModel(
      title: FusionResultV4Copy.contradictionTitle,
      body: body,
    );
  }

  static List<FusionSignal> _visibleSignals(List<FusionSignal> signals) {
    return signals
        .where(
          (signal) =>
              signal.supportLevel != FusionSupportLevel.low &&
              signal.type != FusionSignalType.transformation,
        )
        .toList();
  }

  static String _shortHeadline(String summary) {
    final trimmed = summary.trim();
    if (trimmed.isEmpty) return 'ภาพรวมของคุณกำลังค่อย ๆ ชัดขึ้น';
    final parts = trimmed.split(RegExp(r'(?<=[。．.!?])\s*'));
    return parts.first.trim();
  }

  static String _shortChipLabel(String label) {
    if (label.contains('และ')) {
      return label.split('และ').first.trim();
    }
    return label;
  }

  static IconData _iconForLens(String lensId) {
    return switch (lensId) {
      'western_natal' => Icons.explore_rounded,
      'chinese_bazi' => Icons.balance_rounded,
      'thai_astrology' => Icons.temple_buddhist_rounded,
      _ => Icons.auto_awesome_rounded,
    };
  }

  static Color _checkColorForLens(String lensId) {
    return switch (lensId) {
      'western_natal' => const Color(0xFF9B7BD4),
      'chinese_bazi' => const Color(0xFF5CB88A),
      'thai_astrology' => const Color(0xFF5B9BD4),
      _ => const Color(0xFFE8C547),
    };
  }

  static IconData _iconForSignal(FusionSignalType type) {
    return switch (type) {
      FusionSignalType.autonomy => Icons.flight_rounded,
      FusionSignalType.structure => Icons.grid_view_rounded,
      FusionSignalType.growth => Icons.trending_up_rounded,
      FusionSignalType.connection => Icons.favorite_rounded,
      FusionSignalType.adaptation => Icons.waves_rounded,
      FusionSignalType.expression => Icons.theater_comedy_rounded,
      FusionSignalType.reflection => Icons.search_rounded,
      FusionSignalType.leadership => Icons.flag_rounded,
      FusionSignalType.creativity => Icons.lightbulb_rounded,
      FusionSignalType.transformation => Icons.change_circle_rounded,
    };
  }

  static IconData _chipIconForTheme(String themeId) {
    return switch (themeId) {
      'independent' || 'autonomy' => Icons.flight_rounded,
      'expressive' || 'expression' => Icons.theater_comedy_rounded,
      'reflection' || 'analytical' || 'intuitive' => Icons.search_rounded,
      'growth' || 'growth_focused' => Icons.trending_up_rounded,
      'structured' || 'structure' => Icons.grid_view_rounded,
      _ => Icons.auto_awesome_rounded,
    };
  }
}
