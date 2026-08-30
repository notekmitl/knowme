import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_narrative_plan.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

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

const _psychologyTokens = <String>['บุคลิก', 'นิสัย', 'ตัวตน', 'จิตใจลึก ๆ'];
const _adviceTokens = <String>['คุณควร', 'ควรจะ', 'แนะนำให้', 'ให้คุณลอง'];

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
      var malformedCopy = 0;
      var reflectivePast = 0;
      var psychologyLeakage = 0;
      var adviceRoleLeakage = 0;
      var duplicateMotif = 0;
      var unresolvedEvidence = 0;
      var placeholderRuntimeRefs = 0;
      var sequenceOnlyOwners = 0;
      var legacyFallback = 0;
      var fixtureSpecialPath = 0;
      var unsupportedTiming = 0;
      final rawRecords = <Map<String, Object?>>[];
      final contextSamples = <String, Map<String, Object?>>{};

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
        if (plan.isKnownTime) {
          contextSamples.putIfAbsent(
            plan.contextId,
            () => {
              'sample_source': 'canonical-300',
              'profile_id': profile.id,
              'context_id': plan.contextId,
              'known_time': true,
              'generation_path': plan.generationPath,
              'language_content_review_only': true,
              'plan': plan.toMap(),
            },
          );
        }
        atoms += plan.atoms.length;
        expect(second.narrativePlan!.toMap(), plan.toMap(), reason: profile.id);
        expect(second.fullPlainText, first.fullPlainText, reason: profile.id);
        expect(plan.sections, isNotEmpty, reason: profile.id);
        expect(plan.monthlyTimelineAvailable, isFalse, reason: profile.id);

        final projectedIds = plan.sections
            .where((section) => section.role != NarrativeSectionRole.disclaimer)
            .map((section) => 'predictive-${section.id}')
            .toList(growable: false);
        final documentIds = first.sections
            .where((section) => section.id.startsWith('predictive-'))
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

        legacyFallback += plan.legacyFallbackInvocations;
        fixtureSpecialPath += plan.fixtureSpecialInvocations;
        unresolvedEvidence += plan.unresolvedEvidenceRefs.length;
        final detailedOwners = plan.atoms
            .where((atom) => atom.role == NarrativeAtomRole.prediction)
            .map((atom) => atom.owner.id)
            .toList(growable: false);
        duplicateMotif += detailedOwners.length - detailedOwners.toSet().length;

        for (final section in plan.sections) {
          for (final atom in section.atoms) {
            final text = atom.readerText.trim();
            final malformedHits = <String>[
              if (text.isEmpty) 'empty',
              if (text.contains('  ')) 'double-space',
              if (RegExp(r'\s+[,.!?。]').hasMatch(text))
                'space-before-punctuation',
            ];
            final predictionText = text.replaceAll('อาจารย์', '');
            final predictionHits = atom.role == NarrativeAtomRole.prediction
                ? [
                    ..._forbidden.where(predictionText.contains),
                    if (predictionText.contains('อาจ')) 'อาจ',
                  ]
                : const <String>[];
            final reflectiveHits = section.role == NarrativeSectionRole.past
                ? [
                    if (text.contains('ลองนึกย้อน')) 'ลองนึกย้อน',
                    if (text.contains('ลองทบทวน')) 'ลองทบทวน',
                    if (text.contains('?')) 'question-mark',
                  ]
                : const <String>[];
            final psychologyHits = atom.role == NarrativeAtomRole.prediction
                ? _psychologyTokens.where(text.contains).toList()
                : const <String>[];
            final adviceHits = atom.role == NarrativeAtomRole.prediction
                ? _adviceTokens.where(text.contains).toList()
                : const <String>[];
            final unresolved = atom.evidence.refs
                .where((ref) => !plan.resolvesEvidenceRef(ref))
                .toList(growable: false);
            final placeholderRefs = atom.evidence.refs
                .where((ref) => ref.startsWith('runtime.'))
                .toList(growable: false);
            final sequenceOwners =
                RegExp(r'^CTX-[0-9]+$').hasMatch(atom.owner.id)
                ? [atom.owner.id]
                : const <String>[];
            final timingHits = atom.role == NarrativeAtomRole.prediction
                ? RegExp(
                    r'(มกราคม|กุมภาพันธ์|มีนาคม|เมษายน|พฤษภาคม|มิถุนายน|กรกฎาคม|กันยายน|ตุลาคม|พฤศจิกายน|ธันวาคม|ต้นปี|กลางปี|ปลายปี)',
                  ).allMatches(text).map((match) => match.group(0)!).toList()
                : const <String>[];
            malformedCopy += malformedHits.length;
            forbiddenHits += predictionHits.length;
            reflectivePast += reflectiveHits.length;
            psychologyLeakage += psychologyHits.length;
            adviceRoleLeakage += adviceHits.length;
            unresolvedEvidence += unresolved.length;
            placeholderRuntimeRefs += placeholderRefs.length;
            sequenceOnlyOwners += sequenceOwners.length;
            unsupportedTiming += timingHits.length;
            rawRecords.add({
              'profile_id': profile.id,
              'context_id': plan.contextId,
              'generation_path': plan.generationPath,
              'section': section.role.name,
              'claim_id': atom.id,
              'semantic_owner_id': atom.owner.id,
              'evidence_refs': atom.evidence.refs,
              'role': atom.role.name,
              'rendered_text': atom.readerText,
              'malformed_copy_hits': malformedHits,
              'forbidden_prediction_hits': predictionHits,
              'reflective_past_hits': reflectiveHits,
              'psychology_leakage': psychologyHits,
              'advice_role_leakage': adviceHits,
              'duplicate_motif_hits': 0,
              'unresolved_evidence_hits': unresolved,
              'placeholder_runtime_ref_hits': placeholderRefs,
              'sequence_only_semantic_owner_hits': sequenceOwners,
              'legacy_fallback_hits': plan.legacyFallbackInvocations,
              'fixture_special_path_hits': plan.fixtureSpecialInvocations,
              'unsupported_timing_hits': timingHits,
            });
          }
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

        if (plan.isKnownTime) {
          known++;
          contexts.add(plan.contextId);
          if (plan.atoms.whereType<PredictionAtom>().isEmpty) missing++;
        } else {
          unknown++;
          if (plan.atoms.whereType<PredictionAtom>().isNotEmpty) leakage++;
          final planText = [
            plan.title,
            plan.subtitle,
            ...plan.atoms.map((atom) => atom.readerText),
          ].join('\n');
          for (final token in const [
            'ลัคนา',
            'เรือน',
            'วันทางโหราศาสตร์',
            'คำทำนาย 12 เดือนข้างหน้า',
          ]) {
            if (planText.contains(token)) leakage++;
          }
          if (!planText.contains('แทนการเดาข้อมูลที่ไม่มี')) leakage++;
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
      expect(malformedCopy, 0);
      expect(reflectivePast, 0);
      expect(psychologyLeakage, 0);
      expect(adviceRoleLeakage, 0);
      expect(duplicateMotif, 0);
      expect(unresolvedEvidence, 0);
      expect(placeholderRuntimeRefs, 0);
      expect(sequenceOnlyOwners, 0);
      expect(legacyFallback, 0);
      expect(fixtureSpecialPath, 0);
      expect(unsupportedTiming, 0);

      final supplemental = PredictiveNarrativePlan.fromAnalysis(
        ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: 'Context',
            lastName: 'Coverage',
            birthDate: DateTime(1986, 4, 18),
            birthHour: 12,
            province: 'กรุงเทพมหานคร',
            provinceKey: 'bangkok',
          ),
          asOf: DateTime.parse(_referenceDate),
        ),
      );
      final totalContexts = {...contexts, supplemental.contextId};
      expect(totalContexts, hasLength(49));
      contextSamples.putIfAbsent(
        supplemental.contextId,
        () => {
          'sample_source': 'supplemental-targeted',
          'profile_id': 'supplemental-context-49',
          'context_id': supplemental.contextId,
          'known_time': supplemental.isKnownTime,
          'generation_path': supplemental.generationPath,
          'language_content_review_only': true,
          'plan': supplemental.toMap(),
        },
      );
      expect(contextSamples, hasLength(49));

      final payload = <String, Object?>{
        'schema': 'thai-predictive-narrative-v2-phase2-audit-v1',
        'profiles': cases.length,
        'known': known,
        'unknown': unknown,
        'canonical_profiles': cases.length,
        'canonical_known': known,
        'canonical_unknown': unknown,
        'contexts_reached_by_canonical_300': contexts.length,
        'supplemental_targeted_contexts': 1,
        'total_contexts_covered': totalContexts.length,
        'atomsAudited': atoms,
        'monthlyTimelineAvailable': false,
        'missing': missing,
        'mismatch': mismatch,
        'duplicate': duplicate,
        'orderMismatch': orderMismatch,
        'semanticOwnerMismatch': ownerMismatch,
        'knownToUnknownLeakage': leakage,
        'forbiddenReaderCopyHits': forbiddenHits,
        'malformed_copy': malformedCopy,
        'reflective_past': reflectivePast,
        'psychology_leakage': psychologyLeakage,
        'advice_prediction_leakage': adviceRoleLeakage,
        'duplicate_detailed_owner': duplicateMotif,
        'unresolved_evidence': unresolvedEvidence,
        'placeholder_runtime_refs': placeholderRuntimeRefs,
        'sequence_only_semantic_owners': sequenceOnlyOwners,
        'legacy_fallback': legacyFallback,
        'fixture_special_path': fixtureSpecialPath,
        'unsupported_timing': unsupportedTiming,
        'predictionAccuracyClaimed': false,
      };
      final output = Platform.environment['KNOWME_COPY_LEDGER_OUTPUT'];
      if (output != null && output.isNotEmpty) {
        File(output).writeAsStringSync(
          const JsonEncoder.withIndent(
            ' ',
          ).convert({
            'summary': payload,
            'context_samples': contextSamples.values.toList(growable: false),
            'records': rawRecords,
          }),
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
