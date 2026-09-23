import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/features/astrology/fusion/adapters/adapter_helpers.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/three_tradition_report_page.dart';
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
      return LensThemeOutput(lensId: lens, themeId: theme,
          category: meta.category, family: meta.family,
          confidence: 0.8, evidence: const []);
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

  test('one tradition, duplicate lens, and empty evidence never imply consensus', () {
    expect(ThreeTraditionConsensus.fromOutputs([
      output(thai, 'independent'),
      output(thai, 'driven'),
      output(bazi, 'independent', evidence: false),
      output('unrecognized', 'independent'),
    ]), isEmpty);
  });

  test('growth-area warning is not conflated with a positive reflection', () {
    expect(ThreeTraditionConsensus.fromOutputs([
      output(thai, 'overthinking'),
      output(bazi, 'analytical'),
      output(western, 'grounded'),
    ]), isEmpty);
    final exactWarning = ThreeTraditionConsensus.fromOutputs([
      output(thai, 'overthinking'),
      output(bazi, 'overthinking'),
    ]);
    expect(exactWarning.single.key, 'overthinking');
    expect(exactWarning.single.sourceCount, 2);
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
      expect(item.sources.values.every((source) => source.evidence.isNotEmpty),
          isTrue);
    }
  });

  testWidgets('mobile reader displays three and two lens groups without overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final agreements = ThreeTraditionConsensus.fromOutputs([
      output(thai, 'independent'),
      output(bazi, 'independent'),
      output(western, 'leadership'),
      output(thai, 'supportive'),
      output(bazi, 'loyal'),
    ]);
    await tester.pumpWidget(MaterialApp(
      home: ThreeTraditionReportPage(agreements: agreements),
    ));
    expect(find.text('ตรงกันทั้ง 3 ศาสตร์'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('สอดคล้องกัน 2 ศาสตร์'), 160);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop reader shows a truthful empty state', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
      home: ThreeTraditionReportPage(agreements: []),
    ));
    expect(find.textContaining('ยังไม่พบประเด็น'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
