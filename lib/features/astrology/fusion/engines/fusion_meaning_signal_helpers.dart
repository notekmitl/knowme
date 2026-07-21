import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';

/// Shared signal/theme helpers for meaning-layer builders.
abstract final class FusionMeaningSignalHelpers {
  static List<FusionSignal> visibleSignals(AstrologyFusionResult result) {
    return result.signals
        .where(
          (s) =>
              s.supportLevel != FusionSupportLevel.low &&
              s.type != FusionSignalType.transformation,
        )
        .toList();
  }

  static FusionSignalType? primarySignalType(AstrologyFusionResult result) {
    final signals = visibleSignals(result);
    if (signals.isNotEmpty) return signals.first.type;
    return null;
  }

  static String? primaryThemeId(AstrologyFusionResult result) {
    if (result.topThemes.isNotEmpty) return result.topThemes.first;
    return null;
  }

  static bool hasSignal(AstrologyFusionResult result, FusionSignalType type) {
    return visibleSignals(result).any((s) => s.type == type);
  }

  static bool hasTheme(AstrologyFusionResult result, String themeId) {
    return result.topThemes.contains(themeId);
  }
}
