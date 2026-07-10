import 'package:flutter/material.dart' show Icons;



import '../models/thai_mirror_result.dart';

import '../models/thai_mirror_section.dart';

import '../models/thai_mirror_section_id.dart';

import '../models/thai_mirror_theme_ref.dart';

import 'copy/thai_mirror_consumer_copy.dart';
import 'copy/thai_mirror_content_context.dart';
import 'copy/thai_mirror_report_copy.dart';
import 'copy/thai_mirror_theme_phrases.dart';

import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';

import 'models/thai_mirror_consumer_view_state.dart';

import 'prediction/prediction_composer.dart';
import 'prediction/prediction_section_model.dart';

import 'timeline/timeline_presenter.dart';



/// Maps [ThaiMirrorResult] to consumer-facing [ThaiMirrorConsumerViewState].

///

/// All user-visible copy is generated here — never passes engine narrative through.

abstract final class ThaiMirrorConsumerPresenter {

  static const _maxCards = 3;

  /// [lifePeriods] (when available) powers the V8 Life Timeline. It is engine
  /// *evidence* produced by [LifePeriodEngine] from the canonical birth profile
  /// upstream — the presenter never receives a raw birth date, so birth-profile
  /// resolution is never duplicated here.
  static ThaiMirrorConsumerViewState present(
    ThaiMirrorResult result, {
    LifeTimeline? lifePeriods,
  }) {

    final topThemeIds =

        result.topThemes.map((theme) => theme.themeId).toList(growable: false);

    final allThemeIds = _allThemeIds(result);

    final lagnaKey = result.profileContext.lagnaKey;
    final themeScores = _themeScores(result);
    final profileSeed = _profileSeed(
      topThemeIds,
      allThemeIds,
      lagnaKey: lagnaKey,
      themeScores: themeScores,
    );
    final growthPathIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.growthPath),
    );
    final ctx = ThaiMirrorConsumerCopy.buildContext(
      allThemeIds: allThemeIds,
      topThemeIds: topThemeIds,
      profileSeed: profileSeed,
      lagnaKey: lagnaKey,
      growthPathIds: growthPathIds,
    );

    // Up to 3 distinct strongest-pattern tags so the timeline can cite a
    // *different* strength per period instead of echoing the same word in
    // every card.
    final topThemeTags = <String>[];
    for (final id in topThemeIds.isNotEmpty ? topThemeIds : allThemeIds) {
      final tag = ThaiMirrorThemePhrases.phrase(id).tag.trim();
      if (tag.isNotEmpty && !topThemeTags.contains(tag)) {
        topThemeTags.add(tag);
      }
      if (topThemeTags.length >= 3) break;
    }
    final lifeTimeline = TimelinePresenter.build(
      lifePeriods: lifePeriods,
      lagnaLordKey: result.profileContext.lagnaLordKey,
      orderedThemeIds: allThemeIds.isNotEmpty ? allThemeIds : topThemeIds,
      topThemeTags: topThemeTags,
      profileSeed: profileSeed,
    );

    final futurePrediction = _buildFuturePrediction(
      lifePeriods: lifePeriods,
      lagnaLordKey: result.profileContext.lagnaLordKey,
      profileSeed: profileSeed,
    );

    return ThaiMirrorConsumerViewState(
      lifeTimeline: lifeTimeline,
      futurePrediction: futurePrediction,
      hero: _buildHero(ctx),
      strengths: _buildStrengths(result, allThemeIds, ctx),
      cautions: _buildCautions(result, allThemeIds, ctx),
      advice: _buildAdvice(result, ctx),
      lifeDashboard: _buildLifeDashboard(result, ctx),

      narrativeSections: ThaiMirrorReportCopy.buildNarrativeSections(
        ctx: ctx,
        aspectThemeIds: _aspectThemeIds(result),
      ),

      signatureInsight: ThaiMirrorReportCopy.buildSignatureInsight(
        ctx: ctx,
        coreThemeIds: ctx.coreThemeIds,
      ),

      reflectionSummary: ThaiMirrorReportCopy.buildReflectionSummary(
        ctx: ctx,
        coreThemeIds: ctx.coreThemeIds,
      ),

      closingMessage: ThaiMirrorReportCopy.buildClosingMessage(
        ctx: ctx,
        coreThemeIds: ctx.coreThemeIds,
      ),

      sourceTransparency: _buildSourceTransparency(result),

      birthDataConfidence: ThaiMirrorConsumerCopy.birthDataConfidence(

        hasBirthTime: result.profileContext.hasBirthTime,

      ),

      secretTip: ThaiMirrorConsumerCopy.buildSecretTip(

        _themeIdsFromSection(

          result.sectionById(ThaiMirrorSectionId.growthPath),

        ),

      ),

      disclaimers: ThaiMirrorConsumerCopy.consumerDisclaimers,

    );

  }



  /// V10.5 — builds the Future Prediction section from the same life-period
  /// *evidence* the timeline uses. The V10 prediction engine is deterministic
  /// and copy-free; [PredictionComposer] turns its evidence into consumer copy
  /// here (copy boundary preserved). Returns null when no timeline evidence is
  /// available (e.g. some preview/QA states).
  static PredictionSectionModel? _buildFuturePrediction({
    required LifeTimeline? lifePeriods,
    required String? lagnaLordKey,
    required int profileSeed,
  }) {
    if (lifePeriods == null) return null;
    final intelligence = LifeTimelineIntelligenceEngine.fromTimeline(
      lifePeriods,
      lagnaLord: LifePlanets.fromLagnaLordKey(lagnaLordKey),
    );
    final prediction = PredictionIntelligenceEngine.fromIntelligence(
      intelligence,
    );
    return PredictionComposer.compose(
      intelligence: prediction,
      seed: profileSeed,
    );
  }

  static ThaiMirrorConsumerHeroState _buildHero(ThaiMirrorContentContext ctx) {
    final themeIds =
        ctx.allThemeIds.isNotEmpty ? ctx.allThemeIds : ctx.topThemeIds;

    return ThaiMirrorConsumerHeroState(
      headline: ThaiMirrorReportCopy.buildEmotionalHeadline(
        ctx: ctx,
        coreThemeIds: themeIds,
      ),
      summary: ThaiMirrorReportCopy.buildHeroSummary(
        ctx: ctx,
        coreThemeIds: ctx.coreThemeIds,
      ),
      tags: ctx.topThemeIds
          .take(5)
          .map(ThaiMirrorConsumerCopy.tagLabel)
          .toList(growable: false),
    );
  }

  /// Maps each long-form report aspect to a priority list of theme ids drawn
  /// from the relevant result sections. Presentation-only grouping — no engine
  /// data is altered.
  static Map<String, List<String>> _aspectThemeIds(ThaiMirrorResult result) {
    List<String> from(ThaiMirrorSectionId id) =>
        _themeIdsFromSection(result.sectionById(id));

    final core = from(ThaiMirrorSectionId.coreSelf);
    final thinking = from(ThaiMirrorSectionId.thinkingStyle);
    final emotional = from(ThaiMirrorSectionId.emotionalWorld);
    final relationships = from(ThaiMirrorSectionId.relationships);
    final work = from(ThaiMirrorSectionId.workAndAmbition);
    final growthPath = from(ThaiMirrorSectionId.growthPath);
    final growthAreas = from(ThaiMirrorSectionId.growthAreas);
    final top = result.topThemes.map((t) => t.themeId).toList();

    return {
      'work': [...work, ...core],
      'money': [...core, ...work],
      'love': [...relationships, ...emotional],
      'family': [...relationships, ...core],
      'social': [...relationships, ...thinking],
      'health': [...emotional, ...core],
      'rhythm': [...growthPath, ...top],
      'pressure': [...emotional, ...core],
      'compatibility': [...relationships, ...emotional],
      'growth': [...growthPath, ...growthAreas],
    };
  }



  static ThaiMirrorInsightSectionState _buildStrengths(
    ThaiMirrorResult result,
    List<String> allThemeIds,
    ThaiMirrorContentContext ctx,
  ) {

    final pool = _deriveStrengthThemeIds(result, allThemeIds);
    final growthPathIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.growthPath),
    ).toSet();
    final growthAreaIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.growthAreas),
    ).toSet();
    final excluded = {...growthPathIds, ...growthAreaIds};

    final extended = pool.where((id) => !excluded.contains(id)).toList();
    for (final id in allThemeIds) {
      if (excluded.contains(id) || extended.contains(id)) continue;
      extended.add(id);
    }

    return ThaiMirrorInsightSectionState(
      title: ThaiMirrorConsumerCopy.strengthsSectionTitle,
      sectionIcon: Icons.auto_awesome_rounded,
      cards: _strengthCards(_rotateThemeIds(extended, ctx.profileSeed * 41), ctx),
    );

  }



  static ThaiMirrorInsightSectionState _buildCautions(
    ThaiMirrorResult result,
    List<String> allThemeIds,
    ThaiMirrorContentContext ctx,
  ) {
    final growthAreaIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.growthAreas),
    );

    return ThaiMirrorInsightSectionState(
      title: ThaiMirrorConsumerCopy.cautionsSectionTitle,
      sectionIcon: Icons.terrain_rounded,
      cards: _cautionCards(growthAreaIds, allThemeIds, ctx),
    );
  }



  static ThaiMirrorAdviceState _buildAdvice(
    ThaiMirrorResult result,
    ThaiMirrorContentContext ctx,
  ) {
    return ThaiMirrorAdviceState(
      title: ThaiMirrorAdviceState.defaultTitle,
      body: ThaiMirrorConsumerCopy.buildAdviceBody(
        ctx.growthPathIds,
        allThemeIds: ctx.allThemeIds,
        topThemeIds: ctx.topThemeIds,
        profileSeed: ctx.profileSeed,
        lagnaKey: ctx.lagnaKey,
      ),
    );
  }



  static List<ThaiMirrorLifeDashboardItemState> _buildLifeDashboard(
    ThaiMirrorResult result,
    ThaiMirrorContentContext ctx,
  ) {
    final usedCurrentStates = <String>{};
    final usedThemeIds = <String>{};
    final usedActions = <String>{};
    final topThemeIds = ctx.topThemeIds;
    final profileSeed = ctx.profileSeed;

    final workIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.workAndAmbition),
    );
    final loveIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.relationships),
    );
    final healthIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.emotionalWorld),
    );
    final luckIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.growthPath),
    );
    final moneyIds = [
      ..._themeIdsFromSection(result.sectionById(ThaiMirrorSectionId.coreSelf)),
      ..._themeIdsFromSection(
        result.sectionById(ThaiMirrorSectionId.workAndAmbition),
      ),
    ];

    return [
      _dashboardItem(
        label: 'การงาน',
        priorityThemeIds: workIds.isNotEmpty ? workIds : topThemeIds,
        ctx: ctx,
        aspect: 'work',
        profileSeed: profileSeed,
        usedCurrentStates: usedCurrentStates,
        usedThemeIds: usedThemeIds,
        usedActions: usedActions,
      ),
      _dashboardItem(
        label: 'การเงิน',
        priorityThemeIds: moneyIds.isNotEmpty ? moneyIds : topThemeIds,
        ctx: ctx,
        aspect: 'money',
        profileSeed: profileSeed + 1,
        usedCurrentStates: usedCurrentStates,
        usedThemeIds: usedThemeIds,
        usedActions: usedActions,
      ),
      _dashboardItem(
        label: 'ความรัก',
        priorityThemeIds: loveIds.isNotEmpty ? loveIds : topThemeIds,
        ctx: ctx,
        aspect: 'love',
        profileSeed: profileSeed + 2,
        usedCurrentStates: usedCurrentStates,
        usedThemeIds: usedThemeIds,
        usedActions: usedActions,
      ),
      _dashboardItem(
        label: 'สุขภาพ',
        priorityThemeIds: healthIds.isNotEmpty ? healthIds : topThemeIds,
        ctx: ctx,
        aspect: 'health',
        profileSeed: profileSeed + 3,
        usedCurrentStates: usedCurrentStates,
        usedThemeIds: usedThemeIds,
        usedActions: usedActions,
      ),
      _dashboardItem(
        label: 'โชคและโอกาส',
        priorityThemeIds: luckIds.isNotEmpty ? luckIds : topThemeIds,
        ctx: ctx,
        aspect: 'luck',
        profileSeed: profileSeed + 4,
        usedCurrentStates: usedCurrentStates,
        usedThemeIds: usedThemeIds,
        usedActions: usedActions,
      ),
    ];
  }

  static ThaiMirrorLifeDashboardItemState _dashboardItem({
    required String label,
    required List<String> priorityThemeIds,
    required ThaiMirrorContentContext ctx,
    required String aspect,
    required int profileSeed,
    required Set<String> usedCurrentStates,
    required Set<String> usedThemeIds,
    required Set<String> usedActions,
  }) {
    final parts = ThaiMirrorConsumerCopy.lifeAspectDashboardParts(
      aspect: aspect,
      priorityThemeIds: priorityThemeIds,
      allThemeIds: ctx.allThemeIds,
      profileSeed: profileSeed,
      usedCurrentStates: usedCurrentStates,
      usedThemeIds: usedThemeIds,
      usedActions: usedActions,
      lagnaKey: ctx.lagnaKey,
      growthPathIds: ctx.growthPathIds,
    );

    usedCurrentStates.add(parts.currentState);
    usedThemeIds.add(parts.themeId);
    usedActions.add(parts.suggestedAction);

    return ThaiMirrorLifeDashboardItemState(
      label: label,
      currentState: parts.currentState,
      whyItAppears: parts.whyItAppears,
      suggestedAction: parts.suggestedAction,
      status: _lifeStatus(priorityThemeIds.length),
    );
  }



  static int _profileSeed(
    List<String> topThemeIds,
    List<String> allThemeIds, {
    String? lagnaKey,
    List<double>? themeScores,
  }) {
    var seed = 0;
    for (var i = 0; i < allThemeIds.length; i++) {
      seed ^= allThemeIds[i].hashCode * (i + 17);
    }
    if (themeScores != null) {
      for (var i = 0; i < themeScores.length; i++) {
        seed ^= (themeScores[i] * 10000).round() * (i + 1);
      }
    }
    if (lagnaKey != null && lagnaKey.isNotEmpty) {
      seed ^= lagnaKey.hashCode * 29;
    }
    if (seed == 0 && topThemeIds.isNotEmpty) {
      seed = topThemeIds.first.hashCode;
    }
    return seed;
  }

  static List<double> _themeScores(ThaiMirrorResult result) {
    final scores = <double>[];
    for (final sectionId in ThaiMirrorSectionId.values) {
      final section = result.sectionById(sectionId);
      if (section == null) continue;
      for (final theme in section.supportingThemes) {
        scores.add(theme.score);
      }
    }
    for (final theme in result.topThemes) {
      scores.add(theme.score);
    }
    return scores;
  }

  static List<String> _rotateThemeIds(List<String> ids, int seed) {
    if (ids.isEmpty) return ids;
    final start = seed.abs() % ids.length;
    return [for (var i = 0; i < ids.length; i++) ids[(start + i) % ids.length]];
  }



  static List<String> _allThemeIds(ThaiMirrorResult result) {

    final seen = <String>{};

    final ordered = <String>[];



    void addFrom(Iterable<String> ids) {

      for (final id in ids) {

        if (seen.add(id)) ordered.add(id);

      }

    }



    addFrom(result.topThemes.map((theme) => theme.themeId));

    for (final sectionId in ThaiMirrorSectionId.values) {

      addFrom(_themeIdsFromSection(result.sectionById(sectionId)));

    }



    return ordered;

  }



  static List<String> _deriveStrengthThemeIds(

    ThaiMirrorResult result,

    List<String> allThemeIds,

  ) {

    final seen = <String>{};

    final ordered = <String>[];



    void addFrom(List<String> ids) {

      for (final id in ids) {

        if (seen.add(id)) ordered.add(id);

      }

    }



    addFrom(_themeIdsFromSection(

      result.sectionById(ThaiMirrorSectionId.strengths),

    ));

    addFrom(result.topThemes.map((theme) => theme.themeId).toList());

    final growthPathIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.growthPath),
    ).toSet();
    ordered.removeWhere(growthPathIds.contains);

    addFrom(_themeIdsFromSection(

      result.sectionById(ThaiMirrorSectionId.workAndAmbition),

    ));

    addFrom(_themeIdsFromSection(

      result.sectionById(ThaiMirrorSectionId.relationships),

    ));

    addFrom(_themeIdsFromSection(

      result.sectionById(ThaiMirrorSectionId.coreSelf),

    ));

    addFrom(_themeIdsFromSection(

      result.sectionById(ThaiMirrorSectionId.thinkingStyle),

    ));

    addFrom(_themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.emotionalWorld),
    ));

    final growthAreaIds = _themeIdsFromSection(
      result.sectionById(ThaiMirrorSectionId.growthAreas),
    ).toSet();
    ordered.removeWhere(growthAreaIds.contains);

    return ordered;

  }



  static ThaiMirrorLifeStatus _lifeStatus(int themeCount) {

    return switch (themeCount) {

      >= 3 => ThaiMirrorLifeStatus.veryGood,

      2 => ThaiMirrorLifeStatus.bright,

      1 => ThaiMirrorLifeStatus.good,

      _ => ThaiMirrorLifeStatus.moderate,

    };

  }



  static ThaiMirrorSourceTransparencyState _buildSourceTransparency(

    ThaiMirrorResult result,

  ) {

    final hasBirthTime = result.profileContext.hasBirthTime;



    return ThaiMirrorSourceTransparencyState(

      dataUsed: hasBirthTime

          ? ThaiMirrorConsumerCopy.dataUsedWithBirthTime

          : ThaiMirrorConsumerCopy.dataUsedWithoutBirthTime,

      calculation: ThaiMirrorConsumerCopy.calculationExplanation,

      meaning: ThaiMirrorConsumerCopy.resultsMeaning,

    );

  }



  static List<String> _themeIdsFromSection(ThaiMirrorSection? section) {

    if (section == null) return const [];

    return section.supportingThemes

        .map((ThaiMirrorThemeRef theme) => theme.themeId)

        .toList(growable: false);

  }



  static List<ThaiMirrorInsightCardState> _strengthCards(
    List<String> themeIds,
    ThaiMirrorContentContext ctx,
  ) {
    final cards = <ThaiMirrorInsightCardState>[];
    const icons = [
      Icons.psychology_rounded,
      Icons.verified_user_rounded,
      Icons.favorite_rounded,
    ];

    final seenTitles = <String>{};
    final picked =
        _pickSpacedStrengthThemes(themeIds, ctx.profileSeed, _maxCards);

    for (final themeId in picked) {
      if (cards.length >= _maxCards) break;

      final variant = ThaiMirrorConsumerCopy.strengthForTheme(
        themeId: themeId,
        ctx: ctx,
        cardIndex: cards.length,
      );

      if (!seenTitles.add(variant.title)) continue;

      cards.add(
        ThaiMirrorInsightCardState(
          title: variant.title,
          body: variant.body,
          accent: ThaiMirrorInsightAccent.strength,
          icon: icons[cards.length % icons.length],
          expandedBody: ThaiMirrorReportCopy.buildExpandedStrength(
            themeId: themeId,
            ctx: ctx,
          ),
        ),
      );
    }

    if (cards.length < _maxCards) {
      for (final themeId in themeIds) {
        if (cards.length >= _maxCards) break;
        final variant = ThaiMirrorConsumerCopy.strengthForTheme(
          themeId: themeId,
          ctx: ctx,
          cardIndex: cards.length,
        );
        if (!seenTitles.add(variant.title)) continue;
        cards.add(
          ThaiMirrorInsightCardState(
            title: variant.title,
            body: variant.body,
            accent: ThaiMirrorInsightAccent.strength,
            icon: icons[cards.length % icons.length],
            expandedBody: ThaiMirrorReportCopy.buildExpandedStrength(
              themeId: themeId,
              ctx: ctx,
            ),
          ),
        );
      }
    }

    return cards;
  }

  static List<String> _pickSpacedStrengthThemes(
    List<String> themeIds,
    int seed,
    int count,
  ) {
    if (themeIds.length <= count) return themeIds;
    final picks = <String>[];
    final step = 3 + (seed.abs() % 4);
    var index = (seed.abs() * 7 + 3) % themeIds.length;
    var attempts = 0;
    while (picks.length < count && attempts < themeIds.length * 2) {
      final themeId = themeIds[index];
      if (!picks.contains(themeId)) picks.add(themeId);
      index = (index + step) % themeIds.length;
      attempts++;
    }
    if (picks.length < count) {
      for (final themeId in themeIds) {
        if (picks.length >= count) break;
        if (!picks.contains(themeId)) picks.add(themeId);
      }
    }
    return picks;
  }

  static List<ThaiMirrorInsightCardState> _cautionCards(
    List<String> themeIds,
    List<String> allThemeIds,
    ThaiMirrorContentContext ctx,
  ) {
    final cards = <ThaiMirrorInsightCardState>[];
    const icons = [
      Icons.warning_amber_rounded,
      Icons.info_outline_rounded,
      Icons.schedule_rounded,
    ];

    final seenTitles = <String>{};
    final pool = <String>[
      ...themeIds,
      ..._rotateThemeIds(allThemeIds, ctx.profileSeed + 19),
    ];

    for (final themeId in pool) {
      if (cards.length >= _maxCards) break;

      final title = ThaiMirrorConsumerCopy.cautionTitle(themeId);
      final body = ThaiMirrorConsumerCopy.cautionBody(themeId);
      if (title == null || body == null) continue;
      if (!seenTitles.add(title)) continue;

      cards.add(
        ThaiMirrorInsightCardState(
          title: title,
          body: body,
          accent: ThaiMirrorInsightAccent.caution,
          icon: icons[cards.length % icons.length],
        ),
      );
    }

    if (cards.length < _maxCards) {
      for (final themeId in allThemeIds) {
        if (cards.length >= _maxCards) break;
        final phrase = ThaiMirrorThemePhrases.phrase(themeId);
        // Vary the fallback caution so two generated cards never share the same
        // "ระวัง…เกินไป / ลองสังเกตผลกระทบ" template.
        final v = cards.length;
        final titles = <String>[
          'จุด${phrase.tag}อาจกลายเป็นดาบสองคม',
          'ระวัง${phrase.tag}จนเผลอกดดันตัวเอง',
          'เมื่อ${phrase.tag}มากไปในบางจังหวะ',
        ];
        final bodies = <String>[
          'เวลา${phrase.headlinePart} ลองถอยมามองภาพรวมสักนิดก่อนทุ่มสุดตัว',
          'ข้อดีข้อนี้จะยิ่งดี ถ้าคุณรู้ว่าเมื่อไหร่ควรพอ',
          'ลองสังเกตว่ามันเริ่มกินพลังคุณตอนไหน แล้วอนุญาตให้ตัวเองผ่อนได้',
        ];
        final title = titles[v % titles.length];
        final body = bodies[v % bodies.length];
        if (!seenTitles.add(title)) continue;
        cards.add(
          ThaiMirrorInsightCardState(
            title: title,
            body: body,
            accent: ThaiMirrorInsightAccent.caution,
            icon: icons[cards.length % icons.length],
          ),
        );
      }
    }

    return cards;
  }
}


