/// WOW opening composer for Thai Beta hero section.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';

import 'thai_beta_narrative_dedupe.dart';
import 'thai_beta_narrative_formatting.dart';
import 'thai_beta_narrative_specificity.dart';
import 'thai_beta_narrative_trace.dart';

abstract final class ThaiBetaNarrativeHero {
  /// Builds a 5-part WOW opening from existing engine signals only.
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
  }) {
    if (orderedThemeIds.isEmpty) {
      return (hero: sourceHero, trace: const []);
    }

    final profile = ThaiMirrorEvidenceComposer.profileFor(orderedThemeIds);
    final primaryFacet = profile.primary;
    final contrastFacet = profile.contrastFor(primaryFacet);

    final primaryThemeId = orderedThemeIds.first;
    final secondaryThemeId =
        orderedThemeIds.length > 1 ? orderedThemeIds[1] : null;
    final primaryPhrase = ThaiMirrorThemePhrases.phrase(primaryThemeId);
    final secondaryPhrase = secondaryThemeId != null
        ? ThaiMirrorThemePhrases.phrase(secondaryThemeId)
        : null;

    final used = <String>{};
    final parts = <String>[];

    // 1. What others see first (external behavior).
    parts.add(
      _addUnique(
        used,
        'คนที่เพิ่งรู้จักคุณมักสังเกตว่า ${primaryPhrase.tag} — '
            '${primaryPhrase.heroDetail}',
      ),
    );

    // 2. Inner drive (primary + secondary link).
    if (secondaryPhrase != null &&
        primaryFacet != ThaiMirrorEvidenceComposer.facetForThemeId(
          secondaryThemeId!,
        )) {
      parts.add(
        _addUnique(
          used,
          'เบื้องหลังนั้น คุณ${primaryPhrase.headlinePart} '
              'และยัง${secondaryPhrase.headlinePart}เมื่อสถานการณ์เร่ง',
        ),
      );
    } else {
      parts.add(
        _addUnique(
          used,
          ThaiMirrorEvidenceComposer.discovery(primaryFacet, profileSeed),
        ),
      );
    }

    // 3. Self-difference (contrast only when supported).
    if (contrastFacet != primaryFacet) {
      parts.add(
        _addUnique(
          used,
          ThaiMirrorEvidenceComposer.contradiction(
            primaryFacet,
            contrastFacet,
            profileSeed + 11,
          ),
        ),
      );
    }

    // 4. Observable behavior.
    parts.add(
      _addUnique(
        used,
        ThaiBetaNarrativeSpecificity.observableBehavior(
          themeId: primaryThemeId,
          seed: profileSeed + 3,
        ),
      ),
    );

    // 5. Reflective closing with grounded tension when caution exists.
    var closing =
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — '
        'ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ';
    if (cautionBody != null && cautionBody.trim().isNotEmpty) {
      closing =
          '${ThaiBetaNarrativeFormatting.normalize(cautionBody)} '
          'และนั่นไม่ได้หมายความว่าคุณอ่อนแอ — แค่เป็นจุดที่ควรดูแลตัวเองให้พอดี';
    }
    parts.add(ThaiBetaNarrativeFormatting.normalize(closing));

    final headline = ThaiBetaNarrativeSpecificity.composeTraitPair(
      primaryThemeId: primaryThemeId,
      secondaryThemeId: secondaryThemeId,
      seed: profileSeed,
    );

    var summary = parts.join('\n\n');
    if (!hasBirthTime) {
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
          secondaryThemeId: secondaryThemeId,
          relationship: 'primary+secondary',
          lifePeriod: lifePeriodLabel,
        ),
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'hero',
          field: 'summary',
          primaryThemeId: primaryThemeId,
          secondaryThemeId: secondaryThemeId,
          relationship: 'wow_opening',
          lifePeriod: lifePeriodLabel,
        ),
      ],
    );
  }

  static String _addUnique(Set<String> used, String text) {
    return ThaiBetaNarrativeDedupe.resolveUnique(
      text: text,
      used: used,
    );
  }
}
