import 'package:flutter/foundation.dart';

import 'thai_beta_analysis.dart';

/// In-memory holder for the user's most recent successful Thai Beta analysis
/// in this app session. Used by `/beta/thai/capture` so PDF export matches the
/// report the user actually generated — never a QA sample fallback.
abstract final class ThaiBetaCurrentAnalysis {
  static ThaiBetaAnalysis? _current;

  static ThaiBetaAnalysis? get current => _current;

  static void set(ThaiBetaAnalysis analysis) {
    if (analysis.isSuccess) {
      _current = analysis;
    }
  }

  @visibleForTesting
  static void resetForTest() {
    _current = null;
  }
}
