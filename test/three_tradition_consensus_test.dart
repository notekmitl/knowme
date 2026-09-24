import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/features/astrology/fusion/adapters/adapter_helpers.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/adapters/western_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/three_tradition_report_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/reading_evidence_text.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  final thai = FusionAdapterHelpers.thaiLensId;
  final bazi = FusionAdapterHelpers.baziLensId;
  final western = FusionAdapterHelpers.westernLensId;

  LensThemeOutput output(String lens, String theme, {bool evidence = true}) {
    if (!evidence) {
      final meta = FusionThemeRegistry.getById(theme)!;
      return LensThemeOutput(
        lensId: lens,
        themeId: theme,
        category: meta.category,
        family: meta.family,
        confidence: 0.8,
        evidence: const [],
      );
    }
    return FusionAdapterHelpers.buildRegistered(
      lensId: lens,
      themeId: theme,
      confidence: 0.8,
      evidence: ['$lens:$theme'],
    )!;
  }

  test('three identical themes form one exact agreement', () {
    final result = ThreeTraditionConsensus.fromOutputs([
      output(thai, 'independent'),
      output(bazi, 'independent'),
      output(western, 'independent'),
    ]);
    expect(result.length, 1);
    expect(result.single.exact, isTrue);
    expect(result.single.sourceCount, 3);
    expect(result.single.sources.keys, [thai, bazi, western]);
    expect(result.single.sources[thai]!.evidence, ['$thai:independent']);
  });

  test('two exact and third similar become one three-lens agreement', () {
    final result = ThreeTraditionConsensus.fromOutputs([
      output(western, 'leadership'),
      output(bazi, 'independent'),
      output(thai, 'independent'),
    ]);
    expect(result.length, 1);
    expect(result.single.sourceCount, 3);
    expect(result.single.exact, isFalse);
    expect(result.single.sources[western]!.themeId, 'leadership');
  });

  test(
    'one tradition, duplicate lens, and empty evidence never imply consensus',
    () {
      expect(
        ThreeTraditionConsensus.fromOutputs([
          output(thai, 'independent'),
          output(thai, 'driven'),
          output(bazi, 'independent', evidence: false),
          output('unrecognized', 'independent'),
        ]),
        isEmpty,
      );
    },
  );

  test('growth-area warning is not conflated with a positive reflection', () {
    expect(
      ThreeTraditionConsensus.fromOutputs([
        output(thai, 'overthinking'),
        output(bazi, 'analytical'),
        output(western, 'grounded'),
      ]),
      isEmpty,
    );
    final exactWarning = ThreeTraditionConsensus.fromOutputs([
      output(thai, 'overthinking'),
      output(bazi, 'overthinking'),
    ]);
    expect(exactWarning.single.key, 'overthinking');
    expect(exactWarning.single.sourceCount, 2);
  });

  test('broad relationship family does not create unsupported agreement', () {
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      output(thai, 'supportive'),
      output(bazi, 'independent_connection'),
      output(western, 'loyal'),
    ]);
    expect(reading.agreements, isEmpty);
    expect(reading.byLens[western]!.single.themeId, 'loyal');
  });

  test(
    'weak year-animal evidence stays visible but cannot create consensus',
    () {
      final weak = FusionAdapterHelpers.buildRegistered(
        lensId: bazi,
        themeId: 'grounded',
        confidence: 0.55,
        evidence: ['Year Animal: Ox · stability (primary)'],
      )!;
      final reading = ThreeTraditionConsensus.analyzeOutputs([
        output(western, 'grounded'),
        weak,
      ]);
      expect(reading.agreements, isEmpty);
      expect(reading.byLens[bazi], contains(weak));
    },
  );

  test('two agreeing lenses keep the third lens separate', () {
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      output(thai, 'grounded'),
      output(bazi, 'grounded'),
      output(western, 'expressive'),
    ]);
    expect(reading.agreements.single.sourceCount, 2);
    expect(reading.agreements.single.sources.containsKey(western), isFalse);
    expect(reading.byLens[western]!.single.themeId, 'expressive');
  });

  test('Chinese and Western facts retain different, readable evidence', () {
    final chinese = FusionAdapterHelpers.buildRegistered(
      lensId: bazi,
      themeId: 'grounded',
      confidence: 0.8,
      evidence: ['Dominant Element: earth'],
    )!;
    final west = FusionAdapterHelpers.buildRegistered(
      lensId: western,
      themeId: 'grounded',
      confidence: 0.8,
      evidence: ['Sun Sign: Taurus'],
    )!;
    expect(
      ReadingEvidenceText.observation(chinese),
      contains('ธาตุเด่นของดวงจีนเป็นดิน'),
    );
    expect(
      ReadingEvidenceText.observation(west),
      contains('อาทิตย์อยู่ราศีพฤษภ'),
    );
    expect(
      ReadingEvidenceText.observation(chinese),
      isNot(ReadingEvidenceText.observation(west)),
    );
  });

  test('Western adapter does not invent a dominant summary on a tie', () {
    final outputs = WesternRealAdapter.adapt(
      AstrologyChartModel(
        version: 'v',
        contractId: 'c',
        engineVersion: 'e',
        inputHash: 'h',
        big3: {'sun': 'Aries', 'moon': 'Taurus', 'rising': 'Gemini'},
        planets: {},
        insight: {},
        overallSummary: {},
      ),
    );
    expect(
      outputs
          .expand((source) => source.evidence)
          .where(
            (fact) =>
                fact.startsWith('Element Summary: ') ||
                fact.startsWith('Modality Summary: '),
          ),
      isEmpty,
    );
  });

  test('Thai engine result joins BaZi and Western chart adapters', () {
    final analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Sample',
        lastName: 'Reader',
        birthDate: DateTime(1990, 5, 12),
        birthHour: 15,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
      asOf: DateTime(2026, 9, 23),
    );
    expect(analysis.isSuccess, isTrue);
    final agreements = ThreeTraditionConsensus.fromCharts(
      thai: analysis.pipelineResult!.mirrorResult!,
      bazi: BaziCompatibilityOwnerFixtures.chart(BaziOwnerCase.known),
      western: AstrologyChartModel(
        version: 'western_natal_v2',
        contractId: 'knowme_western_reader_v2',
        engineVersion: 'engine-v2',
        inputHash: 'aligned-1990-fixture',
        big3: {'sun': 'Taurus', 'moon': 'Sagittarius', 'rising': 'Libra'},
        planets: {},
        insight: {},
        overallSummary: {},
      ),
    );
    expect(agreements, isNotEmpty);
    for (final item in agreements) {
      expect(item.sourceCount, inInclusiveRange(2, 3));
      expect(
        item.sources.values.every((source) => source.evidence.isNotEmpty),
        isTrue,
      );
    }
  });

  testWidgets(
    'mobile reader displays three and two lens groups without overflow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final reading = ThreeTraditionConsensus.analyzeOutputs([
        output(thai, 'independent'),
        output(bazi, 'independent'),
        output(western, 'leadership'),
        output(thai, 'grounded'),
        output(bazi, 'grounded'),
      ]);
      await tester.pumpWidget(
        MaterialApp(home: ThreeTraditionReportPage(reading: reading)),
      );
      expect(find.text('ตรงกันทั้ง 3 ศาสตร์'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('สอดคล้องกัน 2 ศาสตร์'), 160);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('report shows distinct lens facts and separates the third lens',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      FusionAdapterHelpers.buildRegistered(
        lensId: bazi, themeId: 'grounded', confidence: 0.8,
        evidence: ['Dominant Element: earth'],
      )!,
      FusionAdapterHelpers.buildRegistered(
        lensId: western, themeId: 'grounded', confidence: 0.8,
        evidence: ['Sun Sign: Taurus'],
      )!,
      FusionAdapterHelpers.buildRegistered(
        lensId: thai, themeId: 'expressive', confidence: 0.8,
        evidence: ['ลัคนา: ลัคนาราศีเมษ'],
      )!,
    ]);
    await tester.pumpWidget(MaterialApp(
      home: ThreeTraditionReportPage(reading: reading),
    ));
    expect(find.text('สอดคล้องกัน 2 ศาสตร์'), findsOneWidget);
    expect(find.textContaining('จีน: พบประเด็นการให้ความสำคัญกับความมั่นคงจาก '
        'ธาตุเด่นของดวงจีนเป็นดิน'), findsOneWidget);
    expect(find.textContaining('ตะวันตก: พบประเด็นการให้ความสำคัญกับความมั่นคงจาก '
        'อาทิตย์อยู่ราศีพฤษภ'), findsOneWidget);
    expect(find.textContaining('ไทย: ไม่มีหลักฐานที่หนักพอให้นับร่วมในประเด็นนี้'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('พบประเด็นการแสดงออกจาก ลัคนา: ลัคนาราศีเมษ'),
      160,
    );
    expect(find.textContaining('พบประเด็นการแสดงออกจาก ลัคนา: ลัคนาราศีเมษ'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('adapter deduplication preserves distinct facts for one theme', () {
    final strongest = FusionAdapterHelpers.buildRegistered(
      lensId: bazi, themeId: 'grounded', confidence: 0.85,
      evidence: ['Day Master: yin earth'],
    )!;
    final supporting = FusionAdapterHelpers.buildRegistered(
      lensId: bazi, themeId: 'grounded', confidence: 0.7,
      evidence: ['Dominant Element: earth'],
    )!;
    final merged = FusionAdapterHelpers.dedupeByTheme(
      [strongest, supporting],
      mergeEvidence: true,
    );
    expect(merged.single.confidence, 0.85);
    expect(merged.single.evidence,
        ['Day Master: yin earth', 'Dominant Element: earth']);
  });

  testWidgets('desktop reader shows a truthful empty state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: ThreeTraditionReportPage(
          reading: ThreeTraditionConsensus.analyzeOutputs([]),
        ),
      ),
    );
    expect(find.textContaining('ยังไม่พบประเด็น'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
