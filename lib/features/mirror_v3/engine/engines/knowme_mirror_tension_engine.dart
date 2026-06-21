import '../../enums/knowme_mirror_dimension_id.dart';
import '../../enums/knowme_mirror_pattern_type.dart';
import '../../enums/knowme_mirror_system_id.dart';
import '../mapping/knowme_mirror_opposing_pattern_family.dart';
import '../models/knowme_mirror_tension.dart';
import '../models/knowme_mirror_theme_signal.dart';

/// Detects opposing pattern-family tensions within the same dimension.
abstract final class KnowMeMirrorTensionEngine {
  static List<KnowMeMirrorTension> detect(
    List<KnowMeMirrorThemeSignal> signals,
  ) {
    if (signals.isEmpty) return const [];

    final byDimension = <KnowMeMirrorDimensionId, List<KnowMeMirrorThemeSignal>>{};
    for (final signal in signals) {
      byDimension.putIfAbsent(signal.mirrorDimension, () => []).add(signal);
    }

    final tensions = <KnowMeMirrorTension>[];
    for (final entry in byDimension.entries) {
      tensions.addAll(_detectInDimension(entry.key, entry.value));
    }

    return _dedupe(tensions);
  }

  static List<KnowMeMirrorTension> _detectInDimension(
    KnowMeMirrorDimensionId dimension,
    List<KnowMeMirrorThemeSignal> signals,
  ) {
    final tensions = <KnowMeMirrorTension>[];
    final seen = <String>{};

    for (var i = 0; i < signals.length; i++) {
      for (var j = i + 1; j < signals.length; j++) {
        final a = signals[i];
        final b = signals[j];

        if (a.sourceLensKey == b.sourceLensKey &&
            a.patternFamily == b.patternFamily) {
          continue;
        }

        if (!KnowMeMirrorOpposingPatternFamily.areOpposing(
          a.patternFamily,
          b.patternFamily,
        )) {
          continue;
        }

        final reason = KnowMeMirrorOpposingPatternFamily.reasonCodeFor(
          a.patternFamily,
          b.patternFamily,
        );
        if (reason == null) continue;

        final systems = {a.systemId, b.systemId}.toList()
          ..sort((x, y) => x.index.compareTo(y.index));
        final lenses = {a.sourceLensKey, b.sourceLensKey}.toList()..sort();
        final themes = {a.themeId, b.themeId}.toList()..sort();
        final families = {a.patternFamily, b.patternFamily}.toList()..sort();

        final patternType = systems.length >= 2 &&
                a.systemId != b.systemId
            ? KnowMeMirrorPatternType.crossSystemTension
            : KnowMeMirrorPatternType.crossLensTension;

        final key =
            '$dimension|${themes.join(',')}|${families.join(',')}|${lenses.join(',')}';
        if (!seen.add(key)) continue;

        tensions.add(
          KnowMeMirrorTension(
            id: 'tension:$key',
            patternType: patternType,
            mirrorDimension: dimension,
            themeIds: themes,
            patternFamilies: families,
            supportingSystems: List<KnowMeMirrorSystemId>.from(systems),
            supportingLensKeys: lenses,
            reasonCode: reason,
          ),
        );
      }
    }

    return tensions;
  }

  static List<KnowMeMirrorTension> _dedupe(List<KnowMeMirrorTension> tensions) {
    final seen = <String>{};
    final out = <KnowMeMirrorTension>[];

    for (final tension in tensions) {
      if (seen.add(tension.id)) out.add(tension);
    }

    return out;
  }
}
