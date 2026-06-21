import '../domain/global_confidence.dart';
import '../domain/global_fusion_constants.dart';
import '../domain/global_fusion_input.dart';
import '../domain/global_fusion_snapshot.dart';
import 'agreement/global_agreement_engine.dart';
import 'confidence/global_confidence_composer.dart';
import 'tension/global_tension_engine.dart';

/// GF-F2 builder — assembles snapshot with synthesis and confidence v1.
abstract final class GlobalFusionBuilder {
  static GlobalFusionSnapshot build(
    GlobalFusionInput input, {
    DateTime? generatedAt,
  }) {
    final now = generatedAt ?? DateTime.now();
    final agreements = GlobalAgreementEngine.detect(input.normalizedThemes);
    final tensions = GlobalTensionEngine.detect(input.normalizedThemes);
    final confidence = GlobalConfidenceComposer.compose(
      coverage: input.coverage,
      agreements: agreements,
      tensions: tensions,
      themes: input.normalizedThemes,
    );

    return GlobalFusionSnapshot(
      version: GlobalFusionContract.version,
      generatedAt: now,
      input: input,
      normalizedThemes: List.unmodifiable(input.normalizedThemes),
      agreements: List.unmodifiable(agreements),
      tensions: List.unmodifiable(tensions),
      confidence: confidence,
      coverage: input.coverage,
    );
  }
}
