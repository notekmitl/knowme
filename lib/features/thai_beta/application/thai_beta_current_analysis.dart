import 'package:flutter/foundation.dart';

import 'thai_beta_analysis.dart';

/// In-memory holder for the user's most recent **successful** Thai Beta analysis
/// in this app session. Used by `/beta/thai/capture` so PDF export matches the
/// report the user actually generated — never a QA sample fallback, and never a
/// stale prior success after a newer attempt fails.
abstract final class ThaiBetaCurrentAnalysis {
  static ThaiBetaAnalysis? _current;

  static ThaiBetaAnalysis? get current => _current;

  /// Clears exportable analysis. Call when a new analysis attempt starts.
  static void clear() {
    _current = null;
  }

  /// Stores [analysis] only when successful; failures clear export state.
  static void set(ThaiBetaAnalysis analysis) {
    if (analysis.isSuccess) {
      _current = analysis;
    } else {
      _current = null;
    }
  }

  @visibleForTesting
  static void resetForTest() {
    clear();
  }
}
