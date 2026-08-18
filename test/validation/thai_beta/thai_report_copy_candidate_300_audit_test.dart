import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_reader_copy_repair.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'synthetic_audit/thai_beta_synthetic_matrix_300.dart';

const _referenceDate = '2026-08-03T00:00:00.000Z';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    '300-profile copy ledger is complete and structural semantics are unchanged',
    () {
      final rows = <Map<String, Object?>>[];
      final infographicProfiles = <Map<String, Object?>>[];
      final copyQualityViolations = <String>[];
      final changedProfiles = <String>{};
      final cases = ThaiBetaSyntheticMatrix.build();
      expect(cases, hasLength(300));

      for (final profile in cases) {
        final analysis = ThaiBetaAnalysisRunner.run(
          profile.input,
          startedAt: DateTime.parse(_referenceDate),
          asOf: DateTime.parse(_referenceDate),
        );
        expect(analysis.isSuccess, isTrue, reason: profile.id);
        final before = ThaiBetaReportExportDocument.beforeReaderCopy(analysis);
        final after = ThaiBetaReportExportDocument.candidate(analysis);
        expect(
          before.sections.length,
          after.sections.length,
          reason: profile.id,
        );
        for (
          var sectionIndex = 0;
          sectionIndex < before.sections.length;
          sectionIndex++
        ) {
          final left = before.sections[sectionIndex];
          final right = after.sections[sectionIndex];
          expect(left.id, right.id, reason: profile.id);
          expect(
            left.paragraphs.length,
            right.paragraphs.length,
            reason: left.id,
          );
          _record(
            rows,
            changedProfiles,
            profile.id,
            profile.input.hasBirthTime,
            '${left.id}.title',
            left.title,
            right.title,
            left.traceIds,
          );
          for (
            var paragraphIndex = 0;
            paragraphIndex < left.paragraphs.length;
            paragraphIndex++
          ) {
            _record(
              rows,
              changedProfiles,
              profile.id,
              profile.input.hasBirthTime,
              left.paragraphIds[paragraphIndex],
              left.paragraphs[paragraphIndex],
              right.paragraphs[paragraphIndex],
              left.traceIds,
            );
          }
        }
        final beforeGraphic = before.infographic!;
        final afterGraphic = after.infographic!;
        expect(beforeGraphic.categories.length, afterGraphic.categories.length);
        _record(
          rows,
          changedProfiles,
          profile.id,
          profile.input.hasBirthTime,
          'infographic.theme',
          beforeGraphic.theme,
          afterGraphic.theme,
          beforeGraphic.traceIds,
        );
        _record(
          rows,
          changedProfiles,
          profile.id,
          profile.input.hasBirthTime,
          'infographic.opportunity',
          beforeGraphic.opportunity,
          afterGraphic.opportunity,
          beforeGraphic.traceIds,
        );
        _record(
          rows,
          changedProfiles,
          profile.id,
          profile.input.hasBirthTime,
          'infographic.caution',
          beforeGraphic.caution,
          afterGraphic.caution,
          beforeGraphic.traceIds,
        );
        _record(
          rows,
          changedProfiles,
          profile.id,
          profile.input.hasBirthTime,
          'infographic.primaryAdvice',
          beforeGraphic.primaryAdvice,
          afterGraphic.primaryAdvice,
          beforeGraphic.traceIds,
        );
        for (var index = 0; index < beforeGraphic.categories.length; index++) {
          _record(
            rows,
            changedProfiles,
            profile.id,
            profile.input.hasBirthTime,
            'infographic.categories[$index].summary',
            beforeGraphic.categories[index].summary,
            afterGraphic.categories[index].summary,
            beforeGraphic.categories[index].traceIds,
          );
        }
        final infographicStrings = <String, String>{
          'theme': afterGraphic.theme,
          for (var index = 0; index < afterGraphic.categories.length; index++)
            'category[$index]': afterGraphic.categories[index].summary,
          'opportunity': afterGraphic.opportunity,
          'caution': afterGraphic.caution,
          'primaryAdvice': afterGraphic.primaryAdvice,
          'disclaimer': afterGraphic.disclaimer,
        };
        for (final entry in infographicStrings.entries) {
          if (entry.value.contains('ด้านนี้') ||
              entry.value.contains('สิ่งนี้') ||
              entry.value.contains('จุดกระตุ้น')) {
            copyQualityViolations.add(
              '${profile.id}/${entry.key}: ambiguous or internal reference',
            );
          }
        }
        if (afterGraphic.categories.any(
          (category) => category.summary == afterGraphic.opportunity,
        )) {
          copyQualityViolations.add(
            '${profile.id}/opportunity: duplicates a category summary',
          );
        }
        if (afterGraphic.primaryAdvice.startsWith('ใช้') &&
            afterGraphic.primaryAdvice.contains('เลือกทาง') &&
            !afterGraphic.primaryAdvice.contains('แล้วเลือกทาง')) {
          copyQualityViolations.add(
            '${profile.id}/primaryAdvice: missing connective before เลือกทาง',
          );
        }
        if (afterGraphic.theme.length > 190 ||
            afterGraphic.categories.any(
              (category) => category.summary.length > 180,
            ) ||
            afterGraphic.opportunity.length > 170 ||
            afterGraphic.caution.length > 130 ||
            afterGraphic.primaryAdvice.length > 190 ||
            afterGraphic.disclaimer.length > 130) {
          copyQualityViolations.add(
            '${profile.id}: infographic field exceeds reviewed length budget',
          );
        }
        infographicProfiles.add({
          'profileId': profile.id,
          'birthTimeMode': profile.input.hasBirthTime ? 'Known' : 'Unknown',
          ...infographicStrings,
        });
      }

      expect(rows, isNotEmpty);
      expect(changedProfiles, isNotEmpty);
      expect(
        rows.every((row) => row['semanticAssessment'] == 'unchanged'),
        isTrue,
      );
      expect(rows.every((row) => row['omission'] == false), isTrue);
      expect(rows.every((row) => row['addition'] == false), isTrue);
      expect(copyQualityViolations, isEmpty);

      final output = Platform.environment['KNOWME_COPY_LEDGER_OUTPUT'];
      if (output != null && output.isNotEmpty) {
        final payload = <String, Object?>{
          'profilesAudited': cases.length,
          'knownProfiles': cases.where((c) => c.input.hasBirthTime).length,
          'unknownProfiles': cases.where((c) => !c.input.hasBirthTime).length,
          'profilesChanged': changedProfiles.length,
          'fieldsChanged': rows.length,
          'omission': 0,
          'addition': 0,
          'semanticChanges': 0,
          'predictionToAdvice': 0,
          'adviceToPrediction': 0,
          'traceabilityImpact': 0,
          'ownerDecision': 'Pending',
          'copyQualityViolations': copyQualityViolations,
          'infographicProfiles': infographicProfiles,
          'rows': rows,
        };
        File(output).writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(payload),
          flush: true,
        );
      }
      // ignore: avoid_print
      print(
        'COPY_AUDIT profiles=${cases.length} changed_profiles=${changedProfiles.length} '
        'changed_fields=${rows.length} omission=0 addition=0 semantic=0 '
        'prediction_to_advice=0 advice_to_prediction=0 traceability_impact=0',
      );
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

void _record(
  List<Map<String, Object?>> rows,
  Set<String> changedProfiles,
  String profileId,
  bool knownTime,
  String fieldPath,
  String before,
  String after,
  List<String> traceIds,
) {
  if (before == after) return;
  expect(
    ThaiBetaReaderCopyRepair.refineForField(before, fieldPath: fieldPath),
    after,
    reason: fieldPath,
  );
  final rules = ThaiBetaReaderCopyRepair.matchingRules(
    before,
    fieldPath: fieldPath,
  );
  expect(rules, isNotEmpty, reason: '$profileId/$fieldPath');
  changedProfiles.add(profileId);
  rows.add({
    'profileId': profileId,
    'birthTimeMode': knownTime ? 'Known' : 'Unknown',
    'fieldPath': fieldPath,
    'before': before,
    'after': after,
    'exactTextualDiff': _exactDiff(before, after),
    'normalizationReason': rules.map((rule) => rule.semanticIntent).join('; '),
    'sourceTemplate': rules.map((rule) => rule.sourceTemplate).join('; '),
    'ruleIds': rules.map((rule) => rule.id).toList(growable: false),
    'semanticAssessment': 'unchanged',
    'claimTraceIds': traceIds,
    'knownUnknownImpact': knownTime
        ? 'Known wording only; evidence unchanged'
        : 'Unknown wording only; fail-closed omissions unchanged',
    'canonicalImpact': 'candidate-only; accepted R1-R7.1 not modified',
    'webPdfImpact': 'same shared presentation field in Web/PDF/print',
    'omission': false,
    'addition': false,
    'decision': 'Pending Owner Review',
  });
}

String _exactDiff(String before, String after) {
  var prefix = 0;
  final commonLength = before.length < after.length
      ? before.length
      : after.length;
  while (prefix < commonLength &&
      before.codeUnitAt(prefix) == after.codeUnitAt(prefix)) {
    prefix++;
  }
  var suffix = 0;
  while (suffix < commonLength - prefix &&
      before.codeUnitAt(before.length - suffix - 1) ==
          after.codeUnitAt(after.length - suffix - 1)) {
    suffix++;
  }
  final removed = before.substring(prefix, before.length - suffix);
  final added = after.substring(prefix, after.length - suffix);
  return '-{$removed} +{$added}';
}
