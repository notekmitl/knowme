import 'zodiac_fusion_bridge_signal.dart';
import 'zodiac_fusion_signal_weight.dart';

/// Fusion-ready weighted signals for one Year Animal (preparation layer).
class ZodiacFusionSignalBundle {
  const ZodiacFusionSignalBundle({
    required this.animalKey,
    required this.signals,
  });

  final String animalKey;
  final List<ZodiacFusionBridgeSignal> signals;

  List<String> fusionThemeIds({ZodiacFusionSignalWeight? weight}) {
    if (weight == null) {
      return List<String>.unmodifiable(
        signals.map((signal) => signal.fusionThemeId),
      );
    }
    return List<String>.unmodifiable(
      signals
          .where((signal) => signal.weight == weight)
          .map((signal) => signal.fusionThemeId),
    );
  }

  bool get isEmpty => signals.isEmpty;
}
