import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/domain/contracts/astrology_fusion_contract.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_support_level.dart';
import 'package:knowme/features/astrology/fusion/engines/agreement_engine.dart';
import 'package:knowme/features/astrology/fusion/engines/future_tendencies_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/reflection_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/signal_engine.dart';
import 'package:knowme/features/astrology/fusion/engines/tension_engine.dart';
import 'package:knowme/features/astrology/fusion/registry/signal_registry.dart';

void main() {
  group('FusionSignalRegistry', () {
    test('maps autonomy themes', () {
      expect(
        FusionSignalRegistry.signalForTheme('independent'),
        FusionSignalType.autonomy,
      );
      expect(
        FusionSignalRegistry.signalForTheme('leadership'),
        FusionSignalType.autonomy,
      );
      expect(
        FusionSignalRegistry.signalForTheme('driven'),
        FusionSignalType.autonomy,
      );
    });

    test('maps structure themes', () {
      for (final themeId in [
        'structured',
        'responsible',
        'reliable',
        'persistent',
      ]) {
        expect(
          FusionSignalRegistry.signalForTheme(themeId),
          FusionSignalType.structure,
        );
      }
    });

    test('maps growth themes', () {
      for (final themeId in ['growth_focused', 'adaptable', 'openness']) {
        expect(
          FusionSignalRegistry.signalForTheme(themeId),
          FusionSignalType.growth,
        );
      }
    });

    test('maps connection themes', () {
      expect(
        FusionSignalRegistry.signalForTheme('supportive'),
        FusionSignalType.connection,
      );
      expect(
        FusionSignalRegistry.signalForTheme('independent_connection'),
        FusionSignalType.connection,
      );
    });

    test('maps expression and reflection themes', () {
      expect(
        FusionSignalRegistry.signalForTheme('expressive'),
        FusionSignalType.expression,
      );
      expect(
        FusionSignalRegistry.signalForTheme('analytical'),
        FusionSignalType.reflection,
      );
    });

    test('maps creativity theme', () {
      expect(
        FusionSignalRegistry.signalForTheme('creative'),
        FusionSignalType.creativity,
      );
    });

    test('themesForSignal returns mapped ids', () {
      final themes = FusionSignalRegistry.themesForSignal(FusionSignalType.growth);
      expect(themes, contains('growth_focused'));
      expect(themes, contains('adaptable'));
    });
  });

  group('AgreementEngine', () {
    test('detects family-level structure agreement from mock lenses', () {
      final agreements = AgreementEngine.detect(allMockLenses());
      final structureAgreement = agreements.where(
        (agreement) =>
            agreement.familyLevel &&
            agreement.sourceThemeIds.contains('structured') &&
            agreement.sourceThemeIds.contains('responsible'),
      );

      expect(structureAgreement, isNotEmpty);
      expect(
        structureAgreement.first.supportingLenses.length,
        greaterThanOrEqualTo(2),
      );
    });

    test('detects growth family agreement from mock lenses', () {
      final agreements = AgreementEngine.detect(allMockLenses());
      final growthAgreement = agreements.where(
        (agreement) =>
            agreement.sourceThemeIds.contains('growth_focused') &&
            agreement.sourceThemeIds.contains('adaptable'),
      );

      expect(growthAgreement, isNotEmpty);
    });
  });

  group('SignalEngine', () {
    test('builds structure and growth signals from mock pipeline', () {
      final outputs = allMockLenses();
      final agreements = AgreementEngine.detect(outputs);
      final tensions = TensionEngine.detect(outputs);
      final signals = SignalEngine.build(
        agreements: agreements,
        tensions: tensions,
      );

      expect(
        signals.any((signal) => signal.type == FusionSignalType.structure),
        isTrue,
      );
      expect(
        signals.any((signal) => signal.type == FusionSignalType.growth),
        isTrue,
      );
    });

    test('structure signal includes cross-lens themes', () {
      final outputs = allMockLenses();
      final signals = SignalEngine.build(
        agreements: AgreementEngine.detect(outputs),
        tensions: TensionEngine.detect(outputs),
      );

      final structure = signals.firstWhere(
        (signal) => signal.type == FusionSignalType.structure,
      );

      expect(structure.sourceThemes, contains('structured'));
      expect(structure.sourceThemes, contains('responsible'));
      expect(structure.sourceThemes, contains('persistent'));
      expect(structure.supportingLenses.length, 3);
      expect(structure.supportLevel, FusionSupportLevel.high);
    });
  });

  group('ReflectionBuilder', () {
    test('generates Thai summary from autonomy structure growth signals', () {
      final signals = [
        const FusionSignal(
          type: FusionSignalType.autonomy,
          sourceThemes: ['independent', 'leadership'],
          supportingLenses: ['western_natal'],
          supportLevel: FusionSupportLevel.medium,
        ),
        const FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured', 'responsible', 'persistent'],
          supportingLenses: [
            'western_natal',
            'chinese_bazi',
            'thai_astrology',
          ],
          supportLevel: FusionSupportLevel.high,
        ),
        const FusionSignal(
          type: FusionSignalType.growth,
          sourceThemes: ['growth_focused', 'adaptable'],
          supportingLenses: ['chinese_bazi', 'thai_astrology'],
          supportLevel: FusionSupportLevel.medium,
        ),
      ];

      final reflection = ReflectionBuilder.build(signals);

      expect(reflection.summary, contains('หลายศาสตร์สะท้อน'));
      expect(reflection.summary, contains('ความรับผิดชอบต่อสิ่งที่ทำ'));
      expect(reflection.summary, contains('ความมั่นคงระยะยาว'));
      expect(reflection.summary, contains('รูปแบบเดิมมากเกินไป'));
      expect(reflection.keyInsights, isNotEmpty);
    });

    test('returns empty-state copy when no signals', () {
      final reflection = ReflectionBuilder.build(const []);
      expect(reflection.summary, isNotEmpty);
      expect(reflection.keyInsights, isEmpty);
    });
  });

  group('FutureTendenciesBuilder', () {
    test('generates autonomy + structure tendency', () {
      final tendencies = FutureTendenciesBuilder.build(const [
        FusionSignal(
          type: FusionSignalType.autonomy,
          sourceThemes: ['independent'],
          supportingLenses: ['western_natal'],
          supportLevel: FusionSupportLevel.medium,
        ),
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured', 'responsible'],
          supportingLenses: ['western_natal', 'chinese_bazi'],
          supportLevel: FusionSupportLevel.high,
        ),
      ]);

      expect(tendencies, isNotEmpty);
      expect(
        tendencies.any(
          (tendency) => tendency.description.contains('บทบาทที่ต้องรับผิดชอบมากขึ้น') ||
              tendency.description.contains('บทบาทที่เลือกรับเอง'),
        ),
        isTrue,
      );
    });

    test('generates growth + adaptation tendency from growth signal', () {
      final tendencies = FutureTendenciesBuilder.build(const [
        FusionSignal(
          type: FusionSignalType.growth,
          sourceThemes: ['growth_focused', 'adaptable'],
          supportingLenses: ['chinese_bazi', 'thai_astrology'],
          supportLevel: FusionSupportLevel.medium,
        ),
      ]);

      expect(
        tendencies.any(
          (tendency) =>
              tendency.description.contains('การเรียนรู้สิ่งใหม่') ||
              tendency.description.contains('การเรียนรู้หรือการเปลี่ยนแปลง'),
        ),
        isTrue,
      );
    });
  });

  group('Full AF-03 pipeline', () {
    test('mock lenses produce complete AstrologyFusionResult', () {
      final result = AstrologyFusionGenerator.generate(
        allMockLenses(),
        generatedAt: DateTime.utc(2026, 6, 11),
      );

      expect(result.version, AstrologyFusionContract.version);
      expect(result.topThemes, isNotEmpty);
      expect(result.signals, isNotEmpty);
      expect(result.reflection.summary, isNotEmpty);
      expect(result.futureTendencies, isNotEmpty);

      expect(
        result.signals.any((signal) => signal.type == FusionSignalType.structure),
        isTrue,
      );
      expect(
        result.signals.any((signal) => signal.type == FusionSignalType.growth),
        isTrue,
      );
      expect(result.reflection.summary, contains('หลายศาสตร์สะท้อน'));
    });
  });
}
