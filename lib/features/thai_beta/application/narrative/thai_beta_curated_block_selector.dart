/// Deterministic curated block selection for Thai Beta narrative V1.1.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';

import 'thai_beta_curated_narrative_block.dart';
import 'thai_beta_curated_narrative_blocks.dart';
import 'thai_beta_narrative_confidence.dart';
import 'thai_beta_narrative_domain.dart';
import 'thai_beta_narrative_formatting.dart';

/// Query parameters for curated block selection.
class CuratedBlockQuery {
  const CuratedBlockQuery({
    required this.section,
    required this.primaryThemeId,
    this.secondaryThemeId,
    this.domain,
    this.confidence = 1.0,
    this.hasBirthTime = true,
    this.usedBlockIds = const {},
    this.usedTextKeys = const {},
    this.seed = 0,
  });

  final CuratedNarrativeSection section;
  final String primaryThemeId;
  final String? secondaryThemeId;
  final ThaiBetaLifeDomain? domain;
  final double confidence;
  final bool hasBirthTime;
  final Set<String> usedBlockIds;
  final Set<String> usedTextKeys;
  final int seed;
}

abstract final class ThaiBetaCuratedBlockSelector {
  static CuratedBlockSelection select(CuratedBlockQuery query) {
    final primaryTag =
        ThaiMirrorEvidenceComposer.facetForThemeId(query.primaryThemeId).name;
    final secondaryTag = query.secondaryThemeId == null
        ? null
        : ThaiMirrorEvidenceComposer.facetForThemeId(
            query.secondaryThemeId!,
          ).name;

    final candidates = ThaiBetaCuratedNarrativeBlocks.all
        .where((b) => b.section == query.section)
        .where((b) => query.domain == null || b.domain == null || b.domain == query.domain)
        .where((b) => !query.usedBlockIds.contains(b.id))
        .where((b) => _birthTimeOk(b, query.hasBirthTime))
        .toList();

    candidates.sort((a, b) => a.id.compareTo(b.id));

    final levels = <int>[
      if (query.secondaryThemeId != null) 1,
      if (query.secondaryThemeId != null) 2,
      3,
      4,
      5,
    ];

    for (final level in levels) {
      final matched = candidates.where((b) {
        final score = _matchScore(
          block: b,
          query: query,
          primaryTag: primaryTag,
          secondaryTag: secondaryTag,
          level: level,
        );
        return score > 0;
      }).toList();

      if (matched.isEmpty) continue;

      matched.sort((a, b) {
        final scoreA = _matchScore(
          block: a,
          query: query,
          primaryTag: primaryTag,
          secondaryTag: secondaryTag,
          level: level,
        );
        final scoreB = _matchScore(
          block: b,
          query: query,
          primaryTag: primaryTag,
          secondaryTag: secondaryTag,
          level: level,
        );
        final byScore = scoreB.compareTo(scoreA);
        if (byScore != 0) return byScore;
        return a.id.compareTo(b.id);
      });

      final start = (query.seed.abs() + (query.domain?.index ?? 0)) % matched.length;
      for (var k = 0; k < matched.length; k++) {
        final block = matched[(start + k) % matched.length];
        if (_textNotUsed(block, query.usedTextKeys)) {
          return CuratedBlockSelection(block: block, matchLevel: level);
        }
      }
    }

    final fallback = _sectionFallback(query);
    assert(fallback.section == query.section);
    return CuratedBlockSelection(block: fallback, matchLevel: 5);
  }

  static CuratedNarrativeBlock _sectionFallback(CuratedBlockQuery query) {
    final domain = query.domain ?? ThaiBetaLifeDomain.work;

    final domainMatch = _findSectionFallback(
      section: query.section,
      domain: domain,
      hasBirthTime: query.hasBirthTime,
      requireDomainMatch: true,
      usedBlockIds: query.usedBlockIds,
    );
    if (domainMatch != null) return domainMatch;

    // Any unused same-domain block (e.g. themed advice whose tags did not
    // match) before reusing a domain default or crossing domains.
    final unusedSameDomain = ThaiBetaCuratedNarrativeBlocks.all
        .where(
          (b) =>
              b.section == query.section &&
              b.domain == domain &&
              _birthTimeOk(b, query.hasBirthTime) &&
              !query.usedBlockIds.contains(b.id),
        )
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (unusedSameDomain.isNotEmpty) return unusedSameDomain.first;

    // Prefer unused domain-agnostic fallbacks before reusing a domain default.
    final generalUnused = ThaiBetaCuratedNarrativeBlocks.all
        .where(
          (b) =>
              b.section == query.section &&
              b.domain == null &&
              b.relationshipType == CuratedRelationshipType.fallback &&
              _birthTimeOk(b, query.hasBirthTime) &&
              !query.usedBlockIds.contains(b.id),
        )
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (generalUnused.isNotEmpty) return generalUnused.first;

    // Only cross-section unused fallback when the query has no domain.
    if (query.domain == null) {
      final sectionMatch = _findSectionFallback(
        section: query.section,
        domain: null,
        hasBirthTime: query.hasBirthTime,
        requireDomainMatch: false,
        usedBlockIds: query.usedBlockIds,
      );
      if (sectionMatch != null) return sectionMatch;
    }

    // Prefer correct-domain default even if already used over wrong-domain copy.
    return _defaultSectionFallback(query.section, domain, query.hasBirthTime);
  }

  static CuratedNarrativeBlock? _findSectionFallback({
    required CuratedNarrativeSection section,
    required ThaiBetaLifeDomain? domain,
    required bool hasBirthTime,
    required bool requireDomainMatch,
    Set<String> usedBlockIds = const {},
  }) {
    final matches = ThaiBetaCuratedNarrativeBlocks.all
        .where(
          (b) =>
              b.section == section &&
              b.relationshipType == CuratedRelationshipType.fallback &&
              _birthTimeOk(b, hasBirthTime) &&
              !usedBlockIds.contains(b.id),
        )
        .where(
          (b) =>
              !requireDomainMatch ||
              domain == null ||
              b.domain == domain,
        )
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    if (requireDomainMatch && domain != null) {
      final exact = matches.where((b) => b.domain == domain).toList();
      if (exact.isNotEmpty) return exact.first;
      return null;
    }

    return matches.isNotEmpty ? matches.first : null;
  }

  static CuratedNarrativeBlock _defaultSectionFallback(
    CuratedNarrativeSection section,
    ThaiBetaLifeDomain domain,
    bool hasBirthTime,
  ) {
    final fallbackId = switch (section) {
      CuratedNarrativeSection.hero =>
        hasBirthTime ? 'fallback_hero_v1' : 'hero_no_time_cautious_v1',
      CuratedNarrativeSection.strength => hasBirthTime
          ? 'fallback_strength_v1'
          : 'fallback_strength_no_time',
      CuratedNarrativeSection.domain => 'fallback_${domain.aspectKey}_domain',
      CuratedNarrativeSection.dashboard =>
        'fallback_${domain.aspectKey}_dashboard',
      CuratedNarrativeSection.advice =>
        'advice_${domain.aspectKey}_fallback_v1',
    };

    return ThaiBetaCuratedNarrativeBlocks.all.firstWhere(
      (b) => b.id == fallbackId && b.section == section,
    );
  }

  static int _matchScore({
    required CuratedNarrativeBlock block,
    required CuratedBlockQuery query,
    required String primaryTag,
    required String? secondaryTag,
    required int level,
  }) {
    final minimum = ThaiBetaNarrativeConfidence.effectiveMinimum(
      declaredMinimum: block.minimumConfidence,
      requiresBirthTime: block.requiresBirthTime,
      safeWithoutBirthTime: block.safeWithoutBirthTime,
    );
    if (query.confidence < minimum) return 0;

    switch (level) {
      case 1:
        if (!_hasPrimary(block, query.primaryThemeId)) return 0;
        if (!_hasSecondary(block, query.secondaryThemeId!)) return 0;
        if (query.domain != null && block.domain != query.domain) return 0;
        return 100;
      case 2:
        if (!_hasPrimary(block, query.primaryThemeId)) return 0;
        if (!_hasSecondary(block, query.secondaryThemeId!)) return 0;
        if (block.domain != null &&
            query.domain != null &&
            block.domain != query.domain) {
          return 0;
        }
        return 80;
      case 3:
        if (!_hasPrimary(block, query.primaryThemeId)) return 0;
        if (query.domain != null && block.domain != query.domain) return 0;
        if (block.secondaryTraitIds.isNotEmpty ||
            block.secondarySemanticTags.isNotEmpty) {
          return 0;
        }
        return 60;
      case 4:
        if (!block.primarySemanticTags.contains(primaryTag)) return 0;
        if (query.domain != null && block.domain != query.domain) return 0;
        if (block.primaryTraitIds.isNotEmpty) return 0;
        return 40;
      case 5:
        if (block.relationshipType != CuratedRelationshipType.fallback) {
          return 0;
        }
        if (query.domain != null && block.domain != query.domain) return 0;
        return 20;
      default:
        return 0;
    }
  }

  static bool _hasPrimary(CuratedNarrativeBlock block, String themeId) {
    if (block.primaryTraitIds.contains(themeId)) return true;
    final tag = ThaiMirrorEvidenceComposer.facetForThemeId(themeId).name;
    return block.primarySemanticTags.contains(tag);
  }

  static bool _hasSecondary(CuratedNarrativeBlock block, String themeId) {
    if (block.secondaryTraitIds.contains(themeId)) return true;
    final tag = ThaiMirrorEvidenceComposer.facetForThemeId(themeId).name;
    return block.secondarySemanticTags.contains(tag);
  }

  static bool _birthTimeOk(CuratedNarrativeBlock block, bool hasBirthTime) {
    if (hasBirthTime) return true;
    if (block.requiresBirthTime) return false;
    return block.safeWithoutBirthTime;
  }

  static bool _textNotUsed(
    CuratedNarrativeBlock block,
    Set<String> usedTextKeys,
  ) {
    for (final text in _blockTexts(block)) {
      final key = ThaiBetaNarrativeFormatting.normalizedKey(text);
      if (key.length > 8 && usedTextKeys.contains(key)) return false;
    }
    return true;
  }

  static Iterable<String> _blockTexts(CuratedNarrativeBlock block) sync* {
    if (block.observableBehavior != null) yield block.observableBehavior!;
    if (block.strengthText != null) yield block.strengthText!;
    if (block.tensionText != null) yield block.tensionText!;
    if (block.adviceText != null) yield block.adviceText!;
    if (block.domainOverview != null) yield block.domainOverview!;
    if (block.domainWhy != null) yield block.domainWhy!;
    if (block.dashboardCurrent != null) yield block.dashboardCurrent!;
    if (block.dashboardWhy != null) yield block.dashboardWhy!;
    yield* block.heroSentences;
  }
}
