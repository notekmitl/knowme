/// Candidate-only reader copy repair for the Thai report experience vNext.
///
/// The accepted V1.5 composers and evidence packets stay untouched. This
/// boundary refines only text projected into the new shared presentation
/// model, which keeps the before/after corpus auditable for Owner review.
abstract final class ThaiBetaReaderCopyRepair {
  static const rules = <ThaiBetaReaderCopyRule>[
    ThaiBetaReaderCopyRule(
      id: 'copy-life-map-heading',
      sourceTemplate: 'ThaiMirrorLifeTimelineState.sectionTitle',
      before: 'แผนที่ชีวิต',
      after: 'แผนที่ชีวิตของคุณ',
      semanticIntent: 'รักษาหัวข้อที่ผู้อ่านคุ้นเคยและระบุเจ้าของรายงานให้ชัด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-past-reflection-heading',
      sourceTemplate:
          'ThaiBetaReportExportDocument._timelinePastAndCurrentSections',
      before: 'ธีมสำหรับทบทวนอดีต',
      after: 'อดีตของคุณ',
      semanticIntent: 'ใช้หัวข้อสั้นที่บอกลำดับการอ่านโดยไม่เปลี่ยนข้อเท็จจริง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-work-house-human-intro',
      sourceTemplate: 'ThaiBirthProfileCoreReading._composeHouseDomain(work)',
      before: 'หลักฐานเรือนการงานที่เชื่อม',
      after: 'ข้อมูลจากเรือนการงานที่เชื่อม',
      semanticIntent: 'เรียกข้อมูลต้นทางด้วยภาษาทั่วไปแทนศัพท์ตรวจสอบภายใน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-work-house-direct-meaning',
      sourceTemplate: 'ThaiBirthProfileCoreReading._composeHouseDomain(work)',
      before: ' แปลเป็นภาษาคนว่า ',
      after: ' สะท้อนว่า ',
      semanticIntent:
          'เข้าสู่ความหมายโดยตรงและตัดถ้อยคำที่ไม่ให้เกียรติผู้อ่าน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-work-authority-responsibility',
      sourceTemplate: 'ThaiBirthProfileCoreReading._composeHouseDomain(work)',
      before:
          'บทบาทที่คุ้มจึงต้องเพิ่มอำนาจดูแลคุณภาพ ไม่ใช่เพิ่มแต่งานที่ต้องถือ',
      after:
          'งานที่เหมาะกับคุณควรให้อำนาจตัดสินใจสอดคล้องกับความรับผิดชอบ ไม่ใช่เพิ่มภาระเพียงอย่างเดียว',
      semanticIntent:
          'ทำให้ความสัมพันธ์ระหว่างอำนาจตัดสินใจ ความรับผิดชอบ และภาระชัดเจน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-finance-liquid-choice',
      sourceTemplate: 'ThaiBetaNarrativeComposer._forecastClaim(finance)',
      before:
          'เงินพร้อมใช้เปิดพื้นที่ให้ขยับได้ ตราบใดที่รายจ่ายระยะยาวยังไม่เบียดฐานเดิม',
      after:
          'เงินสำรองช่วยให้คุณมีทางเลือกมากขึ้น ตราบใดที่รายจ่ายระยะยาวยังไม่กระทบเงินก้อนหลัก',
      semanticIntent:
          'อธิบายสภาพคล่องและข้อจำกัดของรายจ่ายระยะยาวด้วยคำที่ใช้ในชีวิตประจำวัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-health-recovery',
      sourceTemplate: 'ThaiBetaNarrativeComposer._forecastClaim(health)',
      before: 'เวลาพักที่คืนแรงทัน ทำให้พลังของคุณยังรองรับการขยับได้',
      after:
          'หากพักแล้วร่างกายกลับมามีแรงได้ตามปกติ พลังของคุณยังรองรับการขยับได้',
      semanticIntent: 'ระบุเงื่อนไขการฟื้นตัวให้มีประธานและความหมายชัดเจน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-career-trigger',
      sourceTemplate: 'ThaiBetaNarrativeComposer._forecastClaim(career)',
      before: 'คือจุดกระตุ้นของงาน',
      after: 'คือสัญญาณสำคัญด้านงาน',
      semanticIntent: 'แทนศัพท์กลไกภายในด้วยสัญญาณที่ผู้อ่านนำไปสังเกตได้',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-finance-trigger',
      sourceTemplate: 'ThaiBetaNarrativeComposer._forecastClaim(finance)',
      before: 'คือจุดกระตุ้นทางการเงิน',
      after: 'คือสัญญาณสำคัญด้านการเงิน',
      semanticIntent: 'แทนศัพท์กลไกภายในด้วยสัญญาณที่ผู้อ่านนำไปสังเกตได้',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-fortune-income-source',
      sourceTemplate: 'LifeMapCurrentDomainComposer._fortuneVsWork',
      before:
          'รายได้หลักยังแยกจากโชคเหตุบังเอิญ — ส่วนใหญ่มาจากงานและความสามารถที่ลงมือเอง',
      after:
          'รายได้ส่วนใหญ่ยังมาจากงานและความสามารถที่ลงมือเอง มากกว่าเหตุบังเอิญ',
      semanticIntent: 'รักษาขอบเขตไม่ชี้นำโชคลาภด้วยประโยคที่เป็นธรรมชาติขึ้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-reader-verifiable-information',
      sourceTemplate: 'LifeMapCurrentDomainComposer._fortuneCaution',
      before: 'ประเมินโอกาสจากหลักฐานและภาระจริง',
      after: 'ประเมินโอกาสจากข้อมูลที่ตรวจสอบได้และภาระจริง',
      semanticIntent: 'แยกคำแนะนำสำหรับผู้อ่านออกจากศัพท์ evidence ภายใน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-work-samples',
      sourceTemplate: 'ThaiBetaNarrativeComposer._preparationAction(career)',
      before: 'เก็บหลักฐานผลงาน',
      after: 'เก็บตัวอย่างผลงาน',
      semanticIntent: 'ใช้คำที่บอกการกระทำชัดเจนโดยไม่แสดงศัพท์ระบบ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-element-conflict',
      sourceTemplate: 'PeriodIntelligenceComposer.elementShiftLine',
      before: 'ธาตุขัดกัน',
      after: 'จังหวะเปลี่ยนผ่านที่ต้องปรับตัวมากขึ้น',
      semanticIntent: 'อธิบายผลต่อการปรับตัวแทนการแสดงศัพท์ engine',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-element-support',
      sourceTemplate: 'PeriodIntelligenceComposer.elementShiftLine',
      before: 'ธาตุเสริมกัน',
      after: 'จังหวะเปลี่ยนผ่านที่ต่อเนื่องกันได้ดี',
      semanticIntent: 'อธิบายผลต่อการเปลี่ยนผ่านแทนการแสดงศัพท์ engine',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-element-neutral',
      sourceTemplate: 'PeriodIntelligenceComposer.elementShiftLine',
      before: 'ธาตุเป็นกลาง',
      after: 'จังหวะเปลี่ยนผ่านที่ต้องค่อย ๆ ปรับ',
      semanticIntent: 'อธิบายผลต่อการเปลี่ยนผ่านแทนการแสดงศัพท์ engine',
    ),
  ];

  static String refine(String value) {
    var result = value;
    for (final rule in rules) {
      result = result.replaceAll(rule.before, rule.after);
    }
    return result;
  }

  static List<ThaiBetaReaderCopyRule> matchingRules(String value) => rules
      .where((rule) => value.contains(rule.before))
      .toList(growable: false);
}

class ThaiBetaReaderCopyRule {
  const ThaiBetaReaderCopyRule({
    required this.id,
    required this.sourceTemplate,
    required this.before,
    required this.after,
    required this.semanticIntent,
  });

  final String id;
  final String sourceTemplate;
  final String before;
  final String after;
  final String semanticIntent;
}
