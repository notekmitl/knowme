/// Thai Beta Narrative Quality V1.1 — curated block composer.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import 'thai_beta_narrative_context.dart';
import 'thai_beta_narrative_dedupe.dart';
import 'thai_beta_narrative_domain.dart';
import 'thai_beta_narrative_formatting.dart';
import 'thai_beta_narrative_forbidden.dart';
import 'thai_beta_narrative_hero.dart';
import 'thai_beta_narrative_specificity.dart';
import 'thai_beta_narrative_stable_hash.dart';
import 'thai_beta_narrative_trace.dart';

class ThaiBetaNarrativeResult {
  const ThaiBetaNarrativeResult({
    required this.view,
    required this.trace,
  });

  final ThaiMirrorConsumerViewState view;
  final ThaiBetaNarrativeTrace trace;
}

/// Deterministic narrative quality layer for Thai Beta screen + export parity.
abstract final class ThaiBetaNarrativeComposer {
  static ThaiBetaNarrativeResult compose(ThaiBetaAnalysis analysis) {
    final source = analysis.consumerViewState;
    if (source == null) {
      return ThaiBetaNarrativeResult(
        view: const ThaiMirrorConsumerViewState(
          hero: ThaiMirrorConsumerHeroState(
            headline: ThaiMirrorConsumerHeroState.fallbackHeadline,
            summary: ThaiMirrorConsumerHeroState.fallbackSummary,
            tags: [],
          ),
          strengths: ThaiMirrorInsightSectionState(title: '', cards: []),
          cautions: ThaiMirrorInsightSectionState(title: '', cards: []),
          advice: ThaiMirrorAdviceState(title: '', body: ''),
          lifeDashboard: [],
          narrativeSections: [],
          signatureInsight: ThaiMirrorSignatureInsightState(
            eyebrow: '',
            body: '',
            signature: '',
          ),
          reflectionSummary: ThaiMirrorReflectionSummaryState(
            title: '',
            intro: '',
            points: [],
          ),
          closingMessage: ThaiMirrorClosingMessageState(
            eyebrow: '',
            message: '',
            signature: '',
          ),
          sourceTransparency: ThaiMirrorSourceTransparencyState(
            dataUsed: '',
            calculation: '',
            meaning: '',
          ),
          birthDataConfidence: ThaiMirrorBirthDataConfidenceState(
            isComplete: false,
            title: '',
            body: '',
          ),
          secretTip: '',
          disclaimers: [],
        ),
        trace: const ThaiBetaNarrativeTrace(),
      );
    }

    final ctx = ThaiBetaNarrativeContext.fromAnalysis(analysis);
    final globalUsed = <String>{};
    final usedBlockIds = <String>{};
    var trace = const ThaiBetaNarrativeTrace();

    final cautionBody = source.cautions.cards.isNotEmpty
        ? source.cautions.cards.first.body
        : null;

    final heroResult = ThaiBetaNarrativeHero.compose(
      sourceHero: source.hero,
      orderedThemeIds: ctx.orderedThemeIds,
      profileSeed: ctx.profileSeed,
      hasBirthTime: ctx.hasBirthTime,
      cautionBody: cautionBody,
      lifePeriodLabel: ctx.lifePeriodLabel,
      usedBlockIds: usedBlockIds,
      usedTextKeys: globalUsed,
    );
    for (final entry in heroResult.trace) {
      trace = trace.add(entry);
      if (entry.blockId != null) usedBlockIds.add(entry.blockId!);
    }

    final strengthsResult = _polishStrengths(
      source.strengths,
      ctx,
      globalUsed,
      usedBlockIds,
      trace,
    );
    trace = strengthsResult.trace;
    final strengths = strengthsResult.section;
    final cautions = _polishInsightSection(source.cautions, globalUsed);
    final lifeDashboardResult = _polishLifeDashboard(
      source.lifeDashboard,
      ctx,
      globalUsed,
      usedBlockIds,
      trace,
    );
    trace = lifeDashboardResult.trace;
    final narrativeSectionsResult = _polishNarrativeSections(
      source.narrativeSections,
      ctx,
      globalUsed,
      usedBlockIds,
      trace,
    );
    trace = narrativeSectionsResult.trace;

    final adviceResult = _polishAdvice(
      source.advice,
      ctx,
      globalUsed,
      usedBlockIds,
      trace,
    );
    trace = adviceResult.trace;

    final view = ThaiMirrorConsumerViewState(
      hero: heroResult.hero,
      strengths: strengths,
      cautions: cautions,
      advice: adviceResult.advice,
      lifeDashboard: lifeDashboardResult.items,
      narrativeSections: narrativeSectionsResult.sections,
      signatureInsight: _polishSignature(
        source.signatureInsight,
        globalUsed,
        hasBirthTime: ctx.hasBirthTime,
      ),
      reflectionSummary: _polishReflection(source.reflectionSummary, globalUsed),
      closingMessage: _polishClosing(source.closingMessage, globalUsed),
      sourceTransparency: source.sourceTransparency,
      birthDataConfidence: source.birthDataConfidence,
      secretTip: ThaiBetaNarrativeFormatting.normalize(source.secretTip),
      disclaimers: source.disclaimers
          .map(ThaiBetaNarrativeFormatting.normalize)
          .toList(),
      lifeTimeline: source.lifeTimeline,
      futurePrediction: source.futurePrediction,
    );

    return ThaiBetaNarrativeResult(view: view, trace: trace);
  }

  static ThaiMirrorConsumerViewState narrativeView(ThaiBetaAnalysis analysis) {
    return compose(analysis).view;
  }

  static String? _themeIdForStrengthTitle(
    String title,
    List<String> orderedThemeIds,
    int cardIndex,
  ) {
    final normalizedTitle = ThaiBetaNarrativeFormatting.normalizedKey(title);
    for (final id in orderedThemeIds) {
      final tag = ThaiMirrorThemePhrases.phrase(id).tag;
      if (ThaiBetaNarrativeFormatting.normalizedKey(tag) == normalizedTitle) {
        return id;
      }
    }
    if (cardIndex < orderedThemeIds.length) {
      return orderedThemeIds[cardIndex];
    }
    return orderedThemeIds.isNotEmpty ? orderedThemeIds.first : null;
  }

  static ({
    ThaiMirrorInsightSectionState section,
    ThaiBetaNarrativeTrace trace,
  }) _polishStrengths(
    ThaiMirrorInsightSectionState section,
    ThaiBetaNarrativeContext ctx,
    Set<String> globalUsed,
    Set<String> usedBlockIds,
    ThaiBetaNarrativeTrace trace,
  ) {
    final cards = <ThaiMirrorInsightCardState>[];
    for (var i = 0; i < section.cards.length; i++) {
      final card = section.cards[i];
      final title = ThaiBetaNarrativeFormatting.normalize(card.title);
      var body = ThaiBetaNarrativeFormatting.normalize(card.body);

      final themeId = _themeIdForStrengthTitle(title, ctx.orderedThemeIds, i);
      String? expanded;
      if (themeId != null) {
        final selection = ThaiBetaNarrativeSpecificity.selectStrengthExpanded(
          themeId: themeId,
          seed: ctx.profileSeed + i * 31,
          hasBirthTime: ctx.hasBirthTime,
          usedBlockIds: usedBlockIds,
          usedTextKeys: globalUsed,
        );
        usedBlockIds.add(selection.block.id);
        trace = trace.add(
          ThaiBetaNarrativeSpecificity.traceEntry(
            sectionId: 'strength_$i',
            field: 'expandedBody',
            primaryThemeId: themeId,
            lifePeriod: ctx.lifePeriodLabel,
            block: selection.block,
            matchLevel: selection.matchLevel,
          ),
        );
        expanded = ThaiBetaNarrativeDedupe.buildStrengthExpanded(
          title: title,
          expandedBody: selection.text,
          used: globalUsed,
        );
        final observableParts = expanded.split(RegExp(r'\n\n+'));
        if (observableParts.isNotEmpty) {
          body = observableParts.first;
        }
      } else if (card.expandedBody != null) {
        expanded = ThaiBetaNarrativeDedupe.buildStrengthExpanded(
          title: title,
          expandedBody: card.expandedBody!,
          used: globalUsed,
        );
      }

      cards.add(
        ThaiMirrorInsightCardState(
          title: title,
          body: ThaiBetaNarrativeDedupe.resolveUnique(
            text: body,
            used: globalUsed,
          ),
          accent: card.accent,
          icon: card.icon,
          expandedBody: expanded,
        ),
      );
    }
    return (
      section: ThaiMirrorInsightSectionState(
        title: ThaiBetaNarrativeFormatting.normalize(section.title),
        cards: cards,
        sectionIcon: section.sectionIcon,
      ),
      trace: trace,
    );
  }

  static ThaiMirrorInsightSectionState _polishInsightSection(
    ThaiMirrorInsightSectionState section,
    Set<String> globalUsed,
  ) {
    final cards = section.cards.map((card) {
      final title = ThaiBetaNarrativeFormatting.normalize(card.title);
      final body = ThaiBetaNarrativeFormatting.normalize(card.body);
      return ThaiMirrorInsightCardState(
        title: title,
        body: ThaiBetaNarrativeDedupe.resolveUnique(
          text: body,
          used: globalUsed,
        ),
        accent: card.accent,
        icon: card.icon,
        expandedBody: card.expandedBody == null
            ? null
            : ThaiBetaNarrativeFormatting.normalize(card.expandedBody!),
      );
    }).toList();
    return ThaiMirrorInsightSectionState(
      title: ThaiBetaNarrativeFormatting.normalize(section.title),
      cards: cards,
      sectionIcon: section.sectionIcon,
    );
  }

  static ({
    List<ThaiMirrorLifeDashboardItemState> items,
    ThaiBetaNarrativeTrace trace,
  }) _polishLifeDashboard(
    List<ThaiMirrorLifeDashboardItemState> source,
    ThaiBetaNarrativeContext ctx,
    Set<String> globalUsed,
    Set<String> usedBlockIds,
    ThaiBetaNarrativeTrace trace,
  ) {
    final usedThemes = <String>{};
    final usedActions = <String>{};
    final out = <ThaiMirrorLifeDashboardItemState>[];

    for (var i = 0; i < source.length; i++) {
      final item = source[i];
      final domain = _domainForDashboardLabel(item.label);
      if (domain == null) {
        out.add(_normalizeDashboardItem(item, globalUsed));
        continue;
      }

      final primaryThemeId = ThaiBetaDomainSemanticTags.selectThemeForDomain(
        orderedThemeIds: ctx.orderedThemeIds,
        domain: domain,
        seed: ctx.profileSeed + i * 19,
        usedThemeIds: usedThemes,
      );
      final secondaryThemeId = ctx.orderedThemeIds.length > 1
          ? ThaiBetaDomainSemanticTags.selectThemeForDomain(
              orderedThemeIds: ctx.orderedThemeIds,
              domain: domain,
              seed: ctx.profileSeed + i * 23 + 1,
              usedThemeIds: {primaryThemeId, ...usedThemes},
            )
          : null;

      final copy = ThaiBetaNarrativeSpecificity.composeDashboardFromBlock(
        domain: domain,
        primaryThemeId: primaryThemeId,
        secondaryThemeId:
            secondaryThemeId != primaryThemeId ? secondaryThemeId : null,
        seed: ctx.profileSeed + i,
        hasBirthTime: ctx.hasBirthTime,
        usedBlockIds: usedBlockIds,
        usedTextKeys: globalUsed,
        usedActions: usedActions,
      );

      usedThemes.add(primaryThemeId);
      usedActions.add(copy.suggestedAction);
      usedBlockIds.add(copy.block.id);
      usedBlockIds.add(copy.adviceBlock.id);

      trace = trace.add(
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'dashboard_${domain.aspectKey}',
          field: 'currentState',
          primaryThemeId: primaryThemeId,
          secondaryThemeId: secondaryThemeId,
          domain: domain,
          lifePeriod: ctx.lifePeriodLabel,
          block: copy.block,
          matchLevel: copy.matchLevel,
        ),
      );
      trace = trace.add(
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'dashboard_${domain.aspectKey}',
          field: 'suggestedAction',
          primaryThemeId: primaryThemeId,
          domain: domain,
          relationship: 'curated_advice',
          lifePeriod: ctx.lifePeriodLabel,
          block: copy.adviceBlock,
          matchLevel: copy.adviceMatchLevel,
        ),
      );

      final currentState = ThaiBetaNarrativeDedupe.resolveUnique(
        text: copy.currentState,
        used: globalUsed,
      );

      out.add(
        ThaiMirrorLifeDashboardItemState(
          label: item.label,
          currentState: ThaiBetaNarrativeFormatting.normalize(currentState),
          whyItAppears:
              ThaiBetaNarrativeFormatting.normalize(copy.whyItAppears),
          suggestedAction:
              ThaiBetaNarrativeFormatting.normalize(copy.suggestedAction),
          status: item.status,
        ),
      );
    }
    return (items: out, trace: trace);
  }

  static ThaiBetaLifeDomain? _domainForDashboardLabel(String label) {
    return switch (label.trim()) {
      'การงาน' => ThaiBetaLifeDomain.work,
      'การเงิน' => ThaiBetaLifeDomain.money,
      'ความรัก' => ThaiBetaLifeDomain.love,
      'สุขภาพ' => ThaiBetaLifeDomain.health,
      'โชคและโอกาส' => ThaiBetaLifeDomain.luck,
      _ => null,
    };
  }

  static ThaiMirrorLifeDashboardItemState _normalizeDashboardItem(
    ThaiMirrorLifeDashboardItemState item,
    Set<String> globalUsed,
  ) {
    return ThaiMirrorLifeDashboardItemState(
      label: item.label,
      currentState: ThaiBetaNarrativeFormatting.normalize(
        ThaiBetaNarrativeDedupe.resolveUnique(
          text: item.currentState,
          used: globalUsed,
        ),
      ),
      whyItAppears:
          ThaiBetaNarrativeFormatting.normalize(item.whyItAppears),
      suggestedAction:
          ThaiBetaNarrativeFormatting.normalize(item.suggestedAction),
      status: item.status,
    );
  }

  static ({
    List<ThaiMirrorNarrativeSectionState> sections,
    ThaiBetaNarrativeTrace trace,
  }) _polishNarrativeSections(
    List<ThaiMirrorNarrativeSectionState> sections,
    ThaiBetaNarrativeContext ctx,
    Set<String> globalUsed,
    Set<String> usedBlockIds,
    ThaiBetaNarrativeTrace trace,
  ) {
    final out = <ThaiMirrorNarrativeSectionState>[];

    for (final section in sections) {
      final domain =
          ThaiBetaDomainSemanticTags.domainForNarrativeLabel(section.label);
      final sectionSeed = ThaiBetaNarrativeStableHash.seedOffset(
        ctx.profileSeed,
        [section.label, domain?.aspectKey ?? 'general'],
      );
      final primaryThemeId = domain != null
          ? ThaiBetaDomainSemanticTags.selectThemeForDomain(
              orderedThemeIds: ctx.orderedThemeIds,
              domain: domain,
              seed: sectionSeed,
            )
          : (ctx.orderedThemeIds.isNotEmpty
              ? ctx.orderedThemeIds.first
              : 'independent');
      final secondaryThemeId = ctx.orderedThemeIds.length > 1
          ? ctx.orderedThemeIds[1]
          : null;

      var overview = domain != null
          ? ThaiBetaNarrativeSpecificity.selectDomainOverview(
              primaryThemeId: primaryThemeId,
              secondaryThemeId: secondaryThemeId,
              domain: domain,
              seed: sectionSeed,
              hasBirthTime: ctx.hasBirthTime,
              usedBlockIds: usedBlockIds,
              usedTextKeys: globalUsed,
            )
          : null;
      if (overview != null) {
        usedBlockIds.add(overview.block.id);
      }

      final transition = section.hasTransition
          ? ThaiBetaNarrativeFormatting.normalize(section.transitionIn)
          : '';
      final pullQuote = section.pullQuote.isNotEmpty
          ? ThaiBetaNarrativeFormatting.normalize(section.pullQuote)
          : '';
      final discovery = section.hasDiscovery
          ? ThaiBetaNarrativeFormatting.normalize(section.discovery)
          : '';
      final tension = section.hasTension
          ? ThaiBetaNarrativeFormatting.normalize(section.tension)
          : '';
      var why = domain != null
          ? ThaiBetaNarrativeSpecificity.selectDomainWhy(
              primaryThemeId: primaryThemeId,
              secondaryThemeId: secondaryThemeId,
              domain: domain,
              seed: sectionSeed + 2,
              hasBirthTime: ctx.hasBirthTime,
              usedBlockIds: usedBlockIds,
              usedTextKeys: globalUsed,
            )
          : null;
      if (why != null) {
        usedBlockIds.add(why.block.id);
      }
      var adviceSelection = domain != null
          ? ThaiBetaNarrativeSpecificity.selectAdvice(
              primaryThemeId: primaryThemeId,
              domain: domain,
              seed: sectionSeed + 3,
              hasBirthTime: ctx.hasBirthTime,
              usedBlockIds: usedBlockIds,
              usedTextKeys: globalUsed,
            )
          : null;
      if (adviceSelection != null) {
        usedBlockIds.add(adviceSelection.block.id);
      }

      final overviewText = overview?.text ??
          ThaiBetaNarrativeFormatting.normalize(section.overview);
      final whyText =
          why?.text ?? ThaiBetaNarrativeFormatting.normalize(section.whyItAppears);
      final adviceText = adviceSelection?.text ??
          ThaiBetaNarrativeFormatting.normalize(section.advice);
      var example = ThaiBetaNarrativeFormatting.normalize(section.example);
      final reflection = section.hasReflectionQuestion
          ? ThaiBetaNarrativeFormatting.normalize(section.reflectionQuestion)
          : '';

      if (domain != null && example.isNotEmpty &&
          !ThaiBetaDomainSemanticTags.isTextDomainCompatible(example, domain)) {
        example = '';
      }

      final deduped = ThaiBetaNarrativeDedupe.dedupeParagraphs(
        sectionId: section.label,
        sectionTitle: section.label,
        paragraphs: [
          if (transition.isNotEmpty) transition,
          if (pullQuote.isNotEmpty) pullQuote,
          if (discovery.isNotEmpty) discovery,
          overviewText,
          if (tension.isNotEmpty) tension,
          if (whyText.isNotEmpty) whyText,
          if (adviceText.isNotEmpty) adviceText,
          if (example.isNotEmpty) example,
          if (reflection.isNotEmpty) reflection,
        ],
        globalUsed: globalUsed,
      );

      final overviewFallback = overviewText;

      if (domain != null && overview != null) {
        trace = trace.add(
          ThaiBetaNarrativeSpecificity.traceEntry(
            sectionId: 'narrative_${domain.aspectKey}',
            field: 'overview',
            primaryThemeId: primaryThemeId,
            secondaryThemeId: secondaryThemeId,
            domain: domain,
            lifePeriod: ctx.lifePeriodLabel,
            block: overview.block,
            matchLevel: overview.matchLevel,
          ),
        );
        if (whyText.isNotEmpty && why != null) {
          trace = trace.add(
            ThaiBetaNarrativeSpecificity.traceEntry(
              sectionId: 'narrative_${domain.aspectKey}',
              field: 'whyItAppears',
              primaryThemeId: primaryThemeId,
              secondaryThemeId: secondaryThemeId,
              domain: domain,
              relationship: 'curated_domain',
              lifePeriod: ctx.lifePeriodLabel,
              block: why.block,
              matchLevel: why.matchLevel,
            ),
          );
        }
        if (adviceText.isNotEmpty && adviceSelection != null) {
          trace = trace.add(
            ThaiBetaNarrativeSpecificity.traceEntry(
              sectionId: 'narrative_${domain.aspectKey}',
              field: 'advice',
              primaryThemeId: primaryThemeId,
              domain: domain,
              relationship: 'curated_advice',
              lifePeriod: ctx.lifePeriodLabel,
              block: adviceSelection.block,
              matchLevel: adviceSelection.matchLevel,
            ),
          );
        }
      }

      out.add(
        ThaiMirrorNarrativeSectionState(
          label: ThaiBetaNarrativeFormatting.normalize(section.label),
          icon: section.icon,
          accent: section.accent,
          transitionIn: _fieldAfterSectionDedupe(transition, deduped),
          pullQuote: _fieldAfterSectionDedupe(pullQuote, deduped),
          overview: _fieldAfterSectionDedupe(
            overviewText,
            deduped,
            fallback: overviewFallback,
          ),
          tension: _fieldAfterSectionDedupe(tension, deduped),
          discovery: _fieldAfterSectionDedupe(discovery, deduped),
          reasoningTitle:
              ThaiBetaNarrativeFormatting.normalize(section.reasoningTitle),
          reasoningSignals: section.reasoningSignals
              .map(ThaiBetaNarrativeFormatting.normalize)
              .toList(),
          whyItAppears: _fieldAfterSectionDedupe(whyText, deduped),
          advice: _fieldAfterSectionDedupe(adviceText, deduped),
          example: _fieldAfterSectionDedupe(example, deduped),
          reflectionQuestion: _fieldAfterSectionDedupe(reflection, deduped),
        ),
      );
    }
    return (sections: out, trace: trace);
  }

  static String _fieldAfterSectionDedupe(
    String value,
    List<String> deduped, {
    String fallback = '',
  }) {
    if (value.isEmpty) return value;
    if (deduped.contains(value)) return value;
    return fallback;
  }

  static ({
    ThaiMirrorAdviceState advice,
    ThaiBetaNarrativeTrace trace,
  }) _polishAdvice(
    ThaiMirrorAdviceState advice,
    ThaiBetaNarrativeContext ctx,
    Set<String> globalUsed,
    Set<String> usedBlockIds,
    ThaiBetaNarrativeTrace trace,
  ) {
    final primaryThemeId = ctx.orderedThemeIds.isNotEmpty
        ? ctx.orderedThemeIds.first
        : 'independent';
    var selection = ThaiBetaNarrativeSpecificity.selectAdvice(
      primaryThemeId: primaryThemeId,
      seed: ctx.profileSeed + 99,
      hasBirthTime: ctx.hasBirthTime,
      usedBlockIds: usedBlockIds,
      usedTextKeys: globalUsed,
    );
    var body = selection.text;
    if (body.isEmpty) {
      body = ThaiBetaNarrativeFormatting.normalize(advice.body);
    }
    if (ThaiBetaNarrativeForbidden.findForbidden(body).isNotEmpty) {
      selection = ThaiBetaNarrativeSpecificity.selectAdvice(
        primaryThemeId: primaryThemeId,
        domain: ThaiBetaLifeDomain.work,
        seed: ctx.profileSeed + 100,
        hasBirthTime: ctx.hasBirthTime,
        usedBlockIds: usedBlockIds,
        usedTextKeys: globalUsed,
      );
      body = selection.text;
    }
    usedBlockIds.add(selection.block.id);
    trace = trace.add(
      ThaiBetaNarrativeSpecificity.traceEntry(
        sectionId: 'advice',
        field: 'body',
        primaryThemeId: primaryThemeId,
        lifePeriod: ctx.lifePeriodLabel,
        block: selection.block,
        matchLevel: selection.matchLevel,
        relationship: 'curated_advice',
      ),
    );
    return (
      advice: ThaiMirrorAdviceState(
        title: ThaiBetaNarrativeFormatting.normalize(advice.title),
        body: ThaiBetaNarrativeDedupe.resolveUnique(
          text: body,
          used: globalUsed,
        ),
      ),
      trace: trace,
    );
  }

  static ThaiMirrorSignatureInsightState _polishSignature(
    ThaiMirrorSignatureInsightState insight,
    Set<String> globalUsed, {
    required bool hasBirthTime,
  }) {
    var body = ThaiBetaNarrativeFormatting.normalize(insight.body);
    if (!hasBirthTime &&
        (ThaiBetaNarrativeForbidden.findNoBirthTimeViolations(body).isNotEmpty ||
            body.contains('ถ้าจะเข้าใจคุณ แค่เรื่องเดียว'))) {
      body =
          'ภาพรวมจากวันเกิดสะท้อนว่า คุณอาจมีแนวโน้มที่โดดเด่นในบางด้าน '
          '— ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่าอะไรตรงกับชีวิตจริงของคุณ';
    }
    return ThaiMirrorSignatureInsightState(
      eyebrow: ThaiBetaNarrativeFormatting.normalize(insight.eyebrow),
      body: ThaiBetaNarrativeDedupe.resolveUnique(
        text: body,
        used: globalUsed,
      ),
      signature: ThaiBetaNarrativeFormatting.normalize(insight.signature),
    );
  }

  static ThaiMirrorReflectionSummaryState _polishReflection(
    ThaiMirrorReflectionSummaryState summary,
    Set<String> globalUsed,
  ) {
    final points = ThaiBetaNarrativeDedupe.dedupeParagraphs(
      sectionId: 'reflection',
      paragraphs: summary.points,
      globalUsed: globalUsed,
    );
    return ThaiMirrorReflectionSummaryState(
      title: ThaiBetaNarrativeFormatting.normalize(summary.title),
      intro: ThaiBetaNarrativeFormatting.normalize(summary.intro),
      points: points,
    );
  }

  static ThaiMirrorClosingMessageState _polishClosing(
    ThaiMirrorClosingMessageState closing,
    Set<String> globalUsed,
  ) {
    final message = ThaiBetaNarrativeFormatting.normalize(closing.message);
    return ThaiMirrorClosingMessageState(
      eyebrow: ThaiBetaNarrativeFormatting.normalize(closing.eyebrow),
      message: ThaiBetaNarrativeDedupe.resolveUnique(
        text: message,
        used: globalUsed,
      ),
      signature: ThaiBetaNarrativeFormatting.normalize(closing.signature),
    );
  }
}
