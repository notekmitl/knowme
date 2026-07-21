import '../adapters/lens_theme_output.dart';
import '../domain/entities/astrology_lens.dart';
import '../domain/entities/lens_origin_insight.dart';
import '../presentation/fusion_presentation_copy.dart';

/// Builds per-lens origin summaries for presentation.
abstract final class WhyThisAppearsBuilder {
  static final List<String> _lensOrder = [
    AstrologyLens.westernNatal.lensId,
    AstrologyLens.chineseBazi.lensId,
    AstrologyLens.thaiAstrology.lensId,
  ];

  static List<LensOriginInsight> build(List<LensThemeOutput> outputs) {
    if (outputs.isEmpty) return const [];

    final grouped = <String, List<LensThemeOutput>>{};
    for (final output in outputs) {
      grouped.putIfAbsent(output.lensId, () => []).add(output);
    }

    final insights = <LensOriginInsight>[];
    for (final lensId in _lensOrder) {
      final lensOutputs = grouped[lensId];
      if (lensOutputs == null || lensOutputs.isEmpty) continue;

      final sorted = List<LensThemeOutput>.from(lensOutputs)
        ..sort((a, b) => b.confidence.compareTo(a.confidence));

      final phrases = <String>[];
      final seen = <String>{};
      for (final output in sorted) {
        final phrase = FusionPresentationCopy.themePhrase(output.themeId);
        if (seen.add(phrase)) phrases.add(phrase);
        if (phrases.length >= 2) break;
      }

      if (phrases.isEmpty) continue;

      insights.add(
        LensOriginInsight(
          lensId: lensId,
          lensTitle: FusionPresentationCopy.lensTitle(lensId),
          summary: _formatSummary(phrases),
        ),
      );
    }

    for (final entry in grouped.entries) {
      if (_lensOrder.contains(entry.key)) continue;
      final sorted = List<LensThemeOutput>.from(entry.value)
        ..sort((a, b) => b.confidence.compareTo(a.confidence));
      final phrase = FusionPresentationCopy.themePhrase(sorted.first.themeId);
      insights.add(
        LensOriginInsight(
          lensId: entry.key,
          lensTitle: FusionPresentationCopy.lensTitle(entry.key),
          summary: 'สะท้อน$phrase',
        ),
      );
    }

    return insights;
  }

  static String _formatSummary(List<String> phrases) {
    if (phrases.length == 1) {
      return 'สะท้อน${phrases.first}';
    }
    return 'สะท้อน${phrases.first} และ${phrases[1]}';
  }
}
