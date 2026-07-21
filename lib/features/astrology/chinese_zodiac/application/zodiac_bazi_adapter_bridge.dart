import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/adapters/adapter_helpers.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';

import '../domain/zodiac_fusion_bridge_signal.dart';
import '../domain/zodiac_fusion_signal_weight.dart';
import 'zodiac_fusion_bridge_resolver.dart';

/// Converts Year Animal bridge signals into BaZi lens theme outputs.
///
/// Confidence is intentionally below Day Master, Dominant Element, and
/// Element Balance so zodiac remains a secondary signal source.
abstract final class ZodiacBaziAdapterBridge {
  /// Primary calibration tier — full bridge weight.
  static const double fullConfidence = 0.55;

  /// Secondary calibration tier — reduced bridge weight.
  static const double reducedConfidence = 0.45;

  /// Weak calibration tier — growth-only bridge weight.
  static const double growthOnlyConfidence = 0.35;

  static List<LensThemeOutput> adapt(BaziYearAnimal yearAnimal) {
    final animalKey = yearAnimal.en.trim();
    if (animalKey.isEmpty) return const [];

    final bundle = ZodiacFusionBridgeResolver.bundleForAnimal(animalKey);
    if (bundle.isEmpty) return const [];

    final outputs = <LensThemeOutput>[];
    for (final signal in bundle.signals) {
      final output = FusionAdapterHelpers.buildRegistered(
        lensId: FusionAdapterHelpers.baziLensId,
        themeId: signal.fusionThemeId,
        confidence: confidenceForWeight(signal.weight),
        evidence: [_evidenceLabel(animalKey, signal)],
      );
      if (output != null) outputs.add(output);
    }

    return outputs;
  }

  static double confidenceForWeight(ZodiacFusionSignalWeight weight) {
    return switch (weight) {
      ZodiacFusionSignalWeight.full => fullConfidence,
      ZodiacFusionSignalWeight.reduced => reducedConfidence,
      ZodiacFusionSignalWeight.growthOnly => growthOnlyConfidence,
    };
  }

  static String _evidenceLabel(
    String animalLabel,
    ZodiacFusionBridgeSignal signal,
  ) {
    final tierLabel = switch (signal.weight) {
      ZodiacFusionSignalWeight.full => 'primary',
      ZodiacFusionSignalWeight.reduced => 'secondary',
      ZodiacFusionSignalWeight.growthOnly => 'growth',
    };
    return 'Year Animal: $animalLabel · ${signal.foundationThemeId} ($tierLabel)';
  }
}
