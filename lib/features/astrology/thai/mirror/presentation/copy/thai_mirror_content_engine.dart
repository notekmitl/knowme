import 'thai_mirror_content_context.dart';
import 'thai_mirror_lagna_influence.dart';
import 'thai_mirror_theme_phrases.dart';
import 'thai_mirror_theme_variants.dart';

/// Combination-aware + lagna-personalized consumer copy engine (V2).
abstract final class ThaiMirrorContentEngine {
  static const _aspectLabels = {
    'work': 'การงาน',
    'money': 'การเงิน',
    'love': 'ความรัก',
    'health': 'สุขภาพ',
    'luck': 'โชคและโอกาส',
  };

  static String aspectLabel(String aspect) => _aspectLabel(aspect);

  static String _aspectLabel(String aspect) =>
      _aspectLabels[aspect] ?? aspect;
  static String combinationStrengthSuffix({
    required String primaryId,
    required String partnerId,
    required int seed,
  }) {
    if (primaryId == partnerId) return '';
    final partner = ThaiMirrorThemePhrases.phrase(partnerId);
    final shorts = [
      'ยิ่งเมื่อคุณ${partner.headlinePart}',
      'โดยเฉพาะคู่กับ${partner.tag}',
      'ผสาน${partner.tag}แล้วจุดนี้เด่นขึ้น',
      '${partner.heroDetail} — ช่วยเสริมจุดนี้',
    ];
    return shorts[seed.abs() % shorts.length];
  }

  static ThemeCopyVariant selectStrengthVariant({
    required String themeId,
    required ThaiMirrorContentContext ctx,
    required int cardIndex,
  }) {
    final partners = ctx.allThemeIds.where((id) => id != themeId).toList();
    final partner = partners.isEmpty
        ? themeId
        : partners[ctx.seedFor(
            primaryThemeId: themeId,
            slot: 'strength_partner',
            offset: cardIndex,
          ).abs() % partners.length];

    final seed = ctx.seedFor(
      primaryThemeId: themeId,
      partnerThemeId: partner,
      slot: 'strength_$cardIndex',
    );
    final variants = ThaiMirrorThemeVariants.strengthVariants(themeId);
    final variant = variants[
        (ctx.profileSeed ^ seed ^ partner.hashCode ^ (cardIndex + 1)).abs() %
            variants.length];
    final combo = combinationStrengthSuffix(
      primaryId: themeId,
      partnerId: partner,
      seed: seed + 3,
    );
    final lagna = ThaiMirrorLagnaInfluence.strengthVariant(
      ctx.lagnaKey,
      seed + cardIndex,
    );
    final partnerPhrase = ThaiMirrorThemePhrases.phrase(partner);
    final partnerDetail = partnerPhrase.heroDetail;

    final bodyParts = <String>[variant.body];
    if (combo.isNotEmpty) bodyParts.add(combo);
    if (partnerDetail.isNotEmpty) bodyParts.add(partnerDetail);
    if (combo.isNotEmpty) bodyParts.add(combo);
    if (lagna.isNotEmpty) bodyParts.add(lagna);

    return ThemeCopyVariant(title: variant.title, body: bodyParts.join(' '));
  }

  static String selectAdvice({
    required String growthThemeId,
    required ThaiMirrorContentContext ctx,
  }) {
    final variants = ThaiMirrorThemeVariants.adviceVariants(growthThemeId);
    if (variants.isEmpty) {
      for (final themeId in ctx.allThemeIds) {
        final alt = ThaiMirrorThemeVariants.adviceVariants(themeId);
        if (alt.isNotEmpty) {
          return _composeAdvice(
            growthThemeId: themeId,
            baseAdvice: alt[ctx.seedFor(primaryThemeId: themeId, slot: 'advice').abs() % alt.length],
            ctx: ctx,
          );
        }
      }
      return '';
    }

    final seed = ctx.seedFor(
      primaryThemeId: growthThemeId,
      slot: 'advice_full',
    );
    final baseAdvice = variants[seed.abs() % variants.length];
    return _composeAdvice(
      growthThemeId: growthThemeId,
      baseAdvice: baseAdvice,
      ctx: ctx,
    );
  }

  static String _composeAdvice({
    required String growthThemeId,
    required String baseAdvice,
    required ThaiMirrorContentContext ctx,
  }) {
    final seed = ctx.seedFor(
      primaryThemeId: growthThemeId,
      slot: 'advice_compose',
    );
    final themes = ctx.topThemeIds.isNotEmpty ? ctx.topThemeIds : ctx.coreThemeIds;
    if (themes.isEmpty) return baseAdvice;

    final t1 = themes[seed.abs() % themes.length];
    final t2 = themes[(seed.abs() + 5) % themes.length];
    final t3 = themes[(seed.abs() + 11) % themes.length];
    final p1 = ThaiMirrorThemePhrases.phrase(t1);
    final p2 = ThaiMirrorThemePhrases.phrase(t2);
    final p3 = ThaiMirrorThemePhrases.phrase(t3);

    final weaveTemplates = [
      '${p1.heroDetail} — สอดคล้องกับ${p2.heroDetail}',
      'เมื่อ${p1.headlinePart}พบ${p2.headlinePart} ${p3.heroDetail}',
      'ผสาน${p1.tag}กับ${p2.tag} แล้ว${p3.headlinePart}จะช่วยได้',
      'จาก${p1.tag}ไป${p2.tag}: ${p3.heroDetail}',
      '${p2.heroDetail} เสริม${p1.headlinePart}ในช่วงนี้',
    ];
    final weave = weaveTemplates[(seed.abs() + 1) % weaveTemplates.length];
    final lagna = ThaiMirrorLagnaInfluence.adviceVariant(ctx.lagnaKey, seed + 2);

    return [baseAdvice, weave, if (lagna.isNotEmpty) lagna]
        .where((s) => s.isNotEmpty)
        .join(' ');
  }

  static String selectDashboardHint({
    required String aspect,
    required String themeId,
    required ThaiMirrorContentContext ctx,
    required int aspectOffset,
    String? growthThemeId,
  }) {
    final partners = ctx.allThemeIds.where((id) => id != themeId).toList();
    final partner = partners.isEmpty
        ? themeId
        : partners[(ctx.seedFor(
                  primaryThemeId: themeId,
                  slot: 'dash_partner_$aspect',
                  offset: aspectOffset,
                ).abs()) %
                partners.length];

    final seed = ctx.seedFor(
      primaryThemeId: themeId,
      partnerThemeId: partner,
      slot: 'dash_$aspect',
      offset: aspectOffset,
    );

    final pool = <String>[];
    final phrase = ThaiMirrorThemePhrases.phrase(themeId);
    final partnerPhrase = ThaiMirrorThemePhrases.phrase(partner);

    pool.addAll(ThaiMirrorThemeVariants.aspectHintVariants(themeId, aspect));
    for (final hint in ThaiMirrorThemeVariants.aspectHintVariants(partner, aspect)) {
      pool.add('เมื่อ${partnerPhrase.headlinePart}: $hint');
    }

    const aspects = ['work', 'money', 'love', 'health', 'luck'];
    for (final cross in aspects) {
      if (cross == aspect) continue;
      final crossHints = ThaiMirrorThemeVariants.aspectHintVariants(partner, cross);
      if (crossHints.isNotEmpty) {
        pool.add(
          '${crossHints[seed.abs() % crossHints.length]} — เชื่อมกับ${_aspectLabel(aspect)}',
        );
      }
    }

    final lagna = ThaiMirrorLagnaInfluence.dashboardVariant(
      ctx.lagnaKey,
      aspect,
      seed + aspectOffset,
    );
    if (lagna.isNotEmpty) pool.add(lagna);

    if (growthThemeId != null) {
      pool.addAll(ThaiMirrorThemeVariants.aspectHintVariants(growthThemeId, aspect));
      final growthPhrase = ThaiMirrorThemePhrases.phrase(growthThemeId);
      pool.add('แนวเติบโต${growthPhrase.tag}: ${growthPhrase.heroDetail}');
    }

    pool.add('${phrase.heroDetail} — ${_aspectLabel(aspect)}');
    pool.add('${partnerPhrase.heroDetail} — ส่งผลต่อ${_aspectLabel(aspect)}');

    final unique = pool.where((s) => s.isNotEmpty).toSet().toList();
    if (unique.isEmpty) return '';
    final pick = (seed.abs() + ctx.profileSeed * 31 + aspectOffset * 17) % unique.length;
    return unique[pick];
  }

  static String heroHeadlineTail(ThaiMirrorContentContext ctx) {
    final seed = ctx.seedFor(primaryThemeId: 'hero', slot: 'headline_tail');
    return ThaiMirrorLagnaInfluence.headlineVariant(ctx.lagnaKey, seed);
  }

  static String heroSummaryAccent(ThaiMirrorContentContext ctx, int index) {
    final seed = ctx.seedFor(
      primaryThemeId: ctx.coreThemeIds.isNotEmpty
          ? ctx.coreThemeIds[index % ctx.coreThemeIds.length]
          : 'hero',
      slot: 'hero_accent',
      offset: index,
    );
    final lagna = ThaiMirrorLagnaInfluence.heroAccentVariant(ctx.lagnaKey, seed);
    if (lagna.isEmpty) return '';
    final partners = ctx.coreThemeIds;
    if (partners.isEmpty) return lagna;
    final partnerId = partners[(seed.abs()) % partners.length];
    final partner = ThaiMirrorThemePhrases.phrase(partnerId).headlinePart;
    final joins = [
      '$lagna — ผสานกับ$partner',
      '$partner ช่วยเสริม$lagna',
      'จังหวะ$partnerทำให้$lagna',
    ];
    return joins[seed.abs() % joins.length];
  }
}
