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

  /// Wednesday daytime — harness profile E date (`1972-04-05` พุธ · สาย).
  /// Canon: Taksa weekday 4 is `NOT_IN_SOURCE` (documented separately for
  /// daytime vs night/Rahu); narrative must still compose from other signals.
  static ThaiBetaAnalysis wednesdayDaytime() => ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'WedDay',
          birthDate: DateTime(1972, 4, 5),
          birthHour: 9,
          birthMinute: 15,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
        startedAt: referenceDate,
      );

  /// Wednesday night / pre-sunrise Thursday civil → previous Thai day = พุธ.
  /// Basis: Birth Normalization sunrise day-boundary (`bornBeforeLocalSunrise`).
  static ThaiBetaAnalysis wednesdayNightBeforeSunrise() =>
      ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'WedNight',
          birthDate: DateTime(1972, 4, 6),
          birthHour: 2,
          birthMinute: 0,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
        startedAt: referenceDate,
      );

  /// Wednesday civil date without birth time (noon assumed → same Thai day).
  static ThaiBetaAnalysis wednesdayNoBirthTime() => ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'WedNoTime',
          birthDate: DateTime(1972, 4, 5),
          birthTimeUnknown: true,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
        startedAt: referenceDate,
      );

  /// User marked time unknown even if hour fields exist → no birth time.
  static ThaiBetaAnalysis incompleteTimeUnknownFlag() =>
      ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'TimeUnknown',
          birthDate: DateTime(1982, 4, 4),
          birthHour: 10,
          birthMinute: 30,
          birthTimeUnknown: true,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
        startedAt: referenceDate,
      );
}
