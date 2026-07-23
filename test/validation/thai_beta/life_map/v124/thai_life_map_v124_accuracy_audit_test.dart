import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/mahabhut_planet_position_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_archetype_context_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_archetype_planet_placement_index.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import 'thai_life_map_v124_audit_runner.dart';
import 'thai_life_map_v124_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;
  late ThaiLifeMapV124AuditSummary summary;

  setUpAll(() async {
    ThaiCanonEvidenceRepository.clearCachedForTest();
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    ThaiCanonEvidenceRepository.bindCachedForTest(repository);
    summary = await ThaiLifeMapV124AuditRunner.runAll();

    final report = ThaiLifeMapV124AuditRunner.renderMarkdown(summary);
    // ignore: avoid_print
    print(report);
    final out = File('docs/THAI_LIFE_MAP_V124_ACCURACY_AUDIT.md');
    out.writeAsStringSync(report);
  });

  tearDownAll(ThaiCanonEvidenceRepository.clearCachedForTest);

  group('V1.2.4 fixture coverage', () {
    test('at least 20 deterministic fixtures', () {
      expect(ThaiLifeMapV124Fixtures.all.length, greaterThanOrEqualTo(20));
      expect(summary.chartCount, ThaiLifeMapV124Fixtures.all.length);
    });

    test('covers all 7 weekdays and Wed day/night cases', () {
      final weekdays = <int>{};
      for (final f in ThaiLifeMapV124Fixtures.all) {
        weekdays.add(f.input.birthDate.weekday);
      }
      expect(weekdays, containsAll(DateTime.monday.to(DateTime.sunday)));
      expect(
        ThaiLifeMapV124Fixtures.all.where(
          (f) => f.expectWednesdayNightRahu == true,
        ),
        isNotEmpty,
      );
      expect(
        ThaiLifeMapV124Fixtures.all.where(
          (f) => f.expectWednesdayNightRahu == false,
        ),
        isNotEmpty,
      );
    });
  });

  group('V1.2.4 full audit', () {
    test('every chart has exactly 8 periods (≥160 total)', () {
      expect(summary.periodCount, greaterThanOrEqualTo(160));
      for (final chart in summary.charts) {
        expect(
          chart.periods,
          hasLength(8),
          reason: '${chart.fixture.id} period count',
        );
      }
    });

    test('no chart is all-unknown from missing Canon index / data-flow', () {
      for (final chart in summary.charts) {
        expect(
          chart.anomalies,
          isNot(contains('CANON_INDEX_MISSING_ON_CONSUMER_PATH')),
          reason: chart.fixture.id,
        );
        final allUnknown =
            chart.periods.isNotEmpty &&
            chart.periods.every((p) => !p.mahabhutKnown);
        if (allUnknown) {
          fail(
            '${chart.fixture.id} unknown on all 8 periods — '
            'anomalies=${chart.anomalies} reasons='
            '${chart.periods.map((p) => p.unknownReason).toSet()}',
          );
        }
      }
    });

    test('every unknown has a machine reason', () {
      for (final chart in summary.charts) {
        for (final p in chart.periods.where((p) => !p.mahabhutKnown)) {
          expect(
            p.unknownReason,
            isNotNull,
            reason: '${chart.fixture.id} period ${p.periodIndex}',
          );
          expect(p.unknownReason, isNotEmpty);
        }
      }
    });

    test('no path-parity, determinism, or structure anomalies', () {
      final blocking = <String>[
        'PATH_PARITY_BETA_VS_MIRROR_PRESENTER',
        'NON_DETERMINISTIC_RERUN',
        'MISSING_SUB_PERIODS',
        'MISSING_ANNUAL_TAKSA',
        'PRESENTER_VS_RESOLVER_LABEL',
        'PLANET_NAME_MISMATCH',
        'PHASE_NAME_MISMATCH',
        'WEDNESDAY_NIGHT_MISMATCH',
        'BADGE_NOT_INVITED_BETA',
        'ANONYMOUS_AUDIENCE_LEAKS_BADGE_RIGHTS',
        'CANON_INDEX_MISSING_ON_CONSUMER_PATH',
      ];
      for (final chart in summary.charts) {
        for (final a in chart.anomalies) {
          final blocked = blocking.any((b) => a.startsWith(b) || a == b);
          expect(
            blocked,
            isFalse,
            reason: '${chart.fixture.id}: $a',
          );
        }
      }
    });

    test('Wednesday night expectations hold', () async {
      for (final fixture in ThaiLifeMapV124Fixtures.all.where(
        (f) => f.expectWednesdayNightRahu != null,
      )) {
        final analysis = await ThaiBetaAnalysisRunner.runAsync(fixture.input);
        expect(analysis.isSuccess, isTrue, reason: fixture.id);
        final actual = LifePeriodEngine.isWednesdayNightRahu(
          analysis.pipelineResult!.birthData!,
        );
        expect(
          actual,
          fixture.expectWednesdayNightRahu,
          reason: '${fixture.id} ${fixture.notes}',
        );
        if (fixture.expectWednesdayNightRahu!) {
          expect(
            analysis.pipelineResult!.lifePeriods!.startPlanet,
            LifePlanet.rahu,
            reason: fixture.id,
          );
        }
      }
    });

    test('sub-periods and annual Taksa present on every period', () {
      for (final chart in summary.charts) {
        for (final p in chart.periods) {
          expect(p.subPeriodCount, greaterThan(0), reason: chart.fixture.id);
          expect(p.taksaYearCount, greaterThan(0), reason: chart.fixture.id);
        }
      }
    });

    test('state does not leak between consecutive fixtures', () async {
      final a = ThaiLifeMapV124Fixtures.byId('F03');
      final b = ThaiLifeMapV124Fixtures.byId('F04');
      final first = await ThaiLifeMapV124AuditRunner.auditOne(
        a,
        repository: repository,
      );
      final second = await ThaiLifeMapV124AuditRunner.auditOne(
        b,
        repository: repository,
      );
      expect(first.fingerprint, isNot(second.fingerprint));
      expect(first.startPlanet, isNot(second.startPlanet));
    });

    test('PDF export includes timeline narrative but not Mahabhut nested fields',
        () {
      expect(
        summary.charts.every((c) => c.exportIncludesLifeTimeline),
        isTrue,
      );
      expect(
        summary.charts.every((c) => !c.exportIncludesMahabhut),
        isTrue,
        reason: 'Mahabhut/sub/taksa remain N/A in export document',
      );
    });

    test('Public Evidence Badge stays invited_beta; anonymous has no rights', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'invited_beta');
      const anonymous = ThaiBetaEvidenceBadgeAudience.anonymous();
      expect(anonymous.isInvitedBetaTester, isFalse);
      expect(anonymous.isInternalTester, isFalse);
    });
  });

  group('Resolver semantics (not inventing)', () {
    test('source-conflict Jupiter in นักวิชาการ stays unknown', () {
      final index = ThaiArchetypePlanetPlacementIndex.build(repository.index);
      final conflicted = MahabhutPlanetPositionEngine.resolve(
        period: const PeriodState(
          index: 0,
          planet: LifePlanet.jupiter,
          startAge: 1,
          endAge: 19,
          strength: 19,
          isCurrent: false,
          isPast: true,
          progress: 1,
          remainingYears: 0,
          previousPlanet: null,
          nextPlanet: LifePlanet.rahu,
        ),
        archetypeMetadata: const ThaiArchetypeContextMetadata(
          archetypeChartCanonId: 'archetypeChart.nakwichakan',
          rotationIndexCanonId: 'rotationIndex.remainder6',
          remainderValue: 6,
          mappingEvidenceUnitId: 'test.mapping',
          source: 'test',
        ),
        canonIndex: repository.index,
        placementIndex: index,
      );
      expect(conflicted.known, isFalse);
      expect(
        conflicted.unknownReason,
        'SOURCE_CONFLICT_ARCHETYPE_PLANET_PLACEMENT',
      );
    });

    test('known labels are Canon vocabulary only', () {
      const allowed = {
        'ภังคะ',
        'ปูติ',
        'ขุมทรัพย์',
        'มรณะ',
        'อธิบดี',
        'ราชา',
        'ธงชัย',
        MahabhutPlanetPosition.unknownLabel,
      };
      for (final chart in summary.charts) {
        for (final p in chart.periods) {
          expect(
            allowed.contains(p.mahabhutLabel),
            isTrue,
            reason: '${chart.fixture.id} ${p.mahabhutLabel}',
          );
        }
      }
    });
  });

  group('Province / time sensitivity (formula-bound)', () {
    test('changing birth hour on Wednesday can change start planet', () async {
      final day = await ThaiBetaAnalysisRunner.runAsync(
        ThaiBetaInput(
          firstName: 'Audit',
          lastName: 'HourDay',
          birthDate: DateTime(1972, 4, 5),
          birthHour: 9,
          birthMinute: 0,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
      );
      final night = await ThaiBetaAnalysisRunner.runAsync(
        ThaiBetaInput(
          firstName: 'Audit',
          lastName: 'HourNight',
          birthDate: DateTime(1972, 4, 5),
          birthHour: 22,
          birthMinute: 0,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
      );
      expect(day.isSuccess && night.isSuccess, isTrue);
      expect(
        day.pipelineResult!.lifePeriods!.startPlanet,
        isNot(night.pipelineResult!.lifePeriods!.startPlanet),
      );
    });
  });
}

extension on int {
  Iterable<int> to(int end) sync* {
    for (var i = this; i <= end; i++) {
      yield i;
    }
  }
}
