import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/presentation/three_tradition_life_reading.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_reading_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_report_documents.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/domain/bazi_compatibility_report.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/presentation/pages/astrology/western_reader_v2_copy.dart';

const _asOf = '2026-11-10T03:00:00Z';

Map<String, dynamic> _thaiDocument(ThaiBetaReportExportDocument document) => {
  'sections': [
    for (final section in document.sections)
      {
        'id': section.id,
        'title': section.title,
        'paragraphs': section.paragraphs,
        'traceIds': section.traceIds,
      },
  ],
};

List<Map<String, dynamic>> _chineseDocument(BaziCompatibilityReport report) => [
  for (final section in report.sections)
    {
      'title': section.title,
      'intro': section.intro,
      'paragraphs': section.paragraphs,
      'rows': [
        for (final row in section.rows)
          {'label': row.label, 'value': row.value},
      ],
      'notes': section.notes,
    },
];

void _sameTimingAndPossibility(String before, String after) {
  expect(
    RegExp(r'\d+').allMatches(after).map((m) => m[0]).toList(),
    RegExp(r'\d+').allMatches(before).map((m) => m[0]).toList(),
  );
  expect(
    'อาจ'.allMatches(after).length,
    'อาจ'.allMatches(before).length,
    reason: 'before: $before\nafter: $after',
  );
}

void main() {
  test(
    'assembled trial copy preserves source models, timing and selected evidence',
    () {
      final cases = <String, dynamic>{
        'revision': TrialReadingCopy.revision,
        'asOf': _asOf,
      };
      for (final (id, year, month, day, hour, minute, province, key) in [
        ('a', 2001, 1, 15, 12, 34, 'กรุงเทพมหานคร', 'bangkok'),
        ('b', 1990, 5, 12, 8, 15, 'เชียงใหม่', 'chiang mai'),
        ('unknown', 2001, 1, 15, -1, 0, 'กรุงเทพมหานคร', 'bangkok'),
      ]) {
        final analysis = ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: 'QA',
            lastName: 'Synthetic',
            birthDate: DateTime(year, month, day),
            birthHour: hour < 0 ? null : hour,
            birthMinute: minute,
            birthTimeUnknown: hour < 0,
            province: province,
            provinceKey: key,
            gender: 'หญิง',
          ),
          startedAt: DateTime.parse(_asOf),
          asOf: DateTime.parse(_asOf),
        );
        final original = ThaiBetaReportExportDocument.candidate(analysis);
        final beforeText = original.fullPlainText;
        final trial = TrialReportDocuments.thai(original);
        expect(original.fullPlainText, beforeText);
        expect(trial.predictiveRuntimeV2, same(original.predictiveRuntimeV2));
        expect(trial.sections.length, original.sections.length);
        for (var i = 0; i < original.sections.length; i++) {
          final before = original.sections[i];
          final after = trial.sections[i];
          expect(
            [
              after.id,
              after.kind,
              after.fieldSource,
              after.visibilityRule,
              after.knownUnknownRule,
              after.traceIds,
            ],
            [
              before.id,
              before.kind,
              before.fieldSource,
              before.visibilityRule,
              before.knownUnknownRule,
              before.traceIds,
            ],
          );
          expect(after.paragraphs.length, before.paragraphs.length);
          for (var j = 0; j < before.paragraphs.length; j++) {
            _sameTimingAndPossibility(
              before.paragraphs[j],
              after.paragraphs[j],
            );
          }
        }
        final image = trial.infographic;
        if (image != null) {
          expect(image.traceIds, original.infographic!.traceIds);
          expect(image.periodLabel, original.infographic!.periodLabel);
          expect(
            image.monthlyTimelineAvailable,
            original.infographic!.monthlyTimelineAvailable,
          );
          expect(
            image.categories.map((c) => c.traceIds),
            original.infographic!.categories.map((c) => c.traceIds),
          );
        }
        final view = analysis.consumerViewState!;
        final result = <String, dynamic>{
          'thaiBefore': _thaiDocument(original),
          'thaiAfter': _thaiDocument(trial),
          'heroBefore': {
            'title': view.hero.headline,
            'body': view.hero.summary.split('\n\n').first,
          },
          'heroAfter': {
            'title': TrialReadingCopy.thaiHeadline(view.hero.headline),
            'body': TrialReadingCopy.thai(
              view.hero.summary.split('\n\n').first,
            ),
          },
          'dashboard': [
            for (final item in view.lifeDashboard)
              {
                'title': item.label,
                'before': item.currentState,
                'after': TrialReadingCopy.thai(item.currentState),
              },
          ],
        };
        if (id != 'unknown') {
          final raw =
              jsonDecode(
                    File(
                      'test/fixtures/trial_readability/calculator-$id.json',
                    ).readAsStringSync(),
                  )
                  as Map<String, dynamic>;
          final untouched = jsonEncode(raw);
          final bazi = BaziChartModel.fromMap(
            Map<String, dynamic>.from(raw['bazi']),
          );
          final western = AstrologyChartModel.fromMap(
            Map<String, dynamic>.from(raw['western']),
          );
          final comparison = ThreeTraditionConsensus.analyzeCharts(
            thai: analysis.pipelineResult!.mirrorResult!,
            bazi: bazi,
            western: western,
          );
          final life = ThreeTraditionLifeReadingComposer.compose(
            thai: analysis,
            bazi: bazi,
            western: western,
            comparison: comparison,
          );
          final report = BaziCompatibilityReportBuilder.build(
            bazi,
            asOf: DateTime.parse(_asOf),
          );
          final reportBefore = report.plainText;
          final chinese = TrialReportDocuments.chinese(report, bazi);
          expect(report.plainText, reportBefore);
          _sameTimingAndPossibility(reportBefore, chinese.plainText);
          result['chineseBefore'] = _chineseDocument(report);
          result['chineseAfter'] = _chineseDocument(chinese);
          result['western'] = [
            for (final section in WesternReaderV2Copy.sections(western))
              {
                'id': section.id,
                'basis': section.basis,
                'before': section.body,
                'after': TrialReadingCopy.western(section.body),
              },
          ];
          result['westernOverview'] = {
            'before': WesternReaderV2Copy.overview(western),
            'after': TrialReadingCopy.western(
              WesternReaderV2Copy.overview(western),
            ),
          };
          result['overall'] = [
            for (final topic in life.topics)
              {
                'title': topic.title,
                'before': topic.reading,
                'after': TrialReadingCopy.overall(topic.reading),
                'thaiEvidence': topic.thaiEvidenceKeys,
                'chineseEvidence': topic.chineseEvidenceKeys,
                'westernBasis': topic.westernBasis,
              },
          ];
          for (final topic in life.topics) {
            _sameTimingAndPossibility(
              topic.reading,
              TrialReadingCopy.overall(topic.reading),
            );
          }
          for (final section in WesternReaderV2Copy.sections(western)) {
            _sameTimingAndPossibility(
              section.body,
              TrialReadingCopy.western(section.body),
            );
          }
          result['gaps'] = life.gaps;
          result['conflicts'] = life.conflicts
              .map((c) => {'title': c.title, 'axis': c.axis})
              .toList();
          result['selectedFacts'] = {
            for (final entry in comparison.byLens.entries)
              entry.key: [
                for (final fact in entry.value)
                  {
                    'theme': fact.themeId,
                    'confidence': fact.confidence,
                    'evidence': fact.evidence,
                  },
              ],
          };
          final recomposed = ThreeTraditionConsensus.analyzeCharts(
            thai: analysis.pipelineResult!.mirrorResult!,
            bazi: bazi,
            western: western,
          );
          expect(recomposed.byLens, comparison.byLens);
          expect(
            recomposed.agreements.map((a) => [a.key, a.exact, a.sources]),
            comparison.agreements.map((a) => [a.key, a.exact, a.sources]),
          );
          expect(jsonEncode(raw), untouched);
        }
        cases[id] = result;
      }
      final incomplete = BaziCompatibilityOwnerFixtures.chart(
        BaziOwnerCase.unknown,
      );
      final incompleteBefore = BaziCompatibilityReportBuilder.build(
        incomplete,
        asOf: DateTime.parse(_asOf),
      );
      final incompleteAfter = TrialReportDocuments.chinese(
        incompleteBefore,
        incomplete,
      );
      expect(incompleteAfter.sections.length, incompleteBefore.sections.length);
      cases['incompleteChinese'] = {
        'before': _chineseDocument(incompleteBefore),
        'after': _chineseDocument(incompleteAfter),
      };
      final path = const String.fromEnvironment(
        'COPY_SNAPSHOT',
        defaultValue: '.preview-qa/readability-review.json',
      );
      File(path).parent.createSync(recursive: true);
      File(
        path,
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(cases));
    },
  );
}
