/// Two-layer specificity composer for Thai Beta narrative.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';

import 'thai_beta_narrative_domain.dart';
import 'thai_beta_narrative_formatting.dart';
import 'thai_beta_narrative_trace.dart';

abstract final class ThaiBetaNarrativeSpecificity {
  /// Combines primary + secondary trait when both signals exist.
  static String composeTraitPair({
    required String primaryThemeId,
    required String? secondaryThemeId,
    required int seed,
    ThaiBetaLifeDomain? domain,
  }) {
    final primary = ThaiMirrorThemePhrases.phrase(primaryThemeId);
    if (secondaryThemeId == null || secondaryThemeId == primaryThemeId) {
      return _singleLayer(primary, domain);
    }

    final secondary = ThaiMirrorThemePhrases.phrase(secondaryThemeId);
    final primaryFacet =
        ThaiMirrorEvidenceComposer.facetForThemeId(primaryThemeId);
    final secondaryFacet =
        ThaiMirrorEvidenceComposer.facetForThemeId(secondaryThemeId);
    if (primaryFacet == secondaryFacet) {
      return _singleLayer(primary, domain);
    }

    final templates = <String>[
      'คุณมัก${primary.headlinePart} '
          'แต่เมื่อเห็นภาพชัดแล้ว คุณก็${secondary.headlinePart}ได้เร็วกว่าที่คนรอบตัวคาด',
      'คุณ${primary.headlinePart} '
          'และพอ${secondary.heroDetail} ก็ยิ่งเห็นจุดแข็งของคุณชัดขึ้น',
      'คุณมัก${primary.headlinePart} '
          'ในขณะที่อีกด้านหนึ่งคุณ${secondary.headlinePart}เมื่อสถานการณ์เร่ง',
    ];
    final idx = (seed.abs() + (domain?.index ?? 0)) % templates.length;
    return ThaiBetaNarrativeFormatting.normalize(templates[idx]);
  }

  static String _singleLayer(ThaiThemePhrase phrase, ThaiBetaLifeDomain? domain) {
    if (domain == null) {
      return ThaiBetaNarrativeFormatting.normalize(
        'คุณมัก${phrase.headlinePart} — ${phrase.heroDetail}',
      );
    }
    final lifeHint = switch (domain) {
      ThaiBetaLifeDomain.work => phrase.workHint ?? phrase.heroDetail,
      ThaiBetaLifeDomain.money => phrase.moneyHint ?? phrase.heroDetail,
      ThaiBetaLifeDomain.love => phrase.loveHint ?? phrase.heroDetail,
      ThaiBetaLifeDomain.health => phrase.healthHint ?? phrase.heroDetail,
      ThaiBetaLifeDomain.luck => phrase.luckHint ?? phrase.heroDetail,
    };
    return ThaiBetaNarrativeFormatting.normalize(
      'ด้าน${domain.labelTh} คุณมัก${phrase.headlinePart} — $lifeHint',
    );
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

  /// Observable behavior from existing facet scene data.
  static String observableBehavior({
    required String themeId,
    required int seed,
    ThaiBetaLifeDomain? domain,
  }) {
    final facet = ThaiMirrorEvidenceComposer.facetForThemeId(themeId);
    final area = domain?.aspectKey ?? 'work';
    return ThaiBetaNarrativeFormatting.normalize(
      ThaiMirrorEvidenceComposer.microStory(
        area: area,
        facet: facet,
        seed: seed,
      ),
    );
  }

  static ThaiBetaNarrativeTraceEntry traceEntry({
    required String sectionId,
    required String field,
    required String primaryThemeId,
    String? secondaryThemeId,
    ThaiBetaLifeDomain? domain,
    String relationship = 'primary+secondary',
    String? lifePeriod,
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
      relationship: relationship,
      lifePeriod: lifePeriod,
    );
  }
}
