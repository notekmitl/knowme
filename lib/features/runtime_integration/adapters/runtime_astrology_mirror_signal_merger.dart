import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_bazi_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_theme_signal.dart';

/// Merges Thai + BaZi astrology mirror signals without duplicate theme emission.
abstract final class RuntimeAstrologyMirrorSignalMerger {
  /// Keeps the highest-confidence signal per mirrorKey + themeId pair.
  static List<KnowMeMirrorThemeSignal> merge(
    List<KnowMeMirrorThemeSignal> thaiSignals,
    List<KnowMeMirrorThemeSignal> baziSignals,
  ) {
    final best = <String, KnowMeMirrorThemeSignal>{};

    for (final signal in [...thaiSignals, ...baziSignals]) {
      final key = '${signal.mirrorKey}|${signal.themeId}';
      final existing = best[key];
      if (existing == null || signal.confidence > existing.confidence) {
        best[key] = signal;
      } else if (signal.confidence == existing.confidence &&
          existing.sourceLensKey == KnowMeMirrorBaziAdapter.sourceLensKey &&
          signal.sourceLensKey != KnowMeMirrorBaziAdapter.sourceLensKey) {
        continue;
      }
    }

    final merged = best.values.toList()
      ..sort((a, b) {
        final keyCompare = a.mirrorKey.compareTo(b.mirrorKey);
        if (keyCompare != 0) return keyCompare;
        return a.themeId.compareTo(b.themeId);
      });

    return List<KnowMeMirrorThemeSignal>.unmodifiable(merged);
  }
}
