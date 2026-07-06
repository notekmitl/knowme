import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_summary.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_routes.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/thai_beta/application/thai_research_admin_access.dart';
import 'package:knowme/features/thai_beta/presentation/admin/thai_research_admin_guard.dart';

/// Thai Beta Canon Evidence Review Panel — internal QA surface tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiMirrorCanonEvidenceBundle bundle;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    final pipeline = ThaiMirrorPipeline.generate(
      ThaiMirrorPipeline.sampleQaBirthData(),
    );
    bundle = await ThaiReportCanonEvidenceEnricher.enrich(
      pipeline,
      repository: repository,
    );
  });

  group('ThaiCanonEvidenceReviewPage', () {
    Future<void> pumpReviewPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiCanonEvidenceReviewPage(initialBundle: bundle),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> scrollToTracePanel(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.text('Trace / skipped evidence'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    Future<void> scrollToEvidenceTable(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.textContaining('Evidence table'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('panel widget builds with evidence bundle', (tester) async {
      await pumpReviewPage(tester);

      expect(find.text('Thai Canon Evidence Review'), findsOneWidget);
      expect(find.textContaining('Attachments:'), findsOneWidget);
      await scrollToEvidenceTable(tester);
      expect(find.textContaining('Evidence table'), findsOneWidget);
      await scrollToTracePanel(tester);
      expect(find.text('Trace / skipped evidence'), findsOneWidget);
    });

    testWidgets('coverage cards show skipped remedy count', (tester) async {
      await pumpReviewPage(tester);

      expect(find.textContaining('Remedy skipped: 87'), findsOneWidget);
      expect(find.textContaining('Unmapped candidates:'), findsOneWidget);
    });

    testWidgets('displayed evidence rows are not user-facing', (tester) async {
      final rows = flattenEvidenceRows(bundle);
      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(row.userFacingAllowed, isFalse);
        expect(row.sourcePage, isNotEmpty);
      }

      await pumpReviewPage(tester);

      expect(find.text('yes'), findsNothing);
      await scrollToTracePanel(tester);
      expect(
        find.textContaining('Remedy Hidden:'),
        findsOneWidget,
      );
    });

    testWidgets('badge summary cards render for internal QA', (tester) async {
      await pumpReviewPage(tester);

      expect(find.text('Evidence badges (internal QA only)'), findsOneWidget);
      expect(find.textContaining('Canon Supported:'), findsOneWidget);
      await scrollToEvidenceTable(tester);
      expect(find.text('Badge'), findsOneWidget);
    });

    testWidgets('unmapped candidates visible in trace panel', (tester) async {
      await pumpReviewPage(tester);
      await scrollToTracePanel(tester);

      expect(find.textContaining('Unmapped Canon candidates'), findsOneWidget);
      expect(
        bundle.trace.unmappedCanonEvidenceCandidates,
        contains('planet.ketu'),
      );
    });
  });

  group('ThaiCanonEvidenceRoutes', () {
    test('route is registered with admin guard', () {
      expect(ThaiCanonEvidenceRoutes.routeName, '/internal/thai-canon-evidence');

      final route = ThaiCanonEvidenceRoutes.onGenerateRoute(
        const RouteSettings(name: ThaiCanonEvidenceRoutes.routeName),
      );
      expect(route, isA<MaterialPageRoute<void>>());
      expect(route!.settings.name, ThaiCanonEvidenceRoutes.routeName);

      final wrong = ThaiCanonEvidenceRoutes.onGenerateRoute(
        const RouteSettings(name: '/public/thai'),
      );
      expect(wrong, isNull);
    });

    testWidgets('admin guard accepts injected access in tests', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiResearchAdminGuard(
            access: _FakeAccess(ThaiResearchAccess.admin),
            adminBuilder: (_) =>
                ThaiCanonEvidenceReviewPage(initialBundle: bundle),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thai Canon Evidence Review'), findsOneWidget);
    });
  });

  group('Evidence enrichment', () {
    test('bundle is generated from ThaiMirrorPipeline result', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final enriched = await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      expect(enriched.attachmentCount, greaterThan(0));
      expect(enriched.totalEvidenceRefs, greaterThan(0));
    });

    test('user-facing fingerprint unchanged after enrichment', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final before =
          ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline);
      await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      final after =
          ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline);
      expect(before, after);
    });
  });

  group('Public surface isolation', () {
    test('Thai beta report page does not import review panel', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiCanonEvidenceReviewPage'), isFalse);
      expect(source.contains('thai_canon_evidence'), isFalse);
      expect(source.contains('ThaiInternalEvidenceBadge'), isFalse);
    });

    test('Thai mirror result page does not import review panel', () {
      final source = File(
        'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiCanonEvidenceReviewPage'), isFalse);
      expect(source.contains('ThaiReportCanonEvidenceEnricher'), isFalse);
      expect(source.contains('ThaiInternalEvidenceBadge'), isFalse);
    });
  });
}

class _FakeAccess implements ThaiResearchAdminAccess {
  _FakeAccess(this._level);

  final ThaiResearchAccess _level;

  @override
  Stream<ThaiResearchAccess> watch() async* {
    yield _level;
  }
}
