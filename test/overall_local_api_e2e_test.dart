import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/config/api_config.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/presentation/reading_evidence_text.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_astrology_handoff.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_astrology_selection_page.dart';

const _runLocalE2e = bool.fromEnvironment('RUN_LOCAL_OVERALL_E2E');

void main() {
  testWidgets(
    'synthetic birth reaches the three-tradition report through local API',
    (tester) async {
      final base = Uri.parse(ApiConfig.astrologyBaseUrl);
      expect(base.host, anyOf('localhost', '127.0.0.1'));
      final previousOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = previousOverrides);
      final timer = Stopwatch()..start();
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaAstrologySelectionPage(
            input: ThaiBetaInput(
              firstName: 'QA',
              lastName: 'Synthetic',
              birthDate: DateTime(2001, 1, 15),
              birthHour: 12,
              birthMinute: 34,
              province: 'กรุงเทพมหานคร',
              provinceKey: 'bangkok',
              gender: 'หญิง',
            ),
            startedAt: DateTime.utc(2026, 9, 24, 3),
            submittedAt: DateTime.utc(2026, 9, 24, 3, 1),
            analysisExecutor: (input, {required startedAt, required asOf}) =>
                ThaiBetaAnalysisRunner.runAsync(
                  input,
                  startedAt: startedAt,
                  asOf: asOf,
                ),
            resolveUser: (_) async =>
                throw StateError('Firebase Auth must not be accessed'),
          ),
        ),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -950));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('astrology-select-overall')));
      for (var attempt = 0; attempt < 300; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump();
        if (find.text('อ่านภาพรวมจากสามศาสตร์').evaluate().isNotEmpty) break;
      }
      timer.stop();
      expect(find.text('อ่านภาพรวมจากสามศาสตร์'), findsOneWidget);
      expect(tester.takeException(), isNull);
      // ignore: avoid_print
      print(
        'anonymous overall local API end-to-end: ${timer.elapsedMilliseconds} ms',
      );
    },
    skip: !_runLocalE2e,
  );

  test(
    'two synthetic birth sets keep all three evidence sources distinct',
    () async {
      final base = Uri.parse(ApiConfig.astrologyBaseUrl);
      expect(base.host, anyOf('localhost', '127.0.0.1'));
      final previousOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = previousOverrides);
      final cases = [
        (
          label: 'synthetic-A',
          date: DateTime(2001, 1, 15),
          hour: 12,
          minute: 34,
          province: 'กรุงเทพมหานคร',
          key: 'bangkok',
        ),
        (
          label: 'synthetic-B',
        date: DateTime(1990, 5, 12),
        hour: 15,
        minute: 30,
          province: 'เชียงใหม่',
          key: 'chiang_mai',
        ),
      ];
      for (final birth in cases) {
        final input = ThaiBetaInput(
          firstName: 'QA',
          lastName: 'Synthetic',
          birthDate: birth.date,
          birthHour: birth.hour,
          birthMinute: birth.minute,
          province: birth.province,
          provinceKey: birth.key,
          gender: 'หญิง',
        );
        final timer = Stopwatch()..start();
        final handoff = ThaiBetaAstrologyHandoff();
        final bazi = (await handoff.prepareAnonymous(
          input: input,
          systemId: 'bazi',
        )).baziChart!;
        final western = (await handoff.prepareAnonymous(
          input: input,
          systemId: 'western',
        )).westernChart!;
        final thai = ThaiBetaAnalysisRunner.run(
          input,
          asOf: DateTime(2026, 9, 24),
        );
        expect(thai.isSuccess, isTrue);
        final reading = ThreeTraditionConsensus.analyzeCharts(
          thai: thai.pipelineResult!.mirrorResult!,
          bazi: bazi,
          western: western,
        );
        timer.stop();
        expect(
          reading.byLens.values.every((sources) => sources.isNotEmpty),
          isTrue,
        );
        for (final agreement in reading.agreements) {
          expect(agreement.sourceCount, inInclusiveRange(2, 3));
          expect(
            agreement.sources.values.every(
              (source) => source.evidence.isNotEmpty,
            ),
            isTrue,
          );
        }
        // ignore: avoid_print
        print(
          '${birth.label}: ${reading.agreements.length} supported agreements, '
          '${timer.elapsedMilliseconds} ms; '
          '${reading.agreements.take(3).map((item) => '${item.sourceCount} lenses / '
              '${ReadingEvidenceText.theme(item.sources.values.first.themeId)}: '
              '${item.sources.entries.map((entry) => '${entry.key} '
                  '${ReadingEvidenceText.fact(entry.value.evidence.first)}').join(' | ')}').join(' ; ')}',
        );
      }
    },
    skip: !_runLocalE2e,
  );
}
