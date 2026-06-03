import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/mbti/mbti_types.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';
import 'package:knowme/features/tests/mbti_cognitive/domain/mbti_cognitive_models.dart';
import 'package:knowme/services/mbti/mbti_function_stack.dart';

import '../domain/mbti_summary_constants.dart';
import '../domain/mbti_summary_insight_models.dart';

enum _AlignmentBand { weak, mixed, strong }

enum _OutlierKind {
  none,
  estjAnalytical,
  estjNiVision,
  entjTi,
  entjNi,
  intjFe,
  intjNe,
  enfpTe,
  enfpSi,
}

/// Deterministic fusion insights (no AI, no persistence).
abstract final class MbtiSummaryInsightEngine {
  static const int _maxParagraphs = 2;
  static const int _maxPairs = 2;
  static const int _maxStrengths = 4;
  static const int _maxCareers = 5;

  static MbtiSummaryInsightBundle build({
    required MbtiResultSummary mbti,
    required MbtiCognitiveResultSummary cognitive,
  }) {
    final type = mbti.type.toUpperCase();
    final topFour = cognitive.topFour;

    return MbtiSummaryInsightBundle(
      hero: _buildHeroSummary(type, topFour),
      profileInsight: _buildProfileInsight(type, topFour),
      thinkingInsight: _buildThinkingInsight(type, topFour),
      growthInsight: _buildGrowthInsight(type, topFour),
      confidenceExtras: _buildConfidenceExtras(type, topFour),
    );
  }

  // --- Hero ---

  static MbtiSummaryHeroInsight _buildHeroSummary(
    String type,
    List<String> topFour,
  ) {
    final fnLabel = topFour.take(3).join('/');
    final outlier = _outlierKind(type, topFour);
    final roleKey = _heroRoleKey(type, topFour, outlier);
    final roleEn = _textEn(roleKey);

    return MbtiSummaryHeroInsight(
      identityLine: '$type + $fnLabel',
      roleLabel: AppText.t(roleKey),
      roleLabelEnglish:
          AppText.lang == 'th' && roleEn != roleKey ? roleEn : null,
      paragraphs: _capStrings(
        _heroSynthesisKeys(type, topFour, outlier).map(AppText.t).toList(),
        _maxParagraphs,
      ),
    );
  }

  static String _heroRoleKey(
    String type,
    List<String> topFour,
    _OutlierKind outlier,
  ) {
    switch (type) {
      case 'ESTJ':
        return switch (outlier) {
          _OutlierKind.estjAnalytical => 'mbti_sum_hero_role_estj_analytical',
          _OutlierKind.estjNiVision => 'mbti_sum_hero_role_estj_vision',
          _ => 'mbti_sum_hero_role_estj',
        };
      case 'ENTJ':
        return switch (outlier) {
          _OutlierKind.entjTi => 'mbti_sum_hero_role_entj_analytical',
          _OutlierKind.entjNi => 'mbti_sum_hero_role_entj_strategic',
          _ => 'mbti_sum_hero_role_entj',
        };
      case 'INTJ':
        return switch (outlier) {
          _OutlierKind.intjFe => 'mbti_sum_hero_role_intj_balanced',
          _OutlierKind.intjNe => 'mbti_sum_hero_role_intj_explorer',
          _ => 'mbti_sum_hero_role_intj',
        };
      case 'ENFP':
        return switch (outlier) {
          _OutlierKind.enfpTe => 'mbti_sum_hero_role_enfp_builder',
          _OutlierKind.enfpSi => 'mbti_sum_hero_role_enfp_grounded',
          _ => 'mbti_sum_hero_role_enfp',
        };
      default:
        return 'mbti_sum_hero_role_generic';
    }
  }

  static List<String> _heroSynthesisKeys(
    String type,
    List<String> topFour,
    _OutlierKind outlier,
  ) {
    final top3 = topFour.take(3).toSet();

    switch (type) {
      case 'ESTJ':
        if (top3.containsAll({'Te', 'Ti', 'Ni'})) {
          return ['mbti_sum_hero_syn_estj_te_ti_ni'];
        }
        if (outlier == _OutlierKind.estjAnalytical) {
          return ['mbti_sum_hero_syn_estj_analytical'];
        }
        if (outlier == _OutlierKind.estjNiVision) {
          return ['mbti_sum_hero_syn_estj_vision'];
        }
        return ['mbti_sum_hero_syn_estj_default'];
      case 'ENTJ':
        if (outlier == _OutlierKind.entjTi) {
          return ['mbti_sum_hero_syn_entj_ti'];
        }
        if (outlier == _OutlierKind.entjNi) {
          return ['mbti_sum_hero_syn_entj_ni'];
        }
        return ['mbti_sum_hero_syn_entj_default'];
      case 'INTJ':
        if (_isIntuitionHeavy(topFour)) {
          return ['mbti_sum_hero_syn_intj_ni'];
        }
        return ['mbti_sum_hero_syn_intj_default'];
      case 'ENFP':
        if (_rank(topFour, 'Ti') <= 2) {
          return ['mbti_sum_hero_syn_enfp_ti'];
        }
        return ['mbti_sum_hero_syn_enfp_default'];
      default:
        return ['mbti_sum_hero_syn_generic'];
    }
  }

  // --- Profile (subtitle + paragraph) ---

  static MbtiSummaryProfileInsight _buildProfileInsight(
    String type,
    List<String> topFour,
  ) {
    final band = _alignmentBand(_alignmentScore(type, topFour));

    return MbtiSummaryProfileInsight(
      subtitle: _profileSubtitle(band),
      paragraph: _profileParagraph(type, topFour, band),
    );
  }

  static String _profileSubtitle(_AlignmentBand band) {
    return switch (band) {
      _AlignmentBand.strong => AppText.t('mbti_sum_profile_subtitle_strong'),
      _AlignmentBand.mixed => AppText.t('mbti_sum_profile_subtitle_partial'),
      _AlignmentBand.weak => AppText.t('mbti_sum_profile_subtitle_distinct'),
    };
  }

  static String _profileParagraph(
    String type,
    List<String> topFour,
    _AlignmentBand band,
  ) {
    final keys = _profileParagraphKeys(type, topFour, band);
    if (keys.isNotEmpty) {
      return AppText.t(keys.first);
    }
    return _alignmentSummaryBullet(band);
  }

  static List<String> _profileParagraphKeys(
    String type,
    List<String> topFour,
    _AlignmentBand band,
  ) {
    final outlier = _outlierKind(type, topFour);

    switch (type) {
      case 'ESTJ':
        return switch (outlier) {
          _OutlierKind.estjAnalytical => ['mbti_sum_profile_para_estj_analytical'],
          _OutlierKind.estjNiVision => ['mbti_sum_profile_para_estj_ni'],
          _ => switch (band) {
            _AlignmentBand.strong => ['mbti_sum_profile_para_estj_strong'],
            _AlignmentBand.mixed => ['mbti_sum_profile_para_estj_mixed'],
            _AlignmentBand.weak => ['mbti_sum_profile_para_estj_weak'],
          },
        };
      case 'ENTJ':
        return switch (outlier) {
          _OutlierKind.entjTi => ['mbti_sum_profile_para_entj_ti'],
          _OutlierKind.entjNi => ['mbti_sum_profile_para_entj_ni'],
          _ => ['mbti_sum_profile_para_entj_default'],
        };
      case 'INTJ':
        return switch (outlier) {
          _OutlierKind.intjFe => ['mbti_sum_profile_para_intj_fe'],
          _OutlierKind.intjNe => ['mbti_sum_profile_para_intj_ne'],
          _ => ['mbti_sum_profile_para_intj_default'],
        };
      case 'ENFP':
        return switch (outlier) {
          _OutlierKind.enfpTe => ['mbti_sum_profile_para_enfp_te'],
          _OutlierKind.enfpSi => ['mbti_sum_profile_para_enfp_si'],
          _ => ['mbti_sum_profile_para_enfp_default'],
        };
      default:
        return [];
    }
  }

  // --- Thinking (headline + body pairs) ---

  static MbtiSummaryThinkingInsight _buildThinkingInsight(
    String type,
    List<String> topFour,
  ) {
    final pairPrefixes = _thinkingPairPrefixes(type, topFour);
    final items = pairPrefixes.isNotEmpty
        ? pairPrefixes.map(_pairFromPrefix).toList()
        : _themePairPrefixes(topFour).map(_pairFromPrefix).toList();

    return MbtiSummaryThinkingInsight(
      items: _capPairs(items, _maxPairs),
    );
  }

  static List<String> _thinkingPairPrefixes(String type, List<String> topFour) {
    final top3 = topFour.take(3).toSet();
    final top2 = topFour.take(2).toSet();

    switch (type) {
      case 'ESTJ':
        if (top3.containsAll({'Te', 'Ti', 'Ni'})) {
          return [
            'mbti_sum_think_pair_estj_plan',
            'mbti_sum_think_pair_estj_vision',
          ];
        }
        if (_isLogicHeavy(topFour)) {
          return ['mbti_sum_think_pair_estj_logic'];
        }
      case 'ENTJ':
        if (top2.contains('Ti')) {
          return [
            'mbti_sum_think_pair_entj_drive',
            'mbti_sum_think_pair_entj_refine',
          ];
        }
        if (_rank(topFour, 'Ni') <= 1) {
          return ['mbti_sum_think_pair_entj_strategy'];
        }
      case 'INTJ':
        if (top2.contains('Fe')) {
          return ['mbti_sum_think_pair_intj_fe'];
        }
        if (_isIntuitionHeavy(topFour)) {
          return [
            'mbti_sum_think_pair_intj_vision',
            'mbti_sum_think_pair_intj_detail',
          ];
        }
      case 'ENFP':
        if (top2.contains('Ti') || _rank(topFour, 'Ti') <= 2) {
          return [
            'mbti_sum_think_pair_enfp_open',
            'mbti_sum_think_pair_enfp_check',
          ];
        }
        if (top2.contains('Te')) {
          return ['mbti_sum_think_pair_enfp_finish'];
        }
        if (_isExplorationHeavy(topFour)) {
          return ['mbti_sum_think_pair_enfp_explore'];
        }
    }
    return [];
  }

  static List<String> _themePairPrefixes(List<String> topFour) {
    return _dominantThemeKeys(topFour)
        .map((k) => k.replaceFirst('mbti_sum_insight_theme_', 'mbti_sum_think_theme_'))
        .toList();
  }

  // --- Growth (headline + body pairs) ---

  static MbtiSummaryGrowthInsight _buildGrowthInsight(
    String type,
    List<String> topFour,
  ) {
    final prefixes = _growthPairPrefixes(type, topFour);
    final items = prefixes.isNotEmpty
        ? prefixes.map(_pairFromPrefix).toList()
        : [_pairFromPrefix(_growthFallbackPrefix(type, topFour))];

    return MbtiSummaryGrowthInsight(
      items: _capPairs(items, _maxPairs),
    );
  }

  static List<String> _growthPairPrefixes(String type, List<String> topFour) {
    switch (type) {
      case 'ESTJ':
        if (_isLogicHeavy(topFour)) {
          return [
            'mbti_sum_growth_pair_estj_pace',
            'mbti_sum_growth_pair_estj_listen',
          ];
        }
        if (_outlierKind(type, topFour) == _OutlierKind.estjNiVision) {
          return ['mbti_sum_growth_pair_estj_pace_others'];
        }
      case 'ENTJ':
        if (_isLogicHeavy(topFour)) {
          return ['mbti_sum_growth_pair_entj_control'];
        }
        if (_outlierKind(type, topFour) == _OutlierKind.entjNi) {
          return ['mbti_sum_growth_pair_entj_constraint'];
        }
      case 'INTJ':
        if (_isIntuitionHeavy(topFour)) {
          return [
            'mbti_sum_growth_pair_intj_big_picture',
            'mbti_sum_growth_pair_intj_checkpoint',
          ];
        }
        if (_outlierKind(type, topFour) == _OutlierKind.intjFe) {
          return ['mbti_sum_growth_pair_intj_feedback'];
        }
      case 'ENFP':
        if (_isExplorationHeavy(topFour)) {
          return [
            'mbti_sum_growth_pair_enfp_many_paths',
            'mbti_sum_growth_pair_enfp_good_enough',
          ];
        }
        if (_rank(topFour, 'Ti') <= 2) {
          return ['mbti_sum_growth_pair_enfp_inner_critic'];
        }
    }
    return [];
  }

  static String _growthFallbackPrefix(String type, List<String> topFour) {
    final band = _alignmentBand(_alignmentScore(type, topFour));
    return switch (band) {
      _AlignmentBand.strong => 'mbti_sum_growth_pair_fallback_strong',
      _AlignmentBand.mixed => 'mbti_sum_growth_pair_fallback_mixed',
      _AlignmentBand.weak => 'mbti_sum_growth_pair_fallback_weak',
    };
  }

  // --- Confidence extras ---

  static MbtiSummaryConfidenceExtras _buildConfidenceExtras(
    String type,
    List<String> topFour,
  ) {
    final lang = AppText.lang;
    final mbti = mbtiTypes[type];

    final strengths = <String>[];
    for (final key in _cognitiveStrengthKeys(type, topFour)) {
      if (strengths.length >= _maxStrengths) break;
      strengths.add(AppText.t(key));
    }
    if (mbti != null) {
      for (final item in mbti.strengths) {
        if (strengths.length >= _maxStrengths) break;
        final text = item[lang] ?? item['en'] ?? '';
        if (text.isNotEmpty && !strengths.contains(text)) {
          strengths.add(text);
        }
      }
    }

    final careers = <String>[];
    if (mbti != null) {
      for (final item in mbti.careers) {
        if (careers.length >= _maxCareers) break;
        final text = item[lang] ?? item['en'] ?? '';
        if (text.isNotEmpty) careers.add(text);
      }
    }
    for (final key in _careerHintKeys(type, topFour)) {
      if (careers.length >= _maxCareers) break;
      final hint = AppText.t(key);
      if (!careers.contains(hint)) careers.add(hint);
    }

    return MbtiSummaryConfidenceExtras(
      strengthBullets: strengths,
      careerSuggestions: careers,
    );
  }

  static List<String> _cognitiveStrengthKeys(String type, List<String> topFour) {
    final keys = <String>[];
    if (_isLogicHeavy(topFour)) keys.add('mbti_sum_strength_logic');
    if (_isIntuitionHeavy(topFour)) keys.add('mbti_sum_strength_intuition');
    if (_themeWeight(topFour, {'Si', 'Te'}) >= mbtiSummaryMinThemeWeight) {
      keys.add('mbti_sum_strength_structure');
    }
    if (_isExplorationHeavy(topFour)) keys.add('mbti_sum_strength_exploration');
    if (_themeWeight(topFour, {'Fi', 'Fe'}) >= mbtiSummaryMinThemeWeight) {
      keys.add('mbti_sum_strength_people');
    }

    if (keys.isEmpty) {
      keys.add('mbti_sum_strength_balanced');
    }
    return keys.take(2).toList();
  }

  static List<String> _careerHintKeys(String type, List<String> topFour) {
    if (_isLogicHeavy(topFour)) {
      return switch (type) {
        'ESTJ' => ['mbti_sum_career_hint_operations'],
        'ENTJ' => ['mbti_sum_career_hint_operations'],
        'INTJ' => ['mbti_sum_career_hint_strategy'],
        _ => [],
      };
    }
    if (_isIntuitionHeavy(topFour)) {
      return ['mbti_sum_career_hint_planning'];
    }
    if (_isExplorationHeavy(topFour)) {
      return ['mbti_sum_career_hint_innovation'];
    }
    return [];
  }

  // --- Helpers ---

  static MbtiSummaryInsightPair _pairFromPrefix(String prefix) {
    return MbtiSummaryInsightPair(
      headline: AppText.t('${prefix}_h'),
      body: AppText.t('${prefix}_b'),
    );
  }

  static String _textEn(String key) {
    return AppText.text[key]?['en'] ?? key;
  }

  static List<String> _capStrings(List<String> items, int max) {
    return items.where((s) => s.isNotEmpty).take(max).toList();
  }

  static List<MbtiSummaryInsightPair> _capPairs(
    List<MbtiSummaryInsightPair> items,
    int max,
  ) {
    return items.take(max).toList();
  }

  static String _alignmentSummaryBullet(_AlignmentBand band) {
    return switch (band) {
      _AlignmentBand.strong => AppText.t('mbti_sum_profile_para_fallback_strong'),
      _AlignmentBand.mixed => AppText.t('mbti_sum_profile_para_fallback_mixed'),
      _AlignmentBand.weak => AppText.t('mbti_sum_profile_para_fallback_weak'),
    };
  }

  static bool _isLogicHeavy(List<String> topFour) {
    return _themeWeight(topFour, {'Te', 'Ti'}) >= 6;
  }

  static bool _isIntuitionHeavy(List<String> topFour) {
    final weight = _themeWeight(topFour, {'Ni', 'Ne'});
    return weight >= 4 || _rank(topFour, 'Ni') <= 1;
  }

  static bool _isExplorationHeavy(List<String> topFour) {
    return _themeWeight(topFour, {'Ne', 'Se'}) >= 5 ||
        _rank(topFour, 'Ne') <= 1;
  }

  static int _alignmentScore(String type, List<String> topFour) {
    final stack = mbtiFunctionStacks[type];
    if (stack == null || topFour.isEmpty) return 0;

    var score = 0;
    for (var i = 0; i < topFour.length && i < 4; i++) {
      final idx = stack.indexOf(topFour[i]);
      if (idx < 0) continue;
      if (idx <= 1) {
        score += 2;
      } else {
        score += 1;
      }
    }
    return score;
  }

  static _AlignmentBand _alignmentBand(int score) {
    if (score <= mbtiSummaryAlignmentWeakMax) {
      return _AlignmentBand.weak;
    }
    if (score >= mbtiSummaryAlignmentStrongMin) {
      return _AlignmentBand.strong;
    }
    return _AlignmentBand.mixed;
  }

  static int _rank(List<String> topFour, String fn) {
    final i = topFour.indexOf(fn);
    return i < 0 ? 99 : i;
  }

  static _OutlierKind _outlierKind(String type, List<String> topFour) {
    final top2 = topFour.take(2).toSet();

    switch (type) {
      case 'ESTJ':
        if (_rank(topFour, 'Ti') < _rank(topFour, 'Si')) {
          return _OutlierKind.estjAnalytical;
        }
        if (top2.contains('Ni')) {
          return _OutlierKind.estjNiVision;
        }
      case 'ENTJ':
        if (top2.contains('Ti')) {
          return _OutlierKind.entjTi;
        }
        if (_rank(topFour, 'Ni') < _rank(topFour, 'Se')) {
          return _OutlierKind.entjNi;
        }
      case 'INTJ':
        if (top2.contains('Fe')) {
          return _OutlierKind.intjFe;
        }
        if (top2.contains('Ne')) {
          return _OutlierKind.intjNe;
        }
      case 'ENFP':
        if (top2.contains('Te')) {
          return _OutlierKind.enfpTe;
        }
        if (top2.contains('Si')) {
          return _OutlierKind.enfpSi;
        }
    }
    return _OutlierKind.none;
  }

  static int _themeWeight(List<String> topFour, Set<String> themeFns) {
    var weight = 0;
    for (var i = 0; i < topFour.length && i < 4; i++) {
      if (themeFns.contains(topFour[i])) {
        weight += mbtiSummaryTopFunctionWeight - i;
      }
    }
    return weight;
  }

  static List<String> _dominantThemeKeys(List<String> topFour) {
    const themes = <String, Set<String>>{
      'logic': {'Te', 'Ti'},
      'intuition': {'Ni', 'Ne'},
      'feeling': {'Fi', 'Fe'},
      'structure': {'Si', 'Te'},
      'exploration': {'Ne', 'Se'},
    };

    final ranked = themes.entries
        .map((e) => MapEntry(e.key, _themeWeight(topFour, e.value)))
        .where((e) => e.value >= mbtiSummaryMinThemeWeight)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranked
        .take(_maxPairs)
        .map((e) => 'mbti_sum_insight_theme_${e.key}')
        .toList();
  }
}

