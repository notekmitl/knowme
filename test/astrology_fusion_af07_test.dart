import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_support_level.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_tension.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/reflection_result.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_insight_engine.dart';
import 'package:knowme/features/astrology/fusion/engines/why_this_appears_builder.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/astrology_fusion_result_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_result_hero_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/fusion_insight_section.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/why_this_appears_section.dart';
import 'package:knowme/features/astrology/fusion/registry/fusion_insight_registry.dart';

void main() {
  group('FusionInsightEngine', () {
    test('builds combination insight for autonomy, structure, and growth', () {
      final result = FusionInsightEngine.build(
        signals: const [
          FusionSignal(
            type: FusionSignalType.autonomy,
            sourceThemes: ['independent'],
            supportingLenses: ['western_natal', 'chinese_bazi'],
            supportLevel: FusionSupportLevel.high,
          ),
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
        ],
        tensions: const [],
        reflection: const ReflectionResult(
          summary: 'หลายศาสตร์สะท้อนแนวโน้ม',
          keyInsights: [],
        ),
        futureTendencies: const [],
      );

      expect(result.primary, isNotNull);
      expect(result.primary!.title, 'เส้นทางชีวิตที่สร้างด้วยตัวเอง');
      expect(
        result.primary!.description,
        contains('การเติบโตไม่ได้มาจากความเป็นอิสระเพียงอย่างเดียว'),
      );
    });

    test('builds tension insight as secondary when tensions exist', () {
      final result = FusionInsightEngine.build(
        signals: const [
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
        ],
        tensions: const [
          FusionTension(
            category: FusionCategory.coreSelf,
            perspectives: [
              FusionTensionPerspective(
                lensId: 'western_natal',
                themeId: 'independent',
              ),
              FusionTensionPerspective(
                lensId: 'thai_astrology',
                themeId: 'supportive',
              ),
            ],
          ),
        ],
        reflection: const ReflectionResult(
          summary: 'หลายศาสตร์สะท้อนหลายมุม',
          keyInsights: [],
        ),
        futureTendencies: const [],
      );

      expect(result.secondary, isNotNull);
      expect(result.secondary!.title, 'อิสระและความสัมพันธ์');
      expect(
        result.secondary!.description,
        contains('ความท้าทายอาจไม่ใช่การเลือกด้านใดด้านหนึ่ง'),
      );
    });

    test('does not repeat reflection summary as primary insight', () {
      const reflection = ReflectionResult(
        summary: 'หลายศาสตร์สะท้อนแนวโน้มของการสร้างเส้นทางชีวิต',
        keyInsights: [],
      );

      final result = FusionInsightEngine.build(
        signals: const [
          FusionSignal(
            type: FusionSignalType.growth,
            sourceThemes: ['growth_focused'],
            supportingLenses: ['chinese_bazi', 'thai_astrology'],
            supportLevel: FusionSupportLevel.high,
          ),
          FusionSignal(
            type: FusionSignalType.adaptation,
            sourceThemes: ['adaptable'],
            supportingLenses: ['thai_astrology'],
            supportLevel: FusionSupportLevel.medium,
          ),
        ],
        tensions: const [],
        reflection: reflection,
        futureTendencies: const [],
      );

      expect(result.primary, isNotNull);
      expect(result.primary!.description, isNot(equals(reflection.summary)));
      expect(result.primary!.title, 'เติบโตผ่านการปรับตัว');
    });
  });

  group('FusionInsightRegistry', () {
    test('resolves connection and leadership combination', () {
      final insight = FusionInsightRegistry.insightForCombination({
        FusionSignalType.connection,
        FusionSignalType.leadership,
      });

      expect(insight, isNotNull);
      expect(insight!.title, 'ผู้นำที่เชื่อมคนเข้าด้วยกัน');
    });

    test('resolves structure and creativity combination', () {
      final insight = FusionInsightRegistry.insightForCombination({
        FusionSignalType.structure,
        FusionSignalType.creativity,
      });

      expect(insight, isNotNull);
      expect(insight!.title, 'สร้างสรรค์ภายในกรอบที่ชัด');
    });
  });

  group('WhyThisAppearsBuilder', () {
    test('builds per-lens summaries from lens outputs', () {
      final origins = WhyThisAppearsBuilder.build(allMockLenses());

      expect(origins.length, 3);
      expect(origins.map((o) => o.lensTitle), contains('Western Natal'));
      expect(origins.map((o) => o.lensTitle), contains('Chinese BaZi'));
      expect(origins.map((o) => o.lensTitle), contains('Thai Astrology'));

      for (final origin in origins) {
        expect(origin.summary, startsWith('สะท้อน'));
        expect(origin.summary, isNot(contains('independent')));
        expect(origin.summary, isNot(contains('structured')));
      }
    });

    test('returns empty list when no outputs', () {
      expect(WhyThisAppearsBuilder.build(const []), isEmpty);
    });
  });

  group('AF-07 presentation widgets', () {
    testWidgets('FusionInsightSection shows primary and secondary cards', (
      tester,
    ) async {
      final result = AstrologyFusionGenerator.generate(allMockLenses());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FusionInsightSection(insight: result.fusionInsight),
          ),
        ),
      );

      expect(find.text('Primary Insight'), findsOneWidget);
      expect(find.textContaining('หลายศาสตร์'), findsWidgets);
      expect(find.text('independent'), findsNothing);
    });

    testWidgets('WhyThisAppearsSection shows lens origins', (tester) async {
      final result = AstrologyFusionGenerator.generate(allMockLenses());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhyThisAppearsSection(origins: result.lensOrigins),
          ),
        ),
      );

      expect(find.text('ทำไมภาพนี้จึงเกิดขึ้น'), findsOneWidget);
      expect(find.text('Why This Appears'), findsOneWidget);
      expect(find.text('Western Natal'), findsOneWidget);
      expect(find.text('Chinese BaZi'), findsOneWidget);
      expect(find.text('Thai Astrology'), findsOneWidget);
    });

    testWidgets('result page orders hero before lens agreement', (
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
        find.textContaining('หลายศาสตร์เห็นตรงกัน'),
        250,
        scrollable: find.byType(Scrollable).first,
      );

      final heroOffset = tester.getTopLeft(find.byType(FusionResultHeroSection));
      final agreementOffset = tester.getTopLeft(
        find.textContaining('หลายศาสตร์เห็นตรงกัน'),
      );
      expect(heroOffset.dy, lessThan(agreementOffset.dy));
    });
  });

  group('Full AF-07 pipeline', () {
    test('mock lenses produce fusion insight and lens origins', () {
      final result = AstrologyFusionGenerator.generate(allMockLenses());

      expect(result.fusionInsight.hasAny, isTrue);
      expect(result.fusionInsight.primary, isNotNull);
      expect(result.lensOrigins, isNotEmpty);
      expect(
        result.fusionInsight.primary!.description,
        isNot(equals(result.reflection.summary)),
      );
    });
  });
}
