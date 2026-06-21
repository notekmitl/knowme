import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_builder.dart';
import 'package:knowme/features/global_fusion/application/global_fusion_input_loader.dart';
import 'package:knowme/features/global_fusion/application/narrative/global_narrative_builder.dart';
import 'package:knowme/features/global_fusion/application/narrative/global_narrative_registry.dart';
import 'package:knowme/features/global_fusion/domain/global_agreement.dart';
import 'package:knowme/features/global_fusion/domain/global_agreement_strength.dart';
import 'package:knowme/features/global_fusion/domain/global_confidence.dart';
import 'package:knowme/features/global_fusion/domain/global_confidence_band.dart';
import 'package:knowme/features/global_fusion/domain/global_core_themes.dart';
import 'package:knowme/features/global_fusion/domain/global_coverage.dart';
import 'package:knowme/features/global_fusion/domain/global_evidence.dart';
import 'package:knowme/features/global_fusion/domain/global_lens_id.dart';
import 'package:knowme/features/global_fusion/domain/global_tension.dart';
import 'package:knowme/features/global_fusion/domain/global_theme_activation.dart';
import 'package:knowme/features/global_fusion/validation/global_fusion_golden_fixtures.dart';
import 'package:knowme/features/global_fusion/validation/global_narrative_golden_scenario.dart';
import 'package:knowme/features/global_fusion/validation/global_narrative_validation_harness.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';

void main() {
  const loader = GlobalFusionInputLoader();

  GlobalConfidence confidence({GlobalConfidenceBand band = GlobalConfidenceBand.medium}) {
    return GlobalConfidence(
      formulaVersion: GlobalConfidence.v1FormulaVersion,
      composite: 0.5,
      band: band,
      coverageScore: 0.5,
      coverageContribution: 0.5,
      agreementBonus: 0,
      tensionPenalty: 0,
    );
  }

  GlobalThemeActivation themeActivation(String themeId, {int evidence = 1}) {
    return GlobalThemeActivation(
      globalThemeId: themeId,
      evidence: List.generate(
        evidence,
        (_) => GlobalEvidence(
          sourceMirror: GlobalLensId.astrologyMirror,
          sourceThemeId: themeId,
          referenceKind: 'fixture',
          referenceId: themeId,
        ),
      ),
    );
  }

  group('GlobalNarrativeRegistry', () {
    test('defines theme reflection for all v1 themes', () {
      for (final themeId in GlobalThemeIds.v1Themes) {
        expect(GlobalNarrativeRegistry.themeReflection(themeId), isNotEmpty);
        expect(GlobalNarrativeRegistry.agreementReflection(themeId), isNotEmpty);
      }
    });

    test('structure agreement uses cross-mirror phrasing', () {
      expect(
        GlobalNarrativeRegistry.agreementReflection(GlobalThemeIds.structure),
        contains('หลายมุมสะท้อน'),
      );
    });

    test('structure vs adaptability tension reflection exists', () {
      expect(
        GlobalNarrativeRegistry.tensionReflection(
          GlobalThemeIds.structure,
          GlobalThemeIds.adaptability,
        ),
        contains('ความชัดเจน'),
      );
    });

    test('autonomy theme reflection uses soft phrasing', () {
      expect(
        GlobalNarrativeRegistry.themeReflection(GlobalThemeIds.autonomy),
        contains('คุณอาจ'),
      );
    });

    test('maps agreement strength to confidence band', () {
      expect(
        GlobalNarrativeRegistry.agreementStrengthBand(
          GlobalAgreementStrength.strong,
        ),
        GlobalConfidenceBand.high,
      );
      expect(
        GlobalNarrativeRegistry.agreementStrengthBand(
          GlobalAgreementStrength.weak,
        ),
        GlobalConfidenceBand.low,
      );
    });
  });

  group('GlobalNarrativeBuilder theme reflections', () {
    test('builds theme reflection units', () {
      final units = GlobalNarrativeBuilder.build(
        themes: [themeActivation(GlobalThemeIds.autonomy)],
        agreements: const [],
        tensions: const [],
        confidence: confidence(),
      );

      expect(units, hasLength(1));
      expect(units.first.themeId, GlobalThemeIds.autonomy);
      expect(units.first.category, FusionCategory.coreSelf);
      expect(units.first.reflection, contains('คุณอาจ'));
      expect(units.first.evidenceSummary, contains('autonomy'));
    });

    test('returns empty list for empty input', () {
      expect(
        GlobalNarrativeBuilder.build(
          themes: const [],
          agreements: const [],
          tensions: const [],
          confidence: confidence(),
        ),
        isEmpty,
      );
    });
  });

  group('GlobalNarrativeBuilder agreement reflections', () {
    test('builds agreement reflection with evidence summary', () {
      final units = GlobalNarrativeBuilder.build(
        themes: const [],
        agreements: const [
          GlobalAgreement(
            id: 'agreement:structure',
            themeId: GlobalThemeIds.structure,
            supportingMirrors: [
              GlobalLensId.astrologyMirror,
              GlobalLensId.personalityMirror,
            ],
            supportingEvidenceCount: 4,
            strength: GlobalAgreementStrength.strong,
          ),
        ],
        tensions: const [],
        confidence: confidence(band: GlobalConfidenceBand.high),
      );

      expect(units, hasLength(1));
      expect(units.first.reflection, contains('หลายมุมสะท้อน'));
      expect(units.first.evidenceSummary, contains('ข้อตกลงข้ามมิเรอร์'));
      expect(units.first.confidenceBand, GlobalConfidenceBand.high);
    });
  });

  group('GlobalNarrativeBuilder tension reflections', () {
    test('builds tension reflection for curated pair', () {
      final units = GlobalNarrativeBuilder.build(
        themes: const [],
        agreements: const [],
        tensions: const [
          GlobalTension(
            id: 'tension:adaptability:structure',
            primaryThemeId: GlobalThemeIds.structure,
            secondaryThemeId: GlobalThemeIds.adaptability,
            supportingMirrors: [
              GlobalLensId.astrologyMirror,
              GlobalLensId.personalityMirror,
            ],
            reason: 'structure_adaptability_divergence',
          ),
        ],
        confidence: confidence(),
      );

      expect(units, hasLength(1));
      expect(units.first.reflection, contains('บางมุมสะท้อน'));
      expect(units.first.evidenceSummary, contains('ความต่างระหว่าง'));
    });
  });

  group('GlobalNarrativeBuilder composition', () {
    test('mixed input produces theme agreement and tension units', () {
      final units = GlobalNarrativeBuilder.build(
        themes: [
          themeActivation(GlobalThemeIds.structure),
          themeActivation(GlobalThemeIds.adaptability),
        ],
        agreements: const [
          GlobalAgreement(
            id: 'agreement:structure',
            themeId: GlobalThemeIds.structure,
            supportingMirrors: [
              GlobalLensId.astrologyMirror,
              GlobalLensId.personalityMirror,
            ],
            supportingEvidenceCount: 2,
            strength: GlobalAgreementStrength.medium,
          ),
        ],
        tensions: const [
          GlobalTension(
            id: 'tension:adaptability:structure',
            primaryThemeId: GlobalThemeIds.structure,
            secondaryThemeId: GlobalThemeIds.adaptability,
            supportingMirrors: [
              GlobalLensId.astrologyMirror,
              GlobalLensId.personalityMirror,
            ],
            reason: 'structure_adaptability_divergence',
          ),
        ],
        confidence: confidence(),
      );

      expect(units.length, greaterThanOrEqualTo(4));
      expect(
        units.where((u) => u.evidenceSummary.contains('ธีม')).length,
        greaterThanOrEqualTo(2),
      );
      expect(
        units.any((u) => u.evidenceSummary.contains('ข้อตกลงข้ามมิเรอร์')),
        isTrue,
      );
      expect(
        units.any((u) => u.evidenceSummary.contains('ความต่างระหว่าง')),
        isTrue,
      );
    });

    test('fromSnapshot integrates with fusion builder pipeline', () {
      final pair = GlobalFusionGoldenFixtures.scenarioC();
      final input = loader.load(
        astrologySnapshot: pair.astrology,
        personalitySnapshot: pair.personality,
      );
      final snapshot = GlobalFusionBuilder.build(input);
      final fromSnapshot = GlobalNarrativeBuilder.fromSnapshot(snapshot);
      final direct = GlobalNarrativeBuilder.build(
        themes: snapshot.normalizedThemes,
        agreements: snapshot.agreements,
        tensions: snapshot.tensions,
        confidence: snapshot.confidence,
      );

      expect(fromSnapshot.length, direct.length);
      expect(fromSnapshot, isNotEmpty);
    });
  });

  group('GlobalNarrativeBuilder copy principles', () {
    test('reflections avoid diagnostic phrasing', () {
      final units = GlobalNarrativeBuilder.build(
        themes: GlobalThemeIds.v1Themes
            .map((id) => themeActivation(id))
            .toList(),
        agreements: const [],
        tensions: const [],
        confidence: confidence(),
      );

      for (final unit in units) {
        expect(unit.reflection, isNot(contains('You are')));
        expect(unit.reflection, isNot(contains('You must')));
        expect(unit.reflection, isNot(contains('คุณเป็น')));
        expect(unit.reflection, isNot(contains('คุณต้อง')));
      }
    });
  });

  group('GlobalNarrativeValidationHarness', () {
    for (final scenario in GlobalNarrativeGoldenScenario.values) {
      test('${scenario.name} passes narrative golden expectations', () {
        final reflections = GlobalNarrativeValidationHarness.run(scenario);
        final issues = GlobalNarrativeGoldenExpectations.verify(
          scenario,
          reflections,
        );

        if (issues.isNotEmpty) {
          // ignore: avoid_print
          print('issues: $issues');
        }

        expect(
          issues,
          isEmpty,
          reason: '${scenario.name} failed: ${issues.join('; ')}',
        );
      });
    }

    test('runAllPassing returns true', () {
      expect(GlobalNarrativeValidationHarness.runAllPassing(), isTrue);
    });

    test('empty state produces no reflections', () {
      final reflections = GlobalNarrativeValidationHarness.run(
        GlobalNarrativeGoldenScenario.emptyState,
      );
      expect(reflections, isEmpty);
    });

    test('agreement-only fixture includes structure agreement copy', () {
      final reflections = GlobalNarrativeValidationHarness.run(
        GlobalNarrativeGoldenScenario.agreementOnly,
      );

      expect(
        reflections.any(
          (unit) =>
              unit.themeId == GlobalThemeIds.structure &&
              unit.reflection.contains('ชัดเจน'),
        ),
        isTrue,
      );
    });
  });
}
