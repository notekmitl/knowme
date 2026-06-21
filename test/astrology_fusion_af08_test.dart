import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_support_level.dart';
import 'package:knowme/features/astrology/fusion/engines/future_tendencies_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/growth_opportunities_builder.dart';
import 'package:knowme/features/astrology/fusion/engines/reflection_builder.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/astrology_fusion_result_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/growth_opportunities_section.dart';
import 'package:knowme/features/astrology/fusion/registry/signal_combination_registry_v2.dart';
import 'package:knowme/features/astrology/fusion/registry/signal_growth_registry.dart';
import 'package:knowme/features/astrology/fusion/registry/signal_opportunity_registry.dart';
import 'package:knowme/features/astrology/fusion/registry/signal_shadow_registry.dart';

void main() {
  group('SignalGrowthRegistry', () {
    test('autonomy contains growth depth fields', () {
      final pattern = SignalGrowthRegistry.forSignal(FusionSignalType.autonomy)!;

      expect(pattern.growthPotential, contains('ตัดสินใจอย่างมั่นใจ'));
      expect(pattern.maturityPath, isNotEmpty);
      expect(pattern.developmentDirection, contains('มุมมองจากผู้อื่น'));
    });

    test('structure contains maturity path', () {
      final pattern =
          SignalGrowthRegistry.forSignal(FusionSignalType.structure)!;

      expect(pattern.growthPotential, contains('ความมั่นคงระยะยาว'));
      expect(pattern.maturityPath, isNotEmpty);
    });
  });

  group('SignalShadowRegistry', () {
    test('autonomy shadow includes overuse pattern', () {
      final pattern = SignalShadowRegistry.forSignal(FusionSignalType.autonomy)!;

      expect(pattern.overusePattern, contains('คนเดียวมากเกินไป'));
      expect(pattern.blindSpot, isNotEmpty);
    });

    test('structure shadow includes overuse pattern', () {
      final pattern =
          SignalShadowRegistry.forSignal(FusionSignalType.structure)!;

      expect(pattern.overusePattern, contains('รูปแบบเดิมมากเกินไป'));
    });
  });

  group('SignalOpportunityRegistry', () {
    test('growth opportunity pattern matches spec', () {
      final pattern =
          SignalOpportunityRegistry.forSignal(FusionSignalType.growth)!;

      expect(
        pattern.opportunityPattern,
        contains('การเรียนรู้หรือการเปลี่ยนแปลง'),
      );
    });

    test('connection opportunity pattern matches spec', () {
      final pattern =
          SignalOpportunityRegistry.forSignal(FusionSignalType.connection)!;

      expect(pattern.opportunityPattern, contains('ผู้คนและความร่วมมือ'));
    });
  });

  group('SignalCombinationRegistryV2', () {
    test('resolves autonomy and structure combination', () {
      final tendency = SignalCombinationRegistryV2.tendencyForTypes({
        FusionSignalType.autonomy,
        FusionSignalType.structure,
      });

      expect(tendency, isNotNull);
      expect(tendency!.title, 'บทบาทที่เลือกรับเอง');
    });
  });

  group('ReflectionBuilder V3', () {
    test('combines narrative growth and shadow for autonomy profile', () {
      final reflection = ReflectionBuilder.build(const [
        FusionSignal(
          type: FusionSignalType.autonomy,
          sourceThemes: ['independent'],
          supportingLenses: ['western_natal', 'chinese_bazi'],
          supportLevel: FusionSupportLevel.high,
        ),
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured'],
          supportingLenses: ['western_natal', 'thai_astrology'],
          supportLevel: FusionSupportLevel.medium,
        ),
      ]);

      expect(reflection.summary, contains('หลายศาสตร์สะท้อน'));
      expect(reflection.summary, contains('การพึ่งพาตัวเอง'));
      expect(reflection.summary, contains('ตัดสินใจอย่างมั่นใจ'));
      expect(reflection.summary, contains('คนเดียวมากเกินไป'));
      expect(reflection.keyInsights.first, contains('ค่อย ๆ แยกแยะ'));
    });

    test('produces different reflection for connection profile', () {
      final autonomyReflection = ReflectionBuilder.build(const [
        FusionSignal(
          type: FusionSignalType.autonomy,
          sourceThemes: ['independent'],
          supportingLenses: ['western_natal', 'chinese_bazi'],
          supportLevel: FusionSupportLevel.high,
        ),
      ]);

      final connectionReflection = ReflectionBuilder.build(const [
        FusionSignal(
          type: FusionSignalType.connection,
          sourceThemes: ['supportive'],
          supportingLenses: ['thai_astrology', 'western_natal'],
          supportLevel: FusionSupportLevel.high,
        ),
      ]);

      expect(autonomyReflection.summary, isNot(equals(connectionReflection.summary)));
      expect(connectionReflection.summary, contains('การเชื่อมโยงและดูแลผู้อื่น'));
      expect(connectionReflection.summary, contains('ดูแลผู้อื่นจนลืมขอบเขต'));
    });
  });

  group('FutureTendenciesBuilder V3', () {
    test('enriches combination tendency with opportunity pattern', () {
      final tendencies = FutureTendenciesBuilder.build(const [
        FusionSignal(
          type: FusionSignalType.autonomy,
          sourceThemes: ['independent'],
          supportingLenses: ['western_natal', 'chinese_bazi'],
          supportLevel: FusionSupportLevel.high,
        ),
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured', 'responsible'],
          supportingLenses: ['western_natal', 'chinese_bazi', 'thai_astrology'],
          supportLevel: FusionSupportLevel.high,
        ),
      ]);

      expect(tendencies, isNotEmpty);
      expect(
        tendencies.first.description,
        anyOf(
          contains('มักได้รับโอกาสเมื่อกล้าตัดสินใจ'),
          contains('มักได้รับโอกาสเมื่อแสดงความน่าเชื่อถือ'),
        ),
      );
    });

    test('growth profile yields learning-oriented tendencies', () {
      final tendencies = FutureTendenciesBuilder.build(const [
        FusionSignal(
          type: FusionSignalType.growth,
          sourceThemes: ['growth_focused', 'adaptable'],
          supportingLenses: ['chinese_bazi', 'thai_astrology'],
          supportLevel: FusionSupportLevel.high,
        ),
      ]);

      expect(
        tendencies.any(
          (tendency) =>
              tendency.description.contains('การเรียนรู้หรือการเปลี่ยนแปลง'),
        ),
        isTrue,
      );
    });
  });

  group('GrowthOpportunitiesBuilder', () {
    test('returns up to three cards from strongest signals', () {
      final opportunities = GrowthOpportunitiesBuilder.build(const [
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured'],
          supportingLenses: ['western_natal', 'chinese_bazi', 'thai_astrology'],
          supportLevel: FusionSupportLevel.high,
        ),
        FusionSignal(
          type: FusionSignalType.growth,
          sourceThemes: ['growth_focused'],
          supportingLenses: ['chinese_bazi', 'thai_astrology'],
          supportLevel: FusionSupportLevel.medium,
        ),
        FusionSignal(
          type: FusionSignalType.autonomy,
          sourceThemes: ['independent'],
          supportingLenses: ['western_natal'],
          supportLevel: FusionSupportLevel.low,
        ),
      ]);

      expect(opportunities.length, 2);
      expect(opportunities.first.title, 'โครงสร้างและความรับผิดชอบ');
      expect(opportunities.first.description, isNotEmpty);
    });
  });

  group('GrowthOpportunitiesSection widget', () {
    testWidgets('renders opportunity cards', (tester) async {
      final result = AstrologyFusionGenerator.generate(allMockLenses());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GrowthOpportunitiesSection(
              opportunities: result.growthOpportunities,
            ),
          ),
        ),
      );

      expect(find.text('โอกาสในการเติบโต'), findsOneWidget);
      expect(find.text('Growth Opportunities'), findsOneWidget);
      expect(find.textContaining('มักได้รับโอกาส'), findsWidgets);
    });

    testWidgets('result page shows unified growth path section', (
      tester,
    ) async {
      final result = AstrologyFusionGenerator.generate(allMockLenses());

      await tester.pumpWidget(
        MaterialApp(
          home: AstrologyFusionResultPage(result: result),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('เส้นทางเติบโต'),
        250,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('เส้นทางเติบโต'), findsOneWidget);
      expect(
        find.text(result.growthOpportunities.first.title),
        findsWidgets,
      );
    });
  });

  group('Profile variation', () {
    test('different signal profiles produce different fusion outputs', () {
      final autonomyHeavy = AstrologyFusionGenerator.generate([
        ...allMockLenses().where((output) => output.lensId == 'western_natal'),
      ]);

      final fullMock = AstrologyFusionGenerator.generate(allMockLenses());

      expect(
        autonomyHeavy.reflection.summary,
        isNot(equals(fullMock.reflection.summary)),
      );
      expect(
        autonomyHeavy.growthOpportunities,
        isNot(equals(fullMock.growthOpportunities)),
      );
    });
  });
}
