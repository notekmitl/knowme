import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';

import '../../foundation/models/thai_astrology_profile.dart';
import '../../foundation/models/thai_birth_data.dart';
import '../../foundation/thai_foundation_engine.dart';
import '../models/thai_mirror_result.dart';
import '../presentation/thai_mirror_presenter.dart';
import '../spec/thai_mirror_assembler_spec.dart' hide ThaiMirrorAssembler;
import '../thai_mirror_assembler.dart';
import '../thai_mirror_narrative_generator.dart';
import '../thai_mirror_profile_enrichment.dart';
import 'thai_mirror_pipeline_result.dart';

/// End-to-end orchestrator: Birth Data → Thai Mirror view state.
///
/// Pure runtime wiring — no UI, widgets, or [BuildContext].
abstract final class ThaiMirrorPipeline {
  /// Sample birth data for internal QA (Bangkok, 1972-04-04 02:00 ICT).
  static ThaiBirthData sampleQaBirthData() {
    return ThaiBirthData(
      localDateTime: DateTime(1972, 4, 4, 2, 0),
      timeZoneOffset: Duration(hours: 7),
      latitude: 13.75,
      longitude: 100.50,
      hasBirthTime: true,
    );
  }

  /// Runs the full Thai Mirror pipeline without throwing to callers.
  static ThaiMirrorPipelineResult generate(ThaiBirthData birthData) {
    try {
      final generatedAt = DateTime.now().toUtc();
      final profile = ThaiMirrorProfileEnrichment.enrich(
        profile: ThaiFoundationEngine.generate(birthData),
        birthData: birthData,
      );
      final mirrorResult = _buildMirrorResult(profile);
      final viewState = ThaiMirrorPresenter.present(mirrorResult);

      // V8: derive Life Period evidence from the canonical birth profile here,
      // in the runtime — never by threading a raw birth date into presenters.
      // Consistency: feed the sunrise-adjusted astrological date (the single Thai
      // day), never the civil date — see ThaiBirthData / Birth Normalization.
      final lifePeriods = LifePeriodEngine.fromBirthData(birthData);

      return ThaiMirrorPipelineResult.success(
        viewState: viewState,
        profile: profile,
        mirrorResult: mirrorResult,
        generatedAt: generatedAt,
        birthData: birthData,
        lifePeriods: lifePeriods,
      );
    } catch (error) {
      return ThaiMirrorPipelineResult.failure(
        errorMessage: 'Thai Mirror pipeline failed: $error',
      );
    }
  }

  static ThaiMirrorResult _buildMirrorResult(ThaiAstrologyProfile profile) {
    final input = ThaiMirrorAssemblerSpec.inputFromProfile(profile);
    final structural = ThaiMirrorAssembler.assemble(input);
    return ThaiMirrorNarrativeGenerator.generate(structural);
  }
}
