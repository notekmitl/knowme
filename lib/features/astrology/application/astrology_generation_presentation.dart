import 'package:knowme/features/astrology/domain/astrology_generation_status.dart';
import 'package:knowme/features/home_cohesion/presentation/home_v3_copy.dart';

/// Human-readable labels for generation status in product UI.
abstract final class AstrologyGenerationPresentation {
  static String statusMessage(AstrologySystemSnapshot system) {
    return switch (system.status) {
      AstrologyGenerationStatus.completed => HomeV3Copy.astrologySystemReady,
      AstrologyGenerationStatus.generating ||
      AstrologyGenerationStatus.queued =>
        HomeV3Copy.astrologySystemGenerating,
      AstrologyGenerationStatus.failed => HomeV3Copy.astrologySystemFailed,
      AstrologyGenerationStatus.notReady => HomeV3Copy.profileCompletenessEmpty,
    };
  }

  static String actionLabel(AstrologySystemSnapshot system) {
    return switch (system.status) {
      AstrologyGenerationStatus.completed =>
        HomeV3Copy.astrologyViewResultAction,
      AstrologyGenerationStatus.generating ||
      AstrologyGenerationStatus.queued =>
        HomeV3Copy.astrologySystemGenerating,
      AstrologyGenerationStatus.failed => HomeV3Copy.astrologyRetryAction,
      AstrologyGenerationStatus.notReady =>
        HomeV3Copy.astrologyCompleteProfileAction,
    };
  }

  static bool canOpen(AstrologySystemSnapshot system) =>
      system.status == AstrologyGenerationStatus.completed;

  static bool canRetry(AstrologySystemSnapshot system) =>
      system.status == AstrologyGenerationStatus.failed;

  static bool isBusy(AstrologySystemSnapshot system) => system.isBusy;
}
