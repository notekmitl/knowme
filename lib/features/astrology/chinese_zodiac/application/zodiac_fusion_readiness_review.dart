import '../domain/zodiac_fusion_readiness_signals.dart';
import 'zodiac_theme_calibration_audit.dart';
import 'zodiac_theme_calibration_resolver.dart';

/// Human-readable fusion readiness summary per animal (preparation layer).
abstract final class ZodiacFusionReadinessReview {
  static Map<String, ZodiacFusionReadinessSignals> allSignals() {
    return Map<String, ZodiacFusionReadinessSignals>.unmodifiable({
      for (final animal in ZodiacThemeCalibrationResolver.supportedAnimals)
        animal: ZodiacThemeCalibrationResolver.fusionReadinessForAnimal(animal),
    });
  }

  static bool allAnimalsFusionReady() {
    return ZodiacThemeCalibrationAudit.run().fusionCoverageGaps.isEmpty;
  }
}
