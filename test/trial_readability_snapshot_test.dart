import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/application/three_tradition_consensus.dart';
import 'package:knowme/features/astrology/fusion/presentation/pages/three_tradition_report_page.dart';
import 'package:knowme/features/astrology/fusion/presentation/three_tradition_life_reading.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_overall_topic_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_reading_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_report_documents.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_symbolic_reading_engine.dart';
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
  testWidgets('r4 renders and toggles each real topic at all review widths', (
    tester,
  ) async {
    final asOf = DateTime.parse(_asOf);
    final thai = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'QA',
        lastName: 'Synthetic',
        birthDate: DateTime(1990, 5, 12),
        birthHour: 8,
        birthMinute: 15,
        province: 'เชียงใหม่',
        provinceKey: 'chiang mai',
        gender: 'หญิง',
      ),
      startedAt: asOf,
      asOf: asOf,
    );
    final raw =
        jsonDecode(
              File(
                'test/fixtures/trial_readability/calculator-b.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final bazi = BaziChartModel.fromMap(Map<String, dynamic>.from(raw['bazi']));
    final western = AstrologyChartModel.fromMap(
      Map<String, dynamic>.from(raw['western']),
    );
    final comparison = ThreeTraditionConsensus.analyzeCharts(
      thai: thai.pipelineResult!.mirrorResult!,
      bazi: bazi,
      western: western,
    );
    final life = ThreeTraditionLifeReadingComposer.compose(
      thai: thai,
      bazi: bazi,
      western: western,
      comparison: comparison,
    );
    expect(life.topics, hasLength(4));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final size in [
      const Size(390, 844),
      const Size(1280, 800),
      const Size(1920, 911),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(size),
          home: ThreeTraditionReportPage(
            reading: comparison,
            lifeReading: life,
            thaiAnalysis: thai,
            baziChart: bazi,
            westernChart: western,
          ),
        ),
      );
      await tester.pumpAndSettle();
      double? left;
      for (var i = 0; i < life.topics.length; i++) {
        final card = find.byKey(Key('overall-topic-card-${i + 1}'));
        final toggle = find.byKey(Key('overall-topic-details-${i + 1}'));
        await tester.scrollUntilVisible(
          toggle,
          280,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(toggle);
        await tester.pumpAndSettle();
        final expected = life.topics[i].trialParagraphs;
        expect(expected.length, greaterThan(1));
        Finder paragraph(String text) =>
            find.descendant(of: card, matching: find.text(text));
        void checkCollapsed() {
          expect(paragraph(expected.first), findsOneWidget);
          expect(
            tester.widget<Text>(paragraph(expected.first)).maxLines,
            isNull,
          );
          for (final text in expected.skip(1)) {
            expect(paragraph(text), findsNothing);
          }
        }

        left ??= tester.getTopLeft(card).dx;
        expect(tester.getTopLeft(card).dx, left);
        expect(
          tester.getSize(card).width,
          size.width >= 800 ? greaterThan(450) : lessThanOrEqualTo(size.width),
        );
        checkCollapsed();
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        for (var index = 0; index < expected.length; index++) {
          final text = paragraph(expected[index]);
          expect(text, findsOneWidget);
          expect(tester.widget<Text>(text).maxLines, isNull);
          if (index > 0) {
            expect(
              tester.getTopLeft(text).dy -
                  tester.getBottomLeft(paragraph(expected[index - 1])).dy,
              greaterThanOrEqualTo(14),
            );
          }
        }
        await tester.ensureVisible(toggle);
        await tester.pumpAndSettle();
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        checkCollapsed();
        expect(tester.takeException(), isNull);
      }
    }
  });

  test('missing-cycle copy names only absent calculation fields', () {
    const source = BaziCompatibilityReport(
      title: 'ดวงจีน',
      subtitle: '',
      sections: [
        BaziCompatibilityReportSection(
          title: 'จังหวะชีวิตปัจจุบัน',
          paragraphs: [
            'ยังไม่แสดงดวงจรสิบปี เพราะข้อมูลเพศหรือเวลาเกิดไม่ครบ ระบบจึงไม่กำหนดทิศทางเดินดวงแทนผู้ใช้',
          ],
        ),
      ],
    );
    for (final (timeKnown, gender, hasTimeGap, hasGenderGap) in [
      (true, 'unknown', false, true),
      (false, 'female', true, false),
      (false, 'unknown', true, true),
    ]) {
      final raw =
          (jsonDecode(
                    File(
                      'test/fixtures/trial_readability/calculator-a.json',
                    ).readAsStringSync(),
                  )
                  as Map<String, dynamic>)['bazi']
              as Map<String, dynamic>;
      raw['time_known'] = timeKnown;
      (raw['luck'] as Map<String, dynamic>)['gender'] = gender;
      final projected = TrialReportDocuments.chinese(
        source,
        BaziChartModel.fromMap(raw),
      );
      final text = projected.sections.single.paragraphs.single;
      expect(text.contains('เวลาเกิด'), hasTimeGap);
      expect(text.contains('ข้อมูลเพศ'), hasGenderGap);
      expect(text, contains('ยังอ่านแนวโน้มช่วงละสิบปีไม่ได้'));
      expect(
        source.sections.single.paragraphs.single,
        contains('เพศหรือเวลาเกิด'),
      );
    }
  });

  test(
    'all ten Day Master profile paragraphs retain possibility and meaning fields',
    () {
      for (final stem in const [
        '甲',
        '乙',
        '丙',
        '丁',
        '戊',
        '己',
        '庚',
        '辛',
        '壬',
        '癸',
      ]) {
        final profile = BaziSymbolicReadingEngine.profileFor(stem);
        final paragraph =
            'ดวงนี้มีจุดเด่นคือ${profile.strengths.first} '
            'คุณใช้จุดเด่นนี้ได้ดีเมื่อ${profile.practices.first} '
            'เมื่อต้องรับหลายเรื่องพร้อมกัน ให้เลือกเรื่องสำคัญก่อนและกำหนดขอบเขตให้ชัด';
        _sameTimingAndPossibility(
          paragraph,
          TrialReadingCopy.chinese(paragraph),
        );
        _sameTimingAndPossibility(
          profile.cautions.first,
          TrialReadingCopy.chinese(profile.cautions.first),
        );
      }
    },
  );

  test(
    'balanced and missing-time owner fixtures keep possibility and timing',
    () {
      final fixtures = [
        BaziCompatibilityOwnerFixtures.readerV3Chart(),
        for (final item in BaziOwnerCase.values)
          BaziCompatibilityOwnerFixtures.chart(item),
      ];
      for (final chart in fixtures) {
        final original = BaziCompatibilityReportBuilder.build(
          chart,
          asOf: DateTime.parse(_asOf),
        );
        final projected = TrialReportDocuments.chinese(original, chart);
        _sameTimingAndPossibility(original.plainText, projected.plainText);
        expect(projected.sections.length, original.sections.length);
      }
    },
  );

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
                'after': TrialReadingCopy.thaiDashboard(item),
                if (item.currentStateSource case final source?)
                  'source': {
                    'themeId': source.themeId,
                    'requestedAspect': source.requestedAspect,
                    'originalSourceAspect': source.sourceAspect,
                    'originalSourceField': source.sourceField,
                    'displaySourceField': source.matchingSourceField,
                  },
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
                'displayTitle': TrialOverallTopicCopy.title(topic.title),
                'paragraphs': topic.trialParagraphs,
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
            if (topic.trialParagraphs.isNotEmpty) {
              _sameTimingAndPossibility(
                topic.reading,
                topic.trialParagraphs.join('\n\n'),
              );
              expect(topic.trialParagraphs, everyElement(isNotEmpty));
              expect(
                topic.trialParagraphs.toSet(),
                hasLength(topic.trialParagraphs.length),
              );
              expect(
                topic.trialParagraphs,
                everyElement(isNot(contains('\n'))),
              );
            }
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
        final r3 =
            (jsonDecode(
                      File(
                        'docs/qa/pr149-dashboard-meaning-repair/assembled-reading-review.json',
                      ).readAsStringSync(),
                    )
                    as Map<String, dynamic>)[id]
                as Map<String, dynamic>;
        for (final key in [
          'thaiAfter',
          'dashboard',
          'chineseAfter',
          'western',
        ]) {
          expect(
            result[key],
            r3[key],
            reason: '$id $key changed outside Overall',
          );
        }
        final frozen =
            (jsonDecode(
                      File(
                        'docs/qa/pr149-plain-thai/assembled-reading-review.json',
                      ).readAsStringSync(),
                    )
                    as Map<String, dynamic>)[id]
                as Map<String, dynamic>;
        // Compare to the captured old revision, not another call of the new code.
        for (final key in [
          'thaiBefore',
          'heroBefore',
          'selectedFacts',
          'gaps',
          'conflicts',
        ]) {
          expect(result[key], frozen[key], reason: '$id $key changed');
        }
        for (final key in ['western', 'overall']) {
          final rows = result[key] as List?;
          if (rows == null) continue;
          final old = frozen[key] as List;
          for (var i = 0; i < rows.length; i++) {
            for (final field in [
              'before',
              'basis',
              'thaiEvidence',
              'chineseEvidence',
              'westernBasis',
            ]) {
              expect(
                rows[i][field],
                old[i][field],
                reason: '$id $key $i $field',
              );
            }
          }
        }
        if (id != 'unknown') {
          final work = (result['overall'] as List).first['after'] as String;
          expect(work, contains('ต้องทำอะไรครบจึงถือว่างานเสร็จ'));
          expect(work, contains('หากไม่ตกลงกัน งานที่รับเพิ่มอาจกระจัดกระจาย'));
          expect(work, contains('แทนที่จะค่อย ๆ รวมเป็นผลงาน'));
          expect(work, isNot(contains('ไม่มีงานไหนเสร็จ')));
          final westernWork = (result['western'] as List)[1]['after'] as String;
          expect(westernWork, contains('ต้องทำอะไรครบจึงถือว่างานเสร็จ'));
          expect(westernWork, isNot(contains('งานเสร็จเมื่อไร')));
          final money = (result['western'] as List)[2]['after'] as String;
          final overallMoney =
              (result['overall'] as List)[1]['after'] as String;
          expect(overallMoney, contains('หากจะขยายแผนที่วางไว้'));
          if (id == 'a') {
            final love = (result['western'] as List)[3]['after'] as String;
            expect(
              love,
              contains(
                'ขณะเดียวกัน คุณต้องการความเป็นธรรมและการพูดคุยที่ทั้งสองฝ่ายได้บอกความเห็น',
              ),
            );
            expect(love, isNot(contains('มีที่ยืน')));
            expect(
              money,
              contains('สิ่งที่สำคัญกับตัวเอง ความรู้สึก และการช่วยคนอื่น'),
            );
            expect(
              money,
              contains('มักใช้เงินได้ง่ายเมื่อรู้สึกเอ็นดูหรือได้แรงบันดาลใจ'),
            );
            expect(
              money,
              contains('เว้นช่วงก่อนจ่ายและตั้งงบให้การช่วยคนอื่น'),
            );
          } else {
            expect(
              westernWork,
              contains(
                'เมื่อต้องทำให้งานคืบหน้า คุณทำได้ดีเมื่อสิ่งที่ทำสำคัญกับคุณ ได้ใช้ความคิดสร้างสรรค์ หรือได้ช่วยคนอื่น',
              ),
            );
            expect(westernWork, isNot(contains('เชื่อมโยงกับความหมาย')));
            expect(westernWork, contains('เลือกงานหลักหนึ่งชิ้น'));
            expect(
              westernWork,
              contains('เพื่อไม่ให้การปรับวิธีทำงานทำให้งานกระจัดกระจาย'),
            );
            expect(money, contains('มักตัดสินใจซื้อเร็ว เพราะอยากรู้สึกว่า'));
            expect(money, contains('กำหนดวงเงินก่อนเห็นของที่อยากได้'));
            final relationship =
                (result['overall'] as List)[2]['after'] as String;
            expect(relationship, contains('ใช้ความรู้ที่มี'));
            expect(relationship, contains('ก่อนพัฒนาความสัมพันธ์'));
            expect(relationship, isNot(contains('ก่อนเปลี่ยนความสัมพันธ์')));
          }
        }
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
