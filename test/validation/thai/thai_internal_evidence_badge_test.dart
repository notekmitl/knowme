import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_page.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_summary.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_internal_evidence_badge.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classifier.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_fixtures.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

/// Internal Evidence Badge Prototype — deterministic QA badge assignment tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiMirrorCanonEvidenceBundle bundle;

  const traceabilitySafety = ThaiCanonEvidenceSafety.traceabilityInternal;

  ThaiCanonEvidenceRef ref({
    required String unitId,
    required String subject,
    required String object,
    String relation = 'owns',
    String? contextType,
    String? contextValue,
  }) {
    return ThaiCanonEvidenceRef(
      unitId: unitId,
      relation: relation,
      subject: subject,
      object: object,
      sourceBookId: 'mahabhut',
      sourcePage: 'p1',
      contextType: contextType,
      contextValue: contextValue,
      safety: traceabilitySafety,
    );
  }

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

  group('ThaiInternalEvidenceBadgeAssigner', () {
    test('strong alignment evidence receives CANON_SUPPORTED', () {
      final strong = bundle.attachments.firstWhere((attachment) {
        final (classification, _) =
            ThaiCanonEvidenceAlignmentClassifier.classifyAttachment(attachment);
        return classification ==
            ThaiCanonEvidenceAlignmentClassification.strongMatch;
      });

      expect(
        ThaiInternalEvidenceBadgeAssigner.forAttachment(strong, trace: bundle.trace),
        ThaiInternalEvidenceBadgeCategory.canonSupported,
      );
    });

    test('weak trace-only evidence is not promoted to CANON_SUPPORTED', () {
      final weak = ThaiCanonEvidenceAttachment(
        sectionId: 'coreSelf',
        signalId: 'section:coreSelf:lagnaLord:planet.mars',
        evidenceType: ThaiCanonEvidenceType.planetSignification,
        evidenceRefs: [
          ref(
            unitId: 'unit.weak',
            subject: 'planet.venus',
            object: 'attribute.weak',
          ),
        ],
      );

      expect(
        ThaiInternalEvidenceBadgeAssigner.forAttachment(weak, trace: bundle.trace),
        isNot(ThaiInternalEvidenceBadgeCategory.canonSupported),
      );
      expect(
        ThaiCanonEvidenceAlignmentClassifier.classifyAttachment(weak).$1,
        isNot(ThaiCanonEvidenceAlignmentClassification.strongMatch),
      );
    });

    test('runtime periodStatus with strong match yields RUNTIME_METADATA_SUPPORTED',
        () {
      final runtimeStatus = bundle.attachments.firstWhere(
        (a) =>
            a.evidenceType == ThaiCanonEvidenceType.periodStatusStructural &&
            !a.signalId.contains(':periodStatus:canonDerived:'),
      );
      final (classification, _) =
          ThaiCanonEvidenceAlignmentClassifier.classifyAttachment(runtimeStatus);

      if (classification ==
          ThaiCanonEvidenceAlignmentClassification.strongMatch) {
        expect(
          ThaiInternalEvidenceBadgeAssigner.forAttachment(
            runtimeStatus,
            trace: bundle.trace,
          ),
          ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported,
        );
      }
    });

    test('canon-derived period status remains CANON_DERIVED_INTERNAL', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
      );
      final derived = audit.fixtureResults
          .expand((r) => r.bundle.attachments)
          .where((a) => a.signalId.contains(':periodStatus:canonDerived:'));
      expect(derived, isNotEmpty);
      for (final attachment in derived.take(3)) {
        expect(
          ThaiInternalEvidenceBadgeAssigner.forAttachment(
            attachment,
            trace: audit.fixtureResults.first.bundle.trace,
          ),
          ThaiInternalEvidenceBadgeCategory.canonDerivedInternal,
        );
      }
    });

    test('out-of-scope trace signals receive OUT_OF_CANON_SCOPE', () {
      expect(bundle.trace.outOfCanonScopeSignals, isNotEmpty);
      for (final signal in bundle.trace.outOfCanonScopeSignals.take(5)) {
        expect(
          ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
            signal,
            trace: bundle.trace,
          ),
          ThaiInternalEvidenceBadgeCategory.outOfCanonScope,
        );
      }
    });

    test('ambiguous position blockers receive BLOCKED_AMBIGUOUS', () {
      expect(bundle.trace.runtimeStatusWithoutPositionBreakdown, isNotEmpty);
      final ambiguousBreakdown = bundle.trace.runtimeStatusWithoutPositionBreakdown
          .where((entry) => entry.contains('AMBIGUOUS_POSITION'));
      expect(ambiguousBreakdown, isNotEmpty);
      for (final entry in ambiguousBreakdown.take(3)) {
        expect(
          ThaiInternalEvidenceBadgeAssigner.forRuntimeBlocker(entry),
          ThaiInternalEvidenceBadgeCategory.blockedAmbiguous,
        );
      }
    });

    test('source conflict blockers receive BLOCKED_SOURCE_CONFLICT', () {
      expect(bundle.trace.conflictedArchetypePlanetPairs, isNotEmpty);
      for (final pair in bundle.trace.conflictedArchetypePlanetPairs) {
        expect(
          ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
            'trace:SOURCE_CONFLICT:$pair',
            trace: bundle.trace,
          ),
          ThaiInternalEvidenceBadgeCategory.blockedSourceConflict,
        );
      }
    });

    test('remedy evidence receives REMEDY_HIDDEN and is never user-facing', () {
      final remedy = ThaiCanonEvidenceAttachment(
        signalId: 'trace:remedy:unit.remedy.1',
        evidenceType: ThaiCanonEvidenceType.remedyInternal,
        evidenceRefs: [
          ref(
            unitId: 'unit.remedy.1',
            subject: 'remedy.subject',
            object: 'remedy.object',
          ),
        ],
      );

      expect(
        ThaiInternalEvidenceBadgeAssigner.forAttachment(remedy, trace: bundle.trace),
        ThaiInternalEvidenceBadgeCategory.remedyHidden,
      );
      expect(remedy.userFacingAllowed, isFalse);

      expect(bundle.trace.skippedRemedyEvidenceCount, 87);
      expect(
        ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
          'trace:skipped_remedy',
          trace: bundle.trace,
        ),
        ThaiInternalEvidenceBadgeCategory.remedyHidden,
      );
    });

    test('trace-only weak candidates map to PARTIAL_CANON_SUPPORT', () async {
      final audit = await ThaiCanonEvidenceAlignmentRunner.run(
        repository: repository,
        fixtures: [ThaiCanonEvidenceAlignmentFixtures.qaSample],
      );
      final trace = audit.fixtureResults.first.bundle.trace;
      if (trace.traceOnlyEvidenceCandidates.isEmpty) {
        expect(trace.lifePeriodsWithRuntimeStatus, isNotEmpty);
        return;
      }
      for (final candidate in trace.traceOnlyEvidenceCandidates.take(3)) {
        expect(
          ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
            candidate,
            trace: trace,
          ),
          ThaiInternalEvidenceBadgeCategory.partialCanonSupport,
        );
      }
    });
  });

  group('ThaiInternalEvidenceBadgeSummary', () {
    test('summary counts are populated from real bundle', () {
      final summary = ThaiCanonEvidenceReviewSummary.fromBundle(bundle);

      expect(summary.badgeSummary.totalBadgedRows, greaterThan(0));
      expect(
        summary.badgeSummary.count(ThaiInternalEvidenceBadgeCategory.canonSupported),
        greaterThan(0),
      );
      expect(
        summary.badgeSummary.count(
          ThaiInternalEvidenceBadgeCategory.blockedAmbiguous,
        ),
        bundle.trace.runtimeStatusBlockedByAmbiguousPosition.length,
      );
      expect(
        summary.badgeSummary.count(
          ThaiInternalEvidenceBadgeCategory.blockedSourceConflict,
        ),
        greaterThan(0),
      );
      expect(
        summary.badgeSummary.count(ThaiInternalEvidenceBadgeCategory.remedyHidden),
        greaterThan(0),
      );
    });

    test('flattened evidence rows carry deterministic badges', () {
      final rows = flattenEvidenceRows(bundle);
      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(row.badge, isNotNull);
        expect(row.userFacingAllowed, isFalse);
      }
      expect(
        rows.any(
          (r) => r.badge == ThaiInternalEvidenceBadgeCategory.canonSupported,
        ),
        isTrue,
      );
    });
  });

  group('ThaiCanonEvidenceReviewPage badge UI', () {
    Future<void> scrollToEvidenceTable(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.textContaining('Evidence table'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('internal review panel renders badge summary cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiCanonEvidenceReviewPage(initialBundle: bundle),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Evidence badges (internal QA only)'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Canon Supported:'), findsOneWidget);
      await scrollToEvidenceTable(tester);
      expect(find.text('Badge'), findsOneWidget);
    });
  });

  group('Public surface isolation', () {
    test('Thai beta report page does not import badge layer', () {
      final source = File(
        'lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiInternalEvidenceBadge'), isFalse);
      expect(source.contains('thai_internal_evidence_badge'), isFalse);
    });

    test('Thai mirror result page does not import badge layer', () {
      final source = File(
        'lib/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart',
      ).readAsStringSync();
      expect(source.contains('ThaiInternalEvidenceBadge'), isFalse);
      expect(source.contains('thai_internal_evidence_badge'), isFalse);
    });

    test('user-facing fingerprint unchanged after badge layer', () async {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final before =
          ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline);
      await ThaiReportCanonEvidenceEnricher.enrich(
        pipeline,
        repository: repository,
      );
      expect(
        ThaiReportCanonEvidenceEnricher.userFacingFingerprint(pipeline),
        before,
      );
    });

    test('consumer report timeline text unchanged', () {
      final pipeline = ThaiMirrorPipeline.generate(
        ThaiMirrorPipeline.sampleQaBirthData(),
      );
      final view = ThaiMirrorConsumerPresenter.present(
        pipeline.mirrorResult!,
        lifePeriods: pipeline.lifePeriods,
      );

      for (final period in view.lifeTimeline!.periods) {
        expect(period.summary.contains('ดวงขึ้น'), isFalse);
        expect(period.summary.contains('ดวงตก'), isFalse);
      }
    });
  });
}
