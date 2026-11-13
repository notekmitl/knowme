import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_symbolic_reading_engine.dart';
import 'package:knowme/features/bazi_compatibility/domain/bazi_compatibility_report.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'trial_reading_copy.dart';

/// Projects only display fields after the original report has selected claims.
/// The same Thai document feeds the visible report and browser-print sync.
abstract final class TrialReportDocuments {
  static Iterable<String> _paragraphs(String text) => text
      .split('\n\n')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty);

  // BaziReaderV2/V4 join the selected period theme, relation, and action with
  // spaces. Mark those exact boundaries before the existing phrase projection.
  static final _timingParagraphStart = RegExp(
    r' (?=(?<!ในช่วงยาวนี้ )(?:ในช่วงยาวนี้|มีทั้งเรื่องที่ต้องเปลี่ยนและเรื่องที่ต้องร่วมมือ|'
    r'แผนเดิมอาจต้องปรับ ทั้งเรื่องงาน|(?:ต้องคุยเรื่อง|เรื่อง)เวลา หน้าที่ และข้อตกลง|'
    r'(?:เหมาะกับการรวม|การรวม)คน ความรู้ หรือทรัพยากร|'
    r'ปีนี้ย้ำว่า|(?:จึง)?ควร(?:ลงทุนกับความรู้|ทดลองแบบเล็กก่อน|ทดลองทางเลือกแบบจำกัดขอบเขต|'
    r'สร้างผลงานในชื่อของตน|เขียนข้อตกลงเรื่องเงิน|ทำความรู้หรือผลงานให้เป็นระบบ|'
    r'ใช้การเปลี่ยนแปลงแก้คอขวดหลัก|วางกระแสเงินสด|คัดโอกาสจากผลตอบแทน|'
    r'สร้างมาตรฐาน เอกสาร|เลือกโจทย์ยากที่คุ้มกับพลัง|วางเป้าหมายระยะยาวให้ชัด|'
    r'เพิ่มทักษะ|ลองทางเลือกใหม่ในขอบเขตเล็ก|'
    r'เลือกเรื่องที่(?:คุณ)?เป็นเจ้าของเอง|ทบทวน(?:ทีม|คู่ค้า)|ทำผลงานให้เสร็จ|'
    r'แก้ระบบที่ติดขัด|จัดงบ|ประเมินตลาด|กำหนดบทบาท ข้อตกลง|'
    r'เลือกงานสำคัญหนึ่งเรื่อง|(?:ตั้ง|เลือก)เป้าหมายที่วัดผลได้)|'
    r'หากเปิดตลาดหรือเครือข่ายใหม่))',
  );

  static String _timingParagraphs(String value) {
    final age = _currentCycleAge.firstMatch(value);
    if (age != null) {
      value =
          '${age[0]} ${value.substring(0, age.start).trim()}'
          '${value.substring(age.end)}';
    }
    return value.replaceAll(_timingParagraphStart, '\n\n');
  }

  static final _currentCycleAge = RegExp(
    r'จังหวะนี้อยู่ในช่วงอายุจีน \d+–\d+ ปี',
  );

  static ThaiBetaReportExportDocument thai(
    ThaiBetaReportExportDocument source,
  ) {
    final image = source.infographic;
    return ThaiBetaReportExportDocument(
      title: source.title,
      subtitle: source.subtitle,
      filenameStem: source.filenameStem,
      predictiveRuntimeV2: source.predictiveRuntimeV2,
      sections: [
        for (final section in source.sections)
          ThaiBetaReportExportSection(
            title: TrialReadingCopy.thai(section.title),
            paragraphs: section.paragraphs
                .map(TrialReadingCopy.thai)
                .expand(_paragraphs)
                .toList(),
            kind: section.kind,
            id: section.id,
            fieldSource: section.fieldSource,
            visibilityRule: section.visibilityRule,
            knownUnknownRule: section.knownUnknownRule,
            traceIds: section.traceIds,
          ),
      ],
      infographic: image == null
          ? null
          : ThaiBetaAnnualInfographicData(
              buddhistYear: image.buddhistYear,
              periodLabel: image.periodLabel,
              theme: TrialReadingCopy.thai(image.theme),
              overview: TrialReadingCopy.thai(image.overview),
              categories: [
                for (final category in image.categories)
                  ThaiBetaAnnualInfographicCategory(
                    id: category.id,
                    title: category.title,
                    summary: TrialReadingCopy.thai(category.summary),
                    iconName: category.iconName,
                    traceIds: category.traceIds,
                  ),
              ],
              opportunity: TrialReadingCopy.thai(image.opportunity),
              caution: TrialReadingCopy.thai(image.caution),
              primaryAdvice: TrialReadingCopy.thai(image.primaryAdvice),
              disclaimer: TrialReadingCopy.thai(image.disclaimer),
              monthlyTimelineAvailable: image.monthlyTimelineAvailable,
              monthlyGapReason: TrialReadingCopy.thai(image.monthlyGapReason),
              traceIds: image.traceIds,
            ),
    );
  }

  static BaziCompatibilityReport chinese(
    BaziCompatibilityReport source,
    BaziChartModel chart,
  ) {
    final profile = BaziSymbolicReadingEngine.profileFor(chart.dayMaster.stem);
    // This exact, known template introduces a decorative metaphor. Retain the
    // calculated Day Master and explain its role without inventing a trait.
    final metaphor =
        'แกนดวงของคุณคือ ${profile.name} เปรียบเหมือน “${profile.symbol}” ';
    String text(String value, {bool timing = false}) {
      const missingCycle =
          'ยังไม่แสดงดวงจรสิบปี เพราะข้อมูลเพศหรือเวลาเกิดไม่ครบ ระบบจึงไม่กำหนดทิศทางเดินดวงแทนผู้ใช้';
      if (value == missingCycle) {
        final missing = [
          if (!chart.timeKnown) 'เวลาเกิด',
          if (!const {'male', 'female'}.contains(chart.luck.gender))
            'ข้อมูลเพศที่ใช้คำนวณ',
        ];
        return missing.isEmpty
            ? 'ยังไม่มีผลคำนวณช่วงสิบปีที่ครอบคลุมปีนี้ จึงยังอ่านช่วงชีวิตปัจจุบันไม่ได้'
            : 'ยังขาด${missing.join('และ')} จึงยังอ่านแนวโน้มช่วงละสิบปีไม่ได้';
      }
      final source = timing ? _timingParagraphs(value) : value;
      final projected = TrialReadingCopy.chinese(
        source
            .replaceAll(
              metaphor,
              'ดวงจีนใช้ ${profile.name} เป็นธาตุประจำวัน เพื่ออ่านลักษณะของคุณ ',
            )
            .replaceFirst(
              'แกนวันเกิดของดวงนี้คือ ${profile.name}',
              'ธาตุประจำวัน (Day Master) ของคุณคือ ${profile.name}',
            ),
      );
      return timing ? _paragraphs(projected).join('\n\n') : projected;
    }

    return BaziCompatibilityReport(
      title: source.title,
      subtitle: text(source.subtitle),
      sections: [
        for (final section in source.sections)
          BaziCompatibilityReportSection(
            title: text(section.title),
            intro: section.intro == null ? null : text(section.intro!),
            paragraphs: section.paragraphs
                .map((value) => text(value, timing: _isTiming(section.title)))
                .expand(_paragraphs)
                .toList(),
            rows: [
              for (final row in section.rows)
                BaziCompatibilityReportRow(
                  label: text(row.label),
                  value: text(row.value, timing: _isTiming(section.title)),
                ),
            ],
            notes: section.notes.map(text).toList(),
          ),
      ],
    );
  }

  static bool _isTiming(String title) =>
      title.startsWith('จังหวะชีวิตปัจจุบัน') ||
      title.startsWith('ปี ') ||
      const {
        'เส้นทางที่ผ่านมา · ดวงจรสิบปี',
        'แนวโน้ม 5 ปีข้างหน้า',
        'ภาพระยะยาว · สองดวงจรถัดไป',
      }.contains(title);
}
