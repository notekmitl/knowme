import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

/// Deterministic Thai Beta narrative quality fixtures (test-only).
abstract final class ThaiBetaNarrativeFixtures {
  static final referenceDate = DateTime(2026, 7, 21);

  /// Fixture A — full birth time, ~44 years at [referenceDate].
  static ThaiBetaAnalysis fixtureA() => ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'A',
          birthDate: DateTime(1982, 4, 4),
          birthHour: 10,
          birthMinute: 30,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
        startedAt: referenceDate,
      );

  /// Fixture B — no birth time, ~45 years, confidence limitation.
  static ThaiBetaAnalysis fixtureB() => ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'B',
          birthDate: DateTime(1981, 6, 15),
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
        startedAt: referenceDate,
      );

  /// Fixture C — profile with facet tension (analytical + practical/action).
  static ThaiBetaAnalysis fixtureC() => ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'C',
          birthDate: DateTime(1990, 8, 20),
          birthHour: 14,
          birthMinute: 0,
          province: 'เชียงใหม่',
          provinceKey: 'chiang_mai',
        ),
        startedAt: referenceDate,
      );

  /// Fixture D — nearby birth profile for near-duplicate trait check.
  static ThaiBetaAnalysis fixtureD() => ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'D',
          birthDate: DateTime(1982, 4, 5),
          birthHour: 10,
          birthMinute: 30,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
        startedAt: referenceDate,
      );

  /// Fixture E — different life period from A/B.
  static ThaiBetaAnalysis fixtureE() => ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'E',
          birthDate: DateTime(2000, 1, 10),
          birthHour: 8,
          birthMinute: 0,
          province: 'ขอนแก่น',
          provinceKey: 'khon_kaen',
        ),
        startedAt: referenceDate,
      );
}
