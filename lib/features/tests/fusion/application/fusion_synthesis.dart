import '../domain/fusion_constants.dart';
import '../domain/fusion_models.dart';
import 'fusion_guidance.dart';
import 'fusion_reflection.dart';
import 'fusion_synthesis_copy.dart';
import 'fusion_theme_detection.dart';

/// Phase 4A meaning layer: themes → hero / patterns / why (deterministic).
abstract final class FusionSynthesis {
  static const _maxPatterns = 5;
  static const _maxWhyItems = 5;

  static ({
    String heroSummary,
    List<String> reflectionPrompts,
    List<FusionPattern> patterns,
    List<String> guidanceTips,
    List<FusionWhyItem> whyPersonalized,
  }) build({
    required List<MergedFusionSignal> merged,
    String lang = 'th',
  }) {
    if (merged.isEmpty) {
      return (
        heroSummary: FusionSynthesisCopy.heroFallback(lang),
        reflectionPrompts: const [],
        patterns: const [],
        guidanceTips: const [],
        whyPersonalized: const [],
      );
    }

    final themes = FusionThemeDetection.detect(merged);
    return (
      heroSummary: _hero(merged, themes, lang),
      reflectionPrompts: FusionReflection.build(
        merged: merged,
        themes: themes,
        lang: lang,
      ),
      patterns: _patterns(themes, lang),
      guidanceTips: FusionGuidance.build(
        merged: merged,
        themes: themes,
        lang: lang,
      ),
      whyPersonalized: _whyItems(merged, lang),
    );
  }

  static String _hero(
    List<MergedFusionSignal> merged,
    List<FusionThemeActivation> themes,
    String lang,
  ) {
    if (themes.isEmpty) return FusionSynthesisCopy.heroFallback(lang);

    final exploration = _find(merged, FusionSignalIds.exploration);
    final structure = _find(merged, FusionSignalIds.structure);
    if (_isAtLeast(exploration, FusionSignalStrength.high) &&
        _isAtLeast(structure, FusionSignalStrength.medium)) {
      return FusionSynthesisCopy.heroExplorationStructure(lang);
    }

    final top = themes.first.themeId;
    final second = themes.length > 1 ? themes[1].themeId : null;

    if (top == FusionThemeIds.exploration &&
        second == FusionThemeIds.thinkingStyle) {
      return FusionSynthesisCopy.heroExplorationThinking(lang);
    }
    if (top == FusionThemeIds.exploration &&
        second == FusionThemeIds.emotion) {
      return FusionSynthesisCopy.heroExplorationEmotion(lang);
    }
    if (top == FusionThemeIds.thinkingStyle &&
        second == FusionThemeIds.socialExpression) {
      return FusionSynthesisCopy.heroThinkingSocial(lang);
    }

    final primary = switch (top) {
      FusionThemeIds.exploration =>
        FusionSynthesisCopy.heroExplorationPrimary(lang),
      FusionThemeIds.thinkingStyle =>
        FusionSynthesisCopy.heroThinkingPrimary(lang),
      FusionThemeIds.emotion => FusionSynthesisCopy.heroEmotionPrimary(lang),
      FusionThemeIds.socialExpression =>
        FusionSynthesisCopy.heroSocialPrimary(lang),
      _ => FusionSynthesisCopy.heroFallback(lang),
    };
    return primary;
  }

  static List<FusionPattern> _patterns(
    List<FusionThemeActivation> themes,
    String lang,
  ) {
    final slice = themes.take(_maxPatterns).toList();
    final out = <FusionPattern>[];
    for (var i = 0; i < slice.length; i++) {
      final theme = slice[i];
      final peak = _peakStrength(theme.signals);
      out.add(
        FusionPattern(
          themeId: theme.themeId,
          title: FusionSynthesisCopy.patternTitle(theme.themeId, lang),
          summary: FusionSynthesisCopy.patternSummaryCohesive(
            theme.themeId,
            peak,
            lang,
            index: i,
            total: slice.length,
          ),
          contributors: _unionContributors(theme.signals),
        ),
      );
    }
    return out;
  }

  static List<FusionWhyItem> _whyItems(
    List<MergedFusionSignal> merged,
    String lang,
  ) {
    final candidates = merged
        .where(
          (s) => _strengthRank(s.strength) >= _strengthRank(FusionSignalStrength.medium),
        )
        .toList()
      ..sort((a, b) {
        final byConf = b.confidence.compareTo(a.confidence);
        if (byConf != 0) return byConf;
        return a.id.compareTo(b.id);
      });

    final grouped = <String, List<MergedFusionSignal>>{};
    for (final signal in candidates) {
      final key = signal.contributors.map((c) => c.index).join(',');
      grouped.putIfAbsent(key, () => []).add(signal);
    }

    final groups = grouped.values.toList()
      ..sort((a, b) {
        final aConf = a.map((s) => s.confidence).reduce((x, y) => x > y ? x : y);
        final bConf = b.map((s) => s.confidence).reduce((x, y) => x > y ? x : y);
        if (aConf != bConf) return bConf.compareTo(aConf);
        return a.first.id.compareTo(b.first.id);
      });

    final out = <FusionWhyItem>[];
    for (final group in groups) {
      if (out.length >= _maxWhyItems) break;
      final contributors = List<FusionSignalSource>.unmodifiable(group.first.contributors);
      final signalIds = group.map((s) => s.id).take(2).toList();
      out.add(
        FusionWhyItem(
          signalId: signalIds.first,
          body: FusionSynthesisCopy.whyForSignalGroup(
            signalIds,
            contributors,
            lang,
          ),
          contributors: contributors,
        ),
      );
    }
    return out;
  }

  static MergedFusionSignal? _find(List<MergedFusionSignal> merged, String id) {
    for (final signal in merged) {
      if (signal.id == id) return signal;
    }
    return null;
  }

  static bool _isAtLeast(
    MergedFusionSignal? signal,
    FusionSignalStrength minimum,
  ) {
    if (signal == null) return false;
    return _strengthRank(signal.strength) >= _strengthRank(minimum);
  }

  static FusionSignalStrength _peakStrength(List<MergedFusionSignal> signals) {
    var peak = FusionSignalStrength.low;
    for (final signal in signals) {
      if (_strengthRank(signal.strength) > _strengthRank(peak)) {
        peak = signal.strength;
      }
    }
    return peak;
  }

  static List<FusionSignalSource> _unionContributors(
    List<MergedFusionSignal> signals,
  ) {
    final seen = <FusionSignalSource>{};
    final out = <FusionSignalSource>[];
    for (final signal in signals) {
      for (final source in signal.contributors) {
        if (seen.add(source)) out.add(source);
      }
    }
    out.sort((a, b) => a.index.compareTo(b.index));
    return List.unmodifiable(out);
  }

  static int _strengthRank(FusionSignalStrength strength) => switch (strength) {
        FusionSignalStrength.low => 0,
        FusionSignalStrength.medium => 1,
        FusionSignalStrength.high => 2,
      };
}
