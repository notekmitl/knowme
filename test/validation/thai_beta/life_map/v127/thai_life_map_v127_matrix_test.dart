import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';

import 'thai_life_map_v127_fixture_matrix.dart';
import 'thai_life_map_v127_matrix_runner.dart';
import 'thai_life_map_v127_weekday_oracle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V1.2.7 independent oracle', () {
    test('Sakamoto civil weekday matches known calendar anchors', () {
      // 1972-04-05 was Wednesday; 2000-01-01 was Saturday.
      expect(
        ThaiLifeMapV127WeekdayOracle.civilWeekday(1972, 4, 5),
        DateTime.wednesday,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.civilWeekday(2000, 1, 1),
        DateTime.saturday,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.civilWeekday(2026, 7, 15),
        DateTime.wednesday,
      );
    });

    test('ageYears handles birthday boundary and leap day', () {
      final asOf = DateTime(2026, 7, 15);
      expect(
        ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(2000, 1, 15),
          asOf: asOf,
        ),
        26,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(2000, 7, 16),
          asOf: asOf,
        ),
        25,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(2000, 2, 29),
          asOf: DateTime(2025, 2, 28),
        ),
        24,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.ageYears(
          birthDate: DateTime(2000, 2, 29),
          asOf: DateTime(2025, 3, 1),
        ),
        25,
      );
    });

    test('Wednesday day vs night around Bangkok sunset', () {
      final day = DateTime(1972, 4, 5, 10, 30);
      final night = DateTime(1972, 4, 5, 22, 30);
      expect(
        ThaiLifeMapV127WeekdayOracle.isWednesdayNightRahu(
          civilLocal: day,
          latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
          longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
          utcOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
          hasBirthTime: true,
        ),
        isFalse,
      );
      expect(
        ThaiLifeMapV127WeekdayOracle.isWednesdayNightRahu(
          civilLocal: night,
          latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
          longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
          utcOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
          hasBirthTime: true,
        ),
        isTrue,
      );
    });
  });

  group('V1.2.7 fixture matrix generator', () {
    test('builds exactly 864 deterministic fixtures covering 8×108', () {
      final a = ThaiLifeMapV127FixtureMatrix.buildCore();
      final b = ThaiLifeMapV127FixtureMatrix.buildCore();
      expect(a.length, ThaiLifeMapV127FixtureMatrix.coreCount);
      expect(a.map((f) => f.id).toList(), b.map((f) => f.id).toList());

      final byCategory = <String, int>{};
      final ages = <int>{};
      for (final f in a) {
        byCategory[f.category.id] = (byCategory[f.category.id] ?? 0) + 1;
        ages.add(f.age);
        expect(f.age, inInclusiveRange(1, 108));
        expect(f.input.provinceKey, 'bangkok');
      }
      expect(byCategory.length, 8);
      for (final c in ThaiWeekdayCategory.values) {
        expect(byCategory[c.id], 108, reason: c.id);
      }
      expect(ages.length, 108);
      expect(ages.contains(1), isTrue);
      expect(ages.contains(108), isTrue);
    });
  });

  group('V1.2.7 production-path 864 matrix', () {
    late ThaiCanonEvidenceRepository repository;
    late ThaiLifeMapV127MatrixSummary summary;

    setUpAll(() async {
      ThaiCanonEvidenceRepository.clearCachedForTest();
      repository = await ThaiCanonEvidenceRepository.loadFromAsset();
      ThaiCanonEvidenceRepository.bindCachedForTest(repository);
      summary = await ThaiLifeMapV127MatrixRunner.runCore(
        repository: repository,
      );
      final out = Directory('test/validation/thai_beta/life_map/v127/output');
      ThaiLifeMapV127MatrixRunner.writeArtifacts(summary, outDir: out);
      // Concise committed summary (no bulk JSON).
      File(
        'docs/THAI_LIFE_MAP_V127_SIMULATED_MATRIX.md',
      ).writeAsStringSync(ThaiLifeMapV127MatrixRunner.renderMarkdown(summary));
      // ignore: avoid_print
      print(ThaiLifeMapV127MatrixRunner.renderMarkdown(summary));
    });

    tearDownAll(ThaiCanonEvidenceRepository.clearCachedForTest);

    test('generated == executed == 864 and skipped == 0', () {
      expect(summary.generatedCoreCount, 864);
      expect(summary.executedCoreCount, 864);
      expect(summary.skippedCoreCount, 0);
    });

    test('all 864 fixtures pass production-path assertions', () {
      expect(
        summary.failedFixtureIds,
        isEmpty,
        reason: summary.failedFixtureIds.take(20).join(', '),
      );
      expect(summary.passedCount, 864);
      expect(summary.failedCount, 0);
    });

    test('each weekday category has 108 passes', () {
      for (final c in ThaiWeekdayCategory.values) {
        expect(summary.passByCategory[c.id], 108, reason: c.id);
      }
    });

    test('Canon wiring never yields all-eight-unknown across matrix', () {
      final allUnknown = summary.results.where(
        (r) =>
            r.anomalies.any((a) => a.contains('ALL_EIGHT_UNKNOWN')) ||
            (r.mahabhutKnownCount == 0 && r.mahabhutUnknownCount == 8),
      );
      expect(allUnknown.map((r) => r.fixtureId), isEmpty);
    });
  });
}
