import 'package:flutter/material.dart' show Color, Icons, IconData;

import '../models/thai_mirror_consumer_view_state.dart';
import 'thai_mirror_consumer_copy.dart';
import 'thai_mirror_content_context.dart';
import 'thai_mirror_evidence_composer.dart';
import 'thai_mirror_theme_phrases.dart';
import 'thai_mirror_theme_variants.dart';

/// Long-form consumer report copy.
///
/// V7 moves generation from *theme-driven* to *evidence-combination driven*:
/// the variable, profile-defining text (hero, section interpretation, internal
/// contradictions, micro-stories, signature insight, closing) is assembled by
/// [ThaiMirrorEvidenceComposer] from the weighted facet profile, so two people
/// who share a top theme but differ on the second no longer read alike. The
/// static scaffold (section labels / icons / accents / transitions) is kept for
/// visual identity. No engine, scoring or evidence calculation is touched.
abstract final class ThaiMirrorReportCopy {
  static EvidenceProfile _profile(ThaiMirrorContentContext ctx) =>
      ThaiMirrorEvidenceComposer.profileFor(
        ctx.coreThemeIds.isNotEmpty ? ctx.coreThemeIds : ctx.allThemeIds,
      );

  /// A strong, *combination-derived* emotional hero headline.
  static String buildEmotionalHeadline({
    required ThaiMirrorContentContext ctx,
    required List<String> coreThemeIds,
  }) {
    final themes = coreThemeIds.isNotEmpty ? coreThemeIds : ctx.allThemeIds;
    if (themes.isEmpty) return ThaiMirrorConsumerHeroState.fallbackHeadline;
    final profile = ThaiMirrorEvidenceComposer.profileFor(themes);
    return ThaiMirrorEvidenceComposer.headline(profile, ctx.profileSeed, themes);
  }

  /// Hero summary — three evidence signals woven into interpretation.
  static String buildHeroSummary({
    required ThaiMirrorContentContext ctx,
    required List<String> coreThemeIds,
  }) {
    final themes = coreThemeIds.isNotEmpty ? coreThemeIds : ctx.allThemeIds;
    if (themes.isEmpty) return ThaiMirrorConsumerHeroState.fallbackSummary;
    final profile = ThaiMirrorEvidenceComposer.profileFor(themes);
    return ThaiMirrorEvidenceComposer.heroSummary(
        profile, ctx.profileSeed, themes);
  }

  /// The "heart of the report" — one passage unique to this evidence combo.
  static ThaiMirrorSignatureInsightState buildSignatureInsight({
    required ThaiMirrorContentContext ctx,
    required List<String> coreThemeIds,
  }) {
    final themes = coreThemeIds.isNotEmpty ? coreThemeIds : ctx.allThemeIds;
    if (themes.isEmpty) {
      return const ThaiMirrorSignatureInsightState(
        eyebrow: '',
        body: '',
        signature: '',
      );
    }
    final profile = ThaiMirrorEvidenceComposer.profileFor(themes);
    final ins =
        ThaiMirrorEvidenceComposer.signatureInsight(profile, ctx.profileSeed);
    return ThaiMirrorSignatureInsightState(
      eyebrow: ins.eyebrow,
      body: ins.body,
      signature: ins.signature,
    );
  }

  /// Richer expanded body for a strength card (kept theme-anchored).
  static String buildExpandedStrength({
    required String themeId,
    required ThaiMirrorContentContext ctx,
  }) {
    final phrase = ThaiMirrorThemePhrases.phrase(themeId);
    final variants = ThaiMirrorThemeVariants.strengthVariants(themeId);
    final facet = ThaiMirrorEvidenceComposer.facetForThemeId(themeId);

    final intro = 'สิ่งที่คนมักสัมผัสได้จากคุณก่อนเลยคือ **${phrase.tag}** — '
        'คุณ${phrase.headlinePart} ${_lower(phrase.heroDetail)}';
    final detail = variants.length > 1
        ? _cap(variants[1].body)
        : _cap(phrase.strengthBody);
    final discovery = ThaiMirrorEvidenceComposer.discovery(facet, themeId.hashCode);
    final example = variants.length > 2
        ? 'อย่างเช่น ${_lower(variants[2].body)}'
        : 'อย่างเช่น ในวันที่ทุกอย่างชุลมุน คุณมักเป็นคนที่ยังตั้งหลักได้';

    return [
      _sanitize(intro),
      _sanitize(detail),
      discovery,
      _sanitize(example),
    ].where((s) => s.isNotEmpty).join('\n\n');
  }

  /// Builds all long-form narrative life sections in story order — every
  /// variable line is composed from this profile's evidence combination.
  static List<ThaiMirrorNarrativeSectionState> buildNarrativeSections({
    required ThaiMirrorContentContext ctx,
    required Map<String, List<String>> aspectThemeIds,
  }) {
    final profile = _profile(ctx);
    final sections = <ThaiMirrorNarrativeSectionState>[];
    final orderedFacets = profile.orderedFacets;
    final usedFacets = <ReportFacet>{};

    for (var i = 0; i < _aspects.length; i++) {
      final aspect = _aspects[i];
      final pool = aspectThemeIds[aspect.key] ?? const <String>[];

      // Facet lens for this life area. Prefer the aspect's own themed evidence,
      // but never repeat a facet that an earlier section already used until all
      // of the profile's facets have been shown — so each life area is read
      // through a *different real* side of the person instead of collapsing to
      // the single dominant facet (which produced the same pull-quote / "why" /
      // tension / scene across every section).
      ReportFacet fA = pool.isNotEmpty
          ? ThaiMirrorEvidenceComposer.facetForThemeId(
              _pick(pool, const <String>[], ctx.profileSeed, 0))
          : orderedFacets[i % orderedFacets.length];
      if (usedFacets.contains(fA)) {
        // Cycle: once every facet has appeared, allow reuse (spaced out).
        if (usedFacets.length >= orderedFacets.length) usedFacets.clear();
        fA = orderedFacets.firstWhere(
          (f) => !usedFacets.contains(f),
          orElse: () => orderedFacets[i % orderedFacets.length],
        );
      }
      usedFacets.add(fA);

      // The secondary lens is the facet *after* fA in the evidence order, so it
      // both differs from fA (no "X และ X") and varies section to section.
      final fB = orderedFacets.length > 1
          ? orderedFacets[(orderedFacets.indexOf(fA) + 1) % orderedFacets.length]
          : profile.contrastFor(fA);

      final seed = ctx.profileSeed ^
          (aspect.key.hashCode * 17) ^
          (fA.index * 131) ^
          (fB.index * 71) ^
          (i * 911);

      final overview = ThaiMirrorEvidenceComposer.sectionOverview(
        area: aspect.key,
        primary: fA,
        secondary: fB,
        profile: profile,
        seed: seed,
      );

      var tension = '';
      if (aspect.hasTension) {
        final contrast = fB != fA ? fB : profile.contrastFor(fA);
        tension = ThaiMirrorEvidenceComposer.contradiction(fA, contrast, seed);
      }

      var discovery = '';
      if (aspect.hasDiscovery) {
        discovery = ThaiMirrorEvidenceComposer.discovery(fA, seed);
      }

      // The pull-quote alternates between the facet's signature and discovery
      // lines. When this section also shows a discovery line, force the
      // signature so the same sentence never appears twice in one card.
      final pullQuote = aspect.hasDiscovery
          ? ThaiMirrorEvidenceComposer.signatureQuote(fA)
          : ThaiMirrorEvidenceComposer.pullQuote(fA, seed);

      var reasoningTitle = '';
      var reasoningSignals = const <String>[];
      if (aspect.hasReasoning) {
        final r = ThaiMirrorEvidenceComposer.reasoning(fA, seed);
        reasoningTitle = r.title;
        reasoningSignals = r.signals;
      }

      sections.add(
        ThaiMirrorNarrativeSectionState(
          label: aspect.label,
          icon: aspect.icon,
          accent: aspect.accent,
          transitionIn: aspect.transition,
          pullQuote: pullQuote,
          overview: overview,
          tension: tension,
          discovery: discovery,
          reasoningTitle: reasoningTitle,
          reasoningSignals: reasoningSignals,
          whyItAppears: ThaiMirrorEvidenceComposer.effect(
            area: aspect.key,
            facet: fA,
            seed: seed,
          ),
          advice: ThaiMirrorEvidenceComposer.advice(
            area: aspect.key,
            facet: fA,
            seed: seed,
          ),
          example: ThaiMirrorEvidenceComposer.microStory(
            area: aspect.key,
            facet: fA,
            seed: seed,
          ),
          reflectionQuestion: ThaiMirrorEvidenceComposer.reflectionQuestion(
            area: aspect.key,
            facet: fA,
            seed: seed,
          ),
        ),
      );
    }
    return sections;
  }

  /// Shareable "ถ้ามีคนถามว่าคุณเป็นคนแบบไหน" summary — points derived from the
  /// weighted facet order so they vary per profile.
  static ThaiMirrorReflectionSummaryState buildReflectionSummary({
    required ThaiMirrorContentContext ctx,
    required List<String> coreThemeIds,
  }) {
    final themes = coreThemeIds.isNotEmpty ? coreThemeIds : ctx.allThemeIds;
    final profile = ThaiMirrorEvidenceComposer.profileFor(themes);
    var points = ThaiMirrorEvidenceComposer.summaryPoints(profile);

    if (points.length < 3) {
      final seen = points.toSet();
      for (final id in themes) {
        if (points.length >= 5) break;
        final phrase = ThaiMirrorThemePhrases.phrase(id);
        final clean = _sanitize('คนที่${phrase.headlinePart}');
        if (clean.isEmpty || !seen.add(clean)) continue;
        points.add(clean);
      }
    }

    return ThaiMirrorReflectionSummaryState(
      title: 'ถ้ามีคนถามว่า “คุณเป็นคนแบบไหน”',
      intro: 'ดวงไทยจะตอบประมาณนี้',
      points: points,
    );
  }

  /// Quiet closing thought, flavoured by the dominant facet + tone.
  static ThaiMirrorClosingMessageState buildClosingMessage({
    required ThaiMirrorContentContext ctx,
    required List<String> coreThemeIds,
  }) {
    final themes = coreThemeIds.isNotEmpty ? coreThemeIds : ctx.allThemeIds;
    if (themes.isEmpty) {
      return const ThaiMirrorClosingMessageState(
        eyebrow: 'ก่อนจะปิดหน้านี้',
        message: 'วันนี้คุณไม่ต้องเปลี่ยนอะไรเลยก็ได้\n'
            'แค่กลับมาใจดีกับตัวเองอีกสักนิด\n'
            'เท่านั้นเอง',
        signature: 'เก็บประโยคไหนสักประโยคในนี้ไว้ก็พอ',
      );
    }
    final profile = ThaiMirrorEvidenceComposer.profileFor(themes);
    final c = ThaiMirrorEvidenceComposer.closing(profile, ctx.profileSeed);
    return ThaiMirrorClosingMessageState(
      eyebrow: c.eyebrow,
      message: c.message,
      signature: c.signature,
    );
  }

  // --- aspect scaffold (visual identity only) -----------------------------

  static const _cWork = Color(0xFF3D5AFE);
  static const _cMoney = Color(0xFF2E7D32);
  static const _cLove = Color(0xFFE5396B);
  static const _cFamily = Color(0xFFF57C00);
  static const _cSocial = Color(0xFF00897B);
  static const _cHealth = Color(0xFF43A047);
  static const _cRhythm = Color(0xFF5E35B1);
  static const _cPressure = Color(0xFF455A64);
  static const _cCompat = Color(0xFF00ACC1);
  static const _cGrowth = Color(0xFF7CB342);

  static const List<_ReportAspect> _aspects = [
    _ReportAspect(
      key: 'work',
      label: 'ชีวิตด้านการงาน',
      icon: Icons.work_outline_rounded,
      accent: _cWork,
      transition:
          'เริ่มจากเรื่องที่เห็นชัดที่สุดในตัวคุณก่อน — วิธีที่คุณลงมือทำสิ่งต่าง ๆ',
      hasTension: true,
      hasReasoning: true,
    ),
    _ReportAspect(
      key: 'money',
      label: 'ชีวิตด้านการเงิน',
      icon: Icons.account_balance_wallet_outlined,
      accent: _cMoney,
      transition:
          'และวิธีที่คุณทำงานแบบนี้ ก็แอบส่งผลต่อวิธีที่คุณมองเรื่องเงินด้วย',
      hasDiscovery: true,
    ),
    _ReportAspect(
      key: 'love',
      label: 'ชีวิตด้านความรัก',
      icon: Icons.favorite_outline_rounded,
      accent: _cLove,
      transition:
          'คนที่จริงจังกับงานและเงินแบบคุณ มักมีอีกด้านที่อ่อนโยนกว่าที่คิด — ในเรื่องความรัก',
      hasTension: true,
    ),
    _ReportAspect(
      key: 'family',
      label: 'ชีวิตด้านครอบครัว',
      icon: Icons.home_outlined,
      accent: _cFamily,
      transition:
          'และความอ่อนโยนที่คุณมีให้คนรัก ก็มักเป็นด้านเดียวกับที่คุณมีให้คนที่บ้าน',
    ),
    _ReportAspect(
      key: 'social',
      label: 'เพื่อนและสังคม',
      icon: Icons.groups_2_outlined,
      accent: _cSocial,
      transition:
          'จากคนใกล้ตัวที่สุด ลองขยับออกมามองความสัมพันธ์กับเพื่อนและผู้คน',
      hasTension: true,
      hasReasoning: true,
    ),
    _ReportAspect(
      key: 'health',
      label: 'สุขภาพและพลังใจ',
      icon: Icons.eco_outlined,
      accent: _cHealth,
      transition:
          'ใช้ใจไปกับงานและผู้คนมาขนาดนี้ ลองหันกลับมาฟังร่างกายและใจของตัวเองบ้าง',
      hasDiscovery: true,
    ),
    _ReportAspect(
      key: 'rhythm',
      label: 'จังหวะชีวิตและโอกาส',
      icon: Icons.schedule_rounded,
      accent: _cRhythm,
      transition:
          'และเมื่อเริ่มดูแลตัวเองเป็น จังหวะของชีวิตก็จะค่อย ๆ ชัดขึ้น',
      hasDiscovery: true,
    ),
    _ReportAspect(
      key: 'pressure',
      label: 'เมื่ออยู่ภายใต้ความกดดัน',
      icon: Icons.cyclone,
      accent: _cPressure,
      transition:
          'แต่ชีวิตไม่ได้มีแต่วันที่ราบรื่น ลองดูว่าคุณเป็นอย่างไรในวันที่หนัก',
      hasTension: true,
      hasReasoning: true,
    ),
    _ReportAspect(
      key: 'compatibility',
      label: 'คนแบบไหนเข้ากับคุณได้ดี',
      icon: Icons.diversity_3_outlined,
      accent: _cCompat,
      transition:
          'เมื่อเข้าใจตัวเองทั้งในวันดีและวันร้ายแล้ว คำถามต่อไปคือ ใครที่เข้ากับคุณได้จริง',
      hasDiscovery: true,
    ),
    _ReportAspect(
      key: 'growth',
      label: 'แนวทางการเติบโต',
      icon: Icons.terrain_rounded,
      accent: _cGrowth,
      transition:
          'และทั้งหมดนี้ ก็พามาถึงเรื่องสุดท้าย — คุณกำลังจะเติบโตไปทางไหน',
      hasTension: true,
    ),
  ];

  // --- helpers ------------------------------------------------------------

  static String _pick(
    List<String> pool,
    List<String> fallback,
    int seed,
    int slot, {
    String? exclude,
  }) {
    final candidates = <String>[
      ...pool,
      ...fallback.where((id) => !pool.contains(id)),
    ].where((id) => id != exclude).toList();
    if (candidates.isEmpty) return exclude ?? 'independent';
    final index = (seed.abs() + slot * 7) % candidates.length;
    return candidates[index];
  }

  static String _sanitize(String text) =>
      ThaiMirrorConsumerCopy.sanitizeDisplayText(text);

  static String _cap(String text) => text.trim();

  static String _lower(String text) {
    final t = text.trim();
    if (t.startsWith('คุณ')) return t.substring(3);
    return t;
  }
}

class _ReportAspect {
  const _ReportAspect({
    required this.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.transition,
    this.hasTension = false,
    this.hasDiscovery = false,
    this.hasReasoning = false,
  });

  final String key;
  final String label;
  final IconData icon;
  final Color accent;
  final String transition;
  final bool hasTension;
  final bool hasDiscovery;
  final bool hasReasoning;
}
