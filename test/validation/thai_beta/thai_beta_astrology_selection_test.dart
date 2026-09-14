import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_astrology_selection_page.dart';

void main() {
  group('post-form astrology selection', () {
    testWidgets('shows Thai, Chinese BaZi, and Western choices', (
      tester,
    ) async {
      await _pumpSelection(tester, input: _knownInput);

      expect(find.text('โหราศาสตร์ไทย'), findsOneWidget);
      expect(find.text('โหราศาสตร์จีน · ปาจื้อ (BaZi)'), findsOneWidget);
      expect(find.text('ดูดวงไทย'), findsOneWidget);
      expect(find.text('ดูโหราจีน'), findsOneWidget);
      await _scrollToWestern(tester);
      expect(find.text('โหราศาสตร์ตะวันตก (ยุโรป)'), findsOneWidget);
      expect(find.text('ดูโหราตะวันตก'), findsOneWidget);
    });

    testWidgets('Thai choice preserves startedAt and Bangkok submit instant', (
      tester,
    ) async {
      final openedAt = DateTime.utc(2026, 8, 16, 16, 59, 50);
      final submittedAt = DateTime.utc(2026, 8, 16, 17, 0, 10);
      DateTime? capturedStartedAt;
      DateTime? capturedAsOf;

      await _pumpSelection(
        tester,
        input: _unknownInput,
        startedAt: openedAt,
        submittedAt: submittedAt,
        analysisExecutor: (input, {required startedAt, required asOf}) async {
          capturedStartedAt = startedAt;
          capturedAsOf = asOf;
          return ThaiBetaAnalysis.failedForTest(
            input: input,
            startedAt: startedAt,
            asOf: asOf,
          );
        },
      );

      await tester.tap(find.byKey(const Key('astrology-select-thai')));
      await tester.pumpAndSettle();

      expect(capturedStartedAt, openedAt);
      expect(capturedAsOf, DateTime(2026, 8, 17, 0, 0, 10));
    });

    testWidgets('Unknown time can open BaZi and carries selected system', (
      tester,
    ) async {
      ThaiBetaAstrologySystem? prepared;
      await _pumpSelection(
        tester,
        input: _unknownInput,
        prepareSystem: (uid, input, system) async {
          prepared = system;
        },
      );

      await tester.tap(find.byKey(const Key('astrology-select-bazi')));
      await tester.pumpAndSettle();

      expect(prepared, ThaiBetaAstrologySystem.bazi);
      expect(find.text('destination:bazi'), findsOneWidget);
    });

    testWidgets('Unknown time disables Western instead of inferring an hour', (
      tester,
    ) async {
      await _pumpSelection(tester, input: _unknownInput);
      await _scrollToWestern(tester);

      final button = tester.widget<FilledButton>(
        find.byKey(const Key('astrology-select-western')),
      );
      expect(button.onPressed, isNull);
      expect(find.textContaining('ต้องทราบเวลาเกิด'), findsOneWidget);
    });

    testWidgets('known time and province can open Western', (tester) async {
      ThaiBetaAstrologySystem? prepared;
      await _pumpSelection(
        tester,
        input: _knownInput,
        prepareSystem: (uid, input, system) async {
          prepared = system;
        },
      );
      await _scrollToWestern(tester);

      await tester.tap(find.byKey(const Key('astrology-select-western')));
      await tester.pumpAndSettle();

      expect(prepared, ThaiBetaAstrologySystem.western);
      expect(find.text('destination:western'), findsOneWidget);
    });

    testWidgets('cancelled sign-in does not save or navigate', (tester) async {
      var prepareCalls = 0;
      await _pumpSelection(
        tester,
        input: _knownInput,
        resolveUser: (_) async => null,
        prepareSystem: (_, _, _) async {
          prepareCalls++;
        },
      );

      await tester.tap(find.byKey(const Key('astrology-select-bazi')));
      await tester.pumpAndSettle();

      expect(prepareCalls, 0);
      expect(find.text('destination:bazi'), findsNothing);
      expect(find.text('อยากดูดวงแบบไหน?'), findsOneWidget);
    });
  });
}

Future<void> _scrollToWestern(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -520));
  await tester.pumpAndSettle();
}

Future<void> _pumpSelection(
  WidgetTester tester, {
  required ThaiBetaInput input,
  DateTime? startedAt,
  DateTime? submittedAt,
  Future<ThaiBetaAnalysis> Function(
    ThaiBetaInput input, {
    required DateTime startedAt,
    required DateTime asOf,
  })?
  analysisExecutor,
  Future<String?> Function(BuildContext context)? resolveUser,
  Future<void> Function(
    String userId,
    ThaiBetaInput input,
    ThaiBetaAstrologySystem system,
  )?
  prepareSystem,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ThaiBetaAstrologySelectionPage(
        input: input,
        startedAt: startedAt ?? DateTime.utc(2026, 9, 14, 1),
        submittedAt: submittedAt ?? DateTime.utc(2026, 9, 14, 2),
        analysisExecutor:
            analysisExecutor ??
            (input, {required startedAt, required asOf}) async =>
                ThaiBetaAnalysis.failedForTest(
                  input: input,
                  startedAt: startedAt,
                  asOf: asOf,
                ),
        resolveUser: resolveUser ?? (_) async => 'uid-1',
        prepareSystem: prepareSystem ?? (_, _, _) async {},
        destinationBuilder: (_, _, system) =>
            Scaffold(body: Text('destination:${system.name}')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _knownInput = ThaiBetaInput(
  firstName: 'Owner',
  lastName: 'Known',
  birthDate: DateTime(1990, 5, 12),
  birthHour: 15,
  birthMinute: 30,
  province: 'เชียงใหม่',
  provinceKey: 'chiang mai',
);

final _unknownInput = ThaiBetaInput(
  firstName: 'Owner',
  lastName: 'Unknown',
  birthDate: DateTime(1990, 5, 12),
  birthTimeUnknown: true,
  province: 'เชียงใหม่',
  provinceKey: 'chiang mai',
);
