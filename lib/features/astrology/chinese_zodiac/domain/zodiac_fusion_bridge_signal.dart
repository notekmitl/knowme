import 'zodiac_fusion_signal_weight.dart';
import 'zodiac_theme_weight_tier.dart';

/// One Fusion Registry signal derived from a Theme Foundation id.
class ZodiacFusionBridgeSignal {
  const ZodiacFusionBridgeSignal({
    required this.fusionThemeId,
    required this.foundationThemeId,
    required this.sourceTier,
    required this.weight,
  });

  final String fusionThemeId;
  final String foundationThemeId;
  final ZodiacThemeWeightTier sourceTier;
  final ZodiacFusionSignalWeight weight;
}
