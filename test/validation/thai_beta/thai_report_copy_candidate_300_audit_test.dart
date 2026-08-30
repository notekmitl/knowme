import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_narrative_plan.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'synthetic_audit/thai_beta_synthetic_matrix_300.dart';

const _referenceDate = '2026-08-29T00:00:00.000Z';
const _forbidden = <String>[
  'มีแนวโน้มว่าอาจ',
  'ลองนึกย้อน',
  'ลองทบทวน',
  'ในทางโหราศาสตร์ จุดนี้อ่านจาก',
  'วิธีคำนวณ',
  'คำทำนายรายเดือน',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    '300-profile typed-plan audit is deterministic, ordered and fail closed',
    () {
      final cases = ThaiBetaSyntheticMatrix.build();
      expect(cases, hasLength(300));

      final contexts = <String>{};
      var known = 0;
      var unknown = 0;
      var atoms = 0;
      var missing = 0;
      var mismatch = 0;
      var duplicate = 0;
      var orderMismatch = 0;
      var ownerMismatch = 0;
      var leakage = 0;
      var forbiddenHits = 0;

      for (final profile in cases) {
        final firstAnalysis = ThaiBetaAnalysisRunner.run(
          profile.input,
          startedAt: DateTime.parse(_referenceDate),
          asOf: DateTime.parse(_referenceDate),
        );
        final secondAnalysis = ThaiBetaAnalysisRunner.run(
          profile.input,
          startedAt: DateTime.parse(_referenceDate),
          asOf: DateTime.parse(_referenceDate),
        );
        expect(firstAnalysis.isSuccess, isTrue, reason: profile.id);
        expect(secondAnalysis.isSuccess, isTrue, reason: profile.id);

        final first = ThaiBetaReportExportDocument.candidate(firstAnalysis);
        final second = ThaiBetaReportExportDocument.candidate(secondAnalysis);
        final plan = first.narrativePlan!;
        atoms += plan.atoms.length;
        expect(second.narrativePlan!.toMap(), plan.toMap(), reason: profile.id);
        expect(second.fullPlainText, first.fullPlainText, reason: profile.id);
        expect(plan.sections, isNotEmpty, reason: profile.id);
        expect(plan.monthlyTimelineAvailable, isFalse, reason: profile.id);

        final projectedIds = plan.sections
            .map((section) => 'predictive-${section.id}')
            .toList(growable: false);
        final documentIds = first.sections
            .map((section) => section.id)
            .toList(growable: false);
        if (documentIds.length != projectedIds.length) missing++;
        if (!_listEquals(documentIds, projectedIds)) mismatch++;

        final ownerIds = plan.atoms.map((atom) => atom.owner.id).toList();
        if (ownerIds.toSet().length != ownerIds.length) duplicate++;
        if (plan.atoms.any((atom) => atom.evidence.refs.isEmpty)) {
          ownerMismatch++;
        }
        if (plan.atoms.whereType<DisclosureAtom>().length != 1) {
          ownerMismatch++;
        }
        if (plan.sections
            .where((section) => section.role != NarrativeSectionRole.advice)
            .expand((section) => section.atoms)
            .whereType<AdviceAtom>()
            .isNotEmpty) {
          ownerMismatch++;
        }

        final ranks = plan.sections
            .map((section) => _roleRank(section.role))
            .toList(growable: false);
        for (var i = 1; i < ranks.length; i++) {
          if (ranks[i] < ranks[i - 1]) orderMismatch++;
        }

        final text = first.fullPlainText;
        forbiddenHits += _forbidden.where(text.contains).length;
        if (plan.isKnownTime) {
          known++;
          contexts.add(plan.contextId);
          if (plan.atoms.whereType<PredictionAtom>().isEmpty) missing++;
        } else {
          unknown++;
          if (plan.atoms.whereType<PredictionAtom>().isNotEmpty) leakage++;
          for (final token in const [
            'ลัคนา',
            'เรือน',
            'วันทางโหราศาสตร์',
            'คำทำนาย 12 เดือนข้างหน้า',
          ]) {
            if (text.contains(token)) leakage++;
          }
          if (!text.contains('แทนการเดาข้อมูลที่ไม่มี')) leakage++;
        }

        final infographic = first.infographic!;
        final tracedOwners = infographic.traceIds
            .where(ownerIds.toSet().contains)
            .toSet();
        if (tracedOwners.length != ownerIds.length) ownerMismatch++;
      }

      expect(known, 225);
      expect(unknown, 75);
      expect(contexts, hasLength(48));
      expect(missing, 0);
      expect(mismatch, 0);
      expect(duplicate, 0);
      expect(orderMismatch, 0);
      expect(ownerMismatch, 0);
      expect(leakage, 0);
      expect(forbiddenHits, 0);

      final payload = <String, Object?>{
        'schema': 'thai-predictive-narrative-v2-phase2-audit-v1',
        'profiles': cases.length,
        'known': known,
        'unknown': unknown,
        'contextsInCanonical300': contexts.length,
        'targetedContextCoverage': 49,
        'atomsAudited': atoms,
        'monthlyTimelineAvailable': false,
        'missing': missing,
        'mismatch': mismatch,
        'duplicate': duplicate,
        'orderMismatch': orderMismatch,
        'semanticOwnerMismatch': ownerMismatch,
        'knownToUnknownLeakage': leakage,
        'forbiddenReaderCopyHits': forbiddenHits,
        'predictionAccuracyClaimed': false,
      };
      final output = Platform.environment['KNOWME_COPY_LEDGER_OUTPUT'];
      if (output != null && output.isNotEmpty) {
        File(output).writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(payload),
          flush: true,
        );
      }
      // ignore: avoid_print
      print('PREDICTIVE_NARRATIVE_AUDIT ${jsonEncode(payload)}');
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

int _roleRank(NarrativeSectionRole role) => switch (role) {
  NarrativeSectionRole.overview => 0,
  NarrativeSectionRole.past => 1,
  NarrativeSectionRole.current => 2,
  NarrativeSectionRole.work => 3,
  NarrativeSectionRole.finance => 4,
  NarrativeSectionRole.relationship => 5,
  NarrativeSectionRole.health => 6,
  NarrativeSectionRole.support => 7,
  NarrativeSectionRole.horizon => 8,
  NarrativeSectionRole.nextLifePeriod => 9,
  NarrativeSectionRole.summary => 10,
  NarrativeSectionRole.advice => 11,
  NarrativeSectionRole.disclaimer => 12,
  NarrativeSectionRole.omission => 0,
};

bool _listEquals(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}
