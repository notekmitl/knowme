import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_narrative_plan.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../synthetic_audit/thai_beta_synthetic_matrix_300.dart';

const _forbiddenReaderPhrases = <String>[
  'อาจ',
  'มีแนวโน้มว่าอาจ',
  'ลองนึกย้อน',
  'ลองทบทวน',
];

void main() {
  group('Predictive Narrative V2 accepted Candidate 0011', () {
    test('Known normalized output exactly matches accepted fixture oracle', () {
      final analysis = _owner(known: true, minute: 3);
      final document = ThaiBetaReportExportDocument.candidate(analysis);
      final plan = document.narrativePlan!;

      expect(plan.contextId, 'mahabhut2537.rem0.saturday');
      expect(plan.monthlyTimelineAvailable, isFalse);
      expect(plan.atoms.whereType<PredictionAtom>(), hasLength(22));
      expect(
        _normalizedPlanLines(plan),
        _acceptedMarkdownLines(
          'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md',
        ),
      );
    });

    test('Unknown normalized output exactly matches fail-closed oracle', () {
      final analysis = _owner(known: false);
      final document = ThaiBetaReportExportDocument.candidate(analysis);
      final plan = document.narrativePlan!;

      expect(plan.contextId, 'unknown-time');
      expect(plan.isKnownTime, isFalse);
      expect(plan.atoms.whereType<OmissionAtom>(), hasLength(1));
      expect(plan.atoms.whereType<DisclosureAtom>(), hasLength(1));
      expect(plan.atoms.whereType<PredictionAtom>(), isEmpty);
      expect(
        _normalizedPlanLines(plan),
        _acceptedMarkdownLines(
          'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011_UNKNOWN.md',
        ),
      );
    });

    test('semantic owners are unique and advice stays outside prediction', () {
      final plan = PredictiveNarrativePlan.fromAnalysis(
        _owner(known: true, minute: 3),
      );
      final ownerIds = plan.atoms.map((atom) => atom.owner.id).toList();
      expect(ownerIds.toSet(), hasLength(ownerIds.length));
      expect(plan.claimSpecs, hasLength(plan.atoms.length));
      for (var index = 0; index < plan.atoms.length; index++) {
        final atom = plan.atoms[index];
        final spec = plan.claimSpecs[index];
        expect(spec.claimId, atom.id);
        expect(spec.semanticOwnerId, atom.owner.id);
        expect(spec.contextSelector, plan.contextId);
        expect(spec.periodSelector, atom.period.id);
        expect(spec.domain, atom.domain);
        expect(spec.role, atom.role);
        expect(spec.readerCopy, atom.readerText);
        expect(spec.compactCopy, atom.compactText);
        expect(spec.eligibility, atom.eligibility);
        expect(spec.evidenceRefs, atom.evidence.refs);
        expect(spec.semanticOwnerId, isNot(matches(RegExp(r'^CTX-[0-9]+$'))));
      }
      expect(plan.unresolvedEvidenceRefs, isEmpty);
      expect(plan.resolvesEvidenceRef('runtime.fixture.current'), isFalse);
      expect(
        plan.resolvesEvidenceRef(
          'placement.mahabhut2537.rem0.saturday.sun.999_1000',
        ),
        isFalse,
      );
      expect(
        plan.sections
            .where((section) => section.role != NarrativeSectionRole.advice)
            .expand((section) => section.atoms)
            .whereType<AdviceAtom>(),
        isEmpty,
      );
      expect(plan.atoms.whereType<DisclosureAtom>(), hasLength(1));
    });

    test(
      'forbidden hedging, past-question and methodology copy stays absent',
      () {
        for (final known in [true, false]) {
          final plan = PredictiveNarrativePlan.fromAnalysis(
            _owner(known: known, minute: 3),
          );
          final predictionText = plan.sections
              .where(
                (section) =>
                    section.role != NarrativeSectionRole.advice &&
                    section.role != NarrativeSectionRole.disclaimer &&
                    section.role != NarrativeSectionRole.omission,
              )
              .expand((section) => section.atoms)
              .map((atom) => atom.readerText)
              .join('\n');
          for (final phrase in _forbiddenReaderPhrases) {
            expect(predictionText, isNot(contains(phrase)));
          }
          expect(predictionText, isNot(contains('วิธีคำนวณ')));
          expect(predictionText, isNot(contains('?')));
        }
      },
    );

    test('generic realization never mutates words containing อาจ', () {
      const teacher = 'อาจารย์มอบหมายงานที่ชัดเจน';
      expect(teacher, contains('อาจารย์'));
      expect(teacher.replaceAll('อาจ', ''), isNot(equals(teacher)));
      for (final plan in [
        PredictiveNarrativePlan.fromAnalysis(_owner(known: true, minute: 3)),
        PredictiveNarrativePlan.fromAnalysis(_owner(known: true, minute: 35)),
      ]) {
        expect(
          plan.generationPath,
          startsWith('source-authorized-catalog-v1:'),
        );
        expect(plan.legacyFallbackInvocations, 0);
        expect(plan.fixtureSpecialInvocations, 0);
        for (final atom in plan.atoms) {
          expect(atom.readerText, isNot(contains('  ')));
          expect(atom.readerText, isNot(matches(RegExp(r'\s+[,.!?。]'))));
          expect(atom.readerText.trim(), isNotEmpty);
        }
      }
    });

    test('runtime source has no OR1 context promotion or prose dispatcher', () {
      final source = File(
        'lib/features/thai_beta/application/narrative/'
        'predictive_narrative_plan.dart',
      ).readAsStringSync();
      expect(source, isNot(contains('_acceptedCorpusPromotionByContext')));
      expect(source, isNot(contains('_realizePromotedCorpusClaims')));
      expect(source, isNot(contains('_acceptedKnownPlan')));
      expect(source, isNot(contains("replaceAll('อาจ', '')")));
      expect(
        source,
        isNot(contains('contextId == mahabhut2537.rem0.saturday')),
      );
    });

    test(
      'placement facts cannot own predictions and refs are not self-attested',
      () {
        final plan = PredictiveNarrativePlan.fromAnalysis(
          _owner(known: true, minute: 3),
        );
        final placement = plan
            .evidenceCatalog['placement.mahabhut2537.rem0.saturday.venus.42_62']!;
        final placementValidation = plan.evidenceCatalog.validateSelection(
          record: placement,
          contextId: plan.contextId,
          currentAge: 44,
          asOf: DateTime(2026, 8, 29),
          domain: DomainScope.finance,
          chronology: ClaimChronology.current,
        );
        expect(placementValidation.wrongClaimType, isTrue);
        expect(placementValidation.placementPromotedToPrediction, isTrue);

        final readerClaim = plan.evidenceCatalog['RC11-K-WORK-01']!;
        final missingDependency = plan.evidenceCatalog
            .without({'SDC-R0-SAT-42_62-WORK'})
            .validateSelection(
              record: readerClaim,
              contextId: plan.contextId,
              currentAge: 44,
              asOf: DateTime(2026, 8, 29),
              domain: DomainScope.work,
              chronology: ClaimChronology.current,
            );
        expect(missingDependency.isValid, isFalse);
        expect(
          missingDependency.unresolvedRefs,
          contains('SDC-R0-SAT-42_62-WORK'),
        );
        expect(
          plan.provenance.every((entry) => entry.evidenceResolution.isValid),
          isTrue,
        );
      },
    );
  });

  group('fixture separation and surface parity', () {
    test('00:03 and 00:35 retain distinct canonical ascendants', () {
      final known0003 = ThaiBetaReportExportDocument.candidate(
        _owner(known: true, minute: 3),
      );
      final known0035 = ThaiBetaReportExportDocument.candidate(
        _owner(known: true, minute: 35),
      );
      final subtitle0003 = known0003.narrativePlan!.subtitle;
      final subtitle0035 = known0035.narrativePlan!.subtitle;
      expect(subtitle0003, contains('ลัคนาราศีกุมภ์ 9°24′'));
      expect(subtitle0035, contains('ลัคนาราศีกุมภ์ 19°19′'));
      expect(subtitle0003, isNot(equals(subtitle0035)));
      expect(subtitle0003, contains('วันเสาร์'));
      expect(subtitle0035, contains('วันเสาร์'));
    });

    test('Unknown leaks no ascendant, house, Thai day or Known atom', () {
      final known = PredictiveNarrativePlan.fromAnalysis(
        _owner(known: true, minute: 3),
      );
      final unknown = PredictiveNarrativePlan.fromAnalysis(
        _owner(known: false),
      );
      final unknownText = [
        unknown.title,
        unknown.subtitle,
        ...unknown.atoms.map((atom) => atom.readerText),
      ].join('\n');
      expect(unknownText, isNot(contains('ลัคนา')));
      expect(unknownText, isNot(contains('เรือน')));
      expect(unknownText, isNot(contains('วันทางโหราศาสตร์')));
      expect(
        unknown.atoms
            .map((atom) => atom.owner.id)
            .toSet()
            .intersection(known.atoms.map((atom) => atom.owner.id).toSet()),
        isEmpty,
      );
    });

    test(
      'all rendered document fields and infographic trace back to one plan',
      () {
        for (final known in [true, false]) {
          final document = ThaiBetaReportExportDocument.candidate(
            _owner(known: known, minute: 3),
          );
          final plan = document.narrativePlan!;
          final rendered = <String>[
            for (final section in document.sections.where(
              (section) => section.id.startsWith('predictive-'),
            )) ...[section.title, ...section.paragraphs],
          ];
          final projectedWithoutDisclosure = <String>[
            for (final section in plan.sections.where(
              (section) => section.role != NarrativeSectionRole.disclaimer,
            )) ...[
              section.title,
              for (final block in section.blocks) ...[
                ?block.heading,
                ...block.atoms.map((atom) => atom.readerText),
              ],
            ],
          ];
          expect(rendered, projectedWithoutDisclosure);
          expect(
            document.sections.map((section) => section.title),
            containsAllInOrder([
              'ส่วนที่ 1 · พื้นดวงของคุณ',
              if (known) 'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
              if (known) 'ส่วนที่ 3 · แนวโน้มข้างหน้า',
              'ส่วนที่ 4 · ที่มาและข้อจำกัด',
            ]),
          );
          expect(document.infographic, isNotNull);
          expect(document.infographic!.monthlyTimelineAvailable, isFalse);
          final ownerIds = plan.atoms.map((atom) => atom.owner.id).toSet();
          expect(
            document.infographic!.traceIds.where(ownerIds.contains).toSet(),
            ownerIds,
          );
        }
      },
    );
  });

  test('full report preserves non-predictive baseline topology exactly', () {
    for (final known in [true, false]) {
      final analysis = _owner(known: known, minute: 3);
      final baseline = ThaiBetaReportExportDocument.fromAnalysis(
        analysis,
        applyReaderCopy: true,
      );
      final candidate = ThaiBetaReportExportDocument.candidate(analysis);
      final baselinePart2 = baseline.sections.indexWhere(
        (section) =>
            section.title == 'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
      );
      final baselinePart3 = baseline.sections.indexWhere(
        (section) => section.title == 'ส่วนที่ 3 · แนวโน้มข้างหน้า',
      );
      final baselinePart4 = baseline.sections.indexWhere(
        (section) => section.title == 'ส่วนที่ 4 · ที่มาและข้อจำกัด',
      );
      expect(baselinePart4, greaterThanOrEqualTo(0));
      final predictiveStart = [baselinePart2, baselinePart3]
          .where((index) => index >= 0)
          .fold<int>(
            baselinePart4,
            (best, index) => index < best ? index : best,
          );
      final expectedNonPredictive = [
        ...baseline.sections.take(predictiveStart),
        ...baseline.sections.skip(baselinePart4),
      ].map(_sectionSnapshot).toList(growable: false);
      final actualNonPredictive = candidate.sections
          .where(
            (section) =>
                !section.id.startsWith('predictive-') &&
                section.title !=
                    'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน' &&
                section.title != 'ส่วนที่ 3 · แนวโน้มข้างหน้า',
          )
          .map(_sectionSnapshot)
          .toList(growable: false);
      expect(
        actualNonPredictive,
        expectedNonPredictive,
        reason: 'known=$known',
      );
      expect(candidate.fullPlainText, contains('ส่วนที่ 1 · พื้นดวงของคุณ'));
      expect(candidate.fullPlainText, contains('ส่วนที่ 4 · ที่มาและข้อจำกัด'));
      expect(candidate.fullPlainText, contains('ที่มาของผลวิเคราะห์'));
      expect(candidate.fullPlainText, contains('ข้อจำกัด'));
      if (!known) {
        expect(candidate.sections.length, greaterThan(3));
        expect(candidate.fullPlainText, contains('แทนการเดาข้อมูลที่ไม่มี'));
      }
    }
  });

  test(
    '300 profiles are deterministic and targeted audit covers 49 contexts',
    () {
      final contexts = <String>{};
      for (final synthetic in ThaiBetaSyntheticMatrix.build()) {
        final first = PredictiveNarrativePlan.fromAnalysis(
          ThaiBetaAnalysisRunner.run(
            synthetic.input,
            asOf: DateTime(2026, 8, 29),
          ),
        );
        final second = PredictiveNarrativePlan.fromAnalysis(
          ThaiBetaAnalysisRunner.run(
            synthetic.input,
            asOf: DateTime(2026, 8, 29),
          ),
        );
        expect(second.toMap(), first.toMap(), reason: synthetic.id);
        if (first.isKnownTime) contexts.add(first.contextId);
        expect(first.monthlyTimelineAvailable, isFalse);
        expect(
          first.generationPath,
          startsWith('source-authorized-catalog-v1:'),
        );
        expect(first.legacyFallbackInvocations, 0);
        expect(first.fixtureSpecialInvocations, 0);
        expect(first.unresolvedEvidenceRefs, isEmpty, reason: synthetic.id);
        expect(
          first.atoms.map((atom) => atom.readerText).join('\n'),
          isNot(contains('ในช่วงเดียวกัน ในรอบ 12 เดือนนี้')),
          reason: '${synthetic.id} must not repeat the horizon lead-in',
        );
        expect(
          first.atoms.where(
            (atom) => atom.readerText.trim().endsWith('รับภาระเพ'),
          ),
          isEmpty,
          reason: '${synthetic.id} must not cut a Thai word in its summary',
        );
        expect(
          first.atoms.map((atom) => atom.owner.id).toSet(),
          hasLength(first.atoms.length),
        );
      }
      // The canonical 300 matrix reaches 48/49 contexts. This source-derived
      // remainder-4 Friday case closes the one missing selector without changing
      // the shared population matrix or duplicating its 300-profile audit.
      final targeted = PredictiveNarrativePlan.fromAnalysis(
        ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: 'Context',
            lastName: 'Coverage',
            birthDate: DateTime(1986, 4, 18),
            birthHour: 12,
            province: 'กรุงเทพมหานคร',
            provinceKey: 'bangkok',
          ),
          asOf: DateTime(2026, 8, 29),
        ),
      );
      contexts.add(targeted.contextId);
      expect(
        targeted.generationPath,
        startsWith('source-authorized-catalog-v1:'),
      );
      expect(targeted.legacyFallbackInvocations, 0);
      expect(targeted.fixtureSpecialInvocations, 0);
      expect(targeted.unresolvedEvidenceRefs, isEmpty);
      final expectedContexts = <String>{
        for (var remainder = 0; remainder < 7; remainder++)
          for (final weekday in const [
            'sunday',
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
          ])
            'mahabhut2537.rem$remainder.$weekday',
      };
      expect(
        expectedContexts.difference(contexts),
        isEmpty,
        reason: 'every one of the 49 runtime context selectors must be reached',
      );
    },
  );

  test(
    'accepted fixture remains on generic V2 path when age advances to 45',
    () {
      final age44 = PredictiveNarrativePlan.fromAnalysis(
        _owner(known: true, minute: 3),
      );
      final age45 = PredictiveNarrativePlan.fromAnalysis(
        ThaiBetaAnalysisRunner.run(
          _ownerInput(known: true, minute: 3),
          asOf: DateTime(2027, 8, 29),
        ),
      );
      expect(age44.generationPath, startsWith('source-authorized-catalog-v1:'));
      expect(age45.generationPath, startsWith('source-authorized-catalog-v1:'));
      expect(age45.legacyFallbackInvocations, 0);
      expect(age45.fixtureSpecialInvocations, 0);
      expect(
        age45.provenance.any(
          (entry) => entry.templateId == 'candidate-0011-exact',
        ),
        isFalse,
      );
      expect(
        age45.sections
            .singleWhere((s) => s.role == NarrativeSectionRole.current)
            .title,
        contains('45'),
      );
    },
  );

  test(
    'rem0 Saturday age boundaries classify every selected claim correctly',
    () {
      const ages = [10, 11, 20, 29, 30, 41, 42, 44, 45, 62, 63, 79, 80];
      for (final age in ages) {
        final analysis = ThaiBetaAnalysisRunner.run(
          _ownerInput(known: true, minute: 3),
          asOf: DateTime(1982 + age, 8, 29),
        );
        final plan = PredictiveNarrativePlan.fromAnalysis(analysis);
        expect(
          plan.contextId,
          'mahabhut2537.rem0.saturday',
          reason: 'age=$age',
        );
        expect(plan.legacyFallbackInvocations, 0, reason: 'age=$age');
        expect(plan.fixtureSpecialInvocations, 0, reason: 'age=$age');
        expect(plan.unresolvedEvidenceRefs, isEmpty, reason: 'age=$age');
        for (final entry in plan.provenance.where(
          (item) =>
              item.source != GenerationSource.structuralSummary &&
              item.source != GenerationSource.disclosure,
        )) {
          expect(entry.evidenceResolution.isValid, isTrue, reason: 'age=$age');
        }
        for (final section in plan.sections) {
          for (final atom in section.atoms.whereType<PredictionAtom>()) {
            final provenance = plan.provenance.singleWhere(
              (entry) => entry.atomId == atom.id,
            );
            final record = plan.evidenceCatalog[provenance.selectedClaimId]!;
            final chronology = record.chronologyAt(age);
            if (section.role == NarrativeSectionRole.past) {
              expect(chronology, ClaimChronology.past, reason: 'age=$age');
            }
            if (section.role == NarrativeSectionRole.current) {
              expect(chronology, ClaimChronology.current, reason: 'age=$age');
            }
            if (section.role == NarrativeSectionRole.nextLifePeriod) {
              expect(chronology, ClaimChronology.future, reason: 'age=$age');
              final nextPlacement = plan.evidenceCatalog.nextPlacement(
                plan.contextId,
                age,
              );
              expect(nextPlacement, isNotNull, reason: 'age=$age');
              final nextRange = nextPlacement!.ageRanges.first;
              expect(
                record.ageRanges.any(
                  (range) =>
                      range.$1 == nextRange.$1 && range.$2 == nextRange.$2,
                ),
                isTrue,
                reason: 'age=$age claim=${record.id}',
              );
            }
          }
        }
      }
    },
  );
}

ThaiBetaAnalysis _owner({required bool known, int minute = 3}) =>
    ThaiBetaAnalysisRunner.run(
      _ownerInput(known: known, minute: minute),
      asOf: DateTime(2026, 8, 29),
    );

ThaiBetaInput _ownerInput({required bool known, int minute = 3}) =>
    ThaiBetaInput(
      firstName: 'Acceptance',
      lastName: 'Fixture',
      birthDate: DateTime(1982, 6, 6),
      birthHour: known ? 0 : null,
      birthMinute: known ? minute : 0,
      birthTimeUnknown: !known,
      province: 'เชียงใหม่',
      provinceKey: 'chiang mai',
      gender: 'ชาย',
    );

List<String> _normalizedPlanLines(PredictiveNarrativePlan plan) => [
  plan.title,
  ...plan.subtitle.split('\n'),
  for (final section in plan.sections) ...[
    section.title,
    for (final block in section.blocks) ...[
      ?block.heading,
      ...block.atoms.map((atom) => atom.readerText),
    ],
  ],
].map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

Map<String, Object?> _sectionSnapshot(ThaiBetaReportExportSection section) => {
  'title': section.title,
  'paragraphs': section.paragraphs,
  'kind': section.kind.name,
  'fieldSource': section.fieldSource,
  'visibilityRule': section.visibilityRule,
  'knownUnknownRule': section.knownUnknownRule,
  'traceIds': section.traceIds,
};

List<String> _acceptedMarkdownLines(String path) {
  final source = File(path).readAsStringSync();
  final start = source.indexOf('Reader-facing candidate begins below.');
  final end = source.indexOf('Reader-facing candidate ends above.');
  expect(start, greaterThanOrEqualTo(0), reason: path);
  expect(end, greaterThan(start), reason: path);
  return source
      .substring(start, end)
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where(
        (line) =>
            line.isNotEmpty &&
            line != 'Reader-facing candidate begins below.' &&
            !line.startsWith('<!--'),
      )
      .map((line) => line.replaceFirst(RegExp(r'^#{1,6}\s+'), ''))
      .map((line) => line.replaceAll('<br>', ''))
      .toList(growable: false);
}
