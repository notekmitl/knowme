import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/global_fusion/application/confidence/global_confidence_composer.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_builder.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_input_loader.dart';
import 'package:knowme/features/global_fusion/domain/global_agreement.dart';
import 'package:knowme/features/global_fusion/domain/global_agreement_strength.dart';
import 'package:knowme/features/global_fusion/domain/global_confidence.dart';
import 'package:knowme/features/global_fusion/domain/global_confidence_band.dart';
import 'package:knowme/features/global_fusion/domain/global_coverage.dart';
import 'package:knowme/features/global_fusion/domain/global_lens_id.dart';
import 'package:knowme/features/global_fusion/domain/global_tension.dart';
import 'package:knowme/features/global_fusion/validation/global_confidence_golden_scenario.dart';
import 'package:knowme/features/global_fusion/validation/global_confidence_validation_harness.dart';

void main() {
  const loader = GlobalFusionInputLoader();

  GlobalCoverage coverage({
    bool astrology = false,
    bool personality = false,
  }) {
    return GlobalCoverage(
      astrology: astrology
          ? const AstrologyMirrorCoverageSlice(
              available: true,
              completedLensCount: 2,
              totalLensCount: 3,
              completedLensIds: ['western', 'bazi'],
            )
          : AstrologyMirrorCoverageSlice.empty,
      personality: personality
          ? const PersonalityMirrorCoverageSlice(
              available: true,
              availableLensIds: [],
              missingLensIds: [],
              weightedCoverage: 0.85,
              eqModulesCompleted: 0,
              eqModulesExpected: 6,
            )
          : PersonalityMirrorCoverageSlice.empty,
    );
  }

  GlobalAgreement agreement(GlobalAgreementStrength strength) {
    return GlobalAgreement(
      id: 'agreement:structure',
      themeId: 'structure',
      supportingMirrors: const [
        GlobalLensId.astrologyMirror,
        GlobalLensId.personalityMirror,
      ],
      supportingEvidenceCount: strength == GlobalAgreementStrength.strong
          ? 4
          : strength == GlobalAgreementStrength.medium
              ? 2
              : 1,
      strength: strength,
    );
  }

  group('GlobalConfidenceBands', () {
    test('low band ends at 0.39', () {
      expect(GlobalConfidenceBands.bandFor(0.0), GlobalConfidenceBand.low);
      expect(GlobalConfidenceBands.bandFor(0.39), GlobalConfidenceBand.low);
    });

    test('medium band spans 0.40 to 0.69', () {
      expect(GlobalConfidenceBands.bandFor(0.40), GlobalConfidenceBand.medium);
      expect(GlobalConfidenceBands.bandFor(0.69), GlobalConfidenceBand.medium);
    });

    test('high band starts at 0.70', () {
      expect(GlobalConfidenceBands.bandFor(0.70), GlobalConfidenceBand.high);
      expect(GlobalConfidenceBands.bandFor(1.0), GlobalConfidenceBand.high);
    });

    test('clamp keeps values inside 0.0 to 1.0', () {
      expect(GlobalConfidenceBands.clamp(-0.2), 0.0);
      expect(GlobalConfidenceBands.clamp(1.4), 1.0);
    });
  });

  group('GlobalConfidenceComposer coverage', () {
    test('no mirrors yields zero composite and low band', () {
      final result = GlobalConfidenceComposer.analyze(
        coverage: coverage(),
        agreements: const [],
        tensions: const [],
        themes: const [],
      );

      expect(result.coverageScore, 0.0);
      expect(result.coverageContribution, 0.0);
      expect(result.composite, 0.0);
      expect(result.band, GlobalConfidenceBand.low);
    });

    test('one mirror yields medium composite', () {
      final result = GlobalConfidenceComposer.analyze(
        coverage: coverage(astrology: true),
        agreements: const [],
        tensions: const [],
        themes: const [],
      );

      expect(result.coverageScore, 0.5);
      expect(result.coverageContribution, 0.5);
      expect(result.composite, 0.5);
      expect(result.band, GlobalConfidenceBand.medium);
    });

    test('both mirrors without agreement stay at medium base', () {
      final result = GlobalConfidenceComposer.analyze(
        coverage: coverage(astrology: true, personality: true),
        agreements: const [],
        tensions: const [],
        themes: const [],
      );

      expect(result.coverageScore, 1.0);
      expect(result.coverageContribution, 0.5);
      expect(result.composite, 0.5);
      expect(result.band, GlobalConfidenceBand.medium);
    });
  });

  group('GlobalConfidenceComposer agreement bonus', () {
    test('weak agreement adds 0.10 bonus', () {
      final result = GlobalConfidenceComposer.analyze(
        coverage: coverage(astrology: true, personality: true),
        agreements: [agreement(GlobalAgreementStrength.weak)],
        tensions: const [],
        themes: const [],
      );

      expect(result.agreementBonus, closeTo(0.10, 0.001));
      expect(result.coverageContribution, 1.0);
      expect(result.composite, 1.0);
    });

    test('medium agreement adds 0.20 bonus', () {
      final result = GlobalConfidenceComposer.analyze(
        coverage: coverage(astrology: true, personality: true),
        agreements: [agreement(GlobalAgreementStrength.medium)],
        tensions: const [],
        themes: const [],
      );

      expect(result.agreementBonus, closeTo(0.20, 0.001));
      expect(result.composite, 1.0);
      expect(result.band, GlobalConfidenceBand.high);
    });

    test('strong agreement adds 0.30', () {
      final result = GlobalConfidenceComposer.analyze(
        coverage: coverage(astrology: true, personality: true),
        agreements: [agreement(GlobalAgreementStrength.strong)],
        tensions: const [],
        themes: const [],
      );

      expect(result.agreementBonus, closeTo(0.30, 0.001));
      expect(result.composite, 1.0);
      expect(result.band, GlobalConfidenceBand.high);
    });

    test('multiple agreements stack bonuses', () {
      final result = GlobalConfidenceComposer.analyze(
        coverage: coverage(astrology: true, personality: true),
        agreements: [
          agreement(GlobalAgreementStrength.medium),
          agreement(GlobalAgreementStrength.weak),
        ],
        tensions: const [],
        themes: const [],
      );

      expect(result.agreementBonus, closeTo(0.30, 0.001));
      expect(result.composite, 1.0);
    });
  });

  group('GlobalConfidenceComposer tension penalty', () {
    test('each tension subtracts 0.10', () {
      final result = GlobalConfidenceComposer.analyze(
        coverage: coverage(astrology: true, personality: true),
        agreements: const [],
        tensions: const [
          GlobalTension(
            id: 'tension:structure:adaptability',
            primaryThemeId: 'structure',
            secondaryThemeId: 'adaptability',
            supportingMirrors: [
              GlobalLensId.astrologyMirror,
              GlobalLensId.personalityMirror,
            ],
            reason: 'structure_adaptability_divergence',
          ),
        ],
        themes: const [],
      );

      expect(result.tensionPenalty, 0.10);
      expect(result.composite, 0.40);
      expect(result.band, GlobalConfidenceBand.medium);
    });

    test('agreements plus tensions reduce composite below agreement-only', () {
      final agreementOnly = GlobalConfidenceComposer.analyze(
        coverage: coverage(astrology: true, personality: true),
        agreements: [agreement(GlobalAgreementStrength.strong)],
        tensions: const [],
        themes: const [],
      );
      final mixed = GlobalConfidenceComposer.analyze(
        coverage: coverage(astrology: true, personality: true),
        agreements: [agreement(GlobalAgreementStrength.medium)],
        tensions: const [
          GlobalTension(
            id: 'tension:structure:adaptability',
            primaryThemeId: 'structure',
            secondaryThemeId: 'adaptability',
            supportingMirrors: [
              GlobalLensId.astrologyMirror,
              GlobalLensId.personalityMirror,
            ],
            reason: 'structure_adaptability_divergence',
          ),
          GlobalTension(
            id: 'tension:relationships:reflection',
            primaryThemeId: 'relationships',
            secondaryThemeId: 'reflection',
            supportingMirrors: [
              GlobalLensId.astrologyMirror,
              GlobalLensId.personalityMirror,
            ],
            reason: 'relationships_reflection_divergence',
          ),
          GlobalTension(
            id: 'tension:growth:structure',
            primaryThemeId: 'growth',
            secondaryThemeId: 'structure',
            supportingMirrors: [
              GlobalLensId.astrologyMirror,
              GlobalLensId.personalityMirror,
            ],
            reason: 'growth_structure_divergence',
          ),
        ],
        themes: const [],
      );

      expect(mixed.composite, lessThan(agreementOnly.composite));
      expect(mixed.tensionPenalty, closeTo(0.30, 0.001));
      expect(mixed.composite, closeTo(0.90, 0.001));
    });
  });

  group('GlobalConfidenceComposer output contract', () {
    test('compose returns v1 formula with band', () {
      final confidence = GlobalConfidenceComposer.compose(
        coverage: coverage(astrology: true),
        agreements: const [],
        tensions: const [],
        themes: const [],
      );

      expect(confidence.formulaVersion, GlobalConfidence.v1FormulaVersion);
      expect(confidence.band, GlobalConfidenceBand.medium);
      expect(confidence.isPlaceholder, isFalse);
    });
  });

  group('GlobalFusionBuilder confidence integration', () {
    test('builder emits global_confidence.v1', () {
      final pair = GlobalConfidenceValidationHarness.run(
        GlobalConfidenceGoldenScenario.oneMirror,
      ).snapshot;

      expect(pair.confidence.formulaVersion, GlobalConfidence.v1FormulaVersion);
      expect(pair.confidence.band, isNotNull);
    });

    test('builder confidence matches composer for fixture input', () {
      final fixture = GlobalConfidenceValidationHarness.run(
        GlobalConfidenceGoldenScenario.twoMirrorsNoAgreement,
      );
      final input = loader.load(
        astrologySnapshot: fixture.snapshot.input.astrologySnapshot,
        personalitySnapshot: fixture.snapshot.input.personalitySnapshot,
      );
      final snapshot = GlobalFusionBuilder.build(input);

      expect(snapshot.confidence.composite, fixture.snapshot.confidence.composite);
      expect(snapshot.confidence.band, fixture.snapshot.confidence.band);
    });
  });

  group('GlobalConfidenceValidationHarness', () {
    for (final scenario in GlobalConfidenceGoldenScenario.values) {
      test('${scenario.name} passes confidence golden expectations', () {
        final result = GlobalConfidenceValidationHarness.run(scenario);

        if (!result.passed) {
          // ignore: avoid_print
          print(result.debugReport);
          // ignore: avoid_print
          print('issues: ${result.issues}');
        }

        expect(
          result.passed,
          isTrue,
          reason: '${scenario.name} failed: ${result.issues.join('; ')}',
        );
      });
    }

    test('runAllPassing returns true', () {
      expect(GlobalConfidenceValidationHarness.runAllPassing(), isTrue);
    });

    test('mixed scenario is lower than agreement-only scenario', () {
      final comparisonIssues = GlobalConfidenceValidationHarness.verifyComparisons();
      expect(comparisonIssues, isEmpty);
    });
  });
}
