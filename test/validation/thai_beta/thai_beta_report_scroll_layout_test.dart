import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

/// Layout guards for GoFullPage-compatible scrolling on Thai Beta Report.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiBetaAnalysis analysis;

  setUpAll(() {
    analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Test',
        lastName: 'User',
        birthDate: DateTime(1972, 4, 4),
        birthHour: 10,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
    );
  });

  testWidgets('ThaiBetaReportPage uses single parent scroll; mirror has no inner scroll',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: analysis,
          audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final parentScroll = find.byKey(const Key('thai_beta_report_page_scroll'));
    expect(parentScroll, findsOneWidget);

    final verticalInnerScrolls = find.descendant(
      of: find.byType(ThaiMirrorResultPage),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.vertical,
      ),
    );
    expect(verticalInnerScrolls, findsNothing);
  });

  testWidgets('ThaiBetaReportPage content exceeds viewport height', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ThaiBetaReportPage(
          analysis: analysis,
          audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollableState = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('thai_beta_report_page_scroll')),
        matching: find.byType(Scrollable),
      ).first,
    );
    expect(
      scrollableState.position.maxScrollExtent,
      greaterThan(0),
      reason: 'report should be taller than the viewport for full capture',
    );
  });

  test('public fingerprint unchanged after scroll layout fix', () async {
    final repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    final pipeline = ThaiMirrorPipeline.generate(
      ThaiMirrorPipeline.sampleQaBirthData(),
    );
    final before = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
      pipeline,
    );
    final enriched = await ThaiReportCanonEvidenceEnricher.enrich(
      pipeline,
      repository: repository,
    );
    final after = ThaiReportCanonEvidenceEnricher.userFacingFingerprint(
      enriched.pipelineResult,
    );
    expect(before, after);
  });
}
