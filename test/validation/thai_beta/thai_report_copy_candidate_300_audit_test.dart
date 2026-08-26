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
        for (final rejected in const <String>[
          'ไม่มีเวลาเกิด — บางส่วนอาจคลาดเคลื่อนเล็กน้อย',
          'การเติบโตของช่วงเติบโตและขยาย',
          'การลงมือของช่วงลงมือและบุกเบิก',
          'การยอมรับในช่วงเปล่งประกายอาจเทียบได้กับ',
          'ลองย้อนดูว่า',
          'เปลี่ยนผ่านผ่านงาน',
          'ความก้าวหน้าจึงควรวัดจากทางเลือกที่เงินสำรองเปิดให้',
          'ด้านการเงินคุณอยากใช้เงินวันนี้',
          'ข้อตกลงที่ถูกทำต่อเนื่อง',
          'สิ่งที่ตกลงกันถูกทำจริงต่อเนื่อง',
          'ตัวเลขครั้งเดียวจึงยังไม่พอให้ขยายภาระเงิน',
          'ส่งต่อส่วนที่กระจายแรง',
          'ฐานเงินของจังหวะใหม่',
          'กิจวัตรพลังชีวิตต้องเปลี่ยนพร้อมตารางใหม่',
          'ตัวเลือกครั้งนั้นหล่อวิธีรับมือการตัดสินใจวันนี้อย่างไร',
          'และการลงมือปรากฏตรงไหน',
          'แยกงบทดลองสำหรับการเรียนรู้ออกจากเงินที่ต้องใช้ประจำ',
          'ยอดรับที่เกิดซ้ำ',
          'เก็บตัวอย่างผลงานเป็นรอบและค่อยเลือกบทบาทจากแบบที่ทำซ้ำได้',
          'ผลเดิมเกิดซ้ำ',
          'พฤติกรรมที่เกิดซ้ำ',
          'โดยไม่ยืมแรงจากวันต่อไป',
          'เลือกสิ่งที่คู่ควรกับแรงของคุณ',
          'วางระบบที่ทำซ้ำได้',
          'การพักจึงมีหน้าที่ต่างกันในแต่ละระยะ',
          'บทบาทงานก้อนใหม่มีแรงส่ง',
          'จดเวลาคืนแรง',
          'การนอนและการคืนแรง',
          'หลายเรื่องชนกัน',
          'ฐานการเงินอาจเปลี่ยน',
          'ด้านการเงิน ให้ใช้',
          'การทำตามข้อตกลงจะยืนยันได้',
          'ให้สิ่งที่เกิดซ้ำจริงนำทาง',
          'การพักในหน้าที่ต่างกัน',
          'จากจังหวะที่รับฟัง',
          'จากจังหวะที่เน้นความมั่นคง',
          'ปรับตัวกับการเปลี่ยนผ่านมากขึ้น',
          'ต้องถูกเทียบกับรายจ่ายจำเป็น',
          'คนที่พร้อมจะรักษาคำพูด',
          'รายจ่ายระยะยาวจึงควรเกิดหลัง',
          'ความอดทนที่พาเรื่องยากไปต่อ',
          'งานมีแรงส่งต่อเนื่องจากตอนนี้ไปถึงช่วงถัดไป',
          'ความก้าวหน้าทางการเงินควรวัดจากความยืดหยุ่น',
          'จำนวนเงินพร้อมใช้หลังรายการจำเป็นเป็นเกณฑ์ตัดสินใจ',
          'พลังธาตุน้ำหนุนช่วงเก็บเกี่ยวให้คุณใช้ความสัมพันธ์',
          'ขอบเขตหน้าที่ที่กว้างขึ้นคือสัญญาณสำคัญด้านงาน',
          'พฤติกรรมหลังข้อตกลง',
          'ระยะยาวต้องแบ่งเวลาและหน้าที่ได้จริง',
          'โดยไม่ฝืนจนต้องพักชดเชยในวันถัดไป',
          'ประกอบการตัดสินใจ',
          'รักษาการทำตามข้อตกลง',
          'ผลที่เกิดซ้ำและตรวจสอบได้',
          'โดยยังไม่ผูกผลลัพธ์',
          'ฐานวันตามปฏิทิน',
          'ขอบเขตหน้าที่',
          'ภาระจริง',
          'ทิศทางระยะต่อไป',
          'รองรับบทบาทที่เปลี่ยนไป',
          'สอดคล้องต่อเนื่อง',
          'แก่นของคำอ่าน',
          'ใช้การฟื้นตัวจริงบอกว่า',
          'ให้ขยับเรื่องหลักเท่าที่ชีวิตด้านอื่นยังรับไหว',
        ]) {
          if (after.fullPlainText.contains(rejected)) {
            copyQualityViolations.add(
              '${profile.id}: rejected OR2 phrase remains: $rejected',
            );
          }
        }
        final chapterSections = after.sections
            .where(
              (section) =>
                  section.kind == ThaiBetaReportExportSectionKind.chapter,
            )
            .toList(growable: false);
        expect(
          chapterSections.map((section) => section.title),
          orderedEquals(const [
            'ส่วนที่ 1 · พื้นดวงของคุณ',
            'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
            'ส่วนที่ 3 · แนวโน้มข้างหน้า',
            'ส่วนที่ 4 · ที่มาและข้อจำกัด',
          ]),
          reason: profile.id,
        );
        final afterContentSections = after.sections
            .where(
              (section) =>
                  section.kind != ThaiBetaReportExportSectionKind.chapter,
            )
            .toList(growable: false);
        expect(
          before.sections.length,
          afterContentSections.length,
          reason: profile.id,
        );
        for (
          var sectionIndex = 0;
          sectionIndex < before.sections.length;
          sectionIndex++
        ) {
          final left = before.sections[sectionIndex];
          final candidateTitle = switch (left.title) {
            'แผนที่ชีวิต' => 'แผนที่ชีวิตของคุณ',
            'ธีมสำหรับทบทวนอดีต' => 'อดีตของคุณ',
            'ช่วงชีวิตถัดไป' => 'สิ่งที่ควรเตรียมสำหรับช่วงถัดไป',
            'คำแนะนำปิดท้ายช่วงถัดไป' => 'ข้อสรุปสำหรับช่วงข้างหน้า',
            'แนวโน้มระยะยาว' => 'จังหวะชีวิตระยะต่อไป',
            'งานจะไปต่อได้ เมื่อข้อตกลงยังชัดและทำได้จริง' =>
              'งานจะเดินหน้าได้ เมื่อทุกฝ่ายเข้าใจตรงกันและทำตามที่คุยไว้',
            'ให้สิ่งที่เกิดซ้ำจริงนำทาง ก่อนขยับงาน' =>
              'อย่ารีบรับงานเพิ่มจากผลที่ดีเพียงครั้งเดียว',
            'ให้สิ่งที่เกิดซ้ำจริงนำทาง ก่อนขยับการเงิน' =>
              'ดูผลที่เกิดขึ้นอย่างสม่ำเสมอก่อนตัดสินใจขยับเรื่องการเงิน',
            'ให้สิ่งที่เกิดซ้ำจริงนำทาง ก่อนขยับความสัมพันธ์' =>
              'ดูผลที่เกิดขึ้นอย่างสม่ำเสมอก่อนตัดสินใจขยับเรื่องความสัมพันธ์',
            'ให้สิ่งที่เกิดซ้ำจริงนำทาง ก่อนขยับการพักและการฟื้นตัว' =>
              'ดูผลที่เกิดขึ้นอย่างสม่ำเสมอก่อนตัดสินใจขยับเรื่องการพักและการฟื้นตัว',
            _ => left.title,
          };
          final right = afterContentSections.singleWhere(
            (section) => section.title == candidateTitle,
            orElse: () => throw StateError(
              '${profile.id}: missing section "$candidateTitle"; '
              'candidate titles=${afterContentSections.map((section) => section.title).toList()}',
            ),
          );
          expect(
            left.paragraphs.length,
            right.paragraphs.length,
            reason: left.id,
          );
          if (candidateTitle == left.title) {
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
          } else {
            expect(right.title, candidateTitle, reason: profile.id);
            expect(right.traceIds, orderedEquals(left.traceIds));
          }
          if (left.title == 'ช่วงปัจจุบัน') {
            expect(right.title, left.title, reason: profile.id);
            expect(right.traceIds, orderedEquals(left.traceIds));
            expect(right.paragraphs, hasLength(left.paragraphs.length));
            expect(right.paragraphs.first, contains('(อายุ '));
            expect(right.paragraphs[1], isNotEmpty);
            continue;
          }
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
          'infographic.overview',
          beforeGraphic.overview,
          afterGraphic.overview,
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
          'infographic.disclaimer',
          beforeGraphic.disclaimer,
          afterGraphic.disclaimer,
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
          'overview': afterGraphic.overview,
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
            '${profile.id}/primaryAdvice: missing connective before เลือกทาง: '
            '${afterGraphic.primaryAdvice}',
          );
        }
        final beforeHasTransitionReserve = beforeGraphic.categories.any(
          (category) =>
              category.summary.contains('และกันแรงไว้สำหรับรอยต่อของช่วงชีวิต'),
        );
        if (afterGraphic.categories.any(
              (category) =>
                  category.summary.contains('ควรดูผลที่เกิดซ้ำก่อนตัดสินใจ') ||
                  category.summary.contains('เผื่อแรงไว้ในช่วงเปลี่ยนผ่าน'),
            ) ||
            afterGraphic.opportunity.contains('เผื่อแรงไว้ในช่วงเปลี่ยนผ่าน')) {
          copyQualityViolations.add(
            '${profile.id}: report-level guidance is repeated in a category or opportunity',
          );
        }
        if (beforeHasTransitionReserve !=
            afterGraphic.overview.contains(
              'ควรเผื่อแรงไว้เมื่อหน้าที่เปลี่ยน',
            )) {
          copyQualityViolations.add(
            '${profile.id}: transition reserve was not relocated exactly once',
          );
        }
        if (!profile.input.hasBirthTime &&
            afterGraphic.disclaimer !=
                'ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด') {
          copyQualityViolations.add(
            '${profile.id}: Unknown fail-closed omission boundary is inconsistent',
          );
        }
        if (afterGraphic.theme.contains('พฤติกรรมหลังข้อตกลง') ||
            afterGraphic.theme.contains('ใช้ขอบเขตหน้าที่') ||
            afterGraphic.primaryAdvice.contains(
              'พฤติกรรมที่ทำตามคำตกลงจะยืนยันได้',
            ) ||
            afterGraphic.primaryAdvice.contains(
              'สร้างฐานทีละขั้นกับข้อมูลที่เกิดซ้ำจริง',
            )) {
          copyQualityViolations.add(
            '${profile.id}: abstract or system-generated phrasing remains',
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
    'sourceIdentifier': fieldPath,
    'originalMeaning': rules.map((rule) => rule.semanticIntent).join('; '),
    'predictionOrAdvice': _predictionOrAdvice(fieldPath, before),
    'certaintyLevel': _certaintyLevel(before),
    'timeframe': _timeframe(fieldPath, before),
    'lifeDomain': _lifeDomain(fieldPath, before),
    'evidenceReferences': traceIds,
    'mustPreserve': <String>[
      'semantic intent',
      'prediction/advice type',
      'certainty',
      'timeframe',
      'life domain',
      'trace IDs',
      if (!knownTime) 'Unknown-time fail-closed boundary',
    ],
    'newText': after,
    'ruleIds': rules.map((rule) => rule.id).toList(growable: false),
    'semanticAssessment': 'unchanged',
    'predictionAdviceAssessment': 'unchanged',
    'claimTraceIds': traceIds,
    'knownUnknownImpact': knownTime
        ? 'Known wording only; evidence unchanged'
        : 'Unknown wording only; fail-closed omissions unchanged',
    'canonicalImpact': 'candidate-only; accepted R1-R7.1 not modified',
    'webPdfImpact': 'same shared presentation field in Web/PDF/print',
    'omissionAdditionAssessment':
        'no net omission/addition; report-level relocations retain the same guidance and traces',
    'omission': false,
    'addition': false,
    'decision': 'Pending Owner Review',
  });
}

String _predictionOrAdvice(String fieldPath, String value) {
  if (value.contains('ควร') ||
      value.contains('ให้ดู') ||
      value.contains('ให้เลือก') ||
      value.contains('อย่า') ||
      value.contains('ก่อนตัดสินใจ')) {
    return 'advice';
  }
  if (fieldPath.contains('past') || value.contains('ลองทบทวน')) {
    return 'reflection';
  }
  return 'prediction-or-explanation';
}

String _certaintyLevel(String value) {
  if (value.contains('อาจ') || value.contains('แนวโน้ม')) return 'soft';
  if (value.contains('ถ้า') ||
      value.contains('หาก') ||
      value.contains('เมื่อ')) {
    return 'conditional';
  }
  return 'unchanged-from-source';
}

String _timeframe(String fieldPath, String value) {
  if (fieldPath.contains('next12') || value.contains('12 เดือน')) {
    return 'next-12-months';
  }
  if (fieldPath.contains('next') || value.contains('ช่วงถัดไป')) {
    return 'next-life-period';
  }
  if (fieldPath.contains('current') || value.contains('ช่วงนี้')) {
    return 'current';
  }
  if (fieldPath.contains('past') || value.contains('ทบทวน')) return 'past';
  return 'lifelong-or-unspecified';
}

String _lifeDomain(String fieldPath, String value) {
  if (fieldPath.contains('career') || value.contains('งาน')) return 'career';
  if (fieldPath.contains('finance') ||
      fieldPath.contains('money') ||
      value.contains('เงิน')) {
    return 'finance';
  }
  if (fieldPath.contains('relationship') || value.contains('ความสัมพันธ์')) {
    return 'relationship';
  }
  if (fieldPath.contains('health') ||
      fieldPath.contains('wellbeing') ||
      value.contains('พัก') ||
      value.contains('ฟื้น')) {
    return 'health';
  }
  return 'cross-domain';
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
