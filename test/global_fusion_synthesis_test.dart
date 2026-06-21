import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/global_fusion/application/agreement/global_agreement_engine.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_builder.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_input_loader.dart';
import 'package:knowme/features/global_fusion/application/tension/global_tension_engine.dart';
import 'package:knowme/features/global_fusion/application/tension/global_tension_pairs.dart';
import 'package:knowme/features/global_fusion/domain/global_agreement_strength.dart';
import 'package:knowme/features/global_fusion/domain/global_core_themes.dart';
import 'package:knowme/features/global_fusion/domain/global_evidence.dart';
import 'package:knowme/features/global_fusion/domain/global_lens_id.dart';
import 'package:knowme/features/global_fusion/domain/global_theme_activation.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_golden_fixtures.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_golden_scenario.dart';
import 'package:knowme/features/global_fusion/domain/global_confidence.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_golden_scenario.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_validation_harness.dart';

void main() {
  const loader = GlobalFusionInputLoader();

  GlobalThemeActivation activation({
    required String themeId,
    required List<GlobalEvidence> evidence,
  }) {
    return GlobalThemeActivation(globalThemeId: themeId, evidence: evidence);
  }

  GlobalEvidence evidence(GlobalLensId mirror, {String themeId = 'fixture'}) {
    return GlobalEvidence(
      sourceMirror: mirror,
      sourceThemeId: themeId,
      referenceKind: 'fixture',
      referenceId: themeId,
    );
  }

  group('GlobalAgreementStrengthRules', () {
    test('strong when evidence count >= 4', () {
      expect(
        GlobalAgreementStrengthRules.forEvidenceCount(4),
        GlobalAgreementStrength.strong,
      );
      expect(
        GlobalAgreementStrengthRules.forEvidenceCount(6),
        GlobalAgreementStrength.strong,
      );
    });

    test('medium when evidence count >= 2 and < 4', () {
      expect(
        GlobalAgreementStrengthRules.forEvidenceCount(2),
        GlobalAgreementStrength.medium,
      );
      expect(
        GlobalAgreementStrengthRules.forEvidenceCount(3),
        GlobalAgreementStrength.medium,
      );
    });

    test('weak when evidence count < 2', () {
      expect(
        GlobalAgreementStrengthRules.forEvidenceCount(1),
        GlobalAgreementStrength.weak,
      );
      expect(
        GlobalAgreementStrengthRules.forEvidenceCount(0),
        GlobalAgreementStrength.weak,
      );
    });
  });

  group('GlobalAgreementEngine', () {
    test('detects agreement when both mirrors support same theme', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [
            evidence(GlobalLensId.astrologyMirror, themeId: 'structured'),
            evidence(GlobalLensId.personalityMirror, themeId: 'structured'),
          ],
        ),
      ];

      final agreements = GlobalAgreementEngine.detect(activations);

      expect(agreements, hasLength(1));
      expect(agreements.first.themeId, GlobalThemeIds.structure);
      expect(agreements.first.supportingMirrors, hasLength(2));
    });

    test('returns empty when only one mirror supports theme', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [evidence(GlobalLensId.astrologyMirror)],
        ),
      ];

      expect(GlobalAgreementEngine.detect(activations), isEmpty);
    });

    test('assigns strong strength with combined evidence >= 4', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [
            evidence(GlobalLensId.astrologyMirror),
            evidence(GlobalLensId.astrologyMirror),
            evidence(GlobalLensId.personalityMirror),
            evidence(GlobalLensId.personalityMirror),
          ],
        ),
      ];

      final agreements = GlobalAgreementEngine.detect(activations);
      expect(agreements.single.strength, GlobalAgreementStrength.strong);
      expect(agreements.single.supportingEvidenceCount, 4);
    });

    test('does not duplicate agreements for same theme', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [
            evidence(GlobalLensId.astrologyMirror),
            evidence(GlobalLensId.personalityMirror),
          ],
        ),
      ];

      final agreements = GlobalAgreementEngine.detect(activations);
      expect(agreements.map((a) => a.id).toSet(), hasLength(1));
    });

    test('detects multiple agreements on different themes', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [
            evidence(GlobalLensId.astrologyMirror),
            evidence(GlobalLensId.personalityMirror),
          ],
        ),
        activation(
          themeId: GlobalThemeIds.reflection,
          evidence: [
            evidence(GlobalLensId.astrologyMirror),
            evidence(GlobalLensId.personalityMirror),
          ],
        ),
      ];

      final agreements = GlobalAgreementEngine.detect(activations);
      expect(agreements, hasLength(2));
    });
  });

  group('GlobalTensionEngine', () {
    test('detects structure vs adaptability divergence', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.adaptability,
          evidence: [evidence(GlobalLensId.astrologyMirror)],
        ),
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [evidence(GlobalLensId.personalityMirror)],
        ),
      ];

      final tensions = GlobalTensionEngine.detect(activations);

      expect(tensions, hasLength(1));
      expect(tensions.first.primaryThemeId, GlobalThemeIds.structure);
      expect(tensions.first.secondaryThemeId, GlobalThemeIds.adaptability);
      expect(tensions.first.reason, 'structure_adaptability_divergence');
    });

    test('returns empty when only one mirror present', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [evidence(GlobalLensId.astrologyMirror)],
        ),
        activation(
          themeId: GlobalThemeIds.adaptability,
          evidence: [evidence(GlobalLensId.astrologyMirror)],
        ),
      ];

      expect(GlobalTensionEngine.detect(activations), isEmpty);
    });

    test('returns empty when both mirrors share same side of pair', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [
            evidence(GlobalLensId.astrologyMirror),
            evidence(GlobalLensId.personalityMirror),
          ],
        ),
      ];

      expect(GlobalTensionEngine.detect(activations), isEmpty);
    });

    test('does not duplicate tensions for same pair', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.adaptability,
          evidence: [
            evidence(GlobalLensId.astrologyMirror),
            evidence(GlobalLensId.astrologyMirror),
          ],
        ),
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [
            evidence(GlobalLensId.personalityMirror),
            evidence(GlobalLensId.personalityMirror),
          ],
        ),
      ];

      final tensions = GlobalTensionEngine.detect(activations);
      expect(tensions.map((t) => t.id).toSet(), hasLength(1));
    });

    test('detects relationships vs reflection pair', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.relationships,
          evidence: [evidence(GlobalLensId.astrologyMirror)],
        ),
        activation(
          themeId: GlobalThemeIds.reflection,
          evidence: [evidence(GlobalLensId.personalityMirror)],
        ),
      ];

      final tensions = GlobalTensionEngine.detect(activations);
      expect(tensions, hasLength(1));
      expect(tensions.first.reason, 'relationships_reflection_divergence');
    });

    test('detects growth vs structure pair', () {
      final activations = [
        activation(
          themeId: GlobalThemeIds.growth,
          evidence: [evidence(GlobalLensId.personalityMirror)],
        ),
        activation(
          themeId: GlobalThemeIds.structure,
          evidence: [evidence(GlobalLensId.astrologyMirror)],
        ),
      ];

      final tensions = GlobalTensionEngine.detect(activations);
      expect(tensions, hasLength(1));
      expect(tensions.first.reason, 'growth_structure_divergence');
    });
  });

  group('GlobalTensionPairRegistry', () {
    test('defines three curated starter pairs', () {
      expect(GlobalTensionPairRegistry.pairs, hasLength(3));
    });
  });

  group('GlobalFusionBuilder synthesis integration', () {
    test('single mirror produces no agreements or tensions', () {
      final pair = GlobalFusionGoldenFixtures.scenarioA();
      final input = loader.load(
        astrologySnapshot: pair.astrology,
        personalitySnapshot: pair.personality,
      );
      final snapshot = GlobalFusionBuilder.build(input);

      expect(snapshot.agreements, isEmpty);
      expect(snapshot.tensions, isEmpty);
    });

    test('agreement-only fixture produces agreements without tensions', () {
      final pair = GlobalFusionGoldenFixtures.scenarioC();
      final input = loader.load(
        astrologySnapshot: pair.astrology,
        personalitySnapshot: pair.personality,
      );
      final snapshot = GlobalFusionBuilder.build(input);

      expect(snapshot.agreements, isNotEmpty);
      expect(snapshot.tensions, isEmpty);
    });

    test('tension-only fixture produces tensions without agreements', () {
      final pair = GlobalFusionGoldenFixtures.scenarioD();
      final input = loader.load(
        astrologySnapshot: pair.astrology,
        personalitySnapshot: pair.personality,
      );
      final snapshot = GlobalFusionBuilder.build(input);

      expect(snapshot.agreements, isEmpty);
      expect(snapshot.tensions, isNotEmpty);
    });

    test('mixed fixture produces both agreements and tensions', () {
      final pair = GlobalFusionGoldenFixtures.scenarioE();
      final input = loader.load(
        astrologySnapshot: pair.astrology,
        personalitySnapshot: pair.personality,
      );
      final snapshot = GlobalFusionBuilder.build(input);

      expect(snapshot.agreements, isNotEmpty);
      expect(snapshot.tensions, isNotEmpty);
      expect(snapshot.confidence.formulaVersion, GlobalConfidence.v1FormulaVersion);
      expect(snapshot.confidence.isPlaceholder, isFalse);
    });

    test('empty mirrors produce empty synthesis output', () {
      final pair = GlobalFusionGoldenFixtures.scenarioF();
      final input = loader.load(
        astrologySnapshot: pair.astrology,
        personalitySnapshot: pair.personality,
      );
      final snapshot = GlobalFusionBuilder.build(input);

      expect(snapshot.normalizedThemes, isEmpty);
      expect(snapshot.agreements, isEmpty);
      expect(snapshot.tensions, isEmpty);
    });
  });

  group('GlobalFusionValidationHarness GF-F1 scenarios', () {
    for (final scenario in GlobalFusionGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final result = GlobalFusionValidationHarness.run(scenario);

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
      expect(GlobalFusionValidationHarness.runAllPassing(), isTrue);
    });
  });
}
