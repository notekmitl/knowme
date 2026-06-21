import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/personality/bigfive/bigfive_traits.dart';

import '../domain/big_five_depth_tier.dart';
import '../domain/big_five_models.dart';
import '../domain/big_five_trait_id.dart';

class BigFiveTraitCardContent {
  const BigFiveTraitCardContent({
    required this.traitId,
    required this.productName,
    required this.bandLabel,
    required this.reflection,
  });

  final String traitId;
  final String productName;
  final String bandLabel;
  final String reflection;
}

class BigFiveResultViewContent {
  const BigFiveResultViewContent({
    required this.heroParagraphs,
    required this.traitCards,
    this.patternText,
    required this.depthHint,
    required this.disclosure,
  });

  final List<String> heroParagraphs;
  final List<BigFiveTraitCardContent> traitCards;
  final String? patternText;
  final String depthHint;
  final String disclosure;
}

/// Deterministic reflective copy for Big Five Result V1 (no scores in text).
abstract final class BigFiveResultContent {
  static BigFiveResultViewContent build(BigFiveResultSummary summary) {
    final lang = AppText.lang;
    final traitCards = [
      for (final trait in BigFiveTraitId.all)
        _traitCard(summary, trait, lang),
    ];

    return BigFiveResultViewContent(
      heroParagraphs: _heroParagraphs(summary),
      traitCards: traitCards,
      patternText: _patternText(summary),
      depthHint: _depthHint(summary),
      disclosure: AppText.t('big_five_result_disclosure')
          .replaceAll('{count}', '${summary.scoredQuestionCount}'),
    );
  }

  static BigFiveTraitCardContent _traitCard(
    BigFiveResultSummary summary,
    String traitId,
    String lang,
  ) {
    final band = summary.bandForTrait(traitId);
    return BigFiveTraitCardContent(
      traitId: traitId,
      productName: AppText.t('big_five_trait_${traitId}_name'),
      bandLabel: _bandLabel(band),
      reflection: _traitReflection(traitId, band, lang),
    );
  }

  static String _bandLabel(String band) => switch (band) {
        BigFiveBandId.emerging => AppText.t('big_five_band_emerging'),
        BigFiveBandId.strong => AppText.t('big_five_band_strong'),
        _ => AppText.t('big_five_band_moderate'),
      };

  static String _traitReflection(String traitId, String band, String lang) {
    final profile = bigFiveTraits[traitId];
    if (profile == null) {
      return AppText.t('big_five_trait_reflection_fallback');
    }

    final bucket = switch (band) {
      BigFiveBandId.emerging => 'low',
      BigFiveBandId.strong => 'high',
      _ => 'medium',
    };

    final raw = switch (bucket) {
      'high' => profile.high[lang] ?? profile.high['en'] ?? '',
      'low' => profile.low[lang] ?? profile.low['en'] ?? '',
      _ => profile.medium[lang] ?? profile.medium['en'] ?? '',
    };

    if (raw.isEmpty) return AppText.t('big_five_trait_reflection_fallback');
    return _softenReflection(raw);
  }

  static String _softenReflection(String text) {
    if (AppText.lang != 'th') return text;
    if (text.startsWith('คุณ')) {
      return 'อาจสะท้อนว่า${text.substring(2)}';
    }
    return text;
  }

  static List<String> _heroParagraphs(BigFiveResultSummary summary) {
    final patternId = _dominantPatternId(summary);
    final primary = AppText.t('big_five_hero_$patternId');
    final secondary = AppText.t('big_five_hero_support_$patternId');
    return [
      primary,
      if (secondary.trim().isNotEmpty) secondary,
    ];
  }

  static String? _patternText(BigFiveResultSummary summary) {
  return switch (summary.depthTier) {
      BigFiveDepthTier.quick => AppText.t(
          'big_five_pattern_quick_${_dominantPatternId(summary)}',
        ),
      BigFiveDepthTier.standard => AppText.t(
          'big_five_pattern_standard_${_crossPatternId(summary)}',
        ),
      BigFiveDepthTier.deep => AppText.t(
          'big_five_pattern_deep_${_crossPatternId(summary)}',
        ),
    };
  }

  static String _depthHint(BigFiveResultSummary summary) {
    return switch (summary.depthTier) {
      BigFiveDepthTier.quick => AppText.t('big_five_depth_hint_quick'),
      BigFiveDepthTier.standard => AppText.t('big_five_depth_hint_standard'),
      BigFiveDepthTier.deep => AppText.t('big_five_depth_hint_deep'),
    };
  }

  static String _dominantPatternId(BigFiveResultSummary summary) {
    final strongTraits = BigFiveTraitId.all
        .where((trait) => summary.bandForTrait(trait) == BigFiveBandId.strong)
        .toList();

    if (strongTraits.contains(BigFiveTraitId.conscientiousness) &&
        strongTraits.contains(BigFiveTraitId.extraversion)) {
      return 'drive';
    }
    if (strongTraits.contains(BigFiveTraitId.openness) &&
        strongTraits.contains(BigFiveTraitId.agreeableness)) {
      return 'curious_warm';
    }
    if (strongTraits.contains(BigFiveTraitId.extraversion)) return 'social';
    if (strongTraits.contains(BigFiveTraitId.conscientiousness)) {
      return 'steady';
    }
    if (strongTraits.contains(BigFiveTraitId.openness)) return 'curious';
    if (summary.bandForTrait(BigFiveTraitId.neuroticism) ==
        BigFiveBandId.emerging) {
      return 'grounded';
    }
    return 'balanced';
  }

  static String _crossPatternId(BigFiveResultSummary summary) {
    final c = summary.bandForTrait(BigFiveTraitId.conscientiousness);
    final o = summary.bandForTrait(BigFiveTraitId.openness);
    final e = summary.bandForTrait(BigFiveTraitId.extraversion);
    final n = summary.bandForTrait(BigFiveTraitId.neuroticism);

    if (c == BigFiveBandId.strong && o == BigFiveBandId.strong) {
      return 'builder_explorer';
    }
    if (c == BigFiveBandId.strong && e == BigFiveBandId.strong) {
      return 'driver_connector';
    }
    if (o == BigFiveBandId.strong && n == BigFiveBandId.emerging) {
      return 'open_calm';
    }
    if (e == BigFiveBandId.emerging && c == BigFiveBandId.strong) {
      return 'quiet_discipline';
    }
    return 'general';
  }
}
