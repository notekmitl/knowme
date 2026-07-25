import 'dart:convert';
import 'dart:io';

import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/mahabhut_planet_position_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_life_map_mahabhut_resolution.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/mahabhut_position_user_copy.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/past_retrospective_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_life_stage_context.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import 'thai_life_map_v127_fixture_matrix.dart';
import 'thai_life_map_v127_weekday_oracle.dart';

class ThaiLifeMapV127FixtureResult {
  ThaiLifeMapV127FixtureResult({
    required this.fixtureId,
    required this.categoryId,
    required this.age,
    required this.passed,
    required this.anomalies,
    required this.mahabhutKnownCount,
    required this.mahabhutUnknownCount,
    required this.mahabhutShownOnReport,
    required this.unknownReasons,
    required this.bandName,
    required this.startPlanet,
    required this.wednesdayNightRahu,
  });

  final String fixtureId;
  final String categoryId;
  final int age;
  final bool passed;
  final List<String> anomalies;
  final int mahabhutKnownCount;
  final int mahabhutUnknownCount;
  final bool mahabhutShownOnReport;
  final List<String> unknownReasons;
  final String bandName;
  final String startPlanet;
  final bool wednesdayNightRahu;

  Map<String, Object?> toJson() => {
    'fixtureId': fixtureId,
    'categoryId': categoryId,
    'age': age,
    'passed': passed,
    'anomalies': anomalies,
    'mahabhutKnownCount': mahabhutKnownCount,
    'mahabhutUnknownCount': mahabhutUnknownCount,
    'mahabhutShownOnReport': mahabhutShownOnReport,
    'unknownReasons': unknownReasons,
    'bandName': bandName,
    'startPlanet': startPlanet,
    'wednesdayNightRahu': wednesdayNightRahu,
  };
}

class ThaiLifeMapV127MatrixSummary {
  ThaiLifeMapV127MatrixSummary({
    required this.generatedCoreCount,
    required this.executedCoreCount,
    required this.skippedCoreCount,
    required this.results,
    required this.boundaryPassed,
    required this.boundaryFailed,
    required this.boundaryAnomalies,
  });

  final int generatedCoreCount;
  final int executedCoreCount;
  final int skippedCoreCount;
  final List<ThaiLifeMapV127FixtureResult> results;
  final int boundaryPassed;
  final int boundaryFailed;
  final List<String> boundaryAnomalies;

  int get passedCount => results.where((r) => r.passed).length;
  int get failedCount => results.where((r) => !r.passed).length;

  Map<String, int> get passByCategory {
    final map = <String, int>{};
    for (final r in results) {
      if (!r.passed) continue;
      map[r.categoryId] = (map[r.categoryId] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get failByCategory {
    final map = <String, int>{};
    for (final r in results) {
      if (r.passed) continue;
      map[r.categoryId] = (map[r.categoryId] ?? 0) + 1;
    }
    return map;
  }

  int get mahabhut80Count => results
      .where((r) => r.mahabhutKnownCount == 8 && r.mahabhutUnknownCount == 0)
      .length;

  int get mahabhutPartialOrUnknownCount =>
      results.where((r) => r.mahabhutUnknownCount > 0).length;

  Map<String, int> get unknownReasonCounts {
    final map = <String, int>{};
    for (final r in results) {
      for (final reason in r.unknownReasons) {
        map[reason] = (map[reason] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<String, int> get bandDistribution {
    final map = <String, int>{};
    for (final r in results) {
      map[r.bandName] = (map[r.bandName] ?? 0) + 1;
    }
    return map;
  }

  List<String> get failedFixtureIds =>
      results.where((r) => !r.passed).map((r) => r.fixtureId).toList();

  Map<String, Object?> toJson() => {
    'generatedCoreCount': generatedCoreCount,
    'executedCoreCount': executedCoreCount,
    'skippedCoreCount': skippedCoreCount,
    'passedCount': passedCount,
    'failedCount': failedCount,
    'passByCategory': passByCategory,
    'failByCategory': failByCategory,
    'mahabhut80Count': mahabhut80Count,
    'mahabhutPartialOrUnknownCount': mahabhutPartialOrUnknownCount,
    'unknownReasonCounts': unknownReasonCounts,
    'bandDistribution': bandDistribution,
    'boundaryPassed': boundaryPassed,
    'boundaryFailed': boundaryFailed,
    'boundaryAnomalies': boundaryAnomalies,
    'failedFixtureIds': failedFixtureIds,
    'results': results.map((r) => r.toJson()).toList(),
  };
}

/// Runs the 864-core matrix through the production Thai Beta path with frozen
/// [ThaiLifeMapV127ReferenceClock.asOf] and shared Canon index.
abstract final class ThaiLifeMapV127MatrixRunner {
  static Future<ThaiLifeMapV127MatrixSummary> runCore({
    required ThaiCanonEvidenceRepository repository,
    List<ThaiLifeMapV127Fixture>? fixtures,
    bool rerunDeterminismSample = true,
  }) async {
    final list = fixtures ?? ThaiLifeMapV127FixtureMatrix.buildCore();
    final results = <ThaiLifeMapV127FixtureResult>[];
    var executed = 0;

    for (final fixture in list) {
      executed++;
      results.add(
        await _auditOne(
          fixture,
          repository: repository,
          rerunDeterminism:
              rerunDeterminismSample &&
              (fixture.age == 1 ||
                  fixture.age == 54 ||
                  fixture.age == 108 ||
                  fixture.category == ThaiWeekdayCategory.wednesdayNight),
        ),
      );
    }

    return ThaiLifeMapV127MatrixSummary(
      generatedCoreCount: list.length,
      executedCoreCount: executed,
      skippedCoreCount: list.length - executed,
      results: results,
      boundaryPassed: 0,
      boundaryFailed: 0,
      boundaryAnomalies: const [],
    );
  }

  static Future<ThaiLifeMapV127FixtureResult> _auditOne(
    ThaiLifeMapV127Fixture fixture, {
    required ThaiCanonEvidenceRepository repository,
    required bool rerunDeterminism,
  }) async {
    final anomalies = <String>[];
    final asOf = fixture.referenceAsOf;

    late final ThaiBetaAnalysis analysis;
    try {
      analysis = ThaiBetaAnalysisRunner.run(
        fixture.input,
        startedAt: asOf,
        asOf: asOf,
        canonIndex: repository.index,
      );
    } catch (e) {
      return ThaiLifeMapV127FixtureResult(
        fixtureId: fixture.id,
        categoryId: fixture.category.id,
        age: fixture.age,
        passed: false,
        anomalies: ['EXCEPTION:$e'],
        mahabhutKnownCount: 0,
        mahabhutUnknownCount: 0,
        mahabhutShownOnReport: false,
        unknownReasons: const [],
        bandName: fixture.expectedLifeStageBandName,
        startPlanet: '',
        wednesdayNightRahu: false,
      );
    }

    if (!analysis.isSuccess ||
        analysis.pipelineResult == null ||
        analysis.consumerViewState?.lifeTimeline == null ||
        analysis.pipelineResult!.birthData == null ||
        analysis.pipelineResult!.lifePeriods == null) {
      return ThaiLifeMapV127FixtureResult(
        fixtureId: fixture.id,
        categoryId: fixture.category.id,
        age: fixture.age,
        passed: false,
        anomalies: ['ANALYSIS_FAILED:${analysis.errorMessage ?? 'unknown'}'],
        mahabhutKnownCount: 0,
        mahabhutUnknownCount: 0,
        mahabhutShownOnReport: false,
        unknownReasons: const [],
        bandName: fixture.expectedLifeStageBandName,
        startPlanet: '',
        wednesdayNightRahu: false,
      );
    }

    final pipeline = analysis.pipelineResult!;
    final birthData = pipeline.birthData!;
    final engine = pipeline.lifePeriods!;
    final ui = analysis.consumerViewState!.lifeTimeline!;

    // Independent oracle vs production.
    final civilLocal = birthData.localDateTime;
    final oracleCategory = ThaiLifeMapV127WeekdayOracle.categoryForBirth(
      civilLocal: civilLocal,
      latitude: ThaiLifeMapV127WeekdayOracle.bangkokLat,
      longitude: ThaiLifeMapV127WeekdayOracle.bangkokLng,
      utcOffset: ThaiLifeMapV127WeekdayOracle.bangkokUtcOffset,
      hasBirthTime: birthData.hasBirthTime,
    );
    if (oracleCategory != fixture.category) {
      anomalies.add('ORACLE_CATEGORY_VS_FIXTURE got=${oracleCategory.id}');
    }

    final oracleAge = ThaiLifeMapV127WeekdayOracle.ageYears(
      birthDate: birthData.astrologicalDate,
      asOf: asOf,
    );
    if (oracleAge != fixture.age) {
      anomalies.add('ORACLE_AGE=$oracleAge expected=${fixture.age}');
    }
    if (engine.currentAge != fixture.age) {
      anomalies.add('ENGINE_AGE=${engine.currentAge} expected=${fixture.age}');
    }

    final productionWedNight = LifePeriodEngine.isWednesdayNightRahu(birthData);
    final oracleWedNight = ThaiLifeMapV127WeekdayOracle.isWednesdayNightRahu(
      civilLocal: civilLocal,
      latitude: birthData.latitude,
      longitude: birthData.longitude,
      utcOffset: birthData.timeZoneOffset,
      hasBirthTime: birthData.hasBirthTime,
    );
    if (productionWedNight != oracleWedNight) {
      anomalies.add(
        'WED_NIGHT_ORACLE_VS_PROD oracle=$oracleWedNight '
        'prod=$productionWedNight',
      );
    }
    if (productionWedNight != fixture.expectedWednesdayNightRahu) {
      anomalies.add(
        'WED_NIGHT_VS_FIXTURE expected=${fixture.expectedWednesdayNightRahu} '
        'prod=$productionWedNight',
      );
    }

    // Life Map coverage 1–108, exactly 8 periods, no gap/overlap.
    if (engine.periods.length != 8 || ui.periods.length != 8) {
      anomalies.add(
        'PERIOD_COUNT engine=${engine.periods.length} ui=${ui.periods.length}',
      );
    } else {
      var expectStart = 1;
      var currentCount = 0;
      for (var i = 0; i < engine.periods.length; i++) {
        final p = engine.periods[i];
        final u = ui.periods[i];
        if (p.startAge != expectStart) {
          anomalies.add(
            'GAP_OR_OVERLAP index=$i start=${p.startAge} expected=$expectStart',
          );
        }
        if (p.endAge < p.startAge) {
          anomalies.add('INVERTED_RANGE index=$i');
        }
        expectStart = p.endAge + 1;
        if (p.isCurrent) currentCount++;
        final expectPast = i < engine.currentIndex;
        final expectCurrent = i == engine.currentIndex;
        if (p.isPast != expectPast || p.isCurrent != expectCurrent) {
          anomalies.add('BUCKET_ENGINE index=$i');
        }
        if (u.isPast != p.isPast || u.isCurrent != p.isCurrent) {
          anomalies.add('BUCKET_UI_VS_ENGINE index=$i');
        }
        final expectBucket = expectCurrent
            ? 'ปัจจุบัน'
            : expectPast
            ? 'อดีต'
            : 'อนาคต';
        if (u.timeBucketLabel != expectBucket) {
          anomalies.add(
            'BUCKET_LABEL index=$i got=${u.timeBucketLabel} '
            'expected=$expectBucket',
          );
        }
      }
      if (expectStart != 109) {
        anomalies.add('COVERAGE_END=$expectStart expected=109');
      }
      if (currentCount != 1) {
        anomalies.add('CURRENT_COUNT=$currentCount');
      }
    }

    // Canon wiring + Mahabhut gating.
    final resolution = ThaiLifeMapMahabhutResolution.tryCreate(
      profile: pipeline.profile,
      birthData: pipeline.birthData,
      canonIndex: repository.index,
    );
    if (resolution == null) {
      anomalies.add('CANON_INDEX_MISSING');
    }
    final resolved = <MahabhutPlanetPosition>[];
    for (final p in engine.periods) {
      resolved.add(
        resolution?.resolve(p) ??
            MahabhutPlanetPositionEngine.resolve(period: p),
      );
    }
    final showReport = MahabhutPositionUserCopy.reportReadyToShow(resolved);
    final knownCount = resolved.where((r) => r.known).length;
    final unknownCount = resolved.length - knownCount;
    final unknownReasons = resolved
        .where((r) => !r.known)
        .map((r) => r.unknownReason ?? 'UNSPECIFIED')
        .toList();

    if (resolved.every((r) => !r.known) && resolution != null) {
      anomalies.add('ALL_EIGHT_UNKNOWN_WITH_CANON_PRESENT');
    }

    for (var i = 0; i < ui.periods.length && i < resolved.length; i++) {
      final u = ui.periods[i];
      final m = resolved[i];
      final expectedLabel = showReport ? (m.thaiName ?? '') : '';
      if (u.mahabhutPositionLabel != expectedLabel) {
        anomalies.add('MAHABHUT_UI_LABEL index=$i');
      }
      if (u.mahabhutShownOnReport != showReport) {
        anomalies.add('MAHABHUT_SHOWN_FLAG index=$i');
      }
      if (!showReport && u.mahabhutPositionLabel.isNotEmpty) {
        anomalies.add('MAHABHUT_LEAK_WHEN_HIDDEN index=$i');
      }
      if (m.thaiName == 'ราชาโชค') {
        anomalies.add('FORBIDDEN_MAHABHUT_ALIAS_ราชาโชค index=$i');
      }
    }

    // Narrative hygiene on past cards.
    for (final u in ui.periods.where((p) => p.isPast)) {
      if (PastRetrospectiveComposer.containsRetrospectivePrompt(u.summary)) {
        anomalies.add('PAST_PROMPT_BANNED ${u.ageLabel}');
      }
      if (u.summary.contains('ช่วงช่วง')) {
        anomalies.add('PAST_DOUBLE_PHASE ${u.ageLabel}');
      }
      if (u.summary.contains('null') ||
          u.summary.contains('TODO') ||
          u.summary.contains('{{') ||
          u.summary.contains('undefined')) {
        anomalies.add('PAST_TEMPLATE_LEAK ${u.ageLabel}');
      }
      if (u.summary.trim().endsWith('หรือไม่')) {
        anomalies.add('PAST_QUESTION_ENDING ${u.ageLabel}');
      }
      final paras = u.summary
          .split(RegExp(r'\n\s*\n'))
          .where((p) => p.trim().isNotEmpty)
          .length;
      if (paras < 2 || paras > 3) {
        anomalies.add('PAST_PARAGRAPH_COUNT=$paras ${u.ageLabel}');
      }
    }

    // Age-band narrative framing for the current card.
    final band = ThaiLifeStageContext.fromAge(fixture.age);
    if (band.name != fixture.expectedLifeStageBandName) {
      anomalies.add(
        'BAND_MISMATCH got=${band.name} '
        'expected=${fixture.expectedLifeStageBandName}',
      );
    }
    final currentUi = ui.periods.firstWhere((p) => p.isCurrent);
    if (band == ThaiLifeStageBand.earlyChildhood ||
        band == ThaiLifeStageBand.schoolAge) {
      final blob = currentUi.summary;
      if (blob.contains('ลงทุน') || blob.contains('คู่ครอง')) {
        anomalies.add('CHILD_ADULT_FRAMING');
      }
    }

    if (rerunDeterminism) {
      final again = ThaiBetaAnalysisRunner.run(
        fixture.input,
        startedAt: asOf,
        asOf: asOf,
        canonIndex: repository.index,
      );
      final a = ui.periods
          .map((p) => '${p.planetLine}|${p.summary}')
          .join('||');
      final b = again.consumerViewState!.lifeTimeline!.periods
          .map((p) => '${p.planetLine}|${p.summary}')
          .join('||');
      if (a != b) anomalies.add('NON_DETERMINISTIC_RERUN');
    }

    return ThaiLifeMapV127FixtureResult(
      fixtureId: fixture.id,
      categoryId: fixture.category.id,
      age: fixture.age,
      passed: anomalies.isEmpty,
      anomalies: anomalies,
      mahabhutKnownCount: knownCount,
      mahabhutUnknownCount: unknownCount,
      mahabhutShownOnReport: showReport,
      unknownReasons: unknownReasons,
      bandName: fixture.expectedLifeStageBandName,
      startPlanet: engine.startPlanet.name,
      wednesdayNightRahu: productionWedNight,
    );
  }

  static String renderMarkdown(ThaiLifeMapV127MatrixSummary summary) {
    final buf = StringBuffer()
      ..writeln('# Thai Life Map V1.2.7 — Simulated 864 Profile Matrix')
      ..writeln()
      ..writeln('**Status:** COMPLETED')
      ..writeln(
        '**Fixtures:** synthetic QA only (no real-user PII / Auth / Firestore)',
      )
      ..writeln(
        '**Reference clock:** `${ThaiLifeMapV127ReferenceClock.asOf.toIso8601String()}` '
        '(${ThaiLifeMapV127ReferenceClock.timeZoneId})',
      )
      ..writeln(
        '**Production Canon / formulas / invited_beta:** unchanged '
        '(matrix + optional `asOf` plumbing only)',
      )
      ..writeln()
      ..writeln('## Core matrix')
      ..writeln()
      ..writeln('| Metric | Value |')
      ..writeln('|--------|------:|')
      ..writeln('| Generated | ${summary.generatedCoreCount} |')
      ..writeln('| Executed | ${summary.executedCoreCount} |')
      ..writeln('| Skipped | ${summary.skippedCoreCount} |')
      ..writeln('| Passed | ${summary.passedCount} |')
      ..writeln('| Failed | ${summary.failedCount} |')
      ..writeln('| Mahabhut 8/0 | ${summary.mahabhut80Count} |')
      ..writeln(
        '| Mahabhut with unknown | ${summary.mahabhutPartialOrUnknownCount} |',
      )
      ..writeln()
      ..writeln('## By weekday category')
      ..writeln()
      ..writeln('| Category | Pass | Fail |')
      ..writeln('|----------|-----:|-----:|');
    for (final c in ThaiWeekdayCategory.values) {
      final pass = summary.passByCategory[c.id] ?? 0;
      final fail = summary.failByCategory[c.id] ?? 0;
      buf.writeln('| ${c.labelTh} (`${c.id}`) | $pass | $fail |');
    }
    buf
      ..writeln()
      ..writeln('## Age-band distribution (current age)')
      ..writeln()
      ..writeln('| Band | Count |')
      ..writeln('|------|------:|');
    for (final e in summary.bandDistribution.entries) {
      buf.writeln('| ${e.key} | ${e.value} |');
    }
    buf
      ..writeln()
      ..writeln('## Unresolved Mahabhut reasons')
      ..writeln();
    if (summary.unknownReasonCounts.isEmpty) {
      buf.writeln('_None_');
    } else {
      buf
        ..writeln('| Reason | Count |')
        ..writeln('|--------|------:|');
      final reasons = summary.unknownReasonCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final e in reasons) {
        buf.writeln('| `${e.key}` | ${e.value} |');
      }
    }
    buf
      ..writeln()
      ..writeln('## Failed fixture IDs')
      ..writeln();
    if (summary.failedFixtureIds.isEmpty) {
      buf.writeln('_None_');
    } else {
      for (final id in summary.failedFixtureIds) {
        buf.writeln('- `$id`');
      }
    }
    buf
      ..writeln()
      ..writeln('## Boundary suite')
      ..writeln()
      ..writeln(
        'Boundary assertions live in '
        '`thai_life_map_v127_boundary_test.dart` (Wednesday second-cutoff, '
        'ThaiBeta minute before/after sunset, birthday/year/leap, ages 1 & 108, '
        'pre-sunrise astrological-date rollover). Core matrix markdown does not '
        're-execute that suite; CI runs both files.',
      );
    if (summary.boundaryAnomalies.isNotEmpty) {
      buf.writeln();
      for (final a in summary.boundaryAnomalies) {
        buf.writeln('- $a');
      }
    }
    return buf.toString();
  }

  static void writeArtifacts(
    ThaiLifeMapV127MatrixSummary summary, {
    required Directory outDir,
  }) {
    if (!outDir.existsSync()) outDir.createSync(recursive: true);
    File('${outDir.path}/matrix_summary.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(summary.toJson()),
    );
    File(
      '${outDir.path}/matrix_summary.md',
    ).writeAsStringSync(renderMarkdown(summary));
  }
}
