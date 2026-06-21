import '../content/models/thai_content_section.dart';
import '../content/registry/thai_content_registry.dart';
import 'models/thai_theme_resolver_input.dart';
import 'models/thai_theme_signal.dart';
import 'models/thai_theme_signal_source.dart';
import 'thai_theme_source_weights.dart';

/// Aggregates theme mappings from Thai content lenses into unified signals.
///
/// Resolver only — no confidence, narrative, or mirror output.
abstract final class ThaiThemeResolver {
  static List<ThaiThemeSignal> resolve(ThaiThemeResolverInput input) {
    final accumulators = <String, _ThemeAccumulator>{};

    _collectKey(accumulators, input.lagnaKey);
    _collectKey(accumulators, input.lagnaLordKey);
    _collectKey(accumulators, input.ramahabhutaKey);

    for (final key in input.mahabhutaPositionKeys) {
      _collectKey(accumulators, key);
    }

    for (final key in input.myanmarKeys) {
      _collectKey(accumulators, key);
    }

    final signals = accumulators.values
        .map(
          (accumulator) => ThaiThemeSignal(
            themeId: accumulator.themeId,
            score: accumulator.score,
            sources: List.unmodifiable(accumulator.sources),
          ),
        )
        .toList();

    signals.sort((a, b) => b.score.compareTo(a.score));
    return signals;
  }

  static void _collectKey(
    Map<String, _ThemeAccumulator> accumulators,
    String? key,
  ) {
    if (key == null || key.trim().isEmpty) return;

    final section = ThaiContentRegistry.resolve(key);
    if (section == null) return;

    _collectSection(accumulators, section);
  }

  static void _collectSection(
    Map<String, _ThemeAccumulator> accumulators,
    ThaiContentSection section,
  ) {
    final sourceWeight = ThaiThemeSourceWeights.forType(section.contentType);

    for (final mapping in section.themeMappings) {
      final themeId = mapping.theme;
      final accumulator = accumulators.putIfAbsent(
        themeId,
        () => _ThemeAccumulator(themeId: themeId),
      );

      accumulator.score += mapping.weight * sourceWeight;
      accumulator.sources.add(
        ThaiThemeSignalSource(
          contentKey: section.key,
          sourceType: section.contentType,
          weightUsed: sourceWeight,
          rawWeight: mapping.weight,
        ),
      );
    }
  }
}

final class _ThemeAccumulator {
  _ThemeAccumulator({required this.themeId});

  final String themeId;
  double score = 0;
  final List<ThaiThemeSignalSource> sources = [];
}
