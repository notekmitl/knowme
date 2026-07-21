/// WOW opening composer for Thai Beta hero section — V1.1 curated blocks.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';

import 'thai_beta_curated_block_selector.dart';
import 'thai_beta_curated_narrative_block.dart';
import 'thai_beta_narrative_dedupe.dart';
import 'thai_beta_narrative_formatting.dart';
import 'thai_beta_narrative_specificity.dart';
import 'thai_beta_narrative_trace.dart';

abstract final class ThaiBetaNarrativeHero {
  /// Builds a 3–5 sentence WOW opening from curated blocks.
  static ({
    ThaiMirrorConsumerHeroState hero,
    List<ThaiBetaNarrativeTraceEntry> trace,
  }) compose({
    required ThaiMirrorConsumerHeroState sourceHero,
    required List<String> orderedThemeIds,
    required int profileSeed,
    required bool hasBirthTime,
    String? cautionBody,
    String? lifePeriodLabel,
    Set<String> usedBlockIds = const {},
    Set<String> usedTextKeys = const {},
  }) {
    if (orderedThemeIds.isEmpty) {
      return (hero: sourceHero, trace: const []);
    }

    final primaryThemeId = orderedThemeIds.first;
    final secondaryThemeId =
        orderedThemeIds.length > 1 ? orderedThemeIds[1] : null;

    final primaryFacet =
        ThaiMirrorEvidenceComposer.facetForThemeId(primaryThemeId);
    final secondaryFacet = secondaryThemeId == null
        ? null
        : ThaiMirrorEvidenceComposer.facetForThemeId(secondaryThemeId);

    final hasDistinctSecondary = secondaryFacet != null &&
        secondaryFacet != primaryFacet &&
        !_areSemanticallySimilar(primaryFacet, secondaryFacet);

    final selection = ThaiBetaCuratedBlockSelector.select(
      CuratedBlockQuery(
        section: CuratedNarrativeSection.hero,
        primaryThemeId: primaryThemeId,
        secondaryThemeId: hasDistinctSecondary ? secondaryThemeId : null,
        hasBirthTime: hasBirthTime,
        usedBlockIds: usedBlockIds,
        usedTextKeys: usedTextKeys,
        seed: profileSeed,
        confidence: hasBirthTime ? 1.0 : 0.5,
      ),
    );

    final block = selection.block;
    var sentences = List<String>.from(block.heroSentences);

    if (sentences.length > 5) {
      sentences = sentences.take(5).toList();
    }
    if (sentences.length < 3 && block.observableBehavior != null) {
      sentences.add(block.observableBehavior!);
    }

    if (cautionBody != null &&
        cautionBody.trim().isNotEmpty &&
        sentences.length < 5) {
      sentences.add(
        '${ThaiBetaNarrativeFormatting.normalize(cautionBody)} '
        'และนั่นไม่ได้หมายความว่าคุณอ่อนแอ — แค่เป็นจุดที่ควรดูแลตัวเองให้พอดี',
      );
    }

    final headline = ThaiBetaNarrativeSpecificity.composeHeadlineFromBlock(
      primaryThemeId: primaryThemeId,
      secondaryThemeId: hasDistinctSecondary ? secondaryThemeId : null,
      block: block,
      seed: profileSeed,
    );
    final headlineKey = ThaiBetaNarrativeFormatting.normalizedKey(headline);

    final used = <String>{...usedTextKeys};
    final parts = <String>[];
    for (final sentence in sentences.take(5)) {
      if (parts.isEmpty &&
          ThaiBetaNarrativeFormatting.normalizedKey(sentence) == headlineKey) {
        continue;
      }
      final resolved = ThaiBetaNarrativeDedupe.resolveUnique(
        text: sentence,
        used: used,
      );
      if (resolved.isNotEmpty) {
        parts.add(resolved);
      }
    }

    var summary = parts.join('\n\n');
    if (!hasBirthTime && !summary.contains('ไม่มีเวลาเกิด')) {
      summary = ThaiBetaNarrativeFormatting.normalize(
        '$summary\n\n'
        'โดยไม่มีเวลาเกิด รายงานนี้เน้นภาพรวมจากวันเกิด '
        'และไม่ลงลึกเรื่องจังหวะชีวิตรายชั่วโมง',
      );
    }

    final tags = orderedThemeIds
        .take(3)
        .map((id) => ThaiMirrorThemePhrases.phrase(id).tag)
        .where((t) => t.isNotEmpty)
        .toList();

    return (
      hero: ThaiMirrorConsumerHeroState(
        headline: headline,
        summary: summary,
        tags: tags,
        identityBadge: sourceHero.identityBadge,
        identitySubtitle: sourceHero.identitySubtitle,
      ),
      trace: [
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'hero',
          field: 'headline',
          primaryThemeId: primaryThemeId,
          secondaryThemeId: hasDistinctSecondary ? secondaryThemeId : null,
          relationship: 'curated_block',
          lifePeriod: lifePeriodLabel,
          block: block,
          matchLevel: selection.matchLevel,
        ),
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'hero',
          field: 'summary',
          primaryThemeId: primaryThemeId,
          secondaryThemeId: hasDistinctSecondary ? secondaryThemeId : null,
          relationship: 'curated_hero',
          lifePeriod: lifePeriodLabel,
          block: block,
          matchLevel: selection.matchLevel,
        ),
      ],
    );
  }

  static bool _areSemanticallySimilar(ReportFacet a, ReportFacet b) {
    const similar = {
      ReportFacet.thinking: {ReportFacet.caution},
      ReportFacet.structure: {ReportFacet.caution},
      ReportFacet.drive: {ReportFacet.action},
      ReportFacet.action: {ReportFacet.drive},
      ReportFacet.people: {ReportFacet.emotion},
      ReportFacet.emotion: {ReportFacet.people},
    };
    return similar[a]?.contains(b) == true || similar[b]?.contains(a) == true;
  }
}
