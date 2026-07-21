import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/features/astrology/fusion/adapters/mock_lenses.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_demo_loader.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_result.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_insight.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_support_level.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_tension.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/reflection_result.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_real_input.dart';
import 'package:knowme/features/astrology/fusion/engines/fusion_insight_builder.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_presentation_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/fusion_result_v22_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/astrology_fusion_result_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/widgets/shared_signals_section.dart';

AstrologyChartModel _ariesWesternChart() {
  return AstrologyChartModel.fromMap({
    'big3': {'sun': 'Aries', 'moon': 'Cancer', 'rising': 'Leo'},
    'planets': {},
    'insight': {},
    'overall_summary': {},
  });
}

void main() {
  group('FusionInsightBuilder', () {
    test('builds autonomy and connection balance insight', () {
      final insight = FusionInsightBuilder.build(
        signals: const [
          FusionSignal(
            type: FusionSignalType.autonomy,
            sourceThemes: ['independent'],
            supportingLenses: ['western_natal', 'chinese_bazi'],
            supportLevel: FusionSupportLevel.high,
          ),
          FusionSignal(
            type: FusionSignalType.connection,
            sourceThemes: ['supportive'],
            supportingLenses: ['thai_astrology'],
            supportLevel: FusionSupportLevel.medium,
          ),
        ],
        reflection: const ReflectionResult(
          summary: 'หลายศาสตร์สะท้อนแนวโน้ม',
          keyInsights: [],
        ),
        futureTendencies: const [],
      );

      expect(insight, contains('เส้นทางที่สร้างด้วยตัวเอง'));
      expect(insight, contains('ความต้องการอิสระ'));
      expect(insight, contains('ความสำคัญของความสัมพันธ์'));
    });

    test('returns empty-state insight when no signals', () {
      final insight = FusionInsightBuilder.build(
        signals: const [],
        reflection: const ReflectionResult(
          summary: 'ยังไม่มีสัญญาณ',
          keyInsights: [],
        ),
        futureTendencies: const [],
      );

      expect(insight, isNotEmpty);
      expect(insight, contains('ไม่จำเป็นต้องตัดสิน'));
    });
  });

  group('SharedSignalsSection', () {
    test('hides low support and transformation signals', () {
      final visible = SharedSignalsSection.visibleSignals(const [
        FusionSignal(
          type: FusionSignalType.structure,
          sourceThemes: ['structured'],
          supportingLenses: ['western_natal', 'chinese_bazi'],
          supportLevel: FusionSupportLevel.high,
        ),
        FusionSignal(
          type: FusionSignalType.transformation,
          sourceThemes: ['independent'],
          supportingLenses: ['western_natal', 'thai_astrology'],
          supportLevel: FusionSupportLevel.medium,
        ),
        FusionSignal(
          type: FusionSignalType.growth,
          sourceThemes: ['adaptable'],
          supportingLenses: ['thai_astrology'],
          supportLevel: FusionSupportLevel.low,
        ),
      ]);

      expect(visible.length, 1);
      expect(visible.first.type, FusionSignalType.structure);
    });
  });

  group('AstrologyFusionResultPage widget', () {
    testWidgets('renders core sections from mock pipeline', (tester) async {
      final result = AstrologyFusionGenerator.generate(allMockLenses());

      await tester.pumpWidget(
        MaterialApp(
          home: AstrologyFusionResultPage(result: result),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(FusionResultV22Copy.exploreCta), findsOneWidget);
      expect(find.text('Fusion Evidence'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.textContaining('หลายศาสตร์เห็นตรงกัน'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('หลายศาสตร์เห็นตรงกัน'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('จุดแข็งของคุณ'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('จุดแข็งของคุณ'), findsOneWidget);
      expect(find.text('Primary Insight'), findsNothing);
      expect(find.text('independent'), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('shows empty state when no intelligence output', (tester) async {
      final result = AstrologyFusionGenerator.generate(const []);

      await tester.pumpWidget(
        MaterialApp(
          home: AstrologyFusionResultPage(result: result),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
      expect(find.text('จุดแข็งของคุณ'), findsNothing);
      expect(find.text('ภาพรวมของคุณ'), findsNothing);
    });

    testWidgets('handles partial lens data without debug output', (tester) async {
      final result = AstrologyFusionGenerator.generateFromRealData(
        AstrologyFusionRealInput(western: _ariesWesternChart()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AstrologyFusionResultPage(result: result),
        ),
      );
      await tester.pumpAndSettle();

      expect(result.reflection.summary, isNotEmpty);
      expect(find.text('western_natal'), findsNothing);
      expect(find.text(FusionResultV22Copy.exploreCta), findsOneWidget);
    });

    testWidgets('shows different perspectives when tensions exist', (tester) async {
      final result = AstrologyFusionResult(
        version: 'test',
        generatedAt: DateTime.utc(2026, 6, 11),
        topThemes: const ['independent', 'supportive'],
        signals: const [],
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
        fusionInsight: const FusionInsightResult(),
        lensOrigins: const [],
        growthOpportunities: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AstrologyFusionResultPage(result: result),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('จุดที่ชีวิตมักทดสอบคุณ'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('จุดที่ชีวิตมักทดสอบคุณ'), findsOneWidget);
      expect(find.textContaining('ชีวิตอาจทดสอบคุณ'), findsWidgets);
    });
  });

  group('AstrologyFusionDemoLoader', () {
    test('buildFromParts uses mock when all inputs are null', () {
      final result = AstrologyFusionDemoLoader.buildFromParts();
      expect(result.topThemes, isNotEmpty);
    });

    test('buildFromParts supports partial real input', () {
      final result = AstrologyFusionDemoLoader.buildFromParts(
        western: _ariesWesternChart(),
      );
      expect(result.reflection.summary, isNotEmpty);
    });
  });
}
