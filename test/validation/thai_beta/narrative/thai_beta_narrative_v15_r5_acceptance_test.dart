import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_past_reflection.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_thai_repetition_audit.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  late Map<String, ThaiBetaAnalysis> analyses;

  setUpAll(() {
    analyses = {
      'owner-known-0035': _owner(known: true, minute: 35),
      'owner-unknown': _owner(known: false),
      'regression-known-0003': _owner(known: true, minute: 3),
      'comparison-known-bangkok': _run(
        ThaiBetaInput(
          firstName: 'Comparison',
          lastName: 'Fixture',
          birthDate: DateTime(1991, 11, 18),
          birthHour: 14,
          birthMinute: 20,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
      ),
      'comparison-known-khon-kaen': _run(
        ThaiBetaInput(
          firstName: 'Comparison',
          lastName: 'Fixture',
          birthDate: DateTime(1974, 2, 27),
          birthHour: 6,
          birthMinute: 45,
          province: 'ขอนแก่น',
          provinceKey: 'khon_kaen',
        ),
      ),
    };
  });

  test('age-band resolver uses largest overlap and no fixture identity', () {
    expect(
      ThaiBetaPastReflectionComposer.resolveAgeBand(startAge: 1, endAge: 10),
      ThaiBetaPastAgeBand.childhood,
    );
    expect(
      ThaiBetaPastReflectionComposer.resolveAgeBand(startAge: 7, endAge: 21),
      ThaiBetaPastAgeBand.adolescence,
    );
    expect(
      ThaiBetaPastReflectionComposer.resolveAgeBand(startAge: 11, endAge: 29),
      ThaiBetaPastAgeBand.emergingAdult,
    );
    expect(
      ThaiBetaPastReflectionComposer.resolveAgeBand(startAge: 28, endAge: 46),
      ThaiBetaPastAgeBand.adult,
    );
  });

  test('past reflections are age-appropriate and evidence-bounded once', () {
    const boundary =
        'ส่วนนี้ใช้ตั้งคำถามกับความทรงจำจริง ไม่ใช่ข้อสรุปว่าเหตุการณ์ใดเคยเกิดขึ้น';
    for (final entry in analyses.entries) {
      final view = ThaiBetaNarrativeComposer.narrativeView(entry.value);
      final fullText = ThaiBetaReportExportDocument.fromAnalysis(
        entry.value,
      ).fullPlainText;
      expect(boundary.allMatches(fullText), hasLength(1), reason: entry.key);
      for (final period in view.lifeTimeline!.periods.where(
        (period) => period.isPast,
      )) {
        final ages = period.ageLabel.split('–');
        final start = int.parse(ages.first);
        final end = int.parse(ages.last);
        final band = ThaiBetaPastReflectionComposer.resolveAgeBand(
          startAge: start,
          endAge: end,
        );
        expect(period.summary, startsWith('ธีมสำหรับทบทวน:'));
        expect(period.whatChanges, startsWith('คำถามสะท้อน:'));
        if (band == ThaiBetaPastAgeBand.childhood) {
          final text = '${period.summary}\n${period.whatChanges}';
          expect(
            text,
            isNot(matches(RegExp(r'การงาน|รายได้|วางแผนการเงิน'))),
            reason: '${entry.key}:${period.ageLabel}',
          );
          expect(text, contains('ผู้ดูแล'));
          expect(text, contains('การเล่น'));
        }
      }
    }
  });

  test('Thai-aware gate separates theme and question pairs within reports', () {
    for (final entry in analyses.entries) {
      final past = ThaiBetaNarrativeComposer.narrativeView(
        entry.value,
      ).lifeTimeline!.periods.where((period) => period.isPast).toList();
      for (final spec in <(ThaiBetaPastUnitKind, List<String>)>[
        (
          ThaiBetaPastUnitKind.theme,
          past.map((period) => period.summary).toList(),
        ),
        (
          ThaiBetaPastUnitKind.question,
          past.map((period) => period.whatChanges).toList(),
        ),
      ]) {
        for (var left = 0; left < spec.$2.length; left++) {
          for (var right = left + 1; right < spec.$2.length; right++) {
            final result = ThaiBetaThaiRepetitionAudit.comparePastUnits(
              spec.$2[left],
              spec.$2[right],
              kind: spec.$1,
            );
            expect(
              result.similarity,
              lessThan(.78),
              reason: '${entry.key}:${spec.$1}:$left/$right',
            );
            expect(
              result.repeatedSkeleton,
              isFalse,
              reason: '${entry.key}:${spec.$1}:$left/$right',
            );
          }
        }
      }
    }
  });

  test('R4 template-substitution negatives are detected by the new gate', () {
    const knownThemes = [
      'ธีมสำหรับทบทวน: ในช่วงวางรากฐาน ช่วงอายุ 1–10 ลองย้อนดูว่าความมั่นคงปรากฏผ่านเรื่องการงานและการเงินในรูปแบบใด',
      'ธีมสำหรับทบทวน: ในช่วงเติบโตและขยาย ช่วงอายุ 11–29 ลองย้อนดูว่าการเติบโตปรากฏผ่านเรื่องการงานและการเงินในรูปแบบใด',
      'ธีมสำหรับทบทวน: ในช่วงพลิกผันและเปลี่ยนผ่าน ช่วงอายุ 30–41 ลองย้อนดูว่าการเปลี่ยนแปลงปรากฏผ่านเรื่องการงานและการเงินในรูปแบบใด',
    ];
    const knownQuestions = [
      'คำถามสะท้อน: เมื่อคิดถึงช่วงวางรากฐานในวัย 1–10 การเลือกเรื่องใดทำให้คุณเข้าใจความมั่นคงต่างจากเดิม และสิ่งใดยังมีผลต่อวิธีที่คุณตัดสินใจในวันนี้',
      'คำถามสะท้อน: เมื่อคิดถึงช่วงเติบโตและขยายในวัย 11–29 การเลือกเรื่องใดทำให้คุณเข้าใจการเติบโตต่างจากเดิม และสิ่งใดยังมีผลต่อวิธีที่คุณตัดสินใจในวันนี้',
      'คำถามสะท้อน: เมื่อคิดถึงช่วงพลิกผันและเปลี่ยนผ่านในวัย 30–41 การเลือกเรื่องใดทำให้คุณเข้าใจการเปลี่ยนแปลงต่างจากเดิม และสิ่งใดยังมีผลต่อวิธีที่คุณตัดสินใจในวันนี้',
    ];
    const unknownThemes = [
      'ธีมสำหรับทบทวน: ในช่วงเปล่งประกาย ช่วงอายุ 1–6 ลองย้อนดูว่าการยอมรับปรากฏผ่านเรื่องการงานและการเงินในรูปแบบใด',
      'ธีมสำหรับทบทวน: ในช่วงดูแลใจ ช่วงอายุ 7–21 ลองย้อนดูว่าความรู้สึกปรากฏผ่านเรื่องการงานและการเงินในรูปแบบใด',
      'ธีมสำหรับทบทวน: ในช่วงลงมือและบุกเบิก ช่วงอายุ 22–29 ลองย้อนดูว่าการลงมือปรากฏผ่านเรื่องการงานและการเงินในรูปแบบใด',
    ];
    const unknownQuestions = [
      'คำถามสะท้อน: เมื่อคิดถึงช่วงเปล่งประกายในวัย 1–6 การเลือกเรื่องใดทำให้คุณเข้าใจการยอมรับต่างจากเดิม และสิ่งใดยังมีผลต่อวิธีที่คุณตัดสินใจในวันนี้',
      'คำถามสะท้อน: เมื่อคิดถึงช่วงดูแลใจในวัย 7–21 การเลือกเรื่องใดทำให้คุณเข้าใจความรู้สึกต่างจากเดิม และสิ่งใดยังมีผลต่อวิธีที่คุณตัดสินใจในวันนี้',
      'คำถามสะท้อน: เมื่อคิดถึงช่วงลงมือและบุกเบิกในวัย 22–29 การเลือกเรื่องใดทำให้คุณเข้าใจการลงมือต่างจากเดิม และสิ่งใดยังมีผลต่อวิธีที่คุณตัดสินใจในวันนี้',
    ];
    for (final fixture in <(ThaiBetaPastUnitKind, List<String>)>[
      (ThaiBetaPastUnitKind.theme, knownThemes),
      (ThaiBetaPastUnitKind.question, knownQuestions),
      (ThaiBetaPastUnitKind.theme, unknownThemes),
      (ThaiBetaPastUnitKind.question, unknownQuestions),
    ]) {
      for (var left = 0; left < fixture.$2.length; left++) {
        for (var right = left + 1; right < fixture.$2.length; right++) {
          final result = ThaiBetaThaiRepetitionAudit.comparePastUnits(
            fixture.$2[left],
            fixture.$2[right],
            kind: fixture.$1,
          );
          expect(
            result.similarity >= .78 || result.repeatedSkeleton,
            isTrue,
            reason: '${fixture.$1}:$left/$right ${result.similarity}',
          );
        }
      }
    }
  });

  test(
    'Unknown uses observable framing and has no unsupported present state',
    () {
      final text = ThaiBetaReportExportDocument.fromAnalysis(
        analyses['owner-unknown']!,
      ).fullPlainText;
      expect(
        text,
        contains(
          'เมื่อหน้าที่หลายอย่างเริ่มเบียดเวลาพัก ให้ใช้การฟื้นตัวจริงบอกว่าตารางเดิมยังรับไหวหรือไม่',
        ),
      );
      expect(
        text,
        contains('หากช่วงนี้คุณสังเกตว่างานเดิมเริ่มเปลี่ยนไปสู่โจทย์ใหม่'),
      );
      for (final unsupported in const [
        'ด้านพลังชีวิตคุณมีหน้าที่หลายอย่าง จนแทบไม่มีเวลาพัก',
        'คุณฝืนตัวเองจนสะสมความล้า',
        'ร่างกายและใจถูกใช้จนสุดแรง',
        'คุณต้องแบกงานหลายเรื่อง',
        'งานเดิมกำลังเปลี่ยนแปลงไปสู่โจทย์ใหม่',
        'แม้รายรับดูดีขึ้น',
      ]) {
        expect(text, isNot(contains(unsupported)), reason: unsupported);
      }
      expect(text, contains('ไม่ใช่คำบอกจากแพทย์'));
    },
  );
}

ThaiBetaAnalysis _owner({required bool known, int minute = 0}) => _run(
  ThaiBetaInput(
    firstName: 'Acceptance',
    lastName: 'Fixture',
    birthDate: DateTime(1982, 6, 6),
    birthHour: known ? 0 : null,
    birthMinute: known ? minute : 0,
    birthTimeUnknown: !known,
    province: 'เชียงใหม่',
    provinceKey: 'chiang_mai',
  ),
);

ThaiBetaAnalysis _run(ThaiBetaInput input) =>
    ThaiBetaAnalysisRunner.run(input, startedAt: DateTime(2026, 8, 7));
