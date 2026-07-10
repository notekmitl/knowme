import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_store.dart';
import 'package:knowme/features/thai_beta/application/thai_research_admin_access.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_engine_versions.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_feedback.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_normalized_snapshot.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_perceived_method.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_record.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_report_hash.dart';
import 'package:knowme/features/thai_beta/presentation/admin/thai_research_admin_guard.dart';

class _FakeAccess implements ThaiResearchAdminAccess {
  _FakeAccess(this.value);
  final ThaiResearchAccess value;
  @override
  Stream<ThaiResearchAccess> watch() => Stream.value(value);
}

ThaiBetaRecord _record() => ThaiBetaRecord(
      input: ThaiBetaInput(
        firstName: 'A',
        lastName: 'B',
        birthDate: DateTime(1990, 1, 1),
      ),
      normalizedBirth: const ThaiBetaNormalizedSnapshot(
        rawBirthDate: '1990-01-01',
        birthTime: '',
        province: '',
        sunrise: '06:00',
        sunriseAvailable: true,
        thaiAstrologicalDate: '1990-01-01',
        usedPreviousDay: false,
        timeZoneId: 'Asia/Bangkok',
        utcOffsetHours: 7,
        latitude: 13.7,
        longitude: 100.5,
        locationSource: 'defaulted',
        reasons: [],
      ),
      reportSnapshot: const {'report': {}},
      reportHash: 'abc',
      engineVersions: const ThaiBetaEngineVersions(
        thaiFoundationVersion: 'v1.1',
        birthNormalizationVersion: 'birth-normalization-v1',
        betaSchemaVersion: 'thai-beta-v1',
      ),
      feedback: const ThaiBetaFeedback(
        overallRating: 5,
        mostAccurate: '',
        leastAccurate: '',
        wantMoreAnalysis: '',
        recommendReason: '',
        perceivedMethod: ThaiBetaPerceivedMethod.birthDate,
        consentGiven: true,
      ),
    );

void main() {
  group('Research ID', () {
    test('formats as TH- + 8-digit zero-padded sequence', () {
      expect(ThaiBetaStore.formatResearchId(1), 'TH-00000001');
      expect(ThaiBetaStore.formatResearchId(42), 'TH-00000042');
      expect(ThaiBetaStore.formatResearchId(12345678), 'TH-12345678');
    });
  });

  group('Duration', () {
    test('computes whole seconds, clamped at zero', () {
      final start = DateTime(2026, 1, 1, 10, 0, 0);
      expect(
        ThaiBetaStore.durationSecondsBetween(
            start, start.add(const Duration(seconds: 95))),
        95,
      );
      expect(
        ThaiBetaStore.durationSecondsBetween(
            start, start.subtract(const Duration(seconds: 5))),
        0,
      );
    });
  });

  group('Report hash', () {
    test('is a stable 64-char sha256 independent of key order', () {
      final a = ThaiBetaReportHash.of({
        'report': {'a': 1, 'b': 2},
        'profile': {'x': true},
      });
      final b = ThaiBetaReportHash.of({
        'profile': {'x': true},
        'report': {'b': 2, 'a': 1},
      });
      expect(a.length, 64);
      expect(a, b);
    });

    test('changes when report content changes', () {
      final a = ThaiBetaReportHash.of({'report': {'a': 1}});
      final b = ThaiBetaReportHash.of({'report': {'a': 2}});
      expect(a, isNot(b));
    });
  });

  group('Save failure', () {
    test('never silently ignores: returns a failure result when '
        'persistence is unavailable', () async {
      // No Firebase initialized in this test → store cannot persist.
      final result = await ThaiBetaStore().save(_record());
      expect(result.success, isFalse);
      expect(result.researchId, isNull);
      expect(result.error, isNotNull);
    });
  });

  group('Admin guard', () {
    testWidgets('signed-out users never see admin content', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ThaiResearchAdminGuard(
          access: _FakeAccess(ThaiResearchAccess.signedOut),
          signedOutBuilder: (_) => const Text('LOGIN'),
          deniedBuilder: (_) => const Text('DENIED'),
          adminBuilder: (_) => const Text('ADMIN'),
        ),
      ));
      await tester.pump();
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('ADMIN'), findsNothing);
    });

    testWidgets('signed-in non-admins are denied', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ThaiResearchAdminGuard(
          access: _FakeAccess(ThaiResearchAccess.notAdmin),
          signedOutBuilder: (_) => const Text('LOGIN'),
          deniedBuilder: (_) => const Text('DENIED'),
          adminBuilder: (_) => const Text('ADMIN'),
        ),
      ));
      await tester.pump();
      expect(find.text('DENIED'), findsOneWidget);
      expect(find.text('ADMIN'), findsNothing);
    });

    testWidgets('admins see admin content', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ThaiResearchAdminGuard(
          access: _FakeAccess(ThaiResearchAccess.admin),
          signedOutBuilder: (_) => const Text('LOGIN'),
          deniedBuilder: (_) => const Text('DENIED'),
          adminBuilder: (_) => const Text('ADMIN'),
        ),
      ));
      await tester.pump();
      expect(find.text('ADMIN'), findsOneWidget);
    });
  });
}
