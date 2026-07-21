/// Two-layer specificity composer — V1.1 delegates to curated blocks.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';

import 'thai_beta_curated_block_selector.dart';
import 'thai_beta_curated_narrative_block.dart';
import 'thai_beta_narrative_confidence.dart';
import 'thai_beta_narrative_domain.dart';
import 'thai_beta_narrative_formatting.dart';
import 'thai_beta_narrative_trace.dart';

abstract final class ThaiBetaNarrativeSpecificity {
  /// Headline from curated block context — not clause composition.
  static String composeHeadlineFromBlock({
    required String primaryThemeId,
    required String? secondaryThemeId,
    required CuratedNarrativeBlock block,
    required int seed,
  }) {
    if (block.heroSentences.isNotEmpty) {
      return ThaiBetaNarrativeFormatting.normalize(block.heroSentences.first);
    }
    return composeTraitPair(
      primaryThemeId: primaryThemeId,
      secondaryThemeId: secondaryThemeId,
      seed: seed,
    );
  }

  /// Domain overview from curated block selection.
  static ({
    String text,
    CuratedNarrativeBlock block,
    int matchLevel,
  }) selectDomainOverview({
    required String primaryThemeId,
    String? secondaryThemeId,
    required ThaiBetaLifeDomain domain,
    required int seed,
    required bool hasBirthTime,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
  }) {
    final selection = ThaiBetaCuratedBlockSelector.select(
      CuratedBlockQuery(
        section: CuratedNarrativeSection.domain,
        primaryThemeId: primaryThemeId,
        secondaryThemeId: secondaryThemeId,
        domain: domain,
        hasBirthTime: hasBirthTime,
        usedBlockIds: usedBlockIds,
        usedTextKeys: usedTextKeys,
        seed: seed,
        confidence: ThaiBetaNarrativeConfidence.forBirthTime(hasBirthTime),
      ),
    );
    return (
      text: ThaiBetaNarrativeFormatting.normalize(
        selection.block.domainOverview ?? '',
      ),
      block: selection.block,
      matchLevel: selection.matchLevel,
    );
  }

  static String composeDomainOverview({
    required String primaryThemeId,
    String? secondaryThemeId,
    required ThaiBetaLifeDomain domain,
    required int seed,
    required bool hasBirthTime,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
  }) {
    return selectDomainOverview(
      primaryThemeId: primaryThemeId,
      secondaryThemeId: secondaryThemeId,
      domain: domain,
      seed: seed,
      hasBirthTime: hasBirthTime,
      usedBlockIds: usedBlockIds,
      usedTextKeys: usedTextKeys,
    ).text;
  }

  /// Domain why from curated block selection.
  static ({
    String text,
    CuratedNarrativeBlock block,
    int matchLevel,
  }) selectDomainWhy({
    required String primaryThemeId,
    String? secondaryThemeId,
    required ThaiBetaLifeDomain domain,
    required int seed,
    required bool hasBirthTime,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
  }) {
    final selection = ThaiBetaCuratedBlockSelector.select(
      CuratedBlockQuery(
        section: CuratedNarrativeSection.domain,
        primaryThemeId: primaryThemeId,
        secondaryThemeId: secondaryThemeId,
        domain: domain,
        hasBirthTime: hasBirthTime,
        usedBlockIds: usedBlockIds,
        usedTextKeys: usedTextKeys,
        seed: seed + 1,
        confidence: ThaiBetaNarrativeConfidence.forBirthTime(hasBirthTime),
      ),
    );
    return (
      text: ThaiBetaNarrativeFormatting.normalize(
        selection.block.domainWhy ?? '',
      ),
      block: selection.block,
      matchLevel: selection.matchLevel,
    );
  }

  static String composeDomainWhy({
    required String primaryThemeId,
    String? secondaryThemeId,
    required ThaiBetaLifeDomain domain,
    required int seed,
    required bool hasBirthTime,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
  }) {
    return selectDomainWhy(
      primaryThemeId: primaryThemeId,
      secondaryThemeId: secondaryThemeId,
      domain: domain,
      seed: seed,
      hasBirthTime: hasBirthTime,
      usedBlockIds: usedBlockIds,
      usedTextKeys: usedTextKeys,
    ).text;
  }

  /// Dashboard copy from curated blocks.
  static ({
    String currentState,
    String whyItAppears,
    String suggestedAction,
    CuratedNarrativeBlock block,
    int matchLevel,
    CuratedNarrativeBlock adviceBlock,
    int adviceMatchLevel,
  }) composeDashboardFromBlock({
    required ThaiBetaLifeDomain domain,
    required String primaryThemeId,
    String? secondaryThemeId,
    required int seed,
    required bool hasBirthTime,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
    Set<String> usedActions = const {},
  }) {
    final dashSelection = ThaiBetaCuratedBlockSelector.select(
      CuratedBlockQuery(
        section: CuratedNarrativeSection.dashboard,
        primaryThemeId: primaryThemeId,
        secondaryThemeId: secondaryThemeId,
        domain: domain,
        hasBirthTime: hasBirthTime,
        usedBlockIds: usedBlockIds,
        usedTextKeys: usedTextKeys,
        seed: seed,
        confidence: ThaiBetaNarrativeConfidence.forBirthTime(hasBirthTime),
      ),
    );

    final adviceSelection = ThaiBetaCuratedBlockSelector.select(
      CuratedBlockQuery(
        section: CuratedNarrativeSection.advice,
        primaryThemeId: primaryThemeId,
        domain: domain,
        hasBirthTime: hasBirthTime,
        usedBlockIds: {...usedBlockIds, dashSelection.block.id},
        usedTextKeys: usedTextKeys,
        seed: seed + 7,
        confidence: ThaiBetaNarrativeConfidence.forBirthTime(hasBirthTime),
      ),
    );

    var action = adviceSelection.block.adviceText ?? '';
    if (usedActions.contains(action)) {
      final alt = ThaiBetaCuratedBlockSelector.select(
        CuratedBlockQuery(
          section: CuratedNarrativeSection.advice,
          primaryThemeId: primaryThemeId,
          domain: domain,
          hasBirthTime: hasBirthTime,
          usedBlockIds: {
            ...usedBlockIds,
            dashSelection.block.id,
            adviceSelection.block.id,
          },
          usedTextKeys: {...usedTextKeys, ...usedActions},
          seed: seed + 13,
          confidence: ThaiBetaNarrativeConfidence.forBirthTime(hasBirthTime),
        ),
      );
      action = alt.block.adviceText ?? action;
    }

    return (
      currentState: ThaiBetaNarrativeFormatting.normalize(
        dashSelection.block.dashboardCurrent ?? '',
      ),
      whyItAppears: ThaiBetaNarrativeFormatting.normalize(
        dashSelection.block.dashboardWhy ?? '',
      ),
      suggestedAction: ThaiBetaNarrativeFormatting.normalize(action),
      block: dashSelection.block,
      matchLevel: dashSelection.matchLevel,
      adviceBlock: adviceSelection.block,
      adviceMatchLevel: adviceSelection.matchLevel,
    );
  }

  /// Strength expanded body from curated 3-part block.
  static ({
    String text,
    CuratedNarrativeBlock block,
    int matchLevel,
  }) selectStrengthExpanded({
    required String themeId,
    required int seed,
    required bool hasBirthTime,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
  }) {
    final selection = ThaiBetaCuratedBlockSelector.select(
      CuratedBlockQuery(
        section: CuratedNarrativeSection.strength,
        primaryThemeId: themeId,
        hasBirthTime: hasBirthTime,
        usedBlockIds: usedBlockIds,
        usedTextKeys: usedTextKeys,
        seed: seed,
        confidence: ThaiBetaNarrativeConfidence.forBirthTime(hasBirthTime),
      ),
    );
    final block = selection.block;
    final parts = <String>[
      if (block.observableBehavior != null) block.observableBehavior!,
      if (block.strengthText != null) block.strengthText!,
      if (block.tensionText != null) block.tensionText!,
    ];
    return (
      text: parts.map(ThaiBetaNarrativeFormatting.normalize).join('\n\n'),
      block: block,
      matchLevel: selection.matchLevel,
    );
  }

  static String composeStrengthExpanded({
    required String themeId,
    required int seed,
    required bool hasBirthTime,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
  }) {
    return selectStrengthExpanded(
      themeId: themeId,
      seed: seed,
      hasBirthTime: hasBirthTime,
      usedBlockIds: usedBlockIds,
      usedTextKeys: usedTextKeys,
    ).text;
  }

  /// Curated advice for a domain.
  static ({
    String text,
    CuratedNarrativeBlock block,
    int matchLevel,
  }) selectAdvice({
    required String primaryThemeId,
    ThaiBetaLifeDomain? domain,
    required int seed,
    required bool hasBirthTime,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
  }) {
    final selection = ThaiBetaCuratedBlockSelector.select(
      CuratedBlockQuery(
        section: CuratedNarrativeSection.advice,
        primaryThemeId: primaryThemeId,
        domain: domain,
        hasBirthTime: hasBirthTime,
        usedBlockIds: usedBlockIds,
        usedTextKeys: usedTextKeys,
        seed: seed,
        confidence: ThaiBetaNarrativeConfidence.forBirthTime(hasBirthTime),
      ),
    );
    return (
      text: ThaiBetaNarrativeFormatting.normalize(
        selection.block.adviceText ?? '',
      ),
      block: selection.block,
      matchLevel: selection.matchLevel,
    );
  }

  static String composeAdvice({
    required String primaryThemeId,
    ThaiBetaLifeDomain? domain,
    required int seed,
    required bool hasBirthTime,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
  }) {
    return selectAdvice(
      primaryThemeId: primaryThemeId,
      domain: domain,
      seed: seed,
      hasBirthTime: hasBirthTime,
      usedBlockIds: usedBlockIds,
      usedTextKeys: usedTextKeys,
    ).text;
  }

  /// Legacy fallback — delegates to curated domain block.
  static String composeTraitPair({
    required String primaryThemeId,
    required String? secondaryThemeId,
    required int seed,
    ThaiBetaLifeDomain? domain,
    bool hasBirthTime = true,
  }) {
    if (domain != null) {
      return composeDomainOverview(
        primaryThemeId: primaryThemeId,
        secondaryThemeId: secondaryThemeId,
        domain: domain,
        seed: seed,
        hasBirthTime: hasBirthTime,
      );
    }
    final selection = ThaiBetaCuratedBlockSelector.select(
      CuratedBlockQuery(
        section: CuratedNarrativeSection.hero,
        primaryThemeId: primaryThemeId,
        secondaryThemeId: secondaryThemeId,
        hasBirthTime: hasBirthTime,
        seed: seed,
        confidence: ThaiBetaNarrativeConfidence.forBirthTime(hasBirthTime),
      ),
    );
    if (selection.block.heroSentences.isNotEmpty) {
      return ThaiBetaNarrativeFormatting.normalize(
        selection.block.heroSentences.first,
      );
    }
    return '';
  }

  /// Adds contrast only when two distinct facets are present in profile.
  static String? composeContrast({
    required List<String> orderedThemeIds,
    required int seed,
  }) {
    if (orderedThemeIds.length < 2) return null;
    final a = ThaiMirrorEvidenceComposer.facetForThemeId(orderedThemeIds[0]);
    final b = ThaiMirrorEvidenceComposer.facetForThemeId(orderedThemeIds[1]);
    if (a == b) return null;
    return ThaiBetaNarrativeFormatting.normalize(
      ThaiMirrorEvidenceComposer.contradiction(a, b, seed),
    );
  }

  /// Observable behavior from curated strength block when available.
  static String observableBehavior({
    required String themeId,
    required int seed,
    ThaiBetaLifeDomain? domain,
    bool hasBirthTime = true,
  }) {
    final selection = ThaiBetaCuratedBlockSelector.select(
      CuratedBlockQuery(
        section: CuratedNarrativeSection.strength,
        primaryThemeId: themeId,
        domain: domain,
        hasBirthTime: hasBirthTime,
        seed: seed,
        confidence: ThaiBetaNarrativeConfidence.forBirthTime(hasBirthTime),
      ),
    );
    if (selection.block.observableBehavior != null) {
      return ThaiBetaNarrativeFormatting.normalize(
        selection.block.observableBehavior!,
      );
    }
    return '';
  }

  static ThaiBetaNarrativeTraceEntry traceEntry({
    required String sectionId,
    required String field,
    required String primaryThemeId,
    String? secondaryThemeId,
    ThaiBetaLifeDomain? domain,
    String relationship = 'curated_block',
    String? lifePeriod,
    CuratedNarrativeBlock? block,
    int? matchLevel,
  }) {
    final primary = ThaiMirrorThemePhrases.phrase(primaryThemeId).tag;
    final secondary = secondaryThemeId == null
        ? null
        : ThaiMirrorThemePhrases.phrase(secondaryThemeId).tag;
    return ThaiBetaNarrativeTraceEntry(
      sectionId: sectionId,
      field: field,
      primaryTrait: primary,
      secondaryTrait: secondary,
      domain: domain,
      relationship: matchLevel != null ? '$relationship:$matchLevel' : relationship,
      lifePeriod: lifePeriod,
      blockId: block?.id,
      minimumConfidence: block == null
          ? null
          : ThaiBetaNarrativeConfidence.effectiveMinimum(
              declaredMinimum: block.minimumConfidence,
              requiresBirthTime: block.requiresBirthTime,
              safeWithoutBirthTime: block.safeWithoutBirthTime,
            ),
      requiresBirthTime: block?.requiresBirthTime,
      sourceSignalIds: block?.sourceSignalIds ?? const [],
    );
  }
}
