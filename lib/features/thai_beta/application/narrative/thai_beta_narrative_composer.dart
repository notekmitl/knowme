/// Thai Beta Narrative Quality V1 — presentation-only composer.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import 'thai_beta_narrative_context.dart';
import 'thai_beta_narrative_dedupe.dart';
import 'thai_beta_narrative_domain.dart';
import 'thai_beta_narrative_formatting.dart';
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
    );
    for (final entry in heroResult.trace) {
      trace = trace.add(entry);
    }

    final strengths = _polishStrengths(source.strengths, globalUsed);
    final cautions = _polishInsightSection(source.cautions, globalUsed);
    final lifeDashboardResult = _polishLifeDashboard(
      source.lifeDashboard,
      ctx,
      globalUsed,
      trace,
    );
    trace = lifeDashboardResult.trace;
    final narrativeSectionsResult = _polishNarrativeSections(
      source.narrativeSections,
      ctx,
      globalUsed,
      trace,
    );
    trace = narrativeSectionsResult.trace;

    final view = ThaiMirrorConsumerViewState(
      hero: heroResult.hero,
      strengths: strengths,
      cautions: cautions,
      advice: _polishAdvice(source.advice, globalUsed),
      lifeDashboard: lifeDashboardResult.items,
      narrativeSections: narrativeSectionsResult.sections,
      signatureInsight: _polishSignature(source.signatureInsight, globalUsed),
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

  static ThaiMirrorInsightSectionState _polishStrengths(
    ThaiMirrorInsightSectionState section,
    Set<String> globalUsed,
  ) {
    final cards = <ThaiMirrorInsightCardState>[];
    for (final card in section.cards) {
      final title = ThaiBetaNarrativeFormatting.normalize(card.title);
      final body = ThaiBetaNarrativeFormatting.normalize(card.body);
      final expanded = card.expandedBody == null
          ? null
          : ThaiBetaNarrativeDedupe.rewriteStrengthExpanded(
              title: title,
              expandedBody: card.expandedBody!,
              used: globalUsed,
            );
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
    return ThaiMirrorInsightSectionState(
      title: ThaiBetaNarrativeFormatting.normalize(section.title),
      cards: cards,
      sectionIcon: section.sectionIcon,
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

      final copy = ThaiBetaDomainSemanticTags.composeDashboardCopy(
        domain: domain,
        primaryThemeId: primaryThemeId,
        secondaryThemeId:
            secondaryThemeId != primaryThemeId ? secondaryThemeId : null,
        seed: ctx.profileSeed + i,
        usedActions: usedActions,
      );

      usedThemes.add(primaryThemeId);
      usedActions.add(copy.suggestedAction);

      trace = trace.add(
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'dashboard_${domain.aspectKey}',
          field: 'currentState',
          primaryThemeId: primaryThemeId,
          secondaryThemeId: copy.secondaryThemeId,
          domain: domain,
          lifePeriod: ctx.lifePeriodLabel,
        ),
      );
      trace = trace.add(
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'dashboard_${domain.aspectKey}',
          field: 'whyItAppears',
          primaryThemeId: primaryThemeId,
          secondaryThemeId: copy.secondaryThemeId,
          domain: domain,
          relationship: 'trait+domain_hint',
          lifePeriod: ctx.lifePeriodLabel,
        ),
      );
      trace = trace.add(
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'dashboard_${domain.aspectKey}',
          field: 'suggestedAction',
          primaryThemeId: primaryThemeId,
          domain: domain,
          relationship: 'trait+domain_advice',
          lifePeriod: ctx.lifePeriodLabel,
        ),
      );

      final traitPairAlt = ThaiBetaNarrativeSpecificity.composeTraitPair(
        primaryThemeId: primaryThemeId,
        secondaryThemeId: copy.secondaryThemeId,
        seed: ctx.profileSeed + i,
        domain: domain,
      );
      final currentState = ThaiBetaNarrativeDedupe.resolveUnique(
        text: copy.currentState,
        used: globalUsed,
        fallbacks: [traitPairAlt],
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

      var overview = ThaiBetaNarrativeFormatting.normalize(section.overview);
      if (domain != null &&
          !ThaiBetaDomainSemanticTags.isTextDomainCompatible(
            overview,
            domain,
          )) {
        overview = ThaiBetaNarrativeSpecificity.composeTraitPair(
          primaryThemeId: primaryThemeId,
          secondaryThemeId: secondaryThemeId,
          seed: sectionSeed,
          domain: domain,
        );
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
      var why = ThaiBetaNarrativeFormatting.normalize(section.whyItAppears);
      var advice = ThaiBetaNarrativeFormatting.normalize(section.advice);
      var example = ThaiBetaNarrativeFormatting.normalize(section.example);
      final reflection = section.hasReflectionQuestion
          ? ThaiBetaNarrativeFormatting.normalize(section.reflectionQuestion)
          : '';

      if (domain != null) {
        if (why.isNotEmpty &&
            !ThaiBetaDomainSemanticTags.isTextDomainCompatible(why, domain)) {
          why = ThaiBetaDomainSemanticTags.domainWhyFallback(
            domain: domain,
            primaryThemeId: primaryThemeId,
            secondaryThemeId: secondaryThemeId,
          );
        }
        if (advice.isNotEmpty &&
            !ThaiBetaDomainSemanticTags.isTextDomainCompatible(
              advice,
              domain,
            )) {
          advice = ThaiBetaDomainSemanticTags.domainAdviceFallback(
            domain,
            primaryThemeId,
          );
        }
        if (example.isNotEmpty &&
            !ThaiBetaDomainSemanticTags.isTextDomainCompatible(
              example,
              domain,
            )) {
          example = '';
        }
      }

      final deduped = ThaiBetaNarrativeDedupe.dedupeParagraphs(
        sectionId: section.label,
        sectionTitle: section.label,
        paragraphs: [
          if (transition.isNotEmpty) transition,
          if (pullQuote.isNotEmpty) pullQuote,
          if (discovery.isNotEmpty) discovery,
          overview,
          if (tension.isNotEmpty) tension,
          if (why.isNotEmpty) why,
          if (advice.isNotEmpty) advice,
          if (example.isNotEmpty) example,
          if (reflection.isNotEmpty) reflection,
        ],
        globalUsed: globalUsed,
      );

      final overviewFallback = domain != null
          ? ThaiBetaNarrativeSpecificity.composeTraitPair(
              primaryThemeId: primaryThemeId,
              secondaryThemeId: secondaryThemeId,
              seed: sectionSeed + 1,
              domain: domain,
            )
          : overview;

      if (domain != null) {
        trace = trace.add(
          ThaiBetaNarrativeSpecificity.traceEntry(
            sectionId: 'narrative_${domain.aspectKey}',
            field: 'overview',
            primaryThemeId: primaryThemeId,
            secondaryThemeId: secondaryThemeId,
            domain: domain,
            lifePeriod: ctx.lifePeriodLabel,
          ),
        );
        if (why.isNotEmpty) {
          trace = trace.add(
            ThaiBetaNarrativeSpecificity.traceEntry(
              sectionId: 'narrative_${domain.aspectKey}',
              field: 'whyItAppears',
              primaryThemeId: primaryThemeId,
              secondaryThemeId: secondaryThemeId,
              domain: domain,
              relationship: 'trait+domain_hint',
              lifePeriod: ctx.lifePeriodLabel,
            ),
          );
        }
        if (advice.isNotEmpty) {
          trace = trace.add(
            ThaiBetaNarrativeSpecificity.traceEntry(
              sectionId: 'narrative_${domain.aspectKey}',
              field: 'advice',
              primaryThemeId: primaryThemeId,
              domain: domain,
              relationship: 'trait+domain_advice',
              lifePeriod: ctx.lifePeriodLabel,
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
          overview,
          deduped,
          fallback: overviewFallback,
        ),
        tension: _fieldAfterSectionDedupe(tension, deduped),
        discovery: _fieldAfterSectionDedupe(discovery, deduped),
        reasoningTitle: ThaiBetaNarrativeFormatting.normalize(section.reasoningTitle),
        reasoningSignals: section.reasoningSignals
            .map(ThaiBetaNarrativeFormatting.normalize)
            .toList(),
        whyItAppears: _fieldAfterSectionDedupe(why, deduped),
        advice: _fieldAfterSectionDedupe(advice, deduped),
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

  static ThaiMirrorAdviceState _polishAdvice(
    ThaiMirrorAdviceState advice,
    Set<String> globalUsed,
  ) {
    final body = ThaiBetaNarrativeFormatting.normalize(advice.body);
    return ThaiMirrorAdviceState(
      title: ThaiBetaNarrativeFormatting.normalize(advice.title),
      body: ThaiBetaNarrativeDedupe.resolveUnique(
        text: body,
        used: globalUsed,
      ),
    );
  }

  static ThaiMirrorSignatureInsightState _polishSignature(
    ThaiMirrorSignatureInsightState insight,
    Set<String> globalUsed,
  ) {
    final body = ThaiBetaNarrativeFormatting.normalize(insight.body);
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
