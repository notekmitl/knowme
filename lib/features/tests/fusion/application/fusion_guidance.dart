import '../domain/fusion_constants.dart';
import '../domain/fusion_models.dart';
import 'fusion_guidance_copy.dart';
import 'fusion_theme_detection.dart';

/// Growth / Guidance Layer V1: 1–3 deterministic tips from merged signals/themes.
abstract final class FusionGuidance {
  static const _maxTips = 3;

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
      out.add(FusionGuidanceCopy.explorationStructure(lang));
    }

    for (final theme in themes) {
      if (out.length >= _maxTips) break;
      for (final tip in FusionGuidanceCopy.tipsForTheme(theme.themeId, lang)) {
        if (out.length >= _maxTips) break;
        if (out.contains(tip)) continue;
        out.add(tip);
      }
    }

    if (out.isEmpty) {
      out.add(FusionGuidanceCopy.gentleFallback(lang));
    }

    return out.take(_maxTips).toList(growable: false);
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
