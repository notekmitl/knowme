// Independent test oracle for OR5R civil-input-only output. Never used by runtime.
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import 'or5r_unknown_projection.dart';
export 'or5r_unknown_projection.dart';

void expectOmittedCanonTimeline(
  ThaiCanonEvidenceAlignmentFixtureResult result,
) {
  expect(result.fixture.birthData.hasBirthTime, isFalse);
  final trace = result.bundle.trace;
  expect(trace.lifePeriodsWithPeriodContextMetadata, isEmpty);
  expect(trace.lifePeriodsWithoutPeriodContextMetadata, isEmpty);
  expect(trace.lifePeriodsWithPositionMetadata, isEmpty);
  expect(trace.lifePeriodsWithoutPositionMetadata, isEmpty);
  expect(trace.lifePeriodsWithRuntimeStatus, isEmpty);
  expect(trace.lifePeriodsWithoutRuntimeStatus, isEmpty);
  expect(trace.lifePeriodsWithCanonDerivedStatus, isEmpty);
  expect(trace.positionMatchMethods, isEmpty);
  expect(trace.lifePeriodStatusMetadataBlocker, 'NO_LIFE_TIMELINE');
}

void expectCanonTimePartition(
  Iterable<ThaiCanonEvidenceAlignmentFixtureResult> rows,
) {
  final all = rows.toList();
  final known = all.where((r) => r.fixture.birthData.hasBirthTime).toList();
  final unknown = all.where((r) => !r.fixture.birthData.hasBirthTime).toList();
  expect(all, hasLength(9));
  expect(known, hasLength(8));
  expect(unknown, hasLength(1));
  for (final row in unknown) {
    expectOmittedCanonTimeline(row);
  }
  expect(
    known.fold<int>(
      0,
      (n, r) => n + r.bundle.trace.lifePeriodsWithRuntimeStatus.length,
    ),
    48,
  );
  expect(
    known.fold<int>(
      0,
      (n, r) => n + r.bundle.trace.lifePeriodsWithoutRuntimeStatus.length,
    ),
    16,
  );
  expect(
    known.fold<int>(
      0,
      (n, r) => n + r.bundle.trace.lifePeriodsWithPeriodContextMetadata.length,
    ),
    7,
  );
  expect(
    known.fold<int>(
      0,
      (n, r) =>
          n + r.bundle.trace.lifePeriodsWithoutPeriodContextMetadata.length,
    ),
    57,
  );
}

void expectUnknownDocument(
  ThaiBetaInput input,
  ThaiBetaReportExportDocument doc,
) {
  expect(input.hasBirthTime, isFalse);
  expect(doc.fullPlainText, expectedUnknownText(input));
  expect(doc.sections, hasLength(4));
  expect(doc.sections.map((s) => s.title), or5rTitles);
  expect(doc.infographic, isNull);
  final expected = expectedUnknownParagraphs(input);
  for (var i = 0; i < 4; i++) {
    final s = doc.sections[i];
    expect(s.kind, ThaiBetaReportExportSectionKind.chapter);
    expect(s.id, 'unknown-safe-${or5rIds[i]}');
    expect(s.paragraphs, expected[i]);
    expect(s.fieldSource, 'civil-input-and-omission-only');
    expect(s.knownUnknownRule, 'unknown-only');
    expect(s.traceIds, ['unknown-safe:${or5rIds[i]}']);
    expect(s.paragraphIds.toSet(), hasLength(s.paragraphs.length));
    expect(s.title.allMatches(doc.fullPlainText), hasLength(1));
  }
  expect(or5rOmission.allMatches(doc.fullPlainText), hasLength(1));
  expect(
    doc.sections.expand((s) => s.paragraphs).toSet().length,
    doc.sections.fold<int>(0, (n, s) => n + s.paragraphs.length),
  );
  // Exact paragraph equality above rejects statements that merely contain an
  // omission disclaimer but append a computed claim, date, or legacy body.
  for (final forbidden in const [
    'ก่อนพระอาทิตย์ขึ้น',
    'หลังพระอาทิตย์ขึ้น',
    'เวลาเกิดอยู่',
    'ลัคนาอยู่ที่',
    'ลัคนา:',
    'เรือนการงานที่',
    'เจ้าเรือนลัคนา',
    'วันทางโหราศาสตร์:',
    '12:00',
    '00:00',
    '23:59',
    '°',
    'คุณถูกผลักให้',
    'ร่างกายและใจถูกใช้จนสุดแรง',
    'คุณต้องแบกงานหลายเรื่อง',
    'น้ำหนักเด่น',
    'น้ำหนักปานกลาง',
    'น้ำหนักเบา',
    'คาบเกี่ยวรอยต่อ',
    'internal/beta',
    'Canon ID',
    'themeId',
    'sourceRef',
    'uid:',
  ]) {
    expect(doc.fullPlainText, isNot(contains(forbidden)), reason: forbidden);
  }
}

void expectUnknownContract(ThaiBetaAnalysis analysis) {
  expect(analysis.isSuccess, isTrue);
  expect(analysis.input.hasBirthTime, isFalse);
  expect(analysis.input.toMap()['birthHour'], isNull);
  expect(analysis.input.toMap()['birthMinute'], isNull);
  expect(analysis.pipelineResult!.lifePeriods, isNull);
  expect(analysis.profile!.lagnaKey, isNull);
  expect(analysis.profile!.lagnaLordKey, isNull);
  expect(analysis.profile!.siderealAscendantDeg, isNull);
  final composed = ThaiBetaNarrativeComposer.compose(analysis);
  expect(composed.trace.entries, isEmpty);
  for (final view in [analysis.consumerViewState!, composed.view]) {
    expect(view.lifeTimeline, isNull);
    expect(view.futurePrediction, isNull);
    expect(view.narrativeSections, isEmpty);
    expect(view.lifeDashboard, isEmpty);
    expect(view.strengths.cards, isEmpty);
    expect(view.cautions.cards, isEmpty);
    expect(view.advice.body, isEmpty);
    expect(view.signatureInsight.isEmpty, isTrue);
    expect(view.birthDataConfidence.isComplete, isFalse);
    expect(view.birthDataConfidence.title, isEmpty);
    expect(view.birthDataConfidence.body, isEmpty);
    expect(view.hero.summary, or5rOmission);
    expect(
      view.hero.identitySubtitle,
      'ไม่มีเวลาเกิด — ภาพรวมข้อมูลวันเกิดตามปฏิทินและข้อจำกัด',
    );
  }
  expectUnknownDocument(
    analysis.input,
    ThaiBetaReportExportDocument.fromAnalysis(analysis),
  );
  final candidate = ThaiBetaReportExportDocument.candidate(analysis);
  expectUnknownDocument(analysis.input, candidate);
  expect(candidate.predictiveRuntimeV2!.monthlyTimelineAvailable, isFalse);
  expect(candidate.predictiveRuntimeV2!.emittedPredictions, 0);
}
