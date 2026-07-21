import 'models/thai_theme_evidence.dart';
import 'models/thai_theme_result.dart';
import 'models/thai_theme_signal.dart';
import 'models/thai_theme_signal_source.dart';
import 'thai_theme_confidence_rules.dart';

/// Converts resolver signals into mirror-ready theme results.
///
/// Engine only — no narrative, AI, or UI output.
abstract final class ThaiThemeEngine {
  static List<ThaiThemeResult> process(List<ThaiThemeSignal> signals) {
    final results = signals.map(_toResult).toList();
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  static ThaiThemeResult _toResult(ThaiThemeSignal signal) {
    return ThaiThemeResult(
      themeId: signal.themeId,
      score: signal.score,
      confidence: ThaiThemeConfidenceRules.evaluate(
        sourceCount: signal.sources.length,
        totalScore: signal.score,
      ),
      evidence: _buildEvidence(signal.sources),
    );
  }

  static List<ThaiThemeEvidence> _buildEvidence(
    List<ThaiThemeSignalSource> sources,
  ) {
    return sources
        .map(
          (source) => ThaiThemeEvidence(
            contentKey: source.contentKey,
            sourceType: source.sourceType,
            contribution: source.contribution,
          ),
        )
        .toList(growable: false);
  }
}
