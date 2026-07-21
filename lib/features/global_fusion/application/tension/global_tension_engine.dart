import '../../domain/global_lens_id.dart';
import '../../domain/global_tension.dart';
import '../../domain/global_theme_activation.dart';
import 'global_tension_pairs.dart';

/// Detects curated cross-mirror theme divergences (GF-F1).
abstract final class GlobalTensionEngine {
  static List<GlobalTension> detect(List<GlobalThemeActivation> activations) {
    final mirrorThemes = _themesByMirror(activations);
    final astrologyThemes = mirrorThemes[GlobalLensId.astrologyMirror] ?? {};
    final personalityThemes =
        mirrorThemes[GlobalLensId.personalityMirror] ?? {};

    if (astrologyThemes.isEmpty || personalityThemes.isEmpty) {
      return const [];
    }

    final tensions = <String, GlobalTension>{};

    for (final pair in GlobalTensionPairRegistry.pairs) {
      final astrologyHasA = astrologyThemes.contains(pair.themeA);
      final astrologyHasB = astrologyThemes.contains(pair.themeB);
      final personalityHasA = personalityThemes.contains(pair.themeA);
      final personalityHasB = personalityThemes.contains(pair.themeB);

      final astrologyOpposite = (astrologyHasA && personalityHasB) ||
          (astrologyHasB && personalityHasA);
      if (!astrologyOpposite) continue;

      final tensionId = GlobalTension.idForPair(pair.themeA, pair.themeB);
      tensions.putIfAbsent(
        tensionId,
        () => GlobalTension(
          id: tensionId,
          primaryThemeId: pair.themeA,
          secondaryThemeId: pair.themeB,
          supportingMirrors: const [
            GlobalLensId.astrologyMirror,
            GlobalLensId.personalityMirror,
          ],
          reason: pair.reason,
        ),
      );
    }

    final results = tensions.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return results;
  }

  static Map<GlobalLensId, Set<String>> _themesByMirror(
    List<GlobalThemeActivation> activations,
  ) {
    final byMirror = <GlobalLensId, Set<String>>{};

    for (final activation in activations) {
      for (final evidence in activation.evidence) {
        byMirror
            .putIfAbsent(evidence.sourceMirror, () => {})
            .add(activation.globalThemeId);
      }
    }

    return byMirror;
  }
}
