import 'package:knowme/core/i18n/app_text.dart';

import '../domain/mbti_cognitive_models.dart';

/// Localization keys for cognitive function copy on the result page.
class MbtiCognitiveResultContent {
  static String confidenceTierKey(int scoredQuestionCount) {
    if (scoredQuestionCount >= mbtiCognitiveAccurateCheckpoint) {
      return 'mbti_cog_confidence_accurate';
    }
    if (scoredQuestionCount >= mbtiCognitiveStandardCheckpoint) {
      return 'mbti_cog_confidence_standard';
    }
    return 'mbti_cog_confidence_mini';
  }

  static String confidenceTierLabel(int scoredQuestionCount) =>
      AppText.t(confidenceTierKey(scoredQuestionCount));
  static String functionNameKey(String function) =>
      'mbti_cog_fn_${function.toLowerCase()}_name';

  static String functionDescKey(String function) =>
      'mbti_cog_fn_${function.toLowerCase()}_desc';

  static String functionLabel(String function) =>
      AppText.t(functionNameKey(function));

  static String functionDescription(String function) =>
      AppText.t(functionDescKey(function));

  static String stackProfileSummary(List<String> typeHints) {
    if (typeHints.isEmpty) {
      return AppText.t('mbti_cog_stack_none');
    }
    if (typeHints.length == 1) {
      return AppText.t('mbti_cog_stack_one').replaceAll('{types}', typeHints[0]);
    }
    final joined = '${typeHints[0]}/${typeHints[1]}';
    return AppText.t('mbti_cog_stack_two').replaceAll('{types}', joined);
  }

  static String _thinkLineKey(String function) =>
      'mbti_cog_think_${function.toLowerCase()}';

  /// Rule-based “how you tend to think” copy from ranked functions (not AI).
  static List<String> thinkingStyleLines(List<String> topFunctions) {
    if (topFunctions.isEmpty) {
      return [AppText.t('mbti_cog_think_fallback')];
    }

    final lines = <String>[];
    final usedThemes = <String>{};

    int themeWeight(Set<String> theme) {
      var weight = 0;
      for (var i = 0; i < topFunctions.length && i < 4; i++) {
        if (theme.contains(topFunctions[i])) {
          weight += 4 - i;
        }
      }
      return weight;
    }

    const themes = <String, Set<String>>{
      'logic': {'Ti', 'Te'},
      'intuition': {'Ni', 'Ne'},
      'sensing': {'Si', 'Se'},
      'feeling': {'Fi', 'Fe'},
    };

    final rankedThemes = themes.entries.toList()
      ..sort((a, b) => themeWeight(b.value).compareTo(themeWeight(a.value)));

    for (final entry in rankedThemes) {
      if (themeWeight(entry.value) < 3) continue;
      if (!usedThemes.add(entry.key)) continue;
      lines.add(AppText.t('mbti_cog_think_theme_${entry.key}'));
      if (lines.length >= 2) break;
    }

    for (final fn in topFunctions.take(3)) {
      final line = AppText.t(_thinkLineKey(fn));
      if (!lines.contains(line)) {
        lines.add(line);
      }
      if (lines.length >= 3) break;
    }

    if (lines.isEmpty) {
      lines.add(AppText.t(_thinkLineKey(topFunctions.first)));
    }

    return lines.take(3).toList();
  }

  static String thinkingStyleSummary(List<String> topFunctions) =>
      thinkingStyleLines(topFunctions).join('\n');
}
