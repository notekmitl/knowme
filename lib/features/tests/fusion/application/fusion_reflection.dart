import '../domain/fusion_constants.dart';
import '../domain/fusion_models.dart';
import 'fusion_reflection_copy.dart';
import 'fusion_theme_detection.dart';

/// Reflection Layer V1: 1–2 deterministic prompts from merged signals/themes.
abstract final class FusionReflection {
  static const _maxPrompts = 2;

  static List<String> build({
    required List<MergedFusionSignal> merged,
    required List<FusionThemeActivation> themes,
    String lang = 'th',
  }) {
    if (merged.isEmpty) return const [];

    final out = <String>[];

    final exploration = _find(merged, FusionSignalIds.exploration);
    final structure = _find(merged, FusionSignalIds.structure);
    if (_isAtLeast(exploration, FusionSignalStrength.high) &&
        _isAtLeast(structure, FusionSignalStrength.medium)) {
      out.add(FusionReflectionCopy.explorationStructure(lang));
    }

    for (final theme in themes) {
      if (out.length >= _maxPrompts) break;
      final prompt = FusionReflectionCopy.forTheme(theme.themeId, lang);
      if (prompt == null || out.contains(prompt)) continue;
      out.add(prompt);
    }

    if (out.isEmpty) {
      out.add(FusionReflectionCopy.gentleFallback(lang));
    }

    return out.take(_maxPrompts).toList(growable: false);
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

  static int _strengthRank(FusionSignalStrength strength) => switch (strength) {
        FusionSignalStrength.low => 0,
        FusionSignalStrength.medium => 1,
        FusionSignalStrength.high => 2,
      };
}
