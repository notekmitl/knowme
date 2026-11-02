import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';

import '../adapters/bazi_real_adapter.dart';
import '../adapters/lens_theme_output.dart';
import '../adapters/thai_real_adapter.dart';
import '../adapters/western_real_adapter.dart';
import '../domain/entities/astrology_lens.dart';
import '../registry/theme_registry.dart';

/// One supported reading, with the actual source themes and their engine facts.
class ThreeTraditionAgreement {
  const ThreeTraditionAgreement({
    required this.key,
    required this.exact,
    required this.sources,
  });

  final String key;
  final bool exact;
  final Map<String, LensThemeOutput> sources;
  int get sourceCount => sources.length;
}

/// Keeps the non-matching chart observations visible without treating them as
/// evidence for an agreement.
class ThreeTraditionReading {
  const ThreeTraditionReading({required this.agreements, required this.byLens});

  final List<ThreeTraditionAgreement> agreements;
  final Map<String, List<LensThemeOutput>> byLens;
}

/// A conservative comparison of independently calculated birth charts.
/// It does not derive dates or events from static natal themes.
abstract final class ThreeTraditionConsensus {
  // Zodiac bridge facts (0.35–0.55) can inform a lens observation but are too
  // weak alone to assert a cross-tradition agreement.
  static const double minimumAgreementConfidence = 0.6;
  static final List<String> lensOrder = [
    AstrologyLens.thaiAstrology.lensId,
    AstrologyLens.chineseBazi.lensId,
    AstrologyLens.westernNatal.lensId,
  ];

  static List<ThreeTraditionAgreement> fromCharts({
    required ThaiMirrorResult thai,
    required BaziChartModel bazi,
    required AstrologyChartModel western,
  }) => analyzeCharts(thai: thai, bazi: bazi, western: western).agreements;

  static ThreeTraditionReading analyzeCharts({
    required ThaiMirrorResult thai,
    required BaziChartModel bazi,
    required AstrologyChartModel western,
  }) => analyzeOutputs([
    ...ThaiRealAdapter.adapt(thai),
    ...BaziRealAdapter.adapt(bazi, mergeEvidence: true),
    ...WesternRealAdapter.adapt(western, mergeEvidence: true),
  ]);

  static List<ThreeTraditionAgreement> fromOutputs(
    List<LensThemeOutput> outputs,
  ) => analyzeOutputs(outputs).agreements;

  static ThreeTraditionReading analyzeOutputs(List<LensThemeOutput> outputs) {
    final selected = outputs
        .where(
          (output) =>
              lensOrder.contains(output.lensId) &&
              FusionThemeRegistry.contains(output.themeId) &&
              output.evidence.any((fact) => fact.trim().isNotEmpty),
        )
        .toList();
    final byTheme = <String, Map<String, LensThemeOutput>>{};
    final allByTheme = <String, Map<String, LensThemeOutput>>{};
    final byLens = <String, List<LensThemeOutput>>{
      for (final lens in lensOrder) lens: [],
    };

    for (final output in selected) {
      final themeId = output.themeId.trim().toLowerCase();
      _keepBest(allByTheme.putIfAbsent(themeId, () => {}), output);
      if (output.confidence >= minimumAgreementConfidence) {
        _keepBest(byTheme.putIfAbsent(themeId, () => {}), output);
      }
    }

    for (final themes in allByTheme.values) {
      for (final output in themes.values) {
        byLens[output.lensId]!.add(output);
      }
    }
    for (final outputs in byLens.values) {
      outputs.sort((a, b) {
        final confidence = b.confidence.compareTo(a.confidence);
        return confidence != 0 ? confidence : a.themeId.compareTo(b.themeId);
      });
    }

    final agreements = <ThreeTraditionAgreement>[];
    for (final entry in byTheme.entries) {
      if (entry.value.length < 2) continue;
      agreements.add(
        ThreeTraditionAgreement(
          key: entry.key,
          exact: true,
          sources: _ordered(entry.value),
        ),
      );
    }

    // Only this explicitly reviewed near-match has a defensible common
    // meaning. Broad signal families (e.g. loyal vs needing space) are not
    // interchangeable and must never manufacture a third agreeing lens.
    final autonomy = <String, LensThemeOutput>{};
    for (final themeId in ['independent', 'leadership']) {
      for (final output in byTheme[themeId]?.values ?? <LensThemeOutput>[]) {
        _keepBest(autonomy, output);
      }
    }
    if (autonomy.length >= 2 &&
        autonomy.values.map((source) => source.themeId).toSet().length == 2) {
      final exactAutonomy = agreements
          .where(
            (item) => item.key == 'independent' || item.key == 'leadership',
          )
          .toList();
      // Add the third lens to an existing exact pair; avoid repeating the
      // same point in both a two-lens and three-lens card.
      if (exactAutonomy.isEmpty ||
          autonomy.length > exactAutonomy.first.sourceCount) {
        agreements.removeWhere(
          (item) => item.key == 'independent' || item.key == 'leadership',
        );
        agreements.add(
          ThreeTraditionAgreement(
            key: 'self_direction',
            exact: false,
            sources: _ordered(autonomy),
          ),
        );
      }
    }
    agreements.sort((a, b) {
      final count = b.sourceCount.compareTo(a.sourceCount);
      if (count != 0) return count;
      if (a.exact != b.exact) return a.exact ? -1 : 1;
      return a.key.compareTo(b.key);
    });
    return ThreeTraditionReading(
      agreements: List.unmodifiable(agreements),
      byLens: Map.unmodifiable({
        for (final lens in lensOrder)
          lens: List<LensThemeOutput>.unmodifiable(byLens[lens]!),
      }),
    );
  }

  static void _keepBest(
    Map<String, LensThemeOutput> byLens,
    LensThemeOutput output,
  ) {
    final previous = byLens[output.lensId];
    if (previous == null ||
        output.confidence > previous.confidence ||
        (output.confidence == previous.confidence &&
            output.themeId.compareTo(previous.themeId) < 0)) {
      byLens[output.lensId] = output;
    }
  }

  static Map<String, LensThemeOutput> _ordered(
    Map<String, LensThemeOutput> sources,
  ) => Map.unmodifiable({
    for (final lens in lensOrder)
      if (sources.containsKey(lens)) lens: sources[lens]!,
  });
}
