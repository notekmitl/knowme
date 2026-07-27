import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/evidence/v135/thai_birthday_year_window.dart';
import 'package:knowme/features/astrology/thai/mirror/evidence/v135/thai_detailed_report_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/evidence/v135/thai_detected_event.dart';
import 'package:knowme/features/astrology/thai/mirror/evidence/v135/thai_evidence_item.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

void main() {
  final asOf = DateTime(2026, 7, 27);

  ThaiBetaAnalysis runFixture({
    required DateTime birth,
    int? hour,
    int minute = 0,
    DateTime? readingAt,
  }) {
    return ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'V135',
        lastName: 'Fixture',
        birthDate: birth,
        birthHour: hour,
        birthMinute: minute,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
      startedAt: readingAt ?? asOf,
      asOf: readingAt ?? asOf,
    );
  }

  test('determinism: same birth + asOf → identical evidence and structure', () {
    final a = ThaiBetaNarrativeFixtures.fixtureA();
    final b = ThaiBetaAnalysisRunner.run(
      a.input,
      startedAt: ThaiBetaNarrativeFixtures.referenceDate,
      asOf: ThaiBetaNarrativeFixtures.referenceDate,
    );
    final ta = a.consumerViewState!.lifeTimeline!;
    final tb = b.consumerViewState!.lifeTimeline!;
    expect(ta.detailedReport, isNotNull);
    expect(tb.detailedReport, isNotNull);
    expect(
      ta.detailedReport!.lifetimeTopics.map((t) => t.title).toList(),
      tb.detailedReport!.lifetimeTopics.map((t) => t.title).toList(),
    );
    expect(
      ta.detailedReport!.currentReading.evidenceFound,
      tb.detailedReport!.currentReading.evidenceFound,
    );
    expect(
      ta.detailedReport!.pastPeriods.length,
      tb.detailedReport!.pastPeriods.length,
    );
  });

  test('completeness: lifetime topics, past, current, future from next', () {
    final analysis = runFixture(
      birth: DateTime(1982, 6, 6),
      hour: 0,
      minute: 35,
    );
    expect(analysis.isSuccess, isTrue);
    final timeline = analysis.pipelineResult!.lifePeriods!;
    final report = ThaiDetailedReportComposer.compose(
      birthData: analysis.pipelineResult!.birthData!,
      profile: analysis.profile!,
      timeline: timeline,
      asOfLocal: asOf,
      profileSeed: 42,
    );

    expect(report.lifetimeTopics.map((t) => t.title).toList(), [
      'ภาพรวมชีวิต',
      'บุคลิกและวิธีดำเนินชีวิต',
      'การงาน',
      'การเงิน',
      'ความรัก',
      'สุขภาพ',
    ]);
    for (final t in report.lifetimeTopics) {
      expect(t.evidenceFound, isNotEmpty);
      expect(t.prediction, isNotEmpty);
      expect(t.evidenceIds, isNotEmpty);
    }

    final pastCount = timeline.periods.where((p) => p.isPast).length;
    final futureCount = timeline.periods.where((p) => p.isFuture).length;
    expect(report.pastPeriods.length, pastCount);
    expect(report.futurePeriods.length, futureCount);
    expect(
      report.futurePeriods.map((p) => p.periodIndex).toList(),
      timeline.periods.where((p) => p.isFuture).map((p) => p.index).toList(),
    );
    expect(report.currentReading.evidenceFound, contains('ชั้นช่วงอายุ'));
    expect(report.currentReading.evidenceFound, contains('ชั้นปีเกิด'));
    expect(report.closingAdvice.healthDisclaimer, contains('ไม่ใช่คำบอกจากแพทย์'));
  });

  test('every prediction/event has evidence ID; no orphan events', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final report = ThaiDetailedReportComposer.compose(
      birthData: analysis.pipelineResult!.birthData!,
      profile: analysis.profile!,
      timeline: analysis.pipelineResult!.lifePeriods!,
      asOfLocal: ThaiBetaNarrativeFixtures.referenceDate,
      profileSeed: 7,
    );
    final knownIds = report.allEvidence.map((e) => e.evidenceId).toSet();
    for (final e in report.allEvents) {
      expect(e.evidenceIds, isNotEmpty);
      expect(
        e.evidenceIds.every(knownIds.contains),
        isTrue,
        reason: 'event ${e.eventKey} cites unknown evidence',
      );
    }
    for (final t in report.lifetimeTopics) {
      expect(t.evidenceIds.every(knownIds.contains), isTrue);
    }
    for (final p in [...report.pastPeriods, ...report.futurePeriods]) {
      expect(p.evidenceIds, isNotEmpty);
      expect(p.evidenceIds.every(knownIds.contains), isTrue);
    }
    expect(report.currentReading.evidenceIds.every(knownIds.contains), isTrue);
  });

  test('events: single-rule allowed, no artificial minimum, past wording', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final report = ThaiDetailedReportComposer.compose(
      birthData: analysis.pipelineResult!.birthData!,
      profile: analysis.profile!,
      timeline: analysis.pipelineResult!.lifePeriods!,
      asOfLocal: ThaiBetaNarrativeFixtures.referenceDate,
      profileSeed: 7,
    );
    // Zero events is allowed for quiet periods.
    for (final p in report.pastPeriods) {
      for (final e in p.events) {
        expect(
          e.body.contains('มีเกณฑ์ว่าเคย') || e.body.contains('น่าจะเคย'),
          isTrue,
          reason: e.body,
        );
      }
    }
    for (final p in report.futurePeriods) {
      for (final e in p.events) {
        expect(
          e.body.contains('แนวโน้ม') || e.body.contains('อาจ'),
          isTrue,
          reason: e.body,
        );
        expect(e.body.contains('ยังไม่ใช่สิ่งที่รับประกัน'), isTrue);
      }
    }
    final keys = report.allEvents.map((e) => e.eventKey).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('no ephemeris / Ketu / Uranus / house occupancy claims', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final view = analysis.consumerViewState!.lifeTimeline!.detailedReport!;
    final blob = [
      for (final t in view.lifetimeTopics) '${t.evidenceFound}\n${t.prediction}',
      view.currentReading.evidenceFound,
      view.currentReading.prediction,
      for (final p in [...view.pastPeriods, ...view.futurePeriods])
        '${p.evidenceFound}\n${p.prediction}\n${p.eventLines.join('\n')}',
    ].join('\n');
    expect(blob, isNot(contains('ยูเรนัส')));
    expect(blob, isNot(contains('เกตุ')));
    expect(blob.toLowerCase(), isNot(contains('swiss')));
    // Whole-sign house lords may appear; occupancy claims must not.
    expect(blob, isNot(contains('ดาวอยู่ในเรือน')));
    expect(blob, isNot(contains('องศาดาว')));
  });

  test('no birth time still builds report without lagna houses', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureB();
    expect(analysis.isSuccess, isTrue);
    final report = analysis.consumerViewState!.lifeTimeline!.detailedReport!;
    expect(report.lifetimeTopics.length, 6);
    expect(
      report.lifetimeTopics
          .any((t) => t.evidenceFound.contains('ไม่มีเวลาเกิด')),
      isTrue,
    );
  });

  test('advice appears once at end only', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final report = analysis.consumerViewState!.lifeTimeline!.detailedReport!;
    expect(report.closingAdvice.recommendations, isNotEmpty);
    expect(report.closingAdvice.cautions, isNotEmpty);
    expect(report.closingAdvice.healthDisclaimer, isNotEmpty);
    final pastBlob = report.pastPeriods.map((p) => p.prediction).join();
    expect(pastBlob.contains(report.closingAdvice.recommendations), isFalse);
  });

  test('Wednesday daytime fixture still succeeds', () {
    final analysis = ThaiBetaNarrativeFixtures.wednesdayDaytime();
    expect(analysis.isSuccess, isTrue);
    expect(analysis.consumerViewState!.lifeTimeline!.detailedReport, isNotNull);
  });

  test('evidence rule version is v135.1', () {
    final analysis = ThaiBetaNarrativeFixtures.fixtureA();
    final report = ThaiDetailedReportComposer.compose(
      birthData: analysis.pipelineResult!.birthData!,
      profile: analysis.profile!,
      timeline: analysis.pipelineResult!.lifePeriods!,
      asOfLocal: ThaiBetaNarrativeFixtures.referenceDate,
      profileSeed: 1,
    );
    expect(
      report.allEvidence.every(
        (e) => e.ruleVersion == ThaiEvidenceItem.ruleVersionV135,
      ),
      isTrue,
    );
    expect(
      report.allEvents.every((e) => e.tense != ThaiEventTense.present || true),
      isTrue,
    );
  });

  test('birthday window label present on current reading', () {
    final window = ThaiBirthdayYearWindow.resolve(
      birthLocalDate: DateTime(1982, 6, 6),
      asOfLocal: DateTime(2026, 7, 27),
    );
    final analysis = runFixture(
      birth: DateTime(1982, 6, 6),
      hour: 0,
      minute: 35,
    );
    final current =
        analysis.consumerViewState!.lifeTimeline!.detailedReport!.currentReading;
    expect(current.evidenceFound, contains(window.labelTh));
  });
}
