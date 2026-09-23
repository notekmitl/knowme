import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';

import '../adapters/bazi_real_adapter.dart';
import '../adapters/lens_theme_output.dart';
import '../adapters/thai_real_adapter.dart';
import '../adapters/western_real_adapter.dart';
import '../domain/entities/astrology_lens.dart';
import '../domain/entities/fusion_category.dart';
import '../registry/signal_registry.dart';
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

/// A conservative comparison of independently calculated birth charts.
/// It does not derive dates or events from static natal themes.
abstract final class ThreeTraditionConsensus {
  static final List<String> lensOrder = [
    AstrologyLens.thaiAstrology.lensId,
    AstrologyLens.chineseBazi.lensId,
    AstrologyLens.westernNatal.lensId,
  ];

  static List<ThreeTraditionAgreement> fromCharts({
    required ThaiMirrorResult thai,
    required BaziChartModel bazi,
    required AstrologyChartModel western,
  }) => fromOutputs([
    ...ThaiRealAdapter.adapt(thai),
    ...BaziRealAdapter.adapt(bazi),
    ...WesternRealAdapter.adapt(western),
  ]);

  static List<ThreeTraditionAgreement> fromOutputs(
    List<LensThemeOutput> outputs,
  ) {
    final selected = outputs.where((output) =>
        lensOrder.contains(output.lensId) &&
        FusionThemeRegistry.contains(output.themeId) &&
        output.evidence.isNotEmpty);
    final byTheme = <String, Map<String, LensThemeOutput>>{};
    final bySignal = <String, Map<String, LensThemeOutput>>{};

    for (final output in selected) {
      final themeId = output.themeId.trim().toLowerCase();
      _keepBest(byTheme.putIfAbsent(themeId, () => {}), output);
      // Growth-area themes can have the opposite meaning of positive traits
      // within a broad family (e.g. analytical vs overthinking).
      if (output.category == FusionCategory.growthAreas) continue;
      final signal = FusionSignalRegistry.signalForTheme(themeId);
      if (signal != null) {
        _keepBest(bySignal.putIfAbsent(signal.name, () => {}), output);
      }
    }

    final agreements = <ThreeTraditionAgreement>[];
    for (final entry in bySignal.entries) {
      // Prefer a shared exact theme, then add the third tradition when it
      // expresses a different theme in the same narrowly mapped signal.
      final candidates = byTheme.entries.where((theme) =>
          FusionSignalRegistry.signalForTheme(theme.key)?.name == entry.key &&
          theme.value.length >= 2).toList()
        ..sort((a, b) {
          final count = b.value.length.compareTo(a.value.length);
          return count != 0 ? count : a.key.compareTo(b.key);
        });
      final sources = <String, LensThemeOutput>{
        if (candidates.isNotEmpty) ...candidates.first.value,
        for (final lens in lensOrder)
          if (!(candidates.isNotEmpty &&
                  candidates.first.value.containsKey(lens)) &&
              entry.value.containsKey(lens))
            lens: entry.value[lens]!,
      };
      if (sources.length < 2) continue;
      agreements.add(ThreeTraditionAgreement(
        key: entry.key,
        exact: sources.values.map((output) => output.themeId).toSet().length == 1,
        sources: _ordered(sources),
      ));
    }
    // Themes without a safe similarity mapping may still agree exactly.
    for (final entry in byTheme.entries) {
      if (entry.value.length < 2 ||
          (FusionSignalRegistry.signalForTheme(entry.key) != null &&
              FusionThemeRegistry.getById(entry.key)?.category !=
                  FusionCategory.growthAreas)) {
        continue;
      }
      agreements.add(ThreeTraditionAgreement(
        key: entry.key,
        exact: true,
        sources: _ordered(entry.value),
      ));
    }
    agreements.sort((a, b) {
      final count = b.sourceCount.compareTo(a.sourceCount);
      if (count != 0) return count;
      if (a.exact != b.exact) return a.exact ? -1 : 1;
      return a.key.compareTo(b.key);
    });
    return List.unmodifiable(agreements);
  }

  static void _keepBest(
    Map<String, LensThemeOutput> byLens,
    LensThemeOutput output,
  ) {
    final previous = byLens[output.lensId];
    if (previous == null || output.confidence > previous.confidence ||
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
