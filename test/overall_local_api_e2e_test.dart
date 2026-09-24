import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/config/api_config.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
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
}
