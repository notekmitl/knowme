import '../domain/fusion_models.dart';
import 'fusion_signal_adapter.dart';
import 'fusion_signal_merge.dart';
import 'fusion_synthesis.dart';

/// Deterministic fusion pipeline (Phase 4A: meaning layer, no final narrative).
abstract final class FusionEngine {
  static FusionOutput synthesize(
    FusionInput input, {
    String lang = 'th',
  }) {
    final rawSignals = FusionSignalAdapter.collect(input);
    final mergedSignals = FusionSignalMerge.merge(rawSignals);
    final meaning = FusionSynthesis.build(
      merged: mergedSignals,
      lang: lang,
    );

    return FusionOutput(
      input: input,
      signals: rawSignals,
      mergedSignals: mergedSignals,
      heroSummary: meaning.heroSummary,
      reflectionPrompts: meaning.reflectionPrompts,
      patterns: meaning.patterns,
      guidanceTips: meaning.guidanceTips,
      whyPersonalized: meaning.whyPersonalized,
    );
  }
}
