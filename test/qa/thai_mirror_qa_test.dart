import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_production_loader.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/qa/thai_mirror_qa_profiles.dart';
import 'package:knowme/features/astrology/thai/qa/thai_mirror_qa_report.dart';
import 'package:knowme/features/astrology/thai/qa/thai_mirror_qa_routes.dart';
import 'package:knowme/features/astrology/thai/qa/thai_mirror_qa_screen.dart';

void _bindCanonFixture() {
  final load = ThaiCanonProductionLoader.loadFromJson(
    File(
      'knowledge/canon/production/foundation_v1.knowme.json',
    ).readAsStringSync(),
  );
  ThaiCanonEvidenceRepository.bindCachedForTest(
    ThaiCanonEvidenceRepository.fromLoadResult(load),
  );
}

void main() {
  group('ThaiMirrorQaProfiles', () {
    test('loads at least 20 profiles', () {
      expect(ThaiMirrorQaProfiles.all.length, greaterThanOrEqualTo(20));
      expect(ThaiMirrorQaProfiles.all.every((p) => p.id.isNotEmpty), isTrue);
      expect(ThaiMirrorQaProfiles.all.every((p) => p.label.isNotEmpty), isTrue);
    });

    test('next profile wraps around', () {
      final lastIndex = ThaiMirrorQaProfiles.all.length - 1;
      expect(ThaiMirrorQaProfiles.nextIndex(lastIndex), 0);
      expect(ThaiMirrorQaProfiles.nextIndex(0), 1);
    });

    test('previous profile wraps around', () {
      expect(
        ThaiMirrorQaProfiles.previousIndex(0),
        ThaiMirrorQaProfiles.all.length - 1,
      );
      expect(ThaiMirrorQaProfiles.previousIndex(1), 0);
    });
  });

  group('ThaiMirrorQaReport', () {
    test('generates report for golden profile', () {
      final profile = ThaiMirrorQaProfiles.byId('QA-07');
      final report = ThaiMirrorQaReport.generate(profile);

      expect(report.profileId, 'QA-07');
      expect(report.pipelineSucceeded, isTrue);
      expect(report.generatedAt, isNotNull);
      expect(report.sectionCount, ThaiMirrorQaReport.expectedSectionCount);
      expect(report.evidenceCount, greaterThan(0));
      expect(report.narrativeComplete, isTrue);
      expect(report.topThemes, isNotEmpty);
      expect(report.status, isNot(ThaiMirrorQaStatus.fail));
    });

    test('validation passes for complete golden profile', () {
      final report = ThaiMirrorQaReport.generate(
        ThaiMirrorQaProfiles.byId('QA-07'),
      );

      expect(report.status, ThaiMirrorQaStatus.pass);
      expect(report.issues, isEmpty);
    });

    test('missing birth time profile still runs pipeline', () {
      final report = ThaiMirrorQaReport.generate(
        ThaiMirrorQaProfiles.byId('QA-05'),
      );

      expect(report.pipelineSucceeded, isTrue);
      expect(report.warningCount, greaterThan(0));
      expect(report.sectionCount, ThaiMirrorQaReport.expectedSectionCount);
      expect(report.topThemes, isNotEmpty);
      expect(report.evidenceCount, greaterThan(0));
      expect(report.status, ThaiMirrorQaStatus.pass);
    });

    test('deterministic top themes for same profile', () {
      final profile = ThaiMirrorQaProfiles.byId('QA-07');
      final first = ThaiMirrorQaReport.generate(profile);
      final second = ThaiMirrorQaReport.generate(profile);

      expect(first.topThemes, second.topThemes);
      expect(first.sectionCount, second.sectionCount);
      expect(first.evidenceCount, second.evidenceCount);
    });
  });

  group('ThaiMirrorQa pipeline integration', () {
    test('pipeline integrates with QA profiles', () {
      final profile = ThaiMirrorQaProfiles.byId('QA-01');
      final result = ThaiMirrorPipeline.generate(profile.birthData);

      expect(result.isSuccess, isTrue);
      expect(result.viewState, isNotNull);
      expect(
        result.mirrorResult!.sections.length,
        ThaiMirrorQaReport.expectedSectionCount,
      );
    });

    test('no crash across all profiles', () {
      for (final profile in ThaiMirrorQaProfiles.all) {
        expect(
          () => ThaiMirrorQaReport.generate(profile),
          returnsNormally,
          reason: 'Profile ${profile.id} should not crash',
        );

        final report = ThaiMirrorQaReport.generate(profile);
        expect(
          report.pipelineSucceeded,
          isTrue,
          reason: 'Profile ${profile.id} should succeed',
        );
        expect(
          report.sectionCount,
          ThaiMirrorQaReport.expectedSectionCount,
          reason: 'Profile ${profile.id} should have 8 sections',
        );
      }
    });
  });

  group('ThaiMirrorQaRoutes', () {
    testWidgets('route opens QA screen', (tester) async {
      _bindCanonFixture();
      addTearDown(ThaiCanonEvidenceRepository.clearCachedForTest);
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            final route = ThaiMirrorQaRoutes.onGenerateRoute(settings);
            return route ?? MaterialPageRoute(builder: (_) => const SizedBox());
          },
          initialRoute: ThaiMirrorQaRoutes.qaPath,
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(ThaiMirrorQaScreen), findsOneWidget);
      expect(find.text('Thai Mirror QA'), findsOneWidget);
      expect(find.textContaining('QA-01'), findsWidgets);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('screen renders result page after pipeline', (tester) async {
      _bindCanonFixture();
      addTearDown(ThaiCanonEvidenceRepository.clearCachedForTest);
      await tester.pumpWidget(const MaterialApp(home: ThaiMirrorQaScreen()));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ThaiMirrorQaScreen), findsOneWidget);

      // The loading indicator owns a repeating animation, so waiting for a
      // global settle can never complete. Poll only for the async pipeline
      // boundary and retain a finite failure deadline.
      for (
        var attempt = 0;
        attempt < 100 && find.byType(ThaiMirrorResultPage).evaluate().isEmpty;
        attempt++
      ) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(ThaiMirrorResultPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
