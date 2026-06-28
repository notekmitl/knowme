import 'product_validation_recorder.dart';

/// Phase A — the app-wide access point for product instrumentation.
///
/// The experience calls `ProductValidation.tracker.<event>()` at the measurable
/// moments; the internal dashboard reads `ProductValidation.recorder.insights()`.
/// Swap [recorder] in tests, or set `enabled = false` to turn measurement off.
abstract final class ProductValidation {
  static ProductValidationRecorder recorder = ProductValidationRecorder();

  /// The tracker the experience instruments against.
  static ProductValidationTracker get tracker => recorder;
}
