import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/features/astrology/fusion/adapters/adapter_helpers.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/adapters/thai_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/adapters/western_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/three_tradition_report_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/reading_evidence_text.dart';
import 'package:knowme/features/astrology/fusion/presentation/three_tradition_life_reading.dart';
import 'package:knowme/features/astrology/fusion/presentation/three_tradition_reading_copy.dart';
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

  test(
    'one interpretation relates distinct facts without inventing agreement',
    () {
      final reading = ThreeTraditionConsensus.analyzeOutputs([
        FusionAdapterHelpers.buildRegistered(
          lensId: thai,
          themeId: 'analytical',
          confidence: 0.55,
          evidence: ['ลัคนา: ลัคนาราศีกุมภ'],
        )!,
        FusionAdapterHelpers.buildRegistered(
          lensId: bazi,
          themeId: 'grounded',
          confidence: 0.8,
          evidence: ['Dominant Element: earth'],
        )!,
        FusionAdapterHelpers.buildRegistered(
          lensId: western,
          themeId: 'adaptable',
          confidence: 0.8,
          evidence: ['Sun Sign: Gemini'],
        )!,
      ]);
      expect(reading.agreements, isEmpty);
      final prose = ThreeTraditionReadingCopy.overview(reading);
      expect(prose, contains('ดวงไทยให้มุมของการคิดวิเคราะห์จากลัคนาราศีกุมภ'));
      expect(
        prose,
        contains(
          'ดวงจีนให้มุมของการให้ความสำคัญกับความมั่นคงจากธาตุเด่นของดวงจีนเป็นดิน',
        ),
      );
      expect(
        prose,
        contains('ดวงตะวันตกให้มุมของการปรับตัวจากอาทิตย์อยู่ราศีเมถุน'),
      );
      expect(prose, contains('ใช้วิธีคิดชั่งน้ำหนักสิ่งที่อยากรักษาไว้'));
      expect(prose, contains('ไม่ใช่จุดร่วมที่พิสูจน์แล้ว'));
      expect(ThreeTraditionConsensus.minimumAgreementConfidence, 0.6);
    },
  );

  test(
    'interpretation searches all evidence rather than first observation',
    () {
      final reading = ThreeTraditionConsensus.analyzeOutputs([
        output(thai, 'independent'),
        output(thai, 'analytical'),
        output(bazi, 'persistent'),
        output(bazi, 'grounded'),
        output(western, 'growth_focused'),
        output(western, 'adaptable'),
      ]);
      expect(reading.agreements, isEmpty);
      final prose = ThreeTraditionReadingCopy.overview(reading);
      expect(prose, contains('ดวงไทยให้มุมของการคิดวิเคราะห์'));
      expect(prose, contains('ดวงจีนให้มุมของการให้ความสำคัญกับความมั่นคง'));
      expect(prose, contains('ดวงตะวันตกให้มุมของการปรับตัว'));
    },
  );

  test('unrelated observations state that no coherent link is supported', () {
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      output(thai, 'supportive'),
      output(bazi, 'independent_connection'),
      output(western, 'passionate'),
    ]);
    expect(reading.agreements, isEmpty);
    expect(
      ThreeTraditionReadingCopy.overview(reading),
      contains('ยังไม่เชื่อมเป็นเรื่องเดียวได้อย่างมีเหตุผล'),
    );
  });

  test('two proven points remain separate in a composed reading', () {
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      output(thai, 'independent'),
      output(western, 'independent'),
      output(bazi, 'growth_focused'),
      output(western, 'growth_focused'),
    ]);
    expect(reading.agreements, hasLength(2));
    final prose = ThreeTraditionReadingCopy.overview(reading);
    expect(prose, contains('ไทยกับตะวันตกสอดคล้องกันเรื่อง'));
    expect(prose, contains('จีนกับตะวันตกสอดคล้องกันอีกเรื่อง'));
    expect(prose, contains('ไม่ได้บอกว่าประเด็นทั้งสองเป็นเหตุเป็นผลต่อกัน'));
  });

  test('unrelated proven points are listed without an invented bridge', () {
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      output(thai, 'grounded'),
      output(bazi, 'grounded'),
      output(bazi, 'expressive'),
      output(western, 'expressive'),
    ]);
    expect(reading.agreements, hasLength(2));
    final prose = ThreeTraditionReadingCopy.overview(reading);
    expect(prose, contains('ไทยกับจีนสอดคล้องกันเรื่อง'));
    expect(prose, contains('จีนกับตะวันตกสอดคล้องกันเรื่อง'));
    expect(
      prose,
      contains('ยังไม่มีหลักฐานพอจะบอกว่าจุดร่วมเหล่านี้สัมพันธ์กันอย่างไร'),
    );
  });

  test('proven pair is named while third lens remains its own view', () {
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      output(thai, 'grounded'),
      output(bazi, 'grounded'),
      output(western, 'expressive'),
    ]);
    final prose = ThreeTraditionReadingCopy.overview(reading);
    expect(reading.agreements.single.sourceCount, 2);
    expect(prose, contains('ไทยกับจีนสอดคล้องกันเรื่อง'));
    expect(prose, contains('ดวงตะวันตกยังไม่มีหลักฐานที่เชื่อมมุมของตน'));
    expect(prose, isNot(contains('การแสดงออก')));
  });

  test('three proven lenses read as one natural common point', () {
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      output(thai, 'independent'),
      output(bazi, 'independent'),
      output(western, 'independent'),
    ]);
    final prose = ThreeTraditionReadingCopy.overview(reading);
    expect(reading.agreements.single.sourceCount, 3);
    expect(prose, contains('ไทย จีน และตะวันตกสอดคล้องกันเรื่อง'));
    expect(prose, isNot(contains('ยังไม่นับร่วม')));
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

  test('pre-sunrise Thai section evidence reaches the overall reader', () {
    final analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Sample',
        lastName: 'Reader',
        birthDate: DateTime(1972, 4, 4),
        birthHour: 2,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
      asOf: DateTime(2026, 9, 23),
    );
    expect(analysis.isSuccess, isTrue);
    expect(analysis.normalizedSnapshot!.usedPreviousDay, isTrue);
    expect(analysis.normalizedSnapshot!.thaiAstrologicalDate, '1972-04-03');

    final mirror = analysis.pipelineResult!.mirrorResult!;
    expect(
      mirror.topThemes.every(
        (theme) => !FusionThemeRegistry.contains(theme.themeId),
      ),
      isTrue,
    );
    final thaiOutputs = ThaiRealAdapter.adapt(mirror);
    expect(thaiOutputs, isNotEmpty);
    expect(thaiOutputs.every((item) => item.evidence.isNotEmpty), isTrue);
    expect(
      thaiOutputs.every((item) => FusionThemeRegistry.contains(item.themeId)),
      isTrue,
    );
    expect(
      thaiOutputs.every(
        (item) => mirror.sections.any(
          (section) =>
              section.supportingThemes.any(
                (theme) => theme.themeId == item.themeId,
              ) &&
              section.evidence.any(
                (row) => item.evidence.any(
                  (fact) => fact.contains(row.contentTitle ?? row.contentKey),
                ),
              ),
        ),
      ),
      isTrue,
    );
  });

  test('weak Thai section evidence remains visible without a common claim', () {
    final analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Sample',
        lastName: 'Reader',
        birthDate: DateTime(2000, 1, 3),
        birthHour: 12,
        province: 'เชียงใหม่',
        provinceKey: 'chiang mai',
      ),
      asOf: DateTime(2026, 9, 23),
    );
    expect(analysis.isSuccess, isTrue);
    expect(analysis.normalizedSnapshot!.usedPreviousDay, isFalse);

    final thaiOutputs = ThaiRealAdapter.adapt(
      analysis.pipelineResult!.mirrorResult!,
    );
    final weakSupport = thaiOutputs.singleWhere(
      (item) => item.themeId == 'supportive',
    );
    expect(weakSupport.confidence, lessThan(0.6));
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      ...thaiOutputs,
      output(western, 'supportive'),
    ]);
    expect(reading.byLens[thai], contains(weakSupport));
    expect(reading.agreements, isEmpty);
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
      expect(
        find.textContaining('หลักฐานรายด้านยังไม่พอสร้างคำอ่านประกอบกัน'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('สอดคล้องกันทั้ง 3 ศาสตร์'),
        160,
      );
      expect(find.text('สอดคล้องกันทั้ง 3 ศาสตร์'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('สอดคล้องกัน 2 ศาสตร์'), 160);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('report shows distinct lens facts and separates the third lens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final reading = ThreeTraditionConsensus.analyzeOutputs([
      FusionAdapterHelpers.buildRegistered(
        lensId: bazi,
        themeId: 'grounded',
        confidence: 0.8,
        evidence: ['Dominant Element: earth'],
      )!,
      FusionAdapterHelpers.buildRegistered(
        lensId: western,
        themeId: 'grounded',
        confidence: 0.8,
        evidence: ['Sun Sign: Taurus'],
      )!,
      FusionAdapterHelpers.buildRegistered(
        lensId: thai,
        themeId: 'expressive',
        confidence: 0.8,
        evidence: ['ลัคนา: ลัคนาราศีเมษ'],
      )!,
    ]);
    await tester.pumpWidget(
      MaterialApp(home: ThreeTraditionReportPage(reading: reading)),
    );
    await tester.scrollUntilVisible(find.text('สอดคล้องกัน 2 ศาสตร์'), 160);
    expect(find.text('สอดคล้องกัน 2 ศาสตร์'), findsOneWidget);
    expect(
      find.textContaining('จีนอ้างอิงธาตุเด่นของดวงจีนเป็นดิน'),
      findsWidgets,
    );
    expect(
      find.textContaining('ตะวันตกอ้างอิงอาทิตย์อยู่ราศีพฤษภ'),
      findsWidgets,
    );
    expect(
      find.textContaining('ไทยยังไม่มีหลักฐานหนักพอให้นับร่วมในเรื่องนี้'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('ดูหลักฐานของแต่ละศาสตร์'), 160);
    await tester.tap(find.text('ดูหลักฐานของแต่ละศาสตร์'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('มุมเรื่องการแสดงออก จากลัคนาราศีเมษ'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('adapter deduplication preserves distinct facts for one theme', () {
    final strongest = FusionAdapterHelpers.buildRegistered(
      lensId: bazi,
      themeId: 'grounded',
      confidence: 0.85,
      evidence: ['Day Master: yin earth'],
    )!;
    final supporting = FusionAdapterHelpers.buildRegistered(
      lensId: bazi,
      themeId: 'grounded',
      confidence: 0.7,
      evidence: ['Dominant Element: earth'],
    )!;
    final merged = FusionAdapterHelpers.dedupeByTheme([
      strongest,
      supporting,
    ], mergeEvidence: true);
    expect(merged.single.confidence, 0.85);
    expect(merged.single.evidence, [
      'Day Master: yin earth',
      'Dominant Element: earth',
    ]);
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
    expect(
      find.textContaining('หลักฐานรายด้านยังไม่พอสร้างคำอ่านประกอบกัน'),
      findsOneWidget,
    );
    expect(find.textContaining('ยังไม่มีเรื่องเดียวกัน'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('life reading keeps interpreted copy and source evidence separate from consensus', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: ThreeTraditionReportPage(
        reading: ThreeTraditionConsensus.analyzeOutputs([]),
        lifeReading: const ThreeTraditionLifeReading(
          topics: [
            ThreeTraditionLifeTopic(
              title: 'การงาน',
              reading: 'คำอ่านประกอบกันจากหลักฐานรายด้าน',
              thai: 'คำอ่านไทย',
              thaiEvidenceKeys: ['HouseEngine.calculate.house[10].signKey'],
              chinese: 'คำอ่านจีน',
              chineseEvidenceKeys: ['BaziChartModel.tenGodBalance.topFamilies'],
              western: 'คำอ่านตะวันตก',
              westernBasis: 'ดาวพุธ',
            ),
          ],
          gaps: [],
        ),
      ),
    ));
    expect(find.text('คำอ่านประกอบกันจากหลักฐานรายด้าน'), findsOneWidget);
    expect(find.textContaining('ไม่ใช่จุดร่วมที่พิสูจน์แล้ว'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('จุดร่วมที่หลักฐานรองรับ'), 160);
    expect(find.textContaining('ยังไม่มีเรื่องเดียวกัน'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
