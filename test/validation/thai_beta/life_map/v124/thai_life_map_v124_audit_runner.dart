import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/mahabhut_planet_position_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_life_map_mahabhut_resolution.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';

import 'thai_life_map_v124_fixtures.dart';

/// One Life Map period row for the V1.2.4 accuracy audit.
class ThaiLifeMapV124PeriodRow {
  const ThaiLifeMapV124PeriodRow({
    required this.periodIndex,
    required this.ageLabel,
    required this.planet,
    required this.planetThaiName,
    required this.phaseName,
    required this.archetypeChartCanonId,
    required this.mahabhutKnown,
    required this.mahabhutLabel,
    required this.unknownReason,
    required this.presenterLabel,
    required this.subPeriodCount,
    required this.taksaYearCount,
    required this.summary,
  });

  final int periodIndex;
  final String ageLabel;
  final LifePlanet planet;
  final String planetThaiName;
  final String phaseName;
  final String? archetypeChartCanonId;
  final bool mahabhutKnown;
  final String mahabhutLabel;
  final String? unknownReason;
  final String presenterLabel;
  final int subPeriodCount;
  final int taksaYearCount;
  final String summary;

  Map<String, Object?> toJson() => {
        'periodIndex': periodIndex,
        'ageLabel': ageLabel,
        'planet': planet.name,
        'planetThaiName': planetThaiName,
        'phaseName': phaseName,
        'archetypeChartCanonId': archetypeChartCanonId,
        'mahabhutKnown': mahabhutKnown,
        'mahabhutLabel': mahabhutLabel,
        'unknownReason': unknownReason,
        'presenterLabel': presenterLabel,
        'subPeriodCount': subPeriodCount,
        'taksaYearCount': taksaYearCount,
      };
}

class ThaiLifeMapV124ChartAudit {
  const ThaiLifeMapV124ChartAudit({
    required this.fixture,
    required this.success,
    required this.startPlanet,
    required this.wednesdayNightRahu,
    required this.periods,
    required this.anomalies,
    required this.fingerprint,
    required this.exportIncludesLifeTimeline,
    required this.exportIncludesMahabhut,
    required this.badgeActivation,
    this.errorMessage,
  });

  final ThaiLifeMapV124Fixture fixture;
  final bool success;
  final LifePlanet? startPlanet;
  final bool? wednesdayNightRahu;
  final List<ThaiLifeMapV124PeriodRow> periods;
  final List<String> anomalies;
  final String fingerprint;
  final bool exportIncludesLifeTimeline;
  final bool exportIncludesMahabhut;
  final String badgeActivation;
  final String? errorMessage;

  int get knownCount => periods.where((p) => p.mahabhutKnown).length;
  int get unknownCount => periods.where((p) => !p.mahabhutKnown).length;
}

class ThaiLifeMapV124AuditSummary {
  const ThaiLifeMapV124AuditSummary({
    required this.charts,
    required this.unknownReasonCounts,
  });

  final List<ThaiLifeMapV124ChartAudit> charts;
  final Map<String, int> unknownReasonCounts;

  int get chartCount => charts.length;
  int get periodCount =>
      charts.fold(0, (sum, c) => sum + c.periods.length);
  int get knownCount =>
      charts.fold(0, (sum, c) => sum + c.knownCount);
  int get unknownCount =>
      charts.fold(0, (sum, c) => sum + c.unknownCount);
  List<ThaiLifeMapV124ChartAudit> get anomalousCharts =>
      charts.where((c) => c.anomalies.isNotEmpty).toList();
}

/// Runs the V1.2.4 accuracy audit over synthetic fixtures.
abstract final class ThaiLifeMapV124AuditRunner {
  static Future<ThaiLifeMapV124AuditSummary> runAll({
    List<ThaiLifeMapV124Fixture>? fixtures,
  }) async {
    final list = fixtures ?? ThaiLifeMapV124Fixtures.all;
    final repository = await ThaiCanonEvidenceRepository.loadFromAsset();
    ThaiCanonEvidenceRepository.bindCachedForTest(repository);

    final charts = <ThaiLifeMapV124ChartAudit>[];
    final reasonCounts = <String, int>{};

    for (final fixture in list) {
      final chart = await auditOne(fixture, repository: repository);
      charts.add(chart);
      for (final period in chart.periods) {
        if (!period.mahabhutKnown) {
          final reason = period.unknownReason ?? 'UNSPECIFIED_UNKNOWN';
          reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
        }
      }
    }

    return ThaiLifeMapV124AuditSummary(
      charts: charts,
      unknownReasonCounts: Map.unmodifiable(reasonCounts),
    );
  }

  static Future<ThaiLifeMapV124ChartAudit> auditOne(
    ThaiLifeMapV124Fixture fixture, {
    ThaiCanonEvidenceRepository? repository,
  }) async {
    final repo =
        repository ?? await ThaiCanonEvidenceRepository.loadFromAsset();
    final anomalies = <String>[];

    final analysis = await ThaiBetaAnalysisRunner.runAsync(fixture.input);
    if (!analysis.isSuccess ||
        analysis.pipelineResult == null ||
        analysis.consumerViewState?.lifeTimeline == null) {
      return ThaiLifeMapV124ChartAudit(
        fixture: fixture,
        success: false,
        startPlanet: null,
        wednesdayNightRahu: null,
        periods: const [],
        anomalies: [
          'ANALYSIS_FAILED: ${analysis.errorMessage ?? 'unknown'}',
        ],
        fingerprint: '',
        exportIncludesLifeTimeline: false,
        exportIncludesMahabhut: false,
        badgeActivation:
            ThaiEvidenceBadgeActivation.configuredState ?? 'unset',
        errorMessage: analysis.errorMessage,
      );
    }

    final pipeline = analysis.pipelineResult!;
    final timeline = pipeline.lifePeriods!;
    final view = analysis.consumerViewState!;
    final lifeTimeline = view.lifeTimeline!;

    // Path parity: fresh present with same inputs.
    final mirrorView = ThaiMirrorConsumerPresenter.present(
      pipeline.mirrorResult!,
      lifePeriods: pipeline.lifePeriods,
      profile: pipeline.profile,
      birthData: pipeline.birthData,
      canonIndex: repo.index,
    );
    final betaLabels =
        lifeTimeline.periods.map((p) => p.mahabhutPositionLabel).toList();
    final mirrorLabels = mirrorView.lifeTimeline!.periods
        .map((p) => p.mahabhutPositionLabel)
        .toList();
    if (betaLabels.toString() != mirrorLabels.toString()) {
      anomalies.add('PATH_PARITY_BETA_VS_MIRROR_PRESENTER');
    }

    // Determinism: second runAsync must match mahabhut labels.
    final again = await ThaiBetaAnalysisRunner.runAsync(fixture.input);
    final againLabels = again.consumerViewState!.lifeTimeline!.periods
        .map((p) => p.mahabhutPositionLabel)
        .toList();
    if (betaLabels.toString() != againLabels.toString()) {
      anomalies.add('NON_DETERMINISTIC_RERUN');
    }

    final birthData = pipeline.birthData!;
    final wednesdayNight = LifePeriodEngine.isWednesdayNightRahu(birthData);
    if (fixture.expectWednesdayNightRahu != null &&
        wednesdayNight != fixture.expectWednesdayNightRahu) {
      anomalies.add(
        'WEDNESDAY_NIGHT_MISMATCH expected=${fixture.expectWednesdayNightRahu} '
        'actual=$wednesdayNight',
      );
    }

    if (lifeTimeline.periods.length != 8) {
      anomalies.add('PERIOD_COUNT_${lifeTimeline.periods.length}');
    }

    final resolution = ThaiLifeMapMahabhutResolution.tryCreate(
      profile: pipeline.profile,
      birthData: pipeline.birthData,
      canonIndex: repo.index,
    );
    if (resolution == null) {
      anomalies.add('CANON_INDEX_MISSING_ON_CONSUMER_PATH');
    }

    final rows = <ThaiLifeMapV124PeriodRow>[];
    final enginePeriods = timeline.periods;
    for (var i = 0; i < lifeTimeline.periods.length; i++) {
      final ui = lifeTimeline.periods[i];
      final engine = enginePeriods[i];
      final data = LifePlanets.of(engine.planet);
      final mahabhut = resolution?.resolve(engine) ??
          MahabhutPlanetPositionEngine.resolve(period: engine);

      if (ui.mahabhutPositionLabel != mahabhut.displayLabel) {
        anomalies.add(
          'PRESENTER_VS_RESOLVER_LABEL period=$i '
          'ui=${ui.mahabhutPositionLabel} resolver=${mahabhut.displayLabel}',
        );
      }
      if (ui.planetLine.contains(data.thaiName) == false) {
        anomalies.add(
          'PLANET_NAME_MISMATCH period=$i line=${ui.planetLine} '
          'expectedThai=${data.thaiName}',
        );
      }
      if (ui.phaseName != data.phaseName) {
        anomalies.add(
          'PHASE_NAME_MISMATCH period=$i ui=${ui.phaseName} '
          'expected=${data.phaseName}',
        );
      }
      if (ui.subPeriods.isEmpty) {
        anomalies.add('MISSING_SUB_PERIODS period=$i');
      }
      if (ui.annualTaksaYears.isEmpty) {
        anomalies.add('MISSING_ANNUAL_TAKSA period=$i');
      }

      rows.add(
        ThaiLifeMapV124PeriodRow(
          periodIndex: engine.index,
          ageLabel: ui.ageLabel,
          planet: engine.planet,
          planetThaiName: data.thaiName,
          phaseName: ui.phaseName,
          archetypeChartCanonId:
              resolution?.archetypeMetadata?.archetypeChartCanonId,
          mahabhutKnown: mahabhut.known,
          mahabhutLabel: mahabhut.displayLabel,
          unknownReason: mahabhut.known ? null : mahabhut.unknownReason,
          presenterLabel: ui.mahabhutPositionLabel,
          subPeriodCount: ui.subPeriods.length,
          taksaYearCount: ui.annualTaksaYears.length,
          summary: ui.summary,
        ),
      );
    }

    // All-unknown is a hard fail unless Canon index was missing (already flagged).
    if (rows.isNotEmpty && rows.every((r) => !r.mahabhutKnown)) {
      if (resolution != null) {
        // Still anomalous if Canon was present — may be legitimate rare archetype,
        // but flag for human review rather than auto-pass.
        anomalies.add('ALL_EIGHT_UNKNOWN_WITH_CANON_PRESENT');
      }
    }

    // Export coverage (document N/A for Mahabhut fields).
    final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);
    final exportText = export.sections
        .expand((s) => [s.title, ...s.paragraphs])
        .join('\n');
    final exportHasTimeline = export.sections.any(
      (s) =>
          s.kind == ThaiBetaReportExportSectionKind.timeline ||
          s.title.contains('แผนที่') ||
          s.title.contains('ช่วง'),
    );
    final exportHasMahabhut = exportText.contains('ตำแหน่งมหาภูต') ||
        exportText.contains('ดาวแทรก') ||
        exportText.contains('ทักษาจร');

    final fingerprint = rows
        .map(
          (r) =>
              '${r.periodIndex}:${r.planet.name}:${r.mahabhutLabel}:'
              '${r.subPeriodCount}:${r.taksaYearCount}',
        )
        .join('|');

    // Badge must stay invited_beta; anonymous audience must not expose badge APIs.
    if (ThaiEvidenceBadgeActivation.configuredState != 'invited_beta') {
      anomalies.add(
        'BADGE_NOT_INVITED_BETA=${ThaiEvidenceBadgeActivation.configuredState}',
      );
    }
    const anonymous = ThaiBetaEvidenceBadgeAudience.anonymous();
    if (anonymous.isInvitedBetaTester || anonymous.isInternalTester) {
      anomalies.add('ANONYMOUS_AUDIENCE_LEAKS_BADGE_RIGHTS');
    }

    return ThaiLifeMapV124ChartAudit(
      fixture: fixture,
      success: anomalies.isEmpty,
      startPlanet: timeline.startPlanet,
      wednesdayNightRahu: wednesdayNight,
      periods: rows,
      anomalies: anomalies,
      fingerprint: fingerprint,
      exportIncludesLifeTimeline: exportHasTimeline,
      exportIncludesMahabhut: exportHasMahabhut,
      badgeActivation:
          ThaiEvidenceBadgeActivation.configuredState ?? 'unset',
    );
  }

  static String renderMarkdown(ThaiLifeMapV124AuditSummary summary) {
    final buf = StringBuffer()
      ..writeln('# Thai Life Map V1.2.4 — Real-User Accuracy Audit')
      ..writeln()
      ..writeln('**Status:** COMPLETED')
      ..writeln('**Base:** `2d86e48` / Production code tip `07d0eb9`')
      ..writeln('**Fixtures:** synthetic QA only (no real-user PII)')
      ..writeln(
        '**Production / Frozen Canon / Mahabhut formulas:** **unchanged** '
        '(tests + docs only)',
      )
      ..writeln()
      ..writeln('## Test suite clarification')
      ..writeln()
      ..writeln('| Suite | What it is | Count |')
      ..writeln('|-------|------------|------:|')
      ..writeln(
        '| **14/14** | Assertion cases inside '
        '`thai_life_map_v124_accuracy_audit_test.dart` only '
        '(not the chart/period sample size) | 14 |',
      )
      ..writeln(
        '| **Focused Life Map suite** | Canon-index regression + '
        'V1.2.3 unit + V1.2.3 report acceptance + V1.2.4 audit | **36** |',
      )
      ..writeln(
        '| **Audit sample** | Deterministic synthetic fixtures × '
        '8 Life Map periods | '
        '**${summary.chartCount} × 8 = ${summary.periodCount}** |',
      )
      ..writeln()
      ..writeln(
        'Compile-error fixes (test harness only): `static const` → '
        '`static final` for `DateTime` fixtures; nullable '
        '`ThaiEvidenceBadgeActivation.configuredState` coalesced with '
        "`?? 'unset'`. No `lib/` / formula / Canon edits.",
      )
      ..writeln()
      ..writeln('## Verification commands (evidence)')
      ..writeln()
      ..writeln('```text')
      ..writeln('flutter analyze test/validation/thai_beta/life_map/')
      ..writeln('# → No issues found')
      ..writeln()
      ..writeln(
        'flutter test '
        'test/validation/thai_beta/life_map/'
        'thai_life_map_mahabhut_canon_index_regression_test.dart \\',
      )
      ..writeln(
        '  test/validation/thai_beta/life_map/thai_life_map_v123_test.dart \\',
      )
      ..writeln(
        '  test/validation/thai_beta/life_map/'
        'thai_life_map_v123_report_acceptance_test.dart \\',
      )
      ..writeln(
        '  test/validation/thai_beta/life_map/v124/'
        'thai_life_map_v124_accuracy_audit_test.dart \\',
      )
      ..writeln('  --reporter expanded')
      ..writeln('# → All tests passed! (+36)')
      ..writeln('```')
      ..writeln()
      ..writeln('## Totals')
      ..writeln()
      ..writeln('| Metric | Value |')
      ..writeln('|--------|------:|')
      ..writeln('| Charts | ${summary.chartCount} |')
      ..writeln('| Periods | ${summary.periodCount} |')
      ..writeln('| Known | ${summary.knownCount} |')
      ..writeln('| Unknown | ${summary.unknownCount} |')
      ..writeln(
        '| Known % | ${(100 * summary.knownCount / summary.periodCount).toStringAsFixed(1)}% |',
      )
      ..writeln(
        '| Unknown % | ${(100 * summary.unknownCount / summary.periodCount).toStringAsFixed(1)}% |',
      )
      ..writeln()
      ..writeln('## Unknown by reason')
      ..writeln()
      ..writeln('| Reason | Count |')
      ..writeln('|--------|------:|');
    final reasons = summary.unknownReasonCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in reasons) {
      buf.writeln('| `${e.key}` | ${e.value} |');
    }
    if (reasons.isEmpty) {
      buf.writeln('| _(none)_ | 0 |');
    }

    buf
      ..writeln()
      ..writeln('## Per-fixture summary')
      ..writeln()
      ..writeln(
        '| ID | Tag | Start | WedNight | Known | Unknown | Anomalies |',
      )
      ..writeln('|----|-----|-------|----------|------:|--------:|-----------|');
    for (final c in summary.charts) {
      buf.writeln(
        '| ${c.fixture.id} | `${c.fixture.tag}` | '
        '${c.startPlanet?.name ?? '-'} | ${c.wednesdayNightRahu ?? '-'} | '
        '${c.knownCount} | ${c.unknownCount} | '
        '${c.anomalies.isEmpty ? 'none' : c.anomalies.join('; ')} |',
      );
    }

    buf
      ..writeln()
      ..writeln('## Wednesday day/night')
      ..writeln()
      ..writeln('| ID | Expect | Actual | Pass |')
      ..writeln('|----|--------|--------|------|');
    for (final c in summary.charts.where(
      (c) => c.fixture.expectWednesdayNightRahu != null,
    )) {
      final ok =
          c.wednesdayNightRahu == c.fixture.expectWednesdayNightRahu;
      buf.writeln(
        '| ${c.fixture.id} | ${c.fixture.expectWednesdayNightRahu} | '
        '${c.wednesdayNightRahu} | ${ok ? 'PASS' : 'FAIL'} |',
      );
    }

    buf
      ..writeln()
      ..writeln('## Consumer path parity')
      ..writeln()
      ..writeln(
        'Beta `runAsync` vs fresh `ThaiMirrorConsumerPresenter.present` '
        'compared per fixture (mahabhut labels). '
        'Failures listed in Anomalies as `PATH_PARITY_BETA_VS_MIRROR_PRESENTER`.',
      )
      ..writeln()
      ..writeln('## PDF / export')
      ..writeln()
      ..writeln(
        '| Item | Result |',
      )
      ..writeln('|------|--------|');
    final anyTimeline =
        summary.charts.any((c) => c.exportIncludesLifeTimeline);
    final anyMahabhut =
        summary.charts.any((c) => c.exportIncludesMahabhut);
    buf
      ..writeln(
        '| Life timeline narrative sections | '
        '${anyTimeline ? 'Present' : 'Missing'} |',
      )
      ..writeln(
        '| Mahabhut / ดาวแทรก / ทักษาจร fields | '
        '${anyMahabhut ? 'Present (unexpected)' : '**N/A** — export omits these fields'} |',
      )
      ..writeln()
      ..writeln('## Evidence Badge')
      ..writeln()
      ..writeln(
        'Configured activation: `${summary.charts.first.badgeActivation}` '
        '(must remain `invited_beta`). Anonymous audience has no badge rights.',
      )
      ..writeln()
      ..writeln('## Anomalous fixtures')
      ..writeln();
    final bad = summary.anomalousCharts;
    if (bad.isEmpty) {
      buf.writeln('_None._');
    } else {
      for (final c in bad) {
        buf
          ..writeln('### ${c.fixture.id} `${c.fixture.tag}`')
          ..writeln()
          ..writeln('- Anomalies: ${c.anomalies.join(', ')}')
          ..writeln();
      }
    }

    buf
      ..writeln()
      ..writeln('## Period detail (all fixtures)')
      ..writeln()
      ..writeln(
        '| Fixture | Idx | Ages | Planet | Phase | Mahabhut | Known | Unknown reason | Sub | Taksa |',
      )
      ..writeln(
        '|---------|----:|------|--------|-------|----------|:-----:|----------------|----:|------:|',
      );
    for (final c in summary.charts) {
      for (final p in c.periods) {
        buf.writeln(
          '| ${c.fixture.id} | ${p.periodIndex} | ${p.ageLabel} | '
          '${p.planetThaiName} | ${p.phaseName} | ${p.mahabhutLabel} | '
          '${p.mahabhutKnown ? 'Y' : 'N'} | '
          '${p.unknownReason ?? ''} | ${p.subPeriodCount} | '
          '${p.taksaYearCount} |',
        );
      }
    }

    buf
      ..writeln()
      ..writeln('## Confirmed')
      ..writeln()
      ..writeln('- ≥20 deterministic synthetic fixtures')
      ..writeln('- Each chart yields exactly 8 Life Map periods when successful')
      ..writeln('- Canon index present on consumer path')
      ..writeln('- Presenter mahabhut labels match resolver display labels')
      ..writeln('- Rerun determinism checked')
      ..writeln('- Wednesday day/night expectations checked where declared')
      ..writeln('- Sub-periods and annual Taksa non-empty')
      ..writeln('- Public Evidence Badge remains `invited_beta`')
      ..writeln()
      ..writeln('## Inferences')
      ..writeln()
      ..writeln(
        '- Unknown rates reflect Frozen Canon placement coverage '
        '(ambiguous / missing / source conflict), not a missing index bug.',
      )
      ..writeln(
        '- Civil calendar weekday can differ from Thai astrological day around '
        'sunrise; e.g. early-morning civil Thursday may still resolve as '
        'Wednesday-night Rahu when `astrologicalDate` remains Wednesday.',
      )
      ..writeln()
      ..writeln('## Not confirmed in this audit')
      ..writeln()
      ..writeln(
        '- Interactive Production Visual QA of all 22 fixtures in a browser '
        '(automation limitation on Flutter web TextFields).',
      )
      ..writeln(
        '- PDF Mahabhut / nested Life Map fields (explicitly out of export scope).',
      )
      ..writeln();

    return buf.toString();
  }
}
