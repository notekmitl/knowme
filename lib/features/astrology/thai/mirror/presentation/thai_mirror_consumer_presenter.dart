import 'package:flutter/material.dart' show IconData, Icons;



import '../models/thai_mirror_result.dart';

import '../models/thai_mirror_section.dart';

import '../models/thai_mirror_section_id.dart';

import '../models/thai_mirror_theme_ref.dart';

import 'copy/thai_mirror_consumer_copy.dart';
import 'copy/thai_mirror_content_context.dart';
import 'copy/thai_mirror_theme_phrases.dart';

import 'models/thai_mirror_consumer_view_state.dart';



/// Maps [ThaiMirrorResult] to consumer-facing [ThaiMirrorConsumerViewState].

///

/// All user-visible copy is generated here — never passes engine narrative through.

abstract final class ThaiMirrorConsumerPresenter {

  static const _maxCards = 3;



  static ThaiMirrorConsumerViewState present(ThaiMirrorResult result) {

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

    return ThaiMirrorConsumerViewState(
      hero: _buildHero(ctx),
      strengths: _buildStrengths(result, allThemeIds, ctx),
      cautions: _buildCautions(result, allThemeIds, ctx),
      advice: _buildAdvice(result, ctx),
      lifeDashboard: _buildLifeDashboard(result, ctx),

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



  static ThaiMirrorConsumerHeroState _buildHero(ThaiMirrorContentContext ctx) {
    final themeIds =
        ctx.allThemeIds.isNotEmpty ? ctx.allThemeIds : ctx.topThemeIds;

    return ThaiMirrorConsumerHeroState(
      headline: ThaiMirrorConsumerCopy.buildHeadline(
        themeIds,
        profileSeed: ctx.profileSeed,
        lagnaKey: ctx.lagnaKey,
        ctx: ctx,
      ),
      summary: ThaiMirrorConsumerCopy.buildHeroSummary(
        themeIds,
        profileSeed: ctx.profileSeed,
        ctx: ctx,
      ),
      tags: ctx.topThemeIds
          .take(5)
          .map(ThaiMirrorConsumerCopy.tagLabel)
          .toList(growable: false),
    );
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
    final topThemeIds = ctx.topThemeIds;
    final allThemeIds = ctx.allThemeIds;
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
      ),
      _dashboardItem(
        label: 'การเงิน',
        priorityThemeIds: moneyIds.isNotEmpty ? moneyIds : topThemeIds,
        ctx: ctx,
        aspect: 'money',
        profileSeed: profileSeed + 1,
        usedCurrentStates: usedCurrentStates,
      ),
      _dashboardItem(
        label: 'ความรัก',
        priorityThemeIds: loveIds.isNotEmpty ? loveIds : topThemeIds,
        ctx: ctx,
        aspect: 'love',
        profileSeed: profileSeed + 2,
        usedCurrentStates: usedCurrentStates,
      ),
      _dashboardItem(
        label: 'สุขภาพ',
        priorityThemeIds: healthIds.isNotEmpty ? healthIds : topThemeIds,
        ctx: ctx,
        aspect: 'health',
        profileSeed: profileSeed + 3,
        usedCurrentStates: usedCurrentStates,
      ),
      _dashboardItem(
        label: 'โชคและโอกาส',
        priorityThemeIds: luckIds.isNotEmpty ? luckIds : topThemeIds,
        ctx: ctx,
        aspect: 'luck',
        profileSeed: profileSeed + 4,
        usedCurrentStates: usedCurrentStates,
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
  }) {
    final parts = ThaiMirrorConsumerCopy.lifeAspectDashboardParts(
      aspect: aspect,
      priorityThemeIds: priorityThemeIds,
      allThemeIds: ctx.allThemeIds,
      profileSeed: profileSeed,
      usedCurrentStates: usedCurrentStates,
      lagnaKey: ctx.lagnaKey,
      growthPathIds: ctx.growthPathIds,
    );

    usedCurrentStates.add(parts.currentState);

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
          body: ThaiMirrorConsumerCopy.truncateInsightBody(variant.body),
          accent: ThaiMirrorInsightAccent.strength,
          icon: icons[cards.length % icons.length],
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
            body: ThaiMirrorConsumerCopy.truncateInsightBody(variant.body),
            accent: ThaiMirrorInsightAccent.strength,
            icon: icons[cards.length % icons.length],
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
          body: ThaiMirrorConsumerCopy.truncateInsightBody(body),
          accent: ThaiMirrorInsightAccent.caution,
          icon: icons[cards.length % icons.length],
        ),
      );
    }

    if (cards.length < _maxCards) {
      for (final themeId in allThemeIds) {
        if (cards.length >= _maxCards) break;
        final phrase = ThaiMirrorThemePhrases.phrase(themeId);
        final title = 'ระวัง${phrase.tag}เกินไป';
        final body = 'เมื่อ${phrase.headlinePart} ลองสังเกตผลกระทบก่อนตัดสินใจ';
        if (!seenTitles.add(title)) continue;
        cards.add(
          ThaiMirrorInsightCardState(
            title: title,
            body: ThaiMirrorConsumerCopy.truncateInsightBody(body),
            accent: ThaiMirrorInsightAccent.caution,
            icon: icons[cards.length % icons.length],
          ),
        );
      }
    }

    return cards;
  }
}


