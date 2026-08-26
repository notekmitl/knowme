/// Candidate-only reader copy repair for the Thai report experience vNext.
///
/// The accepted V1.5 composers and evidence packets stay untouched. This
/// boundary refines only text projected into the new shared presentation
/// model, which keeps the before/after corpus auditable for Owner review.
abstract final class ThaiBetaReaderCopyRepair {
  static const rules = <ThaiBetaReaderCopyRule>[
    ThaiBetaReaderCopyRule(
      id: 'or3-financial-progress-flexibility',
      sourceTemplate: 'ThaiBirthProfileCoreReading.money',
      before:
          'ความก้าวหน้าจึงควรวัดจากทางเลือกที่เงินสำรองเปิดให้ มากกว่ายอดที่สะสมอย่างเดียว',
      after:
          'ความก้าวหน้าทางการเงินควรวัดจากความยืดหยุ่นที่เงินสำรองมอบให้ ไม่ใช่ดูเพียงยอดเงินที่สะสมไว้',
      semanticIntent: 'คงการวัดความมั่นคงจากทางเลือกที่เงินสำรองรองรับ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-relationship-agreement-observable',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.relationship',
      before: 'สิ่งที่ตกลงกันถูกทำจริงต่อเนื่องหรือไม่',
      after: 'ทั้งสองฝ่ายปฏิบัติตามสิ่งที่ตกลงกันอย่างต่อเนื่องหรือไม่',
      semanticIntent: 'คงการตรวจพฤติกรรมต่อเนื่องหลังข้อตกลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-quarterly-liquidity-observation',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.finance',
      before:
          'บันทึกยอดคงเหลือรายไตรมาสเพื่อดูสภาพคล่อง ตัวเลขครั้งเดียวจึงยังไม่พอให้ขยายภาระเงิน',
      after:
          'บันทึกยอดคงเหลือรายไตรมาสเพื่อดูสภาพคล่อง ตัวเลขที่ดีเพียงครั้งเดียวยังไม่เพียงพอสำหรับการเพิ่มภาระทางการเงิน',
      semanticIntent: 'คงการรอดูสภาพคล่องต่อเนื่องก่อนเพิ่มภาระ',
    ),
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
      id: 'copy-past-reflection-theme-prefix',
      sourceTemplate: 'ThaiBetaPastReflectionComposer.compose',
      before: 'ธีมสำหรับทบทวน:',
      after: 'ลองย้อนดูว่า',
      semanticIntent: 'ชวนผู้อ่านทบทวนอดีตโดยไม่ใช้ป้ายกำกับเชิงระบบ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-past-reflection-question-prefix',
      sourceTemplate: 'ThaiBetaPastReflectionComposer.compose',
      before: 'คำถามสะท้อน:',
      after: 'คำถามชวนทบทวน:',
      semanticIntent: 'ใช้คำชวนที่เป็นธรรมชาติและคงคำถามเดิมครบถ้วน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-past-reflection-decision-question',
      sourceTemplate: 'ThaiBetaPastReflectionComposer.compose',
      before: 'แล้วบทเรียนนั้นช่วยคัดการตัดสินใจวันนี้แบบไหน',
      after: 'แล้วบทเรียนนั้นช่วยให้คุณตัดสินใจเรื่องปัจจุบันอย่างไร',
      semanticIntent: 'คงการเชื่อมบทเรียนในอดีตกับการตัดสินใจปัจจุบัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-core-double-strength',
      sourceTemplate: 'ThaiBirthProfileCoreReading._composeLagnaSummary',
      before: 'จุดแข็งสองชั้นนี้',
      after: 'จุดแข็งทั้งสองด้านนี้',
      semanticIntent: 'คงจุดแข็งจากหลักฐานสองส่วนด้วยภาษาที่เป็นธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-expressive-strength',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.strengthLabel',
      before: 'ความสามารถในการทำความคิดให้คนอื่นเข้าใจ',
      after: 'ความสามารถในการถ่ายทอดความคิดให้คนอื่นเข้าใจ',
      semanticIntent: 'คงจุดแข็งด้านการสื่อสารด้วยคำกริยาที่ชัดเจน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-agreement-observable',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.observableLabel',
      before: 'พฤติกรรมที่ทำตามคำตกลง',
      after: 'การทำตามข้อตกลง',
      semanticIntent: 'คงหลักฐานจากการปฏิบัติตามข้อตกลงด้วยภาษาทั่วไป',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-preserve-agreement',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ไม่ปล่อยให้การทำตามข้อตกลงเสียไป',
      after: 'ยังรักษาการทำตามข้อตกลงไว้',
      semanticIntent: 'คงการรักษาข้อตกลงด้วยประโยคที่ตรงและเป็นธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-unknown-fail-closed-methodology',
      sourceTemplate: 'ThaiMirrorConsumerCopy.dataUsedWithoutBirthTime',
      before: 'ไม่มีเวลาเกิด — บางส่วนอาจคลาดเคลื่อนเล็กน้อย',
      after: 'ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด',
      semanticIntent:
          'ระบุการเว้นผลแบบ fail-closed ให้ตรงกับพฤติกรรมจริงและไม่สื่อว่าระบบเดาค่าที่คลาดเคลื่อน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-unknown-fail-closed-summary-omission',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(summary)',
      before:
          'สรุปตัวคุณแบบตรง ๆ — ข้อมูลเวลาไม่พอสำหรับสรุปบุคลิกจากตำแหน่งเฉพาะแทนส่วนที่ขาด',
      after:
          'สรุปตัวคุณแบบตรง ๆ — ไม่มีเวลาเกิด จึงไม่สรุปบุคลิกจากตำแหน่งที่ต้องคำนวณด้วยเวลาเกิด',
      semanticIntent:
          'คงการเว้นบทสรุปบุคลิกจากตำแหน่งเฉพาะและอธิบายเหตุผลตรงไปตรงมา',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-unknown-fail-closed-work-omission',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(work)',
      before:
          'คำอ่านการงานที่ต้องใช้เวลาเกิด — เพราะไม่ทราบเวลาเกิด รายงานจึงเว้นรายละเอียดการงานส่วนนี้แทนการสร้างข้อมูลขึ้นเอง',
      after:
          'คำอ่านการงานที่ต้องใช้เวลาเกิด — รายงานเว้นรายละเอียดส่วนนี้แทนการสร้างข้อมูลที่ยืนยันไม่ได้',
      semanticIntent:
          'คงการเว้นคำอ่านการงานที่ต้องใช้เวลาเกิดโดยไม่เพิ่มข้อมูลหรือคำทำนาย',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-unknown-fail-closed-money-omission',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(money)',
      before:
          'รายละเอียดการเงินที่ข้อมูลเวลาไม่พอ — ข้อมูลเวลายังว่าง จึงละรายละเอียดการเงินส่วนที่ยืนยันจากวันเกิดเพียงอย่างเดียวไม่ได้',
      after:
          'รายละเอียดการเงินที่ต้องใช้เวลาเกิด — ไม่มีข้อมูลเพียงพอสำหรับยืนยันรายละเอียดส่วนนี้',
      semanticIntent:
          'คงการเว้นรายละเอียดการเงินที่ไม่มีหลักฐานจากเวลาเกิดด้วยภาษาที่สั้นและชัด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-unknown-fail-closed-relationship-omission',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(relationships)',
      before:
          'มุมความสัมพันธ์ที่ต้องอาศัยเวลาเกิด — ข้อมูลนี้ไม่มีเวลาเกิด มุมความสัมพันธ์ส่วนดังกล่าวจึงถูกละไว้เพื่อไม่ให้ฟันธงเกินหลักฐาน',
      after:
          'มุมความสัมพันธ์ที่ต้องใช้เวลาเกิด — รายงานเว้นส่วนที่ต้องคำนวณจากตำแหน่งเฉพาะ',
      semanticIntent:
          'คงการเว้นมุมความสัมพันธ์ที่ต้องคำนวณจากเวลาเกิดและไม่ฟันธงเกินหลักฐาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-unknown-fail-closed-wellbeing-omission',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(wellbeing)',
      before:
          'รายละเอียดสุขภาวะที่ต้องมีข้อมูลเวลา — เมื่อยังไม่ทราบเวลาเกิด รายงานจะไม่เติมรายละเอียดสุขภาวะส่วนที่ยืนยันไม่ได้',
      after:
          'รายละเอียดสุขภาวะที่ต้องใช้เวลาเกิด — รายงานไม่เติมรายละเอียดที่ข้อมูลยังรองรับไม่เพียงพอ',
      semanticIntent:
          'คงการเว้นรายละเอียดสุขภาวะที่ยังไม่มีหลักฐานเพียงพอโดยไม่เพิ่มข้อสรุปสุขภาพ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-unknown-fail-closed-closing-omission',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(closing)',
      before:
          'คำชี้หลักจากพื้นดวง — ไม่พบชุดจุดแข็ง ความเสี่ยง และแนวทางที่อ้างอิงจากแนวโน้มเดียวกันได้ครบ',
      after:
          'คำชี้หลักจากพื้นดวง — ข้อมูลไม่ครบพอที่จะสรุปจุดแข็ง ความเสี่ยง และแนวทางจากหลักฐานชุดเดียวกัน',
      semanticIntent:
          'คงการเว้นคำชี้หลักเมื่อหลักฐานชุดเดียวกันไม่ครบโดยไม่สร้างข้อสรุปทดแทน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-finance-choice-size',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.supportingCurrentContext',
      before: 'ด้านเงินคุมขนาดทางเลือกด้วยยอดพร้อมใช้หลังรายการจำเป็น',
      after:
          'ด้านการเงิน ให้ใช้จำนวนเงินพร้อมใช้หลังรายการจำเป็นเป็นเกณฑ์ตัดสินใจ',
      semanticIntent: 'คงเกณฑ์เงินพร้อมใช้โดยระบุประธานและการกระทำให้ชัด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-transition-parentheses',
      sourceTemplate: 'PeriodIntelligenceComposer.elementShiftLine',
      before: '(ธาตุขัดกัน)',
      after: 'โดยต้องปรับตัวกับการเปลี่ยนผ่านมากขึ้น',
      semanticIntent:
          'คงความหมายของรอยต่อโดยไม่ทิ้งวงเล็บกำพร้าเมื่อขึ้นบรรทัด',
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
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-reading-flow',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before:
          'ตลอด 12 เดือนของช่วงเรียนรู้และเชื่อมโยง ให้ใช้ขอบเขตหน้าที่ที่เปลี่ยนไปเป็นสัญญาณ แล้วกลับมาทบทวนเมื่อพฤติกรรมหลังข้อตกลงเริ่มชัด',
      after:
          'ตลอด 12 เดือนนี้ ให้ดูว่าหน้าที่เปลี่ยนไปอย่างไร แล้วทบทวนอีกครั้งเมื่อพฤติกรรมหลังข้อตกลงชัดขึ้น',
      semanticIntent:
          'รักษากรอบทบทวน 12 เดือนและสัญญาณเดิมด้วยประโยคที่สั้นและตรงขึ้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-growth-reading-flow',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before:
          'ตลอด 12 เดือนของช่วงเติบโตและขยาย ให้ใช้ขอบเขตหน้าที่ที่เปลี่ยนไปเป็นสัญญาณ แล้วกลับมาทบทวนเมื่อพฤติกรรมหลังข้อตกลงเริ่มชัด',
      after:
          'ตลอด 12 เดือนนี้ ให้ดูการเปลี่ยนแปลงของหน้าที่ แล้วทบทวนเมื่อพฤติกรรมหลังข้อตกลงชัดขึ้น',
      semanticIntent:
          'รักษากรอบ 12 เดือน สัญญาณจากหน้าที่ และจุดทบทวนเดิมด้วยประโยคที่กระชับขึ้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-duty-signal',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before: 'ให้ใช้ขอบเขตหน้าที่ที่เปลี่ยนไปเป็นสัญญาณ',
      after: 'ให้สังเกตว่าหน้าที่เปลี่ยนไปอย่างไร',
      semanticIntent:
          'คงสัญญาณจากขอบเขตหน้าที่ที่เปลี่ยนไปด้วยภาษาที่ตรงและเป็นธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-balance-signal',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before: 'ให้ใช้ยอดคงเหลือที่เปลี่ยนต่อเนื่องเป็นสัญญาณ',
      after: 'ให้สังเกตว่ายอดคงเหลือเปลี่ยนไปอย่างไร',
      semanticIntent:
          'คงสัญญาณจากยอดคงเหลือโดยเปลี่ยนจากศัพท์เชิงกลไกเป็นคำสังเกตที่อ่านง่าย',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-recovery-signal',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before: 'ให้ใช้เวลาฟื้นตัวหลังสัปดาห์หนักเป็นสัญญาณ',
      after: 'ให้สังเกตว่าใช้เวลาฟื้นตัวหลังสัปดาห์หนักนานขึ้นหรือไม่',
      semanticIntent:
          'คงสัญญาณจากเวลาฟื้นตัวโดยเขียนเป็นสิ่งที่ผู้อ่านสังเกตได้โดยตรง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-agreement-signal',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before: 'ให้ใช้คำพูดที่กลายเป็นพฤติกรรมสม่ำเสมอเป็นสัญญาณ',
      after: 'ให้ดูว่าคำพูดเปลี่ยนเป็นการกระทำที่สม่ำเสมอหรือไม่',
      semanticIntent:
          'คงสัญญาณความสม่ำเสมอระหว่างคำพูดกับการกระทำด้วยประโยคที่ตรงขึ้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-agreement-review-start',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before: 'แล้วกลับมาทบทวนเมื่อพฤติกรรมหลังข้อตกลงเริ่มชัด',
      after: 'แล้วทบทวนอีกครั้งเมื่อการทำตามข้อตกลงสม่ำเสมอขึ้น',
      semanticIntent:
          'คงจุดทบทวนจากพฤติกรรมหลังข้อตกลงโดยระบุการทำตามข้อตกลงให้ชัด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-agreement-review-clear',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before: 'แล้วทบทวนอีกครั้งเมื่อพฤติกรรมหลังข้อตกลงชัดขึ้น',
      after: 'แล้วทบทวนอีกครั้งเมื่อการทำตามข้อตกลงสม่ำเสมอขึ้น',
      semanticIntent:
          'คงจุดทบทวนเดิมและแทนคำนามนามธรรมด้วยพฤติกรรมที่สังเกตได้',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-agreement-review-short',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before: 'แล้วทบทวนเมื่อพฤติกรรมหลังข้อตกลงชัดขึ้น',
      after: 'แล้วทบทวนเมื่อการทำตามข้อตกลงสม่ำเสมอขึ้น',
      semanticIntent: 'คงจุดทบทวนเดิมและระบุการทำตามข้อตกลงด้วยภาษาที่ชัดเจน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-theme-no-fixed-event',
      sourceTemplate: 'PredictionWindowCardModel.summary',
      fieldPathPrefix: 'infographic.theme',
      before: 'แทนการกำหนดเหตุการณ์ล่วงหน้า',
      after: 'โดยไม่สรุปเหตุการณ์ล่วงหน้า',
      semanticIntent:
          'รักษาขอบเขตไม่กำหนดเหตุการณ์ล่วงหน้าด้วยถ้อยคำที่เป็นธรรมชาติขึ้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-category-transition-reserve',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact',
      fieldPathPrefix: 'infographic.categories',
      before: 'และกันแรงไว้สำหรับรอยต่อของช่วงชีวิต',
      after: 'และเผื่อแรงไว้ในช่วงเปลี่ยนผ่าน',
      semanticIntent:
          'คงการสำรองแรงสำหรับช่วงเปลี่ยนผ่านด้วยคำที่สั้นและเป็นธรรมชาติขึ้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-category-transition-reserve-relocated',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact',
      fieldPathPrefix: 'infographic.categories',
      before: ' และเผื่อแรงไว้ในช่วงเปลี่ยนผ่าน',
      after: '',
      semanticIntent:
          'ย้ายคำแนะนำทั่วไปเรื่องสำรองแรงไป annual guidance เพียงตำแหน่งเดียว โดยคงสาระระดับรายงาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-career-strong',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact(career)',
      fieldPathPrefix: 'infographic.categories',
      before:
          'รับบทบาทเพิ่มได้หนึ่งก้าวเมื่อคุณภาพงานหลักยังคงเดิม โดยไม่แลกกับคุณภาพงานหลัก',
      after: 'รับบทบาทเพิ่มได้ทีละขั้น หากงานหลักยังรักษาคุณภาพได้ตามเดิม',
      semanticIntent:
          'คงเงื่อนไขการขยายบทบาทโดยตัดคำนามซ้ำและระบุงานหลักให้ชัด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-finance-strong',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact(finance)',
      fieldPathPrefix: 'infographic.categories',
      before:
          'ขยับภาระได้เมื่อกันเงินพร้อมใช้ไว้ครบแล้ว โดยไม่ลดเงินที่ต้องพร้อมใช้',
      after: 'ขยายแผนการเงินได้ เมื่อกันค่าใช้จ่ายจำเป็นและเงินสำรองไว้ครบแล้ว',
      semanticIntent:
          'คงเงื่อนไขสภาพคล่องเดิมและแทนคำซ้ำด้วยรายการเงินที่ต้องกันไว้',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-relationship-strong',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact(relationship)',
      fieldPathPrefix: 'infographic.categories',
      before:
          'เพิ่มข้อผูกพันได้เมื่อคำพูดและการกระทำสอดคล้องกัน โดยให้ความคาดหวังของทั้งสองฝ่ายตรงกันก่อน',
      after:
          'เพิ่มข้อผูกพันได้เมื่อคำพูดและการกระทำสอดคล้องกัน และทั้งสองฝ่ายเข้าใจตรงกัน',
      semanticIntent:
          'คงเงื่อนไขความสม่ำเสมอและความเข้าใจร่วมกันด้วยคำเชื่อมที่เป็นธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-relationship-active',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact(relationship)',
      fieldPathPrefix: 'infographic.categories',
      before:
          'ทดลองข้อตกลงเล็กและดูความสม่ำเสมอก่อนผูกพันเพิ่ม โดยให้ความคาดหวังของทั้งสองฝ่ายตรงกันก่อน',
      after:
          'เริ่มจากข้อตกลงเล็ก ๆ แล้วดูความสม่ำเสมอ ก่อนเพิ่มข้อผูกพันเมื่อทั้งสองฝ่ายเข้าใจตรงกัน',
      semanticIntent:
          'คงลำดับทดลองข้อตกลง ตรวจความสม่ำเสมอ และยืนยันความเข้าใจร่วมกัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-health-strong',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact(health)',
      fieldPathPrefix: 'infographic.categories',
      before:
          'เพิ่มกิจกรรมได้เมื่อเวลาพักและการฟื้นตัวยังคงพอ โดยให้เวลาพักและการฟื้นตัวจริงเป็นเพดาน',
      after:
          'เพิ่มกิจกรรมได้เมื่อพักแล้วฟื้นตัวได้ตามปกติ หากฟื้นช้าลงควรลดภาระ',
      semanticIntent:
          'คงเกณฑ์การฟื้นตัวเดิมและตัดคำซ้ำโดยไม่เพิ่มข้อสรุปด้านสุขภาพ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-health-active',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact(health)',
      fieldPathPrefix: 'infographic.categories',
      before:
          'ทดลองกิจกรรมทีละขั้นและใช้การฟื้นตัวจริงเป็นเพดาน โดยให้เวลาพักและการฟื้นตัวจริงเป็นเพดาน',
      after:
          'ค่อย ๆ เพิ่มกิจกรรมและใช้เวลาฟื้นตัวเป็นเกณฑ์ หากฟื้นช้าลงควรลดภาระ',
      semanticIntent:
          'คงการทดลองทีละขั้นและเกณฑ์การฟื้นตัวโดยตัดข้อความที่ซ้ำกัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-unknown-evidence-boundary',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact(noLagna)',
      fieldPathPrefix: 'infographic.categories',
      before: ' จึงควรยืนยันจากผลที่เกิดซ้ำก่อนตัดสินใจ',
      after: ' ควรดูผลที่เกิดซ้ำก่อนตัดสินใจ',
      semanticIntent:
          'รักษาเงื่อนไข fail-closed ของ Unknown ด้วยถ้อยคำสั้นที่ยังต้องตรวจผลซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-unknown-category-boundary-relocated',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact(noLagna)',
      fieldPathPrefix: 'infographic.categories',
      before: ' ควรดูผลที่เกิดซ้ำก่อนตัดสินใจ',
      after: '',
      semanticIntent:
          'ย้ายคำเตือน fail-closed ที่ซ้ำในสี่หมวดไป disclaimer ครั้งเดียว โดยคงเงื่อนไขการตรวจผลซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-career-strong',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before:
          'รับบทบาทเพิ่มได้หนึ่งก้าวเมื่อคุณภาพงานหลักยังคงเดิม โดยไม่แลกกับคุณภาพงานหลัก',
      after: 'โอกาสอยู่ที่การรับบทบาทเพิ่มทีละขั้น โดยยังรักษาคุณภาพงานหลัก',
      semanticIntent:
          'สรุปโอกาสจากสัญญาณการงานเดิมโดยไม่คัดลอกข้อความหมวดการงานทั้งประโยค',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-transition-reserve',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'และกันแรงไว้สำหรับรอยต่อของช่วงชีวิต',
      after: 'และเผื่อแรงไว้ในช่วงเปลี่ยนผ่าน',
      semanticIntent:
          'คงการสำรองแรงสำหรับช่วงเปลี่ยนผ่านในสรุปโอกาสด้วยถ้อยคำที่กระชับขึ้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-transition-reserve-relocated',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: ' และเผื่อแรงไว้ในช่วงเปลี่ยนผ่าน',
      after: '',
      semanticIntent:
          'ย้ายคำแนะนำทั่วไปเรื่องสำรองแรงจากแถบโอกาสไป annual guidance ครั้งเดียว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-career-active',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'ทดลองขอบเขตงานใหม่ก่อนตัดสินใจรับบทบาทเต็มตัว',
      after: 'โอกาสอยู่ที่การทดลองขอบเขตงานใหม่ในวงเล็ก',
      semanticIntent: 'คงการทดลองก่อนรับบทบาทเต็มตัวด้วยข้อความโอกาสที่สั้นลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-career-quiet',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'หยุดเพิ่มงานและคืนเวลาให้งานหลักก่อน',
      after: 'จังหวะนี้เปิดพื้นที่ให้คืนเวลาแก่งานหลัก',
      semanticIntent: 'คงการชะลอรับงานและการคืนเวลาให้งานหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-finance-strong',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'ขยับภาระได้เมื่อกันเงินพร้อมใช้ไว้ครบแล้ว',
      after: 'โอกาสอยู่ที่การขยายแผนเมื่อมีเงินพร้อมใช้เพียงพอ',
      semanticIntent: 'คงเงื่อนไขเงินพร้อมใช้ก่อนขยายภาระ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-finance-active',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'พิสูจน์กระแสเงินจริงในวงเล็กก่อนเพิ่มภาระ',
      after: 'โอกาสอยู่ที่การทดสอบกระแสเงินในวงเล็ก',
      semanticIntent: 'คงการทดสอบกระแสเงินจริงก่อนเพิ่มภาระ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-finance-quiet',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'ชะลอรายจ่ายก้อนใหม่และรักษาเงินพร้อมใช้',
      after: 'จังหวะนี้เปิดพื้นที่ให้รักษาเงินพร้อมใช้',
      semanticIntent: 'คงการชะลอรายจ่ายใหม่และรักษาสภาพคล่อง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-relationship-strong',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'เพิ่มข้อผูกพันได้เมื่อคำพูดและการกระทำสอดคล้องกัน',
      after: 'โอกาสอยู่ที่การเพิ่มข้อผูกพันบนความสม่ำเสมอ',
      semanticIntent: 'คงเงื่อนไขคำพูดและการกระทำที่สอดคล้องกัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-relationship-active',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'ทดลองข้อตกลงเล็กและดูความสม่ำเสมอก่อนผูกพันเพิ่ม',
      after: 'โอกาสอยู่ที่การเริ่มจากข้อตกลงเล็กและดูความต่อเนื่อง',
      semanticIntent: 'คงการทดลองข้อตกลงและตรวจความสม่ำเสมอก่อนผูกพันเพิ่ม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-relationship-quiet',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'รอความชัดของเงื่อนไขก่อนเพิ่มข้อผูกพัน',
      after: 'จังหวะนี้เปิดพื้นที่ให้รอเงื่อนไขชัดขึ้น',
      semanticIntent: 'คงการรอความชัดก่อนเพิ่มข้อผูกพัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-health-strong',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'เพิ่มกิจกรรมได้เมื่อเวลาพักและการฟื้นตัวยังคงพอ',
      after: 'โอกาสอยู่ที่การเพิ่มกิจกรรมเมื่อร่างกายยังฟื้นตัวได้ตามปกติ',
      semanticIntent: 'คงเงื่อนไขการฟื้นตัวก่อนเพิ่มกิจกรรม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-health-active',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'ทดลองกิจกรรมทีละขั้นและใช้การฟื้นตัวจริงเป็นเพดาน',
      after: 'โอกาสอยู่ที่การค่อย ๆ ทดลองกิจกรรมใหม่',
      semanticIntent: 'คงการทดลองทีละขั้นโดยใช้การฟื้นตัวเป็นขอบเขต',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-health-quiet',
      sourceTemplate: 'PredictionWindowCardModel.topOpportunity',
      fieldPathPrefix: 'infographic.opportunity',
      before: 'ลดกิจกรรมและคืนเวลาฟื้นตัวก่อนรับภาระใหม่',
      after: 'จังหวะนี้เปิดพื้นที่ให้คืนเวลาฟื้นตัว',
      semanticIntent: 'คงการลดกิจกรรมและคืนเวลาฟื้นตัวก่อนรับภาระใหม่',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-opportunity-unknown-boundary',
      sourceTemplate: 'ThaiBetaNarrativeComposer._decisionImpact(noLagna)',
      fieldPathPrefix: 'infographic.opportunity',
      before: ' จึงควรยืนยันจากผลที่เกิดซ้ำก่อนตัดสินใจ',
      after: ' โดยดูผลที่เกิดซ้ำก่อนตัดสินใจ',
      semanticIntent: 'รักษาเงื่อนไขตรวจผลซ้ำของ Unknown ในแถบโอกาส',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-caution-career-reference',
      sourceTemplate: 'ThaiBetaNarrativeComposer._riskSignal(career)',
      fieldPathPrefix: 'infographic.caution',
      before: 'งานหลักอาจถูกภาระด้านนี้เบียดเวลา',
      after: 'ภาระงานที่เพิ่มขึ้นอาจเบียดเวลาของงานหลัก',
      semanticIntent: 'ระบุภาระงานแทนคำอ้างอิงกำกวมโดยคงความเสี่ยงเดิม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-caution-finance-reference',
      sourceTemplate: 'ThaiBetaNarrativeComposer._riskSignal(finance)',
      fieldPathPrefix: 'infographic.caution',
      before: 'ภาระเงินอาจลดพื้นที่ตัดสินใจในด้านนี้',
      after: 'ภาระการเงินอาจลดทางเลือกในการตัดสินใจ',
      semanticIntent: 'ระบุความเสี่ยงด้านการเงินโดยตัดคำอ้างอิงกำกวม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-caution-health-reference',
      sourceTemplate: 'ThaiBetaNarrativeComposer._riskSignal(health)',
      fieldPathPrefix: 'infographic.caution',
      before: 'การพักไม่พออาจลดกำลังสำหรับด้านนี้',
      after: 'การพักไม่พออาจทำให้กำลังลดลง',
      semanticIntent: 'คงความเสี่ยงจากการพักไม่พอโดยตัดคำอ้างอิงกำกวม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-known-reading-flow',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      fieldPathPrefix: 'infographic.primaryAdvice',
      before:
          'ใช้ความถนัดในการสร้างฐานทีละขั้นเลือกทางงานที่ทำให้บทบาทใหม่เพิ่มคุณภาพงาน ไม่ใช่เพียงเพิ่มจำนวนงาน พร้อมรักษาพฤติกรรมที่ทำตามคำตกลงไว้',
      after:
          'ใช้ความถนัดในการสร้างฐานทีละขั้น เลือกรับบทบาทที่ช่วยให้งานดีขึ้น ไม่ใช่เพียงทำให้งานมากขึ้น และรักษาสิ่งที่ตกลงกันไว้',
      semanticIntent:
          'เติมจังหวะและคำเชื่อมให้คำแนะนำเดิมอ่านต่อเนื่องโดยไม่เปลี่ยนข้อเสนอ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-unknown-reading-flow',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing(noLagna)',
      fieldPathPrefix: 'infographic.primaryAdvice',
      before:
          'ใช้ความสามารถในการทำความคิดให้คนอื่นเข้าใจกับข้อมูลที่เกิดซ้ำจริง: เลือกงานทีละก้าว และยังไม่ผูกมัดเพิ่มจนกว่าพฤติกรรมที่ทำตามคำตกลงจะยืนยันได้',
      after:
          'อธิบายความคิดให้คนอื่นเข้าใจด้วยข้อมูลที่เกิดซ้ำจริง เลือกงานทีละก้าว และรอให้พฤติกรรมยืนยันข้อตกลงก่อนผูกมัดเพิ่ม',
      semanticIntent:
          'คงการใช้ข้อมูลซ้ำ เลือกงานทีละก้าว และรอยืนยันข้อตกลงด้วยประโยคที่ลื่นไหลขึ้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-repeated-data-phrase',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing(noLagna)',
      fieldPathPrefix: 'infographic.primaryAdvice',
      before: 'กับข้อมูลที่เกิดซ้ำจริง:',
      after: 'โดยอาศัยข้อมูลที่เกิดขึ้นซ้ำ:',
      semanticIntent:
          'คงเงื่อนไขใช้ข้อมูลที่เกิดซ้ำโดยตัดโครงสร้างคำนามที่แข็งและอ่านสะดุด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-agreement-proof',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing(noLagna)',
      fieldPathPrefix: 'infographic.primaryAdvice',
      before: 'และยังไม่ผูกมัดเพิ่มจนกว่าพฤติกรรมที่ทำตามคำตกลงจะยืนยันได้',
      after: 'และรอให้การทำตามข้อตกลงสม่ำเสมอก่อนผูกมัดเพิ่ม',
      semanticIntent:
          'คงเงื่อนไขรอยืนยันข้อตกลงก่อนผูกมัดเพิ่มด้วยประโยคที่สั้นและมีประธานชัด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-communication-reading-flow',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      fieldPathPrefix: 'infographic.primaryAdvice',
      before:
          'ใช้ความสามารถในการทำความคิดให้คนอื่นเข้าใจเลือกทางงานที่ทำให้บทบาทใหม่เพิ่มคุณภาพงาน ไม่ใช่เพียงเพิ่มจำนวนงาน พร้อมรักษาพฤติกรรมที่ทำตามคำตกลงไว้',
      after:
          'ใช้การสื่อสารให้คนอื่นเข้าใจ แล้วเลือกบทบาทใหม่ที่เพิ่มคุณภาพงานมากกว่าปริมาณ พร้อมรักษาสิ่งที่ตกลงกันไว้',
      semanticIntent:
          'คงจุดแข็งด้านการสื่อสาร ทางเลือกบทบาทใหม่ เกณฑ์คุณภาพเหนือปริมาณ และการรักษาข้อตกลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-steady-foundation',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้ความถนัดในการสร้างฐานทีละขั้นเลือกทาง',
      after: 'ใช้ความถนัดในการสร้างฐานทีละขั้น แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-new-options',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้แรงเรียนรู้จากทางเลือกใหม่เลือกทาง',
      after: 'ใช้แรงเรียนรู้จากทางเลือกใหม่ แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-self-direction',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้การกำหนดทิศทางด้วยตัวเองเลือกทาง',
      after: 'ใช้การกำหนดทิศทางด้วยตัวเอง แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-detail',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้ความสามารถในการเห็นรายละเอียดเลือกทาง',
      after: 'ใช้ความสามารถในการเห็นรายละเอียด แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-endurance',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้ความอดทนที่พาเรื่องยากไปต่อเลือกทาง',
      after: 'ใช้ความอดทนที่พาเรื่องยากไปต่อ แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-growth-drive',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้แรงผลักให้พัฒนาเป้าหมายเลือกทาง',
      after: 'ใช้แรงผลักให้พัฒนาเป้าหมาย แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-discipline',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้วินัยที่ทำเรื่องยากต่อเนื่องเลือกทาง',
      after: 'ใช้วินัยที่ทำเรื่องยากต่อเนื่อง แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-empathy',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้ความเข้าใจคนและมุมมองที่ต่างกันเลือกทาง',
      after: 'ใช้ความเข้าใจคนและมุมมองที่ต่างกัน แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-option-building',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้ความสามารถในการสร้างทางเลือกใหม่เลือกทาง',
      after: 'ใช้ความสามารถในการสร้างทางเลือกใหม่ แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-communication',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้ความสามารถในการถ่ายทอดความคิดให้คนอื่นเข้าใจเลือกทาง',
      after: 'ใช้ความสามารถในการถ่ายทอดความคิดให้คนอื่นเข้าใจ แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-practical',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้ความถนัดในการทำเรื่องให้เกิดผลจริงเลือกทาง',
      after: 'ใช้ความถนัดในการทำเรื่องให้เกิดผลจริง แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-protective',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้ความตั้งใจดูแลสิ่งสำคัญเลือกทาง',
      after: 'ใช้ความตั้งใจดูแลสิ่งสำคัญ แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-advice-connective-adaptable',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ใช้ความสามารถในการปรับตามเงื่อนไขเลือกทาง',
      after: 'ใช้ความสามารถในการปรับตามเงื่อนไข แล้วเลือกทาง',
      semanticIntent:
          'เติมคำเชื่อมระหว่างจุดแข็งกับการเลือกทาง โดยคงจุดแข็ง ทางเลือก และเงื่อนไขเดิมทุกประการ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-unknown-closing-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before:
          'ใช้ความสามารถในการถ่ายทอดความคิดให้คนอื่นเข้าใจโดยอาศัยข้อมูลที่เกิดขึ้นซ้ำ: เลือกงานทีละก้าว และยังไม่ผูกมัดเพิ่มจนกว่าการทำตามข้อตกลงจะยืนยันได้',
      after:
          'ถ่ายทอดความคิดให้ชัดเจน และตัดสินใจจากผลที่เกิดซ้ำจริง เลือกงานทีละก้าว และยังไม่เพิ่มข้อผูกพันจนกว่าการทำตามข้อตกลงจะยืนยันได้',
      semanticIntent:
          'คงจุดแข็งด้านการสื่อสาร การตัดสินใจจากผลซ้ำ ลำดับงาน และเงื่อนไขข้อผูกพันเดิม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'copy-unknown-report-closing-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before:
          'ใช้ความสามารถในการถ่ายทอดความคิดให้คนอื่นเข้าใจกับข้อมูลที่เกิดซ้ำจริง: เลือกงานทีละก้าว และยังไม่ผูกมัดเพิ่มจนกว่าการทำตามข้อตกลงจะยืนยันได้',
      after:
          'ถ่ายทอดความคิดให้ชัดเจน และตัดสินใจจากผลที่เกิดซ้ำจริง เลือกงานทีละก้าว และยังไม่เพิ่มข้อผูกพันจนกว่าการทำตามข้อตกลงจะยืนยันได้',
      semanticIntent:
          'ทำให้ข้อสรุปในเนื้อหารายงานตรงกับ infographic โดยคงความหมายและเงื่อนไขเดิม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-current-money-balance',
      sourceTemplate: 'LifeMapCurrentDomainComposer.money',
      before: 'ด้านการเงินคุณอยากใช้เงินวันนี้ แต่ยังต้องเก็บเพื่อแผนระยะยาว',
      after:
          'ด้านการเงินควรรักษาสมดุลระหว่างค่าใช้จ่ายในปัจจุบันกับเงินที่ต้องเตรียมไว้สำหรับแผนระยะยาว',
      semanticIntent: 'คงสมดุลเงินปัจจุบันกับแผนระยะยาวด้วยภาษาที่ชัดเจน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-relationship-agreement-continuity',
      sourceTemplate: 'ThaiBetaNarrativeComposer.relationship',
      before:
          'ข้อตกลงที่ถูกทำต่อเนื่องจะทำให้ความสัมพันธ์ชัด ไม่ใช่บทสนทนาครั้งเดียว',
      after:
          'การที่ทั้งสองฝ่ายปฏิบัติตามข้อตกลงอย่างต่อเนื่อง จะช่วยให้เห็นทิศทางความสัมพันธ์ชัดขึ้น ไม่ใช่อาศัยเพียงบทสนทนาครั้งเดียว',
      semanticIntent: 'คงเกณฑ์พฤติกรรมต่อเนื่องโดยระบุประธานและกริยาให้ชัด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-next-work-delegation',
      sourceTemplate: 'ThaiBetaNarrativeComposer.next.work',
      before: 'ส่งต่อส่วนที่กระจายแรง',
      after: 'ส่งต่องานส่วนที่ทำให้ต้องแบ่งแรงไปหลายทาง',
      semanticIntent: 'คงความหมายเรื่องส่งต่องานที่ทำให้เสียสมาธิ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-next-money-foundation',
      sourceTemplate: 'ThaiBetaNarrativeComposer.next.money',
      before: 'ฐานเงินของจังหวะใหม่',
      after: 'ฐานะการเงินในช่วงชีวิตถัดไป',
      semanticIntent: 'คงฐานะการเงินระยะถัดไปด้วยคำที่คนทั่วไปใช้',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-next-wellbeing-routine',
      sourceTemplate: 'ThaiBetaNarrativeComposer.next.wellbeing',
      before: 'กิจวัตรพลังชีวิตต้องเปลี่ยนพร้อมตารางใหม่',
      after: 'ควรปรับกิจวัตรการพักและการฟื้นตัวให้สอดคล้องกับตารางชีวิตใหม่',
      semanticIntent: 'คงการปรับกิจวัตรตามตารางใหม่โดยใช้ถ้อยคำที่เป็นธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-past-choice-shapes-decisions',
      sourceTemplate: 'ThaiBetaPastReflection.question',
      before: 'ตัวเลือกครั้งนั้นหล่อวิธีรับมือการตัดสินใจวันนี้อย่างไร',
      after: 'ทางเลือกครั้งนั้นหล่อหลอมวิธีตัดสินใจของคุณในวันนี้อย่างไร',
      semanticIntent: 'คงคำถามเชื่อมทางเลือกในอดีตกับวิธีตัดสินใจปัจจุบัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-current-learning-budget',
      sourceTemplate: 'LifeMapCurrentDomainComposer.money',
      before: 'แยกงบทดลองสำหรับการเรียนรู้ออกจากเงินที่ต้องใช้ประจำ',
      after: 'แยกงบสำหรับทดลองหรือเรียนรู้สิ่งใหม่ออกจากค่าใช้จ่ายประจำ',
      semanticIntent: 'คงการแยกงบทดลองจากค่าใช้จ่ายประจำด้วยภาษาทั่วไป',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-current-income-basis',
      sourceTemplate: 'LifeMapCurrentDomainComposer.money',
      before: 'จังหวะนี้ให้ใช้รายรับจริงเป็นฐาน',
      after: 'ช่วงนี้ให้ใช้รายรับจริงเป็นหลัก',
      semanticIntent: 'คงเกณฑ์รายรับจริงโดยลดคำเชิงแม่แบบ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-current-work-hours-basis',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.current.work',
      before: 'ชั่วโมงทำงานที่เกิดขึ้นจริงควรเป็นฐานตัดสิน',
      after: 'ควรใช้ชั่วโมงทำงานที่เกิดขึ้นจริงเป็นหลักในการตัดสินใจ',
      semanticIntent: 'คงชั่วโมงทำงานจริงเป็นหลักฐานตัดสินใจ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-current-money-records-basis',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.current.money',
      before:
          'รายรับ รายจ่าย และยอดคงเหลือจริงเป็นฐานเดียวที่ใช้พิจารณาข้อผูกพันทางการเงินได้',
      after:
          'ควรพิจารณาข้อผูกพันทางการเงินจากรายรับ รายจ่าย และยอดคงเหลือที่เกิดขึ้นจริง',
      semanticIntent: 'คงข้อมูลการเงินจริงเป็นหลักพิจารณาข้อผูกพัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-childhood-decision-foundation',
      sourceTemplate: 'ThaiBetaPastReflection.question',
      before: 'และความทรงจำนั้นบอกอะไรเกี่ยวกับฐานที่คุณใช้ตัดสินใจวันนี้',
      after: 'และความทรงจำนั้นยังมีผลต่อการตัดสินใจของคุณวันนี้อย่างไร',
      semanticIntent: 'คงการเชื่อมความทรงจำกับการตัดสินใจปัจจุบัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-recurring-income',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annual.money',
      before: 'ยอดรับที่เกิดซ้ำ',
      after: 'รายรับที่เข้ามาอย่างสม่ำเสมอ',
      semanticIntent: 'คงหลักฐานรายรับต่อเนื่องโดยใช้คำทางการเงินที่ชัดเจน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-repeatable-work-samples',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annual.work',
      before: 'เก็บตัวอย่างผลงานเป็นรอบและค่อยเลือกบทบาทจากแบบที่ทำซ้ำได้',
      after:
          'เก็บตัวอย่างผลงานอย่างต่อเนื่อง แล้วเลือกบทบาทจากงานที่คุณทำได้ดีอย่างสม่ำเสมอ',
      semanticIntent: 'คงการใช้ผลงานต่อเนื่องเป็นเกณฑ์เลือกบทบาท',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-repeatable-work-pattern',
      sourceTemplate: 'ThaiBetaNarrativeComposer.next.work',
      before: 'รูปแบบงานที่ทำซ้ำได้จริง',
      after: 'รูปแบบงานที่คุณทำได้ดีอย่างสม่ำเสมอ',
      semanticIntent: 'คงเกณฑ์งานที่ทำได้ต่อเนื่องโดยลดภาษานามธรรม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-repeated-observable-result',
      sourceTemplate: 'ThaiBetaNarrativeComposer.future',
      before: 'ผลเดิมเกิดซ้ำและตรวจสอบได้',
      after: 'ผลแบบเดิมเกิดขึ้นอย่างสม่ำเสมอและตรวจสอบได้',
      semanticIntent: 'คงเงื่อนไขผลซ้ำที่ตรวจสอบได้ด้วยประโยคธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-repeated-relationship-behavior',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annual.relationship',
      before: 'พฤติกรรมที่เกิดซ้ำเป็นสัญญาณสำคัญ',
      after: 'พฤติกรรมที่เห็นอย่างสม่ำเสมอเป็นสัญญาณสำคัญ',
      semanticIntent: 'คงหลักฐานจากพฤติกรรมต่อเนื่องด้วยภาษาทั่วไป',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-repeated-agreement-review',
      sourceTemplate: 'ThaiBetaNarrativeComposer.selectiveAction',
      before: 'ทบทวนข้อตกลงตามพฤติกรรมที่เกิดซ้ำ',
      after: 'ทบทวนข้อตกลงจากพฤติกรรมที่เห็นอย่างสม่ำเสมอ',
      semanticIntent: 'คงการทบทวนข้อตกลงจากพฤติกรรมต่อเนื่อง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-closing-observable-results',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'ตัดสินใจจากผลที่เกิดซ้ำจริง',
      after: 'ตัดสินใจจากผลที่เกิดขึ้นอย่างสม่ำเสมอและตรวจสอบได้',
      semanticIntent: 'คงการตัดสินใจจากผลซ้ำที่ยืนยันได้ด้วยถ้อยคำชัดเจน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-rest-without-borrowing-energy',
      sourceTemplate: 'ThaiBetaNarrativeComposer.next.wellbeing',
      before: 'โดยไม่ยืมแรงจากวันต่อไป',
      after: 'โดยไม่ฝืนจนต้องพักชดเชยในวันถัดไป',
      semanticIntent: 'คงข้อจำกัดการใช้แรงโดยหลีกเลี่ยงอุปมาเชิงนามธรรม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-current-recovery-capacity',
      sourceTemplate: 'LifeMapCurrentDomainComposer.wellbeing',
      before: 'ช่วงนี้พลังชีวิตพอไปได้หากจัดจังหวะพักสม่ำเสมอ',
      after: 'ช่วงนี้ร่างกายยังรับภาระได้ หากพักอย่างสม่ำเสมอ',
      semanticIntent: 'คงเงื่อนไขกำลังและการพักด้วยภาษาที่ตรงไปตรงมา',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-current-recovery-before-expansion',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.current.wellbeing',
      before: 'พลังของคุณยังรองรับการขยับได้',
      after: 'ร่างกายยังพร้อมรองรับกิจกรรมเพิ่ม',
      semanticIntent: 'คงเกณฑ์ฟื้นตัวก่อนเพิ่มกิจกรรมโดยระบุความหมายให้ชัด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-effort-worth-choosing',
      sourceTemplate: 'ThaiBirthProfileCoreReading.closing',
      before: 'เลือกสิ่งที่คู่ควรกับแรงของคุณ',
      after: 'เลือกสิ่งที่คุ้มกับเวลาและกำลังที่มี',
      semanticIntent: 'คงหลักเลือกภาระให้เหมาะกับกำลังด้วยภาษาทั่วไป',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-repeatable-system',
      sourceTemplate: 'ThaiBirthProfileCoreReading.closing',
      before: 'วางระบบที่ทำซ้ำได้',
      after: 'วางระบบที่ทำตามได้อย่างต่อเนื่อง',
      semanticIntent: 'คงระบบที่ทำต่อเนื่องได้โดยลดภาษาเชิงเทคนิค',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-future-domain-priorities',
      sourceTemplate: 'ThaiBetaNarrativeComposer.futureSummary',
      before: 'งาน เงิน ความสัมพันธ์ และการพักจึงมีหน้าที่ต่างกันในแต่ละระยะ',
      after: 'แต่ละช่วงควรให้น้ำหนักกับงาน เงิน ความสัมพันธ์ และการพักต่างกัน',
      semanticIntent: 'คงบทบาทต่างกันของแต่ละด้านในแต่ละช่วง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-new-work-role',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.current.work',
      before: 'บทบาทงานก้อนใหม่มีแรงส่ง',
      after: 'มีโอกาสได้รับบทบาทงานใหม่',
      semanticIntent: 'คงโอกาสจากบทบาทใหม่โดยลดถ้อยคำเชิงนามธรรม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-recovery-duration-log',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.wellbeing',
      before: 'จดเวลาคืนแรงหลังสัปดาห์หนัก',
      after: 'จดระยะเวลาที่ร่างกายใช้ฟื้นตัวหลังสัปดาห์ที่มีภาระหนัก',
      semanticIntent: 'คงการบันทึกระยะฟื้นตัวหลังภาระหนัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-recovery-comparison',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annual.wellbeing',
      before:
          'เปรียบเทียบเดือนที่หน้าที่เบากับเดือนที่หลายเรื่องชนกัน เพื่อดูว่าการนอนและการคืนแรงเปลี่ยนอย่างไร',
      after:
          'เปรียบเทียบเดือนที่ภาระเบากับเดือนที่มีภาระหลายด้านพร้อมกัน เพื่อดูว่าการนอนและการฟื้นตัวเปลี่ยนไปอย่างไร',
      semanticIntent: 'คงการเปรียบเทียบภาระกับการนอนและการฟื้นตัว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-next-financial-position',
      sourceTemplate: 'ThaiBetaNarrativeComposer.next.money',
      before: 'ฐานการเงินอาจเปลี่ยนตามหน้าที่ใหม่',
      after: 'ฐานะการเงินอาจเปลี่ยนตามหน้าที่ใหม่',
      semanticIntent: 'คงความเปลี่ยนแปลงด้านการเงินด้วยคำที่เป็นธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-repeatable-work-selection',
      sourceTemplate: 'ThaiBetaNarrativeComposer.next.work',
      before:
          'รูปแบบงานที่คุณทำได้ดีอย่างสม่ำเสมอจะช่วยเลือกสิ่งที่ควรรักษาหรือส่งต่อในระยะใหม่',
      after:
          'ผลงานที่คุณทำได้ดีอย่างสม่ำเสมอจะช่วยให้เห็นว่างานใดควรรักษาไว้หรืองานใดควรส่งต่อในช่วงถัดไป',
      semanticIntent: 'คงการใช้ผลงานสม่ำเสมอเป็นเกณฑ์รักษาหรือส่งต่องาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-financial-decision-label',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.money',
      before: 'ด้านการเงิน ให้ใช้',
      after: 'สำหรับการเงิน ให้ใช้',
      semanticIntent: 'คงเกณฑ์ตัดสินใจด้านการเงินด้วยคำเชื่อมธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-agreement-confirmation',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'จนกว่าการทำตามข้อตกลงจะยืนยันได้',
      after: 'จนกว่าจะเห็นว่าข้อตกลงได้รับการปฏิบัติจริงอย่างต่อเนื่อง',
      semanticIntent: 'คงเงื่อนไขยืนยันข้อตกลงจากการปฏิบัติอย่างต่อเนื่อง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-unknown-repeated-result-lead',
      sourceTemplate: 'ThaiBetaNarrativeComposer.unknown.hook',
      before: 'ให้สิ่งที่เกิดซ้ำจริงนำทาง ก่อนขยับงาน',
      after: 'ดูผลที่เกิดขึ้นอย่างสม่ำเสมอก่อนตัดสินใจขยับเรื่องงาน',
      semanticIntent: 'คงการรอผลต่อเนื่องก่อนตัดสินใจเรื่องงาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-unknown-repeated-result-lead-finance',
      sourceTemplate: 'ThaiBetaNarrativeComposer.unknown.hook',
      before: 'ให้สิ่งที่เกิดซ้ำจริงนำทาง ก่อนขยับการเงิน',
      after: 'ดูผลที่เกิดขึ้นอย่างสม่ำเสมอก่อนตัดสินใจขยับเรื่องการเงิน',
      semanticIntent: 'คงการรอผลต่อเนื่องก่อนตัดสินใจเรื่องการเงิน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-unknown-repeated-result-lead-relationship',
      sourceTemplate: 'ThaiBetaNarrativeComposer.unknown.hook',
      before: 'ให้สิ่งที่เกิดซ้ำจริงนำทาง ก่อนขยับความสัมพันธ์',
      after: 'ดูผลที่เกิดขึ้นอย่างสม่ำเสมอก่อนตัดสินใจขยับเรื่องความสัมพันธ์',
      semanticIntent: 'คงการรอผลต่อเนื่องก่อนตัดสินใจเรื่องความสัมพันธ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-unknown-repeated-result-lead-wellbeing',
      sourceTemplate: 'ThaiBetaNarrativeComposer.unknown.hook',
      before: 'ให้สิ่งที่เกิดซ้ำจริงนำทาง ก่อนขยับการพักและการฟื้นตัว',
      after:
          'ดูผลที่เกิดขึ้นอย่างสม่ำเสมอก่อนตัดสินใจขยับเรื่องการพักและการฟื้นตัว',
      semanticIntent: 'คงการรอผลต่อเนื่องก่อนเพิ่มภาระด้านการพักและการฟื้นตัว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-unknown-future-domain-priorities',
      sourceTemplate: 'ThaiBetaNarrativeComposer.unknown.futureSummary',
      before: 'แต่ละระยะมองงาน เงิน ความสัมพันธ์ และการพักในหน้าที่ต่างกัน',
      after: 'แต่ละช่วงควรให้น้ำหนักกับงาน เงิน ความสัมพันธ์ และการพักต่างกัน',
      semanticIntent: 'คงบทบาทต่างกันของแต่ละด้านในแต่ละช่วง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-transition-listening-period',
      sourceTemplate: 'ThaiBetaNarrativeComposer.transition',
      before: 'จากจังหวะที่รับฟังและปรับตามสถานการณ์',
      after: 'จากช่วงที่เน้นการรับฟังและปรับตามสถานการณ์',
      semanticIntent: 'คงลักษณะช่วงก่อนเปลี่ยนผ่านด้วยคำที่เป็นธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-transition-stability-period',
      sourceTemplate: 'ThaiBetaNarrativeComposer.transition',
      before: 'จากจังหวะที่เน้นความมั่นคง',
      after: 'จากช่วงที่เน้นความมั่นคง',
      semanticIntent: 'คงลักษณะช่วงก่อนเปลี่ยนผ่านด้วยคำที่เป็นธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-transition-adaptation',
      sourceTemplate: 'ThaiBetaNarrativeComposer.transition',
      before: 'โดยต้องปรับตัวกับการเปลี่ยนผ่านมากขึ้น',
      after: 'และต้องปรับตัวต่อความเปลี่ยนแปลงมากขึ้น',
      semanticIntent: 'คงการปรับตัวในช่วงเปลี่ยนผ่านโดยลดคำซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-income-expense-comparison',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annual.money',
      before: 'รายรับที่เข้ามาอย่างสม่ำเสมอต้องถูกเทียบกับรายจ่ายจำเป็น',
      after: 'ควรเปรียบเทียบรายรับที่เข้ามาอย่างสม่ำเสมอกับรายจ่ายจำเป็น',
      semanticIntent: 'คงการเทียบรายรับต่อเนื่องกับรายจ่ายจำเป็น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-relationship-readiness-evidence',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annual.relationship',
      before: 'คนที่พร้อมจะรักษาคำพูดในเรื่องเล็กได้สม่ำเสมอ',
      after:
          'ความพร้อมของอีกฝ่ายเห็นได้จากการรักษาคำพูดในเรื่องเล็กอย่างสม่ำเสมอ',
      semanticIntent: 'คงการใช้พฤติกรรมสม่ำเสมอเป็นหลักฐานความพร้อม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or3-long-term-expense-timing',
      sourceTemplate: 'ThaiBetaNarrativeComposer.next.money',
      before: 'รายจ่ายระยะยาวจึงควรเกิดหลังรายรับจริงเริ่มนิ่ง',
      after: 'จึงควรเพิ่มรายจ่ายระยะยาวเมื่อรายรับจริงเริ่มคงที่แล้ว',
      semanticIntent: 'คงเงื่อนไขรายรับคงที่ก่อนเพิ่มรายจ่ายระยะยาว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'infographic-unknown-disclaimer-review-boundary',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.disclaimer(noLagna)',
      fieldPathPrefix: 'infographic.disclaimer',
      before:
          'ไม่มีเวลาเกิด จึงแสดงเฉพาะแนวโน้มที่ข้อมูลรองรับและไม่เติมรายละเอียดที่ขาดหาย',
      after: 'ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด',
      semanticIntent:
          'ระบุการเว้นผลแบบ fail-closed ให้ตรงกันกับ Web และ PDF โดยไม่สื่อว่าระบบเติมข้อมูลที่ขาด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-financial-progress-options',
      sourceTemplate: 'ThaiBirthProfileCoreReading.money',
      before:
          'ความก้าวหน้าทางการเงินควรวัดจากความยืดหยุ่นที่เงินสำรองมอบให้ ไม่ใช่ดูเพียงยอดเงินที่สะสมไว้',
      after:
          'เรื่องเงิน อย่าดูแค่ว่าเก็บได้มากแค่ไหน ให้ดูด้วยว่าเงินสำรองช่วยให้คุณมีทางเลือกมากพอหรือยัง',
      semanticIntent:
          'คงการประเมินความมั่นคงจากทางเลือกที่เงินสำรองรองรับ ไม่ใช่จากยอดสะสมเพียงอย่างเดียว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-finance-ready-cash',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.supportingCurrentContext',
      before:
          'สำหรับการเงิน ให้ใช้จำนวนเงินพร้อมใช้หลังรายการจำเป็นเป็นเกณฑ์ตัดสินใจ',
      after:
          'ก่อนตัดสินใจเรื่องเงิน ให้ดูว่าเมื่อจ่ายรายการจำเป็นแล้ว คุณยังเหลือเงินพร้อมใช้เท่าไร',
      semanticIntent: 'คงการใช้เงินพร้อมใช้หลังรายจ่ายจำเป็นเป็นข้อมูลตัดสินใจ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-current-water-phase',
      sourceTemplate: 'LifeMapCurrentPeriodComposer.elementContext',
      before:
          'พลังธาตุน้ำหนุนช่วงเก็บเกี่ยวให้คุณใช้ความสัมพันธ์และความเข้าใจคนประกอบการตัดสินใจ โดยไม่ต้องเร่งทุกเรื่องพร้อมกัน',
      after:
          'ช่วงวัยนี้ คุณตัดสินใจได้ดีขึ้นเมื่อรับฟังคนรอบตัว แต่ไม่จำเป็นต้องตามใจทุกคน และไม่ต้องรีบจัดการทุกเรื่องพร้อมกัน',
      semanticIntent:
          'คงบทบาทของธาตุน้ำด้านการรับฟังและความเข้าใจคน พร้อมข้อจำกัดว่าไม่ต้องเร่งทุกเรื่อง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-work-continuity',
      sourceTemplate: 'ThaiBetaReportNarrativePlan._primaryDirection',
      before: 'งานมีแรงส่งต่อเนื่องจากตอนนี้ไปถึงช่วงถัดไป',
      after: 'เรื่องงานยังมีแนวโน้มเดินหน้าต่อเนื่องไปถึงช่วงถัดไป',
      semanticIntent: 'คงแนวโน้มงานที่ต่อเนื่องจากปัจจุบันไปยังช่วงถัดไป',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-persistence-strength',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.strengthLabel(persistence)',
      before: 'ความอดทนที่พาเรื่องยากไปต่อ',
      after: 'ความอดทนและการทำเรื่องยากอย่างต่อเนื่อง',
      semanticIntent: 'คงจุดแข็งด้านความอดทนและความต่อเนื่องโดยตัดสำนวนกำกวม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-primary-strength-work',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.headline',
      before: 'กลายเป็นแรงสำคัญของงาน',
      after: 'ช่วยให้งานเดินหน้าต่อได้',
      semanticIntent: 'คงความหมายว่าจุดแข็งหลักสนับสนุนการเดินหน้าของงาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-relationship-capacity',
      sourceTemplate: 'ThaiBetaReportNarrativePlan._secondaryPressure',
      before: 'ความสัมพันธ์จะเปราะบางขึ้นเมื่อภาระชุดใหม่เข้ามา',
      after: 'เมื่อรับเรื่องใหม่เพิ่ม ความสัมพันธ์อาจมีพื้นที่น้อยลง',
      semanticIntent:
          'คงความเสี่ยงต่อความสัมพันธ์เมื่อมีภาระใหม่ โดยไม่เพิ่มความแน่นอน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-twelve-month-review',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.next12Months',
      before:
          'ให้ใช้ขอบเขตหน้าที่ที่เปลี่ยนไปเป็นสัญญาณ แล้วกลับมาทบทวนเมื่อพฤติกรรมหลังข้อตกลงเริ่มชัด',
      after:
          'ให้ดูว่าหน้าที่เปลี่ยนไปอย่างไร แล้วทบทวนอีกครั้งเมื่อเห็นว่าแต่ละฝ่ายทำตามที่ตกลงไว้จริงหรือไม่',
      semanticIntent:
          'คงหมุดสังเกตหน้าที่และการทำตามข้อตกลงสำหรับการทบทวน 12 เดือน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-after-agreement-behavior',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.observableLabel',
      before: 'พฤติกรรมหลังข้อตกลง',
      after: 'สิ่งที่แต่ละฝ่ายทำหลังตกลงกัน',
      semanticIntent: 'คงการสังเกตการกระทำของแต่ละฝ่ายหลังมีข้อตกลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-career-role-signal',
      sourceTemplate: 'ThaiBetaNarrativeComposer._forecastClaim(career)',
      before:
          'ขอบเขตหน้าที่ที่กว้างขึ้นคือสัญญาณสำคัญด้านงาน หากอำนาจตัดสินใจไม่เพิ่มตาม งานชิ้นหลักจะเสียคุณภาพ',
      after:
          'ถ้าหน้าที่เพิ่มขึ้น แต่อำนาจตัดสินใจยังเท่าเดิม งานหลักอาจทำได้ไม่ดีเท่าที่ควร',
      semanticIntent:
          'คงความเสี่ยงต่อคุณภาพงานเมื่อหน้าที่เพิ่มแต่อำนาจตัดสินใจไม่เพิ่ม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-finance-recurring-income',
      sourceTemplate: 'ThaiBetaNarrativeComposer._forecastClaim(finance)',
      before:
          'รายรับที่เพิ่มแล้วเหลือเป็นเงินพร้อมใช้คือสัญญาณสำคัญด้านการเงิน หากรายจ่ายประจำโตตามทันที การขยายแผนควรช้าลง',
      after:
          'รายรับที่เพิ่มขึ้นจะช่วยได้จริงเมื่อยังเหลือเป็นเงินพร้อมใช้ ถ้ารายจ่ายประจำเพิ่มตามทันที ควรชะลอแผนใหม่ไว้ก่อน',
      semanticIntent:
          'คงเงื่อนไขเงินพร้อมใช้และการชะลอแผนเมื่อรายจ่ายประจำเพิ่มตามรายรับ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-quarterly-liquidity',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.finance',
      before:
          'บันทึกยอดคงเหลือรายไตรมาสเพื่อดูสภาพคล่อง ตัวเลขที่ดีเพียงครั้งเดียวยังไม่เพียงพอสำหรับการเพิ่มภาระทางการเงิน',
      after:
          'จดยอดเงินคงเหลือทุกสามเดือน แล้วดูว่าดีขึ้นอย่างต่อเนื่องหรือไม่ อย่าเพิ่มรายจ่ายผูกพันเพราะตัวเลขดีเพียงครั้งเดียว',
      semanticIntent:
          'คงการดูยอดคงเหลือเป็นรอบและไม่เพิ่มข้อผูกพันจากผลดีครั้งเดียว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-relationship-observation',
      sourceTemplate: 'ThaiBetaNarrativeComposer.relationship',
      before:
          'การที่ทั้งสองฝ่ายปฏิบัติตามข้อตกลงอย่างต่อเนื่อง จะช่วยให้เห็นทิศทางความสัมพันธ์ชัดขึ้น ไม่ใช่อาศัยเพียงบทสนทนาครั้งเดียว',
      after:
          'เรื่องความสัมพันธ์ อย่าดูแค่สิ่งที่คุยกันครั้งเดียว หลังจากตกลงกันแล้ว ให้ดูต่อว่าแต่ละฝ่ายทำตามที่พูดไว้จริงหรือไม่',
      semanticIntent:
          'คงการประเมินความสัมพันธ์จากพฤติกรรมต่อเนื่องหลังข้อตกลง ไม่ใช่คำพูดครั้งเดียว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-next-relationship',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.boundaryLongTermContext',
      before: 'ระยะยาวต้องแบ่งเวลาและหน้าที่ได้จริง ไม่ใช่เพียงตกลงกันไว้',
      after:
          'ในระยะยาว ให้ดูว่าทั้งสองฝ่ายแบ่งเวลาและหน้าที่กันได้จริง ไม่ใช่แค่พูดตกลงกันไว้',
      semanticIntent:
          'คงการตรวจการแบ่งเวลาและหน้าที่จากการปฏิบัติจริงในระยะยาว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-next-rest-routine',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.supportingLongTermContext',
      before:
          'เลือกกิจวัตรพักที่ทำได้ต่อเนื่อง โดยไม่ฝืนจนต้องพักชดเชยในวันถัดไป',
      after:
          'เลือกวิธีพักที่ทำได้ทุกวัน โดยไม่ฝืนจนวันถัดไปต้องใช้เวลาฟื้นนานกว่าเดิม',
      semanticIntent:
          'คงคำแนะนำให้พักอย่างต่อเนื่องและไม่ฝืนจนต้องชดเชยวันถัดไป',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-past-decision-standard',
      sourceTemplate: 'ThaiBetaPastReflection.question',
      before: 'และเกณฑ์ครั้งนั้นยังเหมาะกับการตัดสินใจวันนี้หรือไม่',
      after: 'และหลักที่คุณใช้ตอนนั้นยังเหมาะกับการตัดสินใจวันนี้หรือไม่',
      semanticIntent: 'คงคำถามว่าหลักตัดสินใจในอดีตยังใช้ได้กับปัจจุบันหรือไม่',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-past-kept-standard',
      sourceTemplate: 'ThaiBetaPastReflection.compose',
      before: 'และเกณฑ์เดิมส่วนใดยังควรรักษา',
      after: 'และหลักเดิมข้อใดยังใช้ได้กับชีวิตตอนนี้',
      semanticIntent: 'คงการทบทวนว่าสิ่งใดจากอดีตยังควรรักษาไว้ในปัจจุบัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-current-health-recovery',
      sourceTemplate: 'ThaiBetaNarrativeComposer._forecastClaim(health)',
      before:
          'หากพักแล้วร่างกายกลับมามีแรงได้ตามปกติ ร่างกายยังพร้อมรองรับกิจกรรมเพิ่ม',
      after: 'ถ้าพักแล้วกลับมามีแรงตามปกติ คุณยังพอเพิ่มกิจกรรมได้',
      semanticIntent:
          'คงเงื่อนไขการฟื้นตัวก่อนเพิ่มกิจกรรม โดยไม่ให้คำแนะนำทางการแพทย์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-current-health-slow-recovery',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.supportingCurrentContext',
      before:
          'หากร่างกายใช้เวลากลับมามีแรงนานขึ้น ให้ลดกิจกรรมก่อนเพิ่มแผนใหม่',
      after: 'ถ้าต้องใช้เวลาพักนานขึ้นกว่าจะมีแรง ให้ลดกิจกรรมก่อนเพิ่มแผนใหม่',
      semanticIntent: 'คงการลดกิจกรรมเมื่อใช้เวลาฟื้นตัวนานขึ้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-evidence-selection',
      sourceTemplate: 'ThaiMirrorConsumerCopy.evidenceExplanation',
      before:
          'คำอ่านข้างต้นเลือกประเด็นที่เชื่อมกับชีวิตคุณได้ชัดที่สุดก่อน แล้วเรียงผลต่อเนื่องไปยังเรื่องที่ควรระวังและการตัดสินใจ',
      after:
          'รายงานเลือกเรื่องที่เกี่ยวกับชีวิตคุณชัดที่สุดขึ้นมาก่อน จากนั้นจึงอธิบายสิ่งที่ควรระวังและใช้ตัดสินใจ',
      semanticIntent:
          'คงลำดับการเลือกประเด็น ความเสี่ยง และการตัดสินใจในคำอธิบายที่มา',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-unknown-future-weight',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.unknownFuture',
      before:
          'ภาพข้างหน้าจะมีน้ำหนักขึ้นเมื่อผลแบบเดิมเกิดขึ้นอย่างสม่ำเสมอและตรวจสอบได้',
      after:
          'ควรให้น้ำหนักกับแนวโน้มนี้มากขึ้นเมื่อเห็นผลแบบเดิมเกิดซ้ำและตรวจสอบได้',
      semanticIntent:
          'คงเงื่อนไขเพิ่มน้ำหนักให้แนวโน้มจากผลที่เกิดซ้ำและตรวจสอบได้',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-unknown-conclusion-observable',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before:
          'ถ่ายทอดความคิดให้ชัดเจน และตัดสินใจจากผลที่เกิดขึ้นอย่างสม่ำเสมอและตรวจสอบได้',
      after: 'อธิบายความคิดให้ชัด แล้วตัดสินใจจากผลที่เกิดซ้ำและตรวจสอบได้',
      semanticIntent:
          'คงจุดแข็งด้านการสื่อสารและการตัดสินใจจากผลซ้ำที่ตรวจสอบได้',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-future-orientation-known',
      sourceTemplate: 'ThaiBetaReportExportDocument.futureOrientation',
      before:
          'ภาพข้างหน้าเริ่มจากการตัดสินใจวันนี้ ต่อด้วยการทบทวนใน 12 เดือน และจบที่ทิศทางระยะยาว',
      after:
          'เริ่มจากเรื่องที่ต้องตัดสินใจตอนนี้ แล้วค่อยดูสิ่งที่ควรทบทวนใน 12 เดือนและภาพระยะยาว',
      semanticIntent: 'คงลำดับปัจจุบัน 12 เดือน และระยะยาวของบทแนวโน้ม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-future-orientation-unknown',
      sourceTemplate: 'ThaiBetaReportExportDocument.futureOrientation',
      before:
          'แบ่งภาพข้างหน้าเป็นสิ่งที่ตรวจได้ตอนนี้ หมุดทบทวนใน 12 เดือน และทิศทางระยะยาว โดยไม่อาศัยข้อมูลนาฬิกาเกิดที่ไม่ได้บันทึก',
      after:
          'เริ่มจากสิ่งที่ตรวจสอบได้ตอนนี้ แล้วค่อยทบทวนอีกครั้งใน 12 เดือนและมองภาพระยะยาว โดยไม่ใช้เวลาเกิดที่ไม่ได้บันทึกไว้',
      semanticIntent:
          'คงลำดับปัจจุบัน 12 เดือน ระยะยาว และขอบเขต fail-closed ของ Unknown-time',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-current-decision-one-work-item',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentDecision',
      before:
          'สิ่งที่ต้องตัดสินใจตอนนี้คืองานหนึ่งเรื่อง โดยใช้คุณภาพของงานชิ้นหลักเป็นหลัก และยังรักษาการทำตามข้อตกลงไว้',
      after:
          'ตอนนี้ ให้เลือกตัดสินใจเรื่องงานเพียงหนึ่งเรื่อง ดูว่างานหลักยังมีคุณภาพ และอย่าละเลยสิ่งที่ตกลงกันไว้',
      semanticIntent:
          'คงการเลือกงานหนึ่งเรื่อง คุณภาพงานหลัก และการรักษาข้อตกลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-primary-decision-priority',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentDomain',
      before: 'เรื่องนี้เป็นแกนตัดสินใจหลัก',
      after: 'ให้เรื่องนี้มาก่อนการตัดสินใจอื่น',
      semanticIntent: 'คงสถานะของเรื่องนี้ในฐานะการตัดสินใจหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-self-check-question',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentEvidence',
      before: 'คำถามที่ใช้ตรวจคือ',
      after: 'ลองถามตัวเองว่า',
      semanticIntent: 'คงคำถามตรวจสอบผลจริงโดยใช้ถ้อยคำที่พูดกับผู้อ่านโดยตรง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-relationship-recurring-action',
      sourceTemplate: 'ThaiBetaNarrativeComposer._forecastClaim(relationship)',
      before: 'พฤติกรรมที่เห็นอย่างสม่ำเสมอเป็นสัญญาณสำคัญ',
      after: 'ให้ดูการกระทำที่เกิดขึ้นอย่างสม่ำเสมอ',
      semanticIntent: 'คงการใช้พฤติกรรมที่เกิดซ้ำเป็นข้อมูลด้านความสัมพันธ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-health-recovery-record',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.supportingCheckpointContext',
      before:
          'จดระยะเวลาที่ร่างกายใช้ฟื้นตัวหลังสัปดาห์ที่มีภาระหนัก แล้วทบทวนว่าตารางกิจกรรมควรลดหรือคงเดิม',
      after:
          'หลังสัปดาห์ที่หนัก ลองจดว่าต้องพักกี่วันจึงกลับมามีแรง แล้วค่อยตัดสินใจว่าจะลดกิจกรรมหรือใช้ตารางเดิม',
      semanticIntent:
          'คงการบันทึกเวลาฟื้นตัวหลังสัปดาห์หนักเพื่อทบทวนตารางกิจกรรม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-long-term-work-selection',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextLifePeriod',
      before: 'ในระยะยาว ให้คัดว่าประสบการณ์งานใดควรรักษาและส่วนใดควรส่งต่อ',
      after:
          'ในระยะยาว ให้เลือกว่างานใดควรเก็บไว้ทำต่อ และงานใดควรส่งต่อให้คนอื่น',
      semanticIntent: 'คงการเลือกรักษาหรือส่งต่องานจากประสบการณ์ในระยะยาว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'plain-language-minimum-cash-reserve',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.supportingLongTermContext',
      before:
          'กำหนดยอดเงินขั้นต่ำที่ห้ามแตะ เพื่อไม่ให้รายจ่ายเร่งด่วนบังคับการตัดสินใจ',
      after:
          'กันเงินขั้นต่ำไว้ส่วนหนึ่งและไม่ใช้ก้อนนี้ เพื่อให้ยังมีทางเลือกเมื่อมีรายจ่ายเร่งด่วน',
      semanticIntent:
          'คงการกันเงินขั้นต่ำเพื่อไม่ให้รายจ่ายเร่งด่วนจำกัดการตัดสินใจ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-opening-tradeoff',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.opening',
      before:
          'เรื่องงานยังมีแนวโน้มเดินหน้าต่อเนื่องไปถึงช่วงถัดไป ขณะเดียวกัน เมื่อรับเรื่องใหม่เพิ่ม ความสัมพันธ์อาจมีพื้นที่น้อยลง',
      after:
          'งานยังมีโอกาสเดินหน้าต่อ แต่ถ้ารับเรื่องใหม่เพิ่ม คุณอาจเหลือเวลาให้คนรอบตัวน้อยลง',
      semanticIntent: 'คงโอกาสด้านงานและผลแลกเปลี่ยนเรื่องเวลาความสัมพันธ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-self-summary-meaning-first',
      sourceTemplate: 'ThaiBirthProfileCoreReading.lagnaSummary',
      before:
          'ลัคนาราศีกุมภ์สะท้อนคนที่ไปได้ดีเมื่อชีวิตมีระบบและรู้ว่าต้องทำอะไรต่อ ส่วนดาวเสาร์ซึ่งเป็นเจ้าเรือนลัคนาย้ำวินัย ความต่อเนื่อง และการสร้างฐานทีละขั้น',
      after:
          'พื้นดวงนี้เด่นเรื่องการคิดเป็นระบบ คุณมักไปได้ดีเมื่อรู้ว่าขั้นต่อไปต้องทำอะไร ภาพนี้มาจากลัคนาราศีกุมภ์ ส่วนดาวเสาร์ซึ่งเป็นเจ้าเรือนลัคนาสะท้อนวินัยและการค่อย ๆ สร้างฐาน',
      semanticIntent:
          'คงลัคนากุมภ์ ดาวเสาร์ ระบบ วินัย และการสร้างฐาน โดยนำความหมายขึ้นก่อน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-career-meaning-first',
      sourceTemplate: 'ThaiBirthProfileCoreReading.work',
      before:
          'ข้อมูลจากเรือนการงานที่เชื่อมราศีพิจิกและดาวอังคาร สะท้อนว่า คุณสร้างผลงานผ่านความกล้าลงมือและการจัดการสิ่งเร่งด่วน',
      after:
          'เรื่องงาน คุณเด่นที่กล้าลงมือและรับมือกับเรื่องเร่งด่วนได้ดี ภาพนี้อ่านจากเรือนการงานที่เชื่อมกับราศีพิจิกและดาวอังคาร',
      semanticIntent:
          'คงความกล้าลงมือ การจัดการเรื่องเร่งด่วน และหลักฐานจากเรือนการงาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-career-authority',
      sourceTemplate: 'ThaiBirthProfileCoreReading.work',
      before:
          'งานที่เหมาะกับคุณควรให้อำนาจตัดสินใจสอดคล้องกับความรับผิดชอบ ไม่ใช่เพิ่มภาระเพียงอย่างเดียว',
      after:
          'ถ้าต้องรับผิดชอบมากขึ้น คุณก็ควรมีสิทธิ์ตัดสินใจมากขึ้นด้วย ไม่ใช่มีแต่งานเพิ่มขึ้นอย่างเดียว',
      semanticIntent: 'คงเงื่อนไขให้อำนาจตัดสินใจเพิ่มตามความรับผิดชอบ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-money-meaning-first',
      sourceTemplate: 'ThaiBirthProfileCoreReading.money',
      before:
          'เรือนการเงินซึ่งอ่านจากราศีมีนและดาวพฤหัสบดี ผูกความมั่นคงของคุณกับภาพระยะยาว ความรู้ และการขยายอย่างมีหลัก',
      after:
          'เรื่องเงิน คุณมั่นคงขึ้นเมื่อมองระยะยาว ใช้ความรู้ และค่อย ๆ ขยายแผน ภาพนี้อ่านจากเรือนการเงินในราศีมีนและดาวพฤหัสบดี',
      semanticIntent:
          'คงความมั่นคงระยะยาว ความรู้ การขยาย และหลักฐานเรือนการเงิน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-relationship-meaning-first',
      sourceTemplate: 'ThaiBirthProfileCoreReading.relationships',
      before:
          'เมื่อเรือนความสัมพันธ์มีราศีสิงห์และดาวอาทิตย์เป็นหลัก ความไว้ใจจึงเกิดผ่านความชัดเจนและการตัดสินใจด้วยตัวเอง ข้อตกลงจึงต้องแบ่งเวลาและความรับผิดชอบโดยยังเหลือพื้นที่ให้แต่ละฝ่าย',
      after:
          'คุณไว้ใจความสัมพันธ์ได้มากขึ้นเมื่อคุยกันชัดและต่างฝ่ายตัดสินใจด้วยตัวเอง ความสัมพันธ์จะไปได้ดีเมื่อรู้ว่าใครรับผิดชอบอะไร และแต่ละคนยังมีพื้นที่ของตัวเอง ภาพนี้อ่านจากเรือนความสัมพันธ์ในราศีสิงห์และดาวอาทิตย์',
      semanticIntent:
          'คงความชัดเจน การตัดสินใจ การแบ่งเวลา หน้าที่ พื้นที่ส่วนตัว และหลักฐานเรือนสัมพันธ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-health-meaning-first',
      sourceTemplate: 'ThaiBirthProfileCoreReading.wellbeing',
      before:
          'เรือนสุขภาวะที่มีราศีกรกฎและดาวจันทร์เชื่อมพลังชีวิตกับการรับรู้ความเปลี่ยนแปลงและความต้องการรอบตัว สัญญาณที่ควรฟังคือเวลาฟื้นตัวที่ยาวขึ้นต่อเนื่อง ไม่ใช่ความล้าเพียงวันเดียว',
      after:
          'เรื่องสุขภาวะ ให้สังเกตว่าหลังพักแล้วใช้เวลานานขึ้นกว่าจะกลับมามีแรงหรือไม่ อย่าตัดสินจากวันที่เหนื่อยเพียงวันเดียว ภาพนี้อ่านจากเรือนสุขภาวะในราศีกรกฎและดาวจันทร์ ซึ่งเกี่ยวกับการรับรู้ความเปลี่ยนแปลงรอบตัว',
      semanticIntent:
          'คงสัญญาณเวลาฟื้นตัวและหลักฐานเรือนสุขภาวะ โดยไม่เพิ่มคำแนะนำแพทย์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-core-guidance-direct',
      sourceTemplate: 'ThaiBirthProfileCoreReading.closing',
      before:
          'แก่นของคำอ่านนี้ไม่ใช่การรับให้มากขึ้น แต่คือการเลือกสิ่งที่คุ้มกับเวลาและกำลังที่มี',
      after:
          'สิ่งสำคัญตอนนี้ไม่ใช่รับงานเพิ่ม แต่คือเลือกสิ่งที่คุ้มกับเวลาและแรงที่มี',
      semanticIntent: 'คงการเลือกสิ่งที่คุ้มกับทรัพยากรแทนการรับเพิ่ม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-future-priority',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.futureOrientation',
      before:
          'ไม่ต้องเร่งทุกด้านพร้อมกัน ให้ขยับเรื่องหลักเท่าที่ชีวิตด้านอื่นยังรับไหว',
      after:
          'เลือกจัดการเรื่องสำคัญก่อน และอย่าเพิ่มงานจนกระทบเรื่องเงิน ความสัมพันธ์ หรือเวลาพัก',
      semanticIntent: 'คงการเลือกเรื่องหลักโดยไม่เบียดด้านอื่นของชีวิต',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-time-limit',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentCareer',
      before:
          'เลือกงานหลักหนึ่งเรื่อง ตั้งเพดานเวลา และปฏิเสธงานใหม่เมื่อเพดานเต็ม',
      after:
          'เลือกงานหลักหนึ่งเรื่อง กำหนดไว้ล่วงหน้าว่างานนี้ใช้เวลาได้แค่ไหน และปฏิเสธงานใหม่เมื่อเวลาเต็มแล้ว',
      semanticIntent: 'คงการจำกัดเวลางานและปฏิเสธงานใหม่เมื่อถึงขีดจำกัด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-twelve-month-opening',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.checkpoint',
      before:
          'ตลอด 12 เดือนของช่วงเก็บเกี่ยวความสุข ให้ดูว่าหน้าที่เปลี่ยนไปอย่างไร',
      after: 'ใน 12 เดือนนี้ ให้ดูว่าหน้าที่ของคุณเปลี่ยนไปอย่างไร',
      semanticIntent: 'คงการสังเกตหน้าที่ในช่วง 12 เดือนโดยลดชื่อช่วงซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-health-remove-duplicate-recovery',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.health',
      before:
          'หลังสัปดาห์หนัก ให้ดูว่าร่างกายใช้เวลากี่วันจึงกลับมามีแรง หากต้องพักนานขึ้นเรื่อย ๆ ตารางเดิมกำลังเกินกำลังที่มี หลังสัปดาห์ที่หนัก ลองจดว่าต้องพักกี่วันจึงกลับมามีแรง แล้วค่อยตัดสินใจว่าจะลดกิจกรรมหรือใช้ตารางเดิม',
      after:
          'หลังสัปดาห์ที่หนัก ลองจดว่าต้องพักกี่วันจึงกลับมามีแรง ถ้าใช้เวลานานขึ้นเรื่อย ๆ ให้ลดกิจกรรมแทนการฝืนใช้ตารางเดิม',
      semanticIntent:
          'คงการจดเวลาฟื้นตัวและลดกิจกรรมเมื่อฟื้นช้าลง โดยตัดคำแนะนำซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-next-work',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextCareer',
      before:
          'ทิศทางงานระยะต่อไปจะเปลี่ยนจากการรับเพิ่มไปสู่การคุมคุณภาพ คุณจึงต้องเลือกงานที่ใช้ประสบการณ์สูงและส่งต่องานส่วนที่ทำให้ต้องแบ่งแรงไปหลายทาง',
      after:
          'ต่อไปควรรับงานให้น้อยลงแต่ดูแลคุณภาพให้มากขึ้น เลือกเก็บงานที่ใช้ประสบการณ์ของคุณเต็มที่ และส่งต่องานที่ทำให้ต้องแบ่งแรงหลายทาง',
      semanticIntent:
          'คงการเปลี่ยนจากรับเพิ่มเป็นคุมคุณภาพ เลือกงานใช้ประสบการณ์ และส่งต่องานกระจายแรง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-next-money',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextFinance',
      before:
          'ฐานะการเงินในช่วงชีวิตถัดไปต้องรองรับการเปลี่ยนบทบาท รายจ่ายผูกพันจึงต้องมีเงินสำรองแยกจากค่าใช้จ่ายปกติ',
      after:
          'ถ้าหน้าที่การงานเปลี่ยนไป ให้แยกเงินสำรองสำหรับรายจ่ายที่ต้องจ่ายต่อเนื่องออกจากค่าใช้จ่ายประจำ',
      semanticIntent: 'คงเงินสำรองแยกสำหรับรายจ่ายผูกพันเมื่อบทบาทเปลี่ยน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-next-relationship',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextRelationship',
      before:
          'ความสัมพันธ์ในระยะใหม่ต้องจัดเวลา หน้าที่ และพื้นที่ส่วนตัวให้ชัด จึงจะรองรับบทบาทที่เปลี่ยนไปได้',
      after:
          'เมื่อหน้าที่เปลี่ยนไป ให้คุยกันใหม่ว่าใครมีเวลาแค่ไหน ใครรับผิดชอบอะไร และแต่ละคนต้องการพื้นที่ส่วนตัวเท่าไร',
      semanticIntent: 'คงการจัดเวลา หน้าที่ และพื้นที่ส่วนตัวเมื่อบทบาทเปลี่ยน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-next-health',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextHealth',
      before:
          'ควรปรับกิจวัตรการพักและการฟื้นตัวให้สอดคล้องกับตารางชีวิตใหม่ ไม่ใช่รอให้ความล้าสะสมแล้วค่อยพัก',
      after:
          'ถ้าตารางงานเปลี่ยน ให้จัดเวลาพักใหม่ไปพร้อมกัน อย่ารอจนเหนื่อยสะสมแล้วค่อยพัก',
      semanticIntent: 'คงการปรับเวลาพักตามตารางใหม่ก่อนความล้าสะสม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-closing',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before:
          'ใช้ความอดทนและการทำเรื่องยากอย่างต่อเนื่อง แล้วเลือกทางงานที่ทำให้บทบาทใหม่เพิ่มคุณภาพงาน ไม่ใช่เพียงเพิ่มจำนวนงาน พร้อมรักษาการทำตามข้อตกลงไว้',
      after:
          'เลือกงานที่ทำให้ผลงานดีขึ้น ไม่ใช่แค่มีงานมากขึ้น แล้วดูว่าคุณและคนที่เกี่ยวข้องยังทำตามสิ่งที่คุยกันไว้ได้จริง',
      semanticIntent: 'คงการเลือกคุณภาพแทนปริมาณและตรวจการทำตามข้อตกลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-opening-relationship-signal',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.opening',
      before:
          'ความสัมพันธ์ช่วยบอกว่าทางเลือกนั้นกินพื้นที่ชีวิตมากเกินไปหรือยัง',
      after:
          'ถ้างานใหม่ทำให้คุณเหลือเวลาให้ความสัมพันธ์น้อยลง นั่นอาจเป็นสัญญาณว่าคุณกำลังรับมากเกินไป',
      semanticIntent:
          'คงการใช้เวลาความสัมพันธ์เป็นสัญญาณว่างานกินพื้นที่ชีวิตเกินไป',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-childhood-reflection',
      sourceTemplate: 'ThaiBetaPastReflection.compose',
      before:
          'ลองทบทวนช่วงดูแลใจผ่านการเรียน เพื่อน กฎ และความคาดหวัง แล้วสังเกตว่าความรู้สึกเกี่ยวข้องกับการเริ่มเลือกด้วยเสียงของตัวเองอย่างไร',
      after:
          'เมื่อนึกถึงวัย 7–21 ปี ลองดูว่าการเรียน เพื่อน กฎ และความคาดหวังรอบตัวมีผลต่อความรู้สึกของคุณอย่างไร และเมื่อไรที่คุณเริ่มเลือกสิ่งที่ตัวเองต้องการ',
      semanticIntent: 'คงบริบทวัย ความรู้สึก และการเริ่มเลือกด้วยตัวเอง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-past-resources-concrete',
      sourceTemplate: 'ThaiBetaPastReflection.compose',
      before: 'ทรัพยากรที่ต้องจัดการเอง',
      after: 'เงิน เวลา หรือสิ่งที่ต้องรับผิดชอบเอง',
      semanticIntent:
          'ขยายทรัพยากรเป็นตัวอย่างที่อยู่ในโดเมนเดิมโดยไม่เพิ่มคำทำนาย',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-current-meaning-first',
      sourceTemplate: 'ThaiBetaNarrativeComposer.current',
      before:
          'พลังธาตุดินของช่วงนี้เน้นการเก็บข้อมูล เชื่อมคน และทดลองใช้ความรู้กับงานจริง ก่อนเลือกทางที่คุ้มจะทำต่อ',
      after:
          'ช่วงนี้เหมาะกับการเรียนรู้จากงานจริงและรู้จักคนที่ช่วยต่อยอดงาน ลองเก็บข้อมูลและทดลองใช้ความรู้ก่อนเลือกสิ่งที่คุ้มจะทำต่อ ภาพนี้สอดคล้องกับพลังธาตุดินของช่วงปัจจุบัน',
      semanticIntent:
          'คงการเก็บข้อมูล เชื่อมคน ทดลองความรู้ และหลักฐานธาตุดิน โดยนำความหมายขึ้นก่อน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-health-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentHealth',
      before:
          'เมื่อหน้าที่หลายอย่างเริ่มเบียดเวลาพัก ให้ใช้การฟื้นตัวจริงบอกว่าตารางเดิมยังรับไหวหรือไม่',
      after:
          'ถ้าพักแล้วใช้เวลานานขึ้นกว่าจะกลับมามีแรง แสดงว่าตารางเดิมอาจหนักเกินไป',
      semanticIntent: 'คงเวลาฟื้นตัวเป็นตัวชี้ว่าตารางเดิมหนักเกินกำลัง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-fortune-skill-network',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentLuck',
      before:
          'หากมีรายได้จากช่องทางใหม่ ให้แยกผลจากทักษะหรือเครือข่ายที่สร้างไว้ ออกจากเหตุบังเอิญที่ยังยืนยันซ้ำไม่ได้',
      after:
          'ถ้ามีรายได้จากช่องทางใหม่ อย่าเพิ่งสรุปจากครั้งเดียว ลองดูว่ารายได้นั้นเกิดซ้ำเพราะทักษะหรือคนรู้จักที่คุณสร้างไว้จริงหรือไม่',
      semanticIntent:
          'คงการแยกรายได้ที่พิสูจน์ซ้ำจากทักษะหรือเครือข่ายออกจากเหตุครั้งเดียว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-future-no-repeat-caveat',
      sourceTemplate: 'ThaiBetaReportExportDocument.futureOrientation',
      before:
          'เริ่มจากสิ่งที่ตรวจสอบได้ตอนนี้ แล้วค่อยทบทวนอีกครั้งใน 12 เดือนและมองภาพระยะยาว โดยไม่ใช้เวลาเกิดที่ไม่ได้บันทึกไว้',
      after:
          'เริ่มจากสิ่งที่ตรวจสอบได้ตอนนี้ แล้วค่อยทบทวนอีกครั้งใน 12 เดือนและมองภาพระยะยาว',
      semanticIntent:
          'คงลำดับปัจจุบัน 12 เดือน และระยะยาว โดยตัด caveat ที่อธิบายแล้ว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-future-repeat-evidence',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.unknownFuture',
      before:
          'ควรให้น้ำหนักกับแนวโน้มนี้มากขึ้นเมื่อเห็นผลแบบเดิมเกิดซ้ำและตรวจสอบได้',
      after:
          'อย่ารีบตัดสินจากเหตุการณ์ครั้งเดียว ให้รอดูว่าเรื่องเดิมเกิดซ้ำหรือไม่',
      semanticIntent: 'คงเงื่อนไขรอผลซ้ำก่อนเพิ่มน้ำหนักให้แนวโน้ม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-remove-second-method-caveat',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.unknownFuture',
      before:
          'รายงานนี้ไม่มีเวลาเกิด จึงไม่ใช้ตำแหน่งหรือจังหวะที่ต้องคำนวณจากข้อมูลนั้น คำอ่านต่อไปนี้ยึดสิ่งที่สังเกตได้จริงเป็นหลัก',
      after: 'คำอ่านต่อไปนี้จึงยึดสิ่งที่สังเกตได้จริงเป็นหลัก',
      semanticIntent:
          'คงหลักสังเกตผลจริงและลดการย้ำ caveat หลังอธิบายต้นรายงาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-current-decision',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentDecision',
      before:
          'เมื่อยังไม่มีเวลาเกิด ให้ตัดสินใจเรื่องงานจากคุณภาพของงานชิ้นหลักที่เห็นจริง และรักษาการทำตามข้อตกลงไว้',
      after:
          'ตัดสินใจเรื่องงานจากคุณภาพของงานหลักที่เห็นจริง และดูว่าคุณกับคนที่เกี่ยวข้องยังทำตามสิ่งที่คุยกันไว้หรือไม่',
      semanticIntent: 'คงคุณภาพงานหลักและการทำตามข้อตกลง โดยตัด caveat ที่ซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-work-hours',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentCareer',
      before:
          'ควรใช้ชั่วโมงทำงานที่เกิดขึ้นจริงเป็นหลักในการตัดสินใจ และคุณภาพชิ้นหลักต้องไม่ลดเมื่อรับหน้าที่เพิ่ม',
      after:
          'ก่อนรับหน้าที่เพิ่ม ให้ดูว่าคุณใช้เวลาทำงานจริงกี่ชั่วโมง และงานหลักยังได้คุณภาพเดิมหรือไม่',
      semanticIntent:
          'คงชั่วโมงทำงานจริงและคุณภาพงานหลักเป็นเกณฑ์ก่อนรับหน้าที่เพิ่ม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-relationship-current',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentRelationship',
      before:
          'คำพูด การกระทำ และสิ่งที่ตกลงกันต้องสอดคล้องต่อเนื่อง จึงค่อยให้น้ำหนักกับความสัมพันธ์',
      after:
          'หลังจากคุยกันแล้ว ให้ดูว่าแต่ละฝ่ายทำตามที่พูดไว้จริงหรือไม่ แล้วค่อยตัดสินใจเรื่องความสัมพันธ์',
      semanticIntent: 'คงการประเมินความสัมพันธ์จากการกระทำหลังคำพูดและข้อตกลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-twelve-month-opening',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.checkpoint',
      before:
          'ตลอด 12 เดือนของช่วงเรียนรู้และเชื่อมโยง ให้ดูว่าหน้าที่เปลี่ยนไปอย่างไร แล้วทบทวนอีกครั้งเมื่อเห็นว่าแต่ละฝ่ายทำตามที่ตกลงไว้จริงหรือไม่ แทนการกำหนดเหตุการณ์ล่วงหน้า',
      after:
          'ใน 12 เดือนนี้ ให้ดูว่าหน้าที่ของคุณเปลี่ยนไปอย่างไร และหลังจากคุยกันแล้วแต่ละฝ่ายทำตามที่พูดไว้จริงหรือไม่ รายงานจึงไม่กำหนดเหตุการณ์ล่วงหน้า',
      semanticIntent:
          'คงการดูหน้าที่ พฤติกรรมหลังข้อตกลง และไม่กำหนดเหตุการณ์ล่วงหน้า',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-relationship-checkpoint',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annual.relationship',
      before:
          'ให้ดูการกระทำที่เกิดขึ้นอย่างสม่ำเสมอ ความพร้อมของอีกฝ่ายเห็นได้จากการรักษาคำพูดในเรื่องเล็กอย่างสม่ำเสมอ',
      after:
          'ดูว่าอีกฝ่ายทำตามที่พูดไว้ในเรื่องเล็ก ๆ ได้จริงหรือไม่ พฤติกรรมนี้ช่วยบอกความพร้อมได้ดีกว่าคำพูดครั้งเดียว',
      semanticIntent: 'คงการใช้การรักษาคำพูดในเรื่องเล็กเป็นหลักฐานความพร้อม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-next-introduction',
      sourceTemplate: 'ThaiBetaReportExportDocument.nextLife',
      before: 'ดูภาพรวมของช่วงถัดไปโดยยังไม่ผูกกับเวลาเกิดที่ไม่มีข้อมูล',
      after: 'ดูภาพรวมของช่วงถัดไป เพื่อเตรียมสิ่งสำคัญไว้ล่วงหน้า',
      semanticIntent: 'คงการเตรียมช่วงถัดไปและลด caveat ที่ซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-next-preparation',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextLife',
      before:
          'เมื่อเข้าสู่ช่วงชีวิตถัดไป ให้เตรียมงานที่ใช้ประสบการณ์ได้เต็มที่ โดยยังไม่ผูกผลลัพธ์กับเวลาที่ไม่ได้บันทึก',
      after:
          'เมื่อเข้าสู่ช่วงถัดไป ให้เตรียมงานที่ได้ใช้ประสบการณ์ของคุณอย่างเต็มที่',
      semanticIntent: 'คงการเตรียมงานที่ใช้ประสบการณ์และตัด caveat ที่ซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-next-relationship',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextRelationship',
      before:
          'ความสัมพันธ์ที่ไปต่อได้ต้องรองรับจังหวะชีวิตใหม่ของทั้งสองฝ่าย ความชัดเรื่องเวลาและหน้าที่จะสำคัญกว่าคำสัญญา',
      after:
          'เมื่อชีวิตของแต่ละฝ่ายเปลี่ยนไป ให้คุยกันใหม่ว่าแบ่งเวลาและหน้าที่อย่างไร สิ่งที่ทำได้จริงสำคัญกว่าคำสัญญา',
      semanticIntent:
          'คงการปรับเวลาและหน้าที่ตามชีวิตใหม่โดยใช้การปฏิบัติจริงเหนือคำสัญญา',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-next-health',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextHealth',
      before:
          'จังหวะวันทำงานและวันพักที่คงเส้นคงวาจะสำคัญขึ้น หากหน้าที่จริงเปลี่ยนไปในระยะใหม่',
      after:
          'ถ้าหน้าที่เปลี่ยนไป ให้จัดวันทำงานและวันพักให้ทำตามได้จริงทุกสัปดาห์',
      semanticIntent: 'คงการจัดวันทำงานและวันพักให้สม่ำเสมอเมื่อหน้าที่เปลี่ยน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-closing',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before:
          'อธิบายความคิดให้ชัด แล้วตัดสินใจจากผลที่เกิดซ้ำและตรวจสอบได้ เลือกงานทีละก้าว และยังไม่เพิ่มข้อผูกพันจนกว่าจะเห็นว่าข้อตกลงได้รับการปฏิบัติจริงอย่างต่อเนื่อง',
      after:
          'พูดสิ่งที่คิดให้ชัด เลือกงานทีละเรื่อง และอย่าเพิ่มข้อผูกพันจนกว่าจะเห็นว่าทั้งสองฝ่ายทำตามที่คุยกันได้จริง',
      semanticIntent:
          'คงการสื่อสาร เลือกงานทีละขั้น และรอการทำตามข้อตกลงก่อนเพิ่มข้อผูกพัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-calendar-day-label',
      sourceTemplate: 'ThaiBirthProfileCoreReading.methodology',
      before: 'ฐานวันตามปฏิทิน:',
      after: 'วันที่เกิดตามปฏิทิน:',
      semanticIntent: 'คงวันที่เกิดตามปฏิทินด้วยป้ายกำกับที่คนทั่วไปเข้าใจ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-calendar-day-explanation',
      sourceTemplate: 'ThaiBirthProfileCoreReading.methodology',
      before:
          'เป็นเพียงฐานวันตามปฏิทิน และไม่ใช้สรุปข้อมูลที่ต้องพึ่งนาฬิกาเกิด',
      after:
          'ระบบรู้วันเกิดแต่ไม่รู้เวลา จึงไม่คำนวณลัคนาหรือหัวข้อที่ต้องใช้เวลาเกิด',
      semanticIntent: 'คงการรู้วันแต่ไม่ใช้คำนวณผลที่ต้องพึ่งเวลาเกิด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-omission-introduction',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions',
      before: 'ระบบตัดหัวข้อต่อไปนี้ออกแทนการเติมคำทำนายที่ไม่มีข้อมูลรองรับ',
      after: 'รายงานเว้นหัวข้อต่อไปนี้ เพราะต้องใช้เวลาเกิดในการคำนวณ',
      semanticIntent: 'คงการเว้นหัวข้อแบบ fail-closed ด้วยคำอธิบายธรรมดา',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-known-opportunity',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.opportunity',
      before: 'รับบทบาทเพิ่มได้ทีละขั้น หากงานหลักยังรักษาคุณภาพได้ตามเดิม',
      after: 'รับงานเพิ่มได้ แต่ต้องไม่ทำให้งานหลักเสียคุณภาพ',
      semanticIntent: 'คงโอกาสรับงานเพิ่มภายใต้เงื่อนไขคุณภาพงานหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-unknown-opportunity',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.opportunity',
      before:
          'โอกาสอยู่ที่การรับบทบาทเพิ่มทีละขั้น โดยยังรักษาคุณภาพงานหลัก โดยดูผลที่เกิดซ้ำก่อนตัดสินใจ',
      after:
          'รับงานเพิ่มได้ทีละขั้น แต่ต้องดูจากผลงานที่เกิดขึ้นจริง และไม่ให้งานหลักเสียคุณภาพ',
      semanticIntent: 'คงโอกาสรับงานเพิ่มทีละขั้น ผลจริง และคุณภาพงานหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-known-advice',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.primaryAdvice',
      before:
          'ใช้ความอดทนและการทำเรื่องยากอย่างต่อเนื่อง แล้วเลือกทางงานที่ทำให้บทบาทใหม่เพิ่มคุณภาพงาน ไม่ใช่เพียงเพิ่มจำนวนงาน พร้อมรักษาการทำตามข้อตกลงไว้',
      after:
          'เลือกงานที่ทำให้ผลงานดีขึ้น ไม่ใช่แค่มีงานมากขึ้น และอย่ารับเพิ่มจนไม่มีเวลาให้สิ่งที่ตกลงกันไว้',
      semanticIntent: 'คงคุณภาพเหนือปริมาณและการรักษาสิ่งที่ตกลงกัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-unknown-theme',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.theme',
      before:
          'ตลอด 12 เดือนนี้ ให้ดูว่าหน้าที่เปลี่ยนไปอย่างไร แล้วทบทวนอีกครั้งเมื่อการทำตามข้อตกลงสม่ำเสมอขึ้น โดยไม่สรุปเหตุการณ์ล่วงหน้า',
      after:
          'ใน 12 เดือนนี้ ให้ดูว่าหน้าที่เปลี่ยนไปอย่างไร และแต่ละฝ่ายทำตามที่คุยกันได้จริงหรือไม่ โดยไม่สรุปเหตุการณ์ล่วงหน้า',
      semanticIntent:
          'คงการดูหน้าที่ การทำตามข้อตกลง และข้อจำกัดไม่สรุปเหตุการณ์ล่วงหน้า',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-opening-headline',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.headline',
      before: 'งานจะไปต่อได้ เมื่อข้อตกลงยังชัดและทำได้จริง',
      after: 'งานจะเดินหน้าได้ เมื่อทุกฝ่ายเข้าใจตรงกันและทำตามที่คุยไว้',
      semanticIntent:
          'คงเงื่อนไขความชัดเจนและการปฏิบัติจริงต่อความก้าวหน้าของงาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-opening-strength',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.opening',
      before:
          'ในช่วงนี้ ความอดทนและการทำเรื่องยากอย่างต่อเนื่องช่วยให้งานเดินหน้าต่อได้',
      after: 'ช่วงนี้ งานจะเดินหน้าได้เพราะคุณอดทนและรับมือกับเรื่องยากได้ดี',
      semanticIntent: 'คงความอดทนและการทำเรื่องยากเป็นแรงสนับสนุนงาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-known-money-remove-echo',
      sourceTemplate: 'ThaiBirthProfileCoreReading.money',
      before:
          'เรื่องเงิน คุณมั่นคงขึ้นเมื่อมองระยะยาว ใช้ความรู้ และค่อย ๆ ขยายแผน ภาพนี้อ่านจากเรือนการเงินในราศีมีนและดาวพฤหัสบดี เรื่องเงิน อย่าดูแค่ว่าเก็บได้มากแค่ไหน ให้ดูด้วยว่าเงินสำรองช่วยให้คุณมีทางเลือกมากพอหรือยัง',
      after:
          'เรื่องเงิน คุณมั่นคงขึ้นเมื่อมองระยะยาว ใช้ความรู้ และค่อย ๆ ขยายแผน อย่าดูแค่ว่าเก็บได้มากแค่ไหน ให้ดูว่าเงินสำรองช่วยให้คุณมีทางเลือกมากพอหรือยัง ภาพนี้อ่านจากเรือนการเงินในราศีมีนและดาวพฤหัสบดี',
      semanticIntent:
          'คงความมั่นคงระยะยาว เงินสำรอง และหลักฐาน โดยตัดคำขึ้นต้นซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-current-period-known-explanation',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentPeriod',
      before:
          'ช่วงวัยนี้ คุณตัดสินใจได้ดีขึ้นเมื่อรับฟังคนรอบตัว แต่ไม่จำเป็นต้องตามใจทุกคน และไม่ต้องรีบจัดการทุกเรื่องพร้อมกัน',
      after:
          'ช่วงเก็บเกี่ยวความสุขหมายถึงการใช้ประสบการณ์ร่วมกับความเห็นของคนรอบตัว คุณรับฟังคนอื่นได้โดยไม่ต้องตามใจทุกคน และไม่ต้องจัดการทุกเรื่องพร้อมกัน',
      semanticIntent:
          'คงการรับฟังโดยไม่ตามใจและไม่เร่งทุกเรื่อง พร้อมอธิบายชื่อช่วงทันที',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-current-work-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentCareer',
      before:
          'มีโอกาสรับงานหรือความรับผิดชอบเพิ่มในช่วงนี้ แต่ไม่จำเป็นต้องรับทุกทางพร้อมกัน ควรระวังการรับงานซ้อนจนกระทบคุณภาพและความต่อเนื่อง',
      after:
          'ช่วงนี้อาจมีงานหรือหน้าที่ใหม่เข้ามา คุณไม่จำเป็นต้องรับทั้งหมด เลือกเฉพาะงานที่ยังทำได้ดีโดยไม่เบียดงานเดิม',
      semanticIntent:
          'คงโอกาสงานเพิ่ม การไม่รับพร้อมกัน และความเสี่ยงต่อคุณภาพงานเดิม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-current-finance-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentFinance',
      before:
          'ด้านการเงินควรรักษาสมดุลระหว่างค่าใช้จ่ายในปัจจุบันกับเงินที่ต้องเตรียมไว้สำหรับแผนระยะยาว เหมาะกับการสะสมและกันเงินสำรองมากกว่าการเสี่ยงทั้งหมดในคราวเดียว แม้รายรับดูดีขึ้น ก็ยังควรกันส่วนหนึ่งไว้ก่อนขยายการใช้',
      after:
          'เรื่องเงิน ให้แบ่งระหว่างค่าใช้จ่ายวันนี้กับเงินสำหรับแผนระยะยาว เก็บเงินสำรองไว้ก่อน และอย่าเสี่ยงทั้งหมดในครั้งเดียว แม้รายรับดีขึ้นก็ควรกันส่วนหนึ่งไว้ก่อนใช้เพิ่ม',
      semanticIntent:
          'คงสมดุลค่าใช้จ่าย เงินระยะยาว เงินสำรอง และไม่เสี่ยงทั้งหมด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-current-health-natural-known',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentHealth',
      before:
          'ช่วงนี้ร่างกายยังรับภาระได้ หากพักอย่างสม่ำเสมอ รักษาเวลานอนให้คงที่ และเว้นช่วงสั้น ๆ ระหว่างภาระ เพื่อไม่ให้ความล้าสะสมจนกระทบช่วงที่ต้องใช้แรง',
      after:
          'ช่วงนี้คุณยังพอรับกิจกรรมเพิ่มได้ ถ้านอนเป็นเวลา พักสม่ำเสมอ และเว้นช่วงระหว่างงาน เพื่อไม่ให้ความเหนื่อยสะสม',
      semanticIntent: 'คงเงื่อนไขพัก นอน และเว้นช่วงเพื่อไม่ให้ความล้าสะสม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-luck-evidence-and-load',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentLuck',
      before: 'ให้ประเมินโอกาสจากข้อมูลที่ตรวจสอบได้และภาระจริงก่อนรับ',
      after:
          'ก่อนรับโอกาสใหม่ ให้ดูข้อมูลที่ตรวจสอบได้และงานที่ต้องรับผิดชอบจริง',
      semanticIntent: 'คงการประเมินข้อมูลและภาระก่อนรับโอกาส',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-future-domain-weight',
      sourceTemplate: 'ThaiBetaReportExportDocument.futureOrientation',
      before: 'แต่ละช่วงควรให้น้ำหนักกับงาน เงิน ความสัมพันธ์ และการพักต่างกัน',
      after:
          'แต่ละช่วงอาจต้องให้ความสำคัญกับงาน เงิน ความสัมพันธ์ และการพักไม่เท่ากัน',
      semanticIntent: 'คงน้ำหนักต่างกันของสี่โดเมนตามช่วงเวลา',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-current-decision-known-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentDecision',
      before:
          'ตอนนี้ ให้เลือกตัดสินใจเรื่องงานเพียงหนึ่งเรื่อง ดูว่างานหลักยังมีคุณภาพ และอย่าละเลยสิ่งที่ตกลงกันไว้',
      after:
          'ตอนนี้ เลือกตัดสินใจเรื่องงานเพียงเรื่องเดียว แล้วดูว่างานหลักยังทำได้ดีและสิ่งที่คุยกับคนอื่นไว้ยังไม่ถูกละเลย',
      semanticIntent: 'คงงานหนึ่งเรื่อง คุณภาพงานหลัก และสิ่งที่ตกลงกัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-current-finance-known-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentFinance',
      before:
          'เงินสำรองช่วยให้คุณมีทางเลือกมากขึ้น ตราบใดที่รายจ่ายระยะยาวยังไม่กระทบเงินก้อนหลัก',
      after:
          'เงินสำรองช่วยให้คุณมีทางเลือกมากขึ้น แต่ต้องไม่ปล่อยให้รายจ่ายระยะยาวกินเงินก้อนหลัก',
      semanticIntent:
          'คงเงินสำรองเป็นทางเลือกและป้องกันรายจ่ายระยะยาวกระทบเงินหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-current-relationship-known-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentRelationship',
      before:
          'ข้อตกลงที่ทั้งสองฝ่ายทำได้จริง เปิดทางให้ความสัมพันธ์ขยับอย่างมั่นคง ก่อนเพิ่มข้อผูกพัน ให้ดูว่าทั้งสองฝ่ายปฏิบัติตามสิ่งที่ตกลงกันอย่างต่อเนื่องหรือไม่',
      after:
          'ก่อนผูกพันมากขึ้น ให้ดูว่าหลังจากคุยกันแล้ว ทั้งสองฝ่ายทำตามที่พูดไว้จริงหรือไม่',
      semanticIntent: 'คงการรอดูการทำตามข้อตกลงก่อนเพิ่มข้อผูกพัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-midyear-remove-duplicate',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.careerCheckpoint',
      before:
          'กำหนดจุดทบทวนกลางปีเพื่อเลือกว่าจะขยายบทบาทเดิมหรือหยุดรับเพิ่ม เมื่อถึงรอบส่งมอบงานกลางปี ให้เลือกว่าจะขยายทางเดิมหรือปรับแผน',
      after:
          'เมื่อถึงรอบส่งมอบงานกลางปี ให้ทบทวนว่าจะรับบทบาทเดิมเพิ่ม หยุดรับ หรือปรับแผน',
      semanticIntent: 'คงจุดทบทวนกลางปีและสามทางเลือกโดยตัดประโยคซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-next-known-preparation',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextLife',
      before:
          'เมื่อเข้าสู่ช่วงชีวิตถัดไป ให้รักษางานที่ใช้ประสบการณ์ได้เต็มที่ไว้ โดยไม่แลกกับความสัมพันธ์ที่แบ่งเวลาและหน้าที่ได้จริง',
      after:
          'เมื่อเข้าสู่ช่วงถัดไป ให้เก็บงานที่ได้ใช้ประสบการณ์ของคุณเต็มที่ แต่ต้องยังแบ่งเวลาและหน้าที่กับคนใกล้ตัวได้จริง',
      semanticIntent:
          'คงงานใช้ประสบการณ์และไม่แลกกับการแบ่งเวลาและหน้าที่ในความสัมพันธ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-opening-headline',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.headline',
      before: 'ดูผลที่เกิดขึ้นอย่างสม่ำเสมอก่อนตัดสินใจขยับเรื่องงาน',
      after: 'อย่ารีบรับงานเพิ่มจากผลที่ดีเพียงครั้งเดียว',
      semanticIntent: 'คงการรอดูผลซ้ำก่อนขยับเรื่องงาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-opening-strength-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.opening',
      before:
          'ในช่วงนี้ จุดแข็งของคุณคือความสามารถในการถ่ายทอดความคิดให้คนอื่นเข้าใจ จึงควรดูว่างานให้ผลแบบเดิมอย่างสม่ำเสมอหรือไม่',
      after:
          'ช่วงนี้ จุดแข็งของคุณคืออธิบายสิ่งที่คิดให้คนอื่นเข้าใจได้ ก่อนรับงานเพิ่ม ให้ดูว่างานเดิมยังให้ผลดีซ้ำได้หรือไม่',
      semanticIntent: 'คงจุดแข็งการสื่อสารและการรอดูผลงานซ้ำก่อนรับเพิ่ม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-current-work-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentCareer',
      before:
          'หากช่วงนี้คุณสังเกตว่างานเดิมเริ่มเปลี่ยนไปสู่โจทย์ใหม่ ให้เลือกงานที่เพิ่มทักษะหรือเครือข่ายจริง แทนการรับบทบาทเพิ่มเพียงเพราะมีคนส่งมา ควรระวังการรับงานซ้อนจนกระทบคุณภาพและความต่อเนื่อง',
      after:
          'ถ้างานเดิมเริ่มมีโจทย์ใหม่ เลือกงานที่ช่วยเพิ่มทักษะหรือทำให้รู้จักคนที่ต่อยอดงานได้ อย่ารับหน้าที่เพิ่มเพียงเพราะมีคนส่งมา และอย่ารับงานซ้อนจนงานหลักเสียคุณภาพ',
      semanticIntent:
          'คงการเลือกงานเพิ่มทักษะหรือเครือข่ายและหลีกเลี่ยงงานซ้อนที่ลดคุณภาพ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-current-finance-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentFinance',
      before:
          'ช่วงนี้ให้ใช้รายรับจริงเป็นหลัก แยกงบสำหรับทดลองหรือเรียนรู้สิ่งใหม่ออกจากค่าใช้จ่ายประจำ หากรายรับดูดีขึ้น ก็ยังควรกันส่วนหนึ่งไว้ก่อนขยายการใช้',
      after:
          'ช่วงนี้ ให้ดูจากรายรับที่เข้ามาจริง แยกเงินสำหรับลองสิ่งใหม่ออกจากค่าใช้จ่ายประจำ แม้รายรับดีขึ้นก็ควรกันส่วนหนึ่งไว้ก่อนใช้เพิ่ม',
      semanticIntent: 'คงรายรับจริง งบทดลองแยก และการกันเงินก่อนขยายรายจ่าย',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-current-health-record',
      sourceTemplate: 'ThaiBetaNarrativeComposer.currentHealth',
      before:
          'ใช้บันทึกการนอนและความล้าเป็นข้อมูลจริง แล้วลดภาระที่ทำให้วันพักไม่ช่วยฟื้นตัว',
      after:
          'จดเวลานอนและความเหนื่อยไว้ ถ้าวันพักยังไม่ช่วยให้มีแรงขึ้น ให้ลดงานหรือกิจกรรมลง',
      semanticIntent: 'คงการบันทึกการนอน ความล้า และลดภาระเมื่อพักแล้วไม่ฟื้น',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-future-introduction-natural',
      sourceTemplate: 'ThaiBetaReportExportDocument.futureOrientation',
      before:
          'เริ่มจากสิ่งที่ตรวจสอบได้ตอนนี้ แล้วค่อยทบทวนอีกครั้งใน 12 เดือนและมองภาพระยะยาว',
      after:
          'เริ่มจากสิ่งที่เห็นได้ตอนนี้ ทบทวนอีกครั้งใน 12 เดือน แล้วค่อยมองต่อไปในระยะยาว',
      semanticIntent: 'คงลำดับปัจจุบัน 12 เดือน และระยะยาว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-current-career-steps',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentCareer',
      before:
          'จดเวลางานจริงหนึ่งสัปดาห์ แล้วคงไว้เฉพาะบทบาทที่ไม่ทำให้งานหลักตก ให้เรื่องนี้มาก่อนการตัดสินใจอื่น ลองถามตัวเองว่างานชิ้นหลักยังได้มาตรฐานหลังรับหน้าที่ใหม่หรือไม่',
      after:
          'จดเวลาทำงานจริงหนึ่งสัปดาห์ แล้วเก็บไว้เฉพาะหน้าที่ที่ไม่ทำให้งานหลักแย่ลง หลังรับงานใหม่ ลองถามว่างานหลักยังได้มาตรฐานเดิมหรือไม่',
      semanticIntent: 'คงการจดเวลางานและตรวจคุณภาพงานหลักหลังรับหน้าที่ใหม่',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-current-finance-commitment',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentFinance',
      before:
          'ควรพิจารณาข้อผูกพันทางการเงินจากรายรับ รายจ่าย และยอดคงเหลือที่เกิดขึ้นจริง',
      after:
          'ก่อนรับรายจ่ายที่ต้องจ่ายต่อเนื่อง ให้ดูรายรับ รายจ่าย และเงินคงเหลือจริง',
      semanticIntent:
          'คงการพิจารณาภาระการเงินจากรายรับ รายจ่าย และยอดคงเหลือจริง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-current-relationship-one-check',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentRelationship',
      before:
          'หลังจากคุยกันแล้ว ให้ดูว่าแต่ละฝ่ายทำตามที่พูดไว้จริงหรือไม่ แล้วค่อยตัดสินใจเรื่องความสัมพันธ์ ก่อนเพิ่มข้อผูกพัน ให้ดูว่าทั้งสองฝ่ายปฏิบัติตามสิ่งที่ตกลงกันอย่างต่อเนื่องหรือไม่',
      after:
          'ก่อนผูกพันมากขึ้น ให้ดูว่าหลังจากคุยกันแล้ว แต่ละฝ่ายทำตามที่พูดไว้จริงหรือไม่',
      semanticIntent:
          'คงการดูพฤติกรรมหลังคุยก่อนเพิ่มข้อผูกพัน โดยตัดคำแนะนำซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-current-health-natural-action',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentHealth',
      before: 'บันทึกเวลานอน ความล้า และการฟื้นตัวจริงก่อนพิจารณาเพิ่มกิจกรรม',
      after:
          'ก่อนเพิ่มกิจกรรม ให้จดเวลานอน ความเหนื่อย และจำนวนวันที่ใช้พักให้มีแรง',
      semanticIntent: 'คงการบันทึกการนอน ความล้า และการฟื้นตัวก่อนเพิ่มกิจกรรม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-checkpoint-work-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annualCareer',
      before:
          'ผลงานที่ทำซ้ำจนเกิดความชำนาญอาจเปิดหน้าที่ใหม่ ให้ดูว่าคุณรักษามาตรฐานเดิมได้ต่อเนื่องหรือไม่ เก็บตัวอย่างผลงานอย่างต่อเนื่อง แล้วเลือกบทบาทจากงานที่คุณทำได้ดีอย่างสม่ำเสมอ',
      after:
          'งานที่ทำได้ดีซ้ำ ๆ อาจนำไปสู่หน้าที่ใหม่ เก็บตัวอย่างผลงานไว้ แล้วเลือกบทบาทจากงานที่คุณยังรักษาคุณภาพเดิมได้',
      semanticIntent:
          'คงผลงานซ้ำ ความชำนาญ หน้าที่ใหม่ หลักฐานผลงาน และมาตรฐานเดิม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-checkpoint-finance-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annualFinance',
      before:
          'ควรเปรียบเทียบรายรับที่เข้ามาอย่างสม่ำเสมอกับรายจ่ายจำเป็น และไม่ควรสร้างข้อผูกพันจากเงินที่ยังมาไม่สม่ำเสมอ',
      after:
          'เทียบรายรับที่เข้ามาจริงกับรายจ่ายจำเป็น และอย่ารับรายจ่ายที่ต้องจ่ายต่อเนื่องจากเงินที่ยังเข้ามาไม่แน่นอน',
      semanticIntent:
          'คงการเทียบรายรับกับรายจ่ายและไม่ผูกพันจากรายรับไม่สม่ำเสมอ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-checkpoint-health-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annualHealth',
      before:
          'เปรียบเทียบเดือนที่ภาระเบากับเดือนที่มีภาระหลายด้านพร้อมกัน เพื่อดูว่าการนอนและการฟื้นตัวเปลี่ยนไปอย่างไร',
      after:
          'ลองเทียบเดือนที่งานเบากับเดือนที่มีหลายเรื่องพร้อมกัน แล้วดูว่าคุณนอนและกลับมามีแรงต่างกันแค่ไหน',
      semanticIntent: 'คงการเทียบเดือนภาระต่างกันกับการนอนและการฟื้นตัว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-next-unknown-work-one-pass',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextCareer',
      before:
          'ผลงานที่คุณทำได้ดีอย่างสม่ำเสมอจะช่วยให้เห็นว่างานใดควรรักษาไว้หรืองานใดควรส่งต่อในช่วงถัดไป ในระยะยาว ให้เลือกว่างานใดควรเก็บไว้ทำต่อ และงานใดควรส่งต่อให้คนอื่น',
      after:
          'ดูจากงานที่คุณทำได้ดีซ้ำ ๆ แล้วเลือกว่างานใดควรเก็บไว้ทำต่อ และงานใดควรส่งต่อให้คนอื่น',
      semanticIntent:
          'คงผลงานสม่ำเสมอเป็นเกณฑ์เลือกเก็บหรือส่งต่องาน โดยตัดคำแนะนำซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-known-theme-natural',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.theme',
      before:
          'ตลอด 12 เดือนของช่วงเก็บเกี่ยวความสุข ให้สังเกตว่าหน้าที่เปลี่ยนไปอย่างไร แล้วทบทวนอีกครั้งเมื่อการทำตามข้อตกลงสม่ำเสมอขึ้น',
      after:
          'ใน 12 เดือนนี้ ให้ดูว่างานและหน้าที่เปลี่ยนไปอย่างไร แล้วเช็กว่าทุกฝ่ายยังทำตามที่คุยกันไว้ได้จริง',
      semanticIntent: 'คงหน้าที่เปลี่ยนและการทำตามข้อตกลงในช่วง 12 เดือน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-finance-card',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.finance',
      before:
          'ขยายแผนการเงินได้ เมื่อกันค่าใช้จ่ายจำเป็นและเงินสำรองไว้ครบแล้ว',
      after: 'ก่อนใช้เงินเพิ่ม ให้กันค่าใช้จ่ายจำเป็นและเงินสำรองไว้ให้พอ',
      semanticIntent: 'คงเงื่อนไขค่าใช้จ่ายจำเป็นและเงินสำรองก่อนขยายแผน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-known-relationship-card',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.relationship',
      before:
          'เพิ่มข้อผูกพันได้เมื่อคำพูดและการกระทำสอดคล้องกัน และทั้งสองฝ่ายเข้าใจตรงกัน',
      after:
          'ก่อนผูกพันมากขึ้น ให้ดูว่าทั้งสองฝ่ายเข้าใจตรงกันและทำตามที่พูดไว้',
      semanticIntent:
          'คงความเข้าใจตรงกันและคำพูดตรงกับการกระทำก่อนเพิ่มข้อผูกพัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-unknown-relationship-card',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.relationship',
      before:
          'เริ่มจากข้อตกลงเล็ก ๆ แล้วดูความสม่ำเสมอ ก่อนเพิ่มข้อผูกพันเมื่อทั้งสองฝ่ายเข้าใจตรงกัน',
      after:
          'เริ่มจากเรื่องเล็ก ๆ แล้วดูว่าทั้งสองฝ่ายทำตามที่พูดไว้จริงหรือไม่',
      semanticIntent:
          'คงการเริ่มจากข้อตกลงเล็กและดูการปฏิบัติสม่ำเสมอก่อนเพิ่มข้อผูกพัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-health-card',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.health',
      before:
          'เพิ่มกิจกรรมได้เมื่อพักแล้วฟื้นตัวได้ตามปกติ หากฟื้นช้าลงควรลดภาระ',
      after:
          'เพิ่มกิจกรรมได้ถ้าพักแล้วกลับมามีแรงตามปกติ ถ้าฟื้นช้าลงให้ลดกิจกรรม',
      semanticIntent: 'คงการเพิ่มหรือลดกิจกรรมตามเวลาฟื้นตัว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-known-opportunity-final',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.opportunity',
      before: 'โอกาสอยู่ที่การรับบทบาทเพิ่มทีละขั้น โดยยังรักษาคุณภาพงานหลัก',
      after: 'รับงานเพิ่มได้ทีละขั้น แต่ต้องไม่ทำให้งานหลักเสียคุณภาพ',
      semanticIntent: 'คงโอกาสรับบทบาทเพิ่มทีละขั้นภายใต้คุณภาพงานหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-known-caution',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.caution',
      before: 'ภาระงานที่เพิ่มขึ้นอาจเบียดเวลาของงานหลัก',
      after: 'งานใหม่อาจกินเวลาจนงานหลักทำได้ไม่ดีเท่าเดิม',
      semanticIntent: 'คงความเสี่ยงที่งานเพิ่มเบียดเวลาและคุณภาพงานหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-infographic-unknown-caution',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.caution',
      before: 'ความคาดหวังในความสัมพันธ์อาจยังไม่ตรงกัน',
      after: 'ทั้งสองฝ่ายอาจยังคาดหวังจากความสัมพันธ์ไม่ตรงกัน',
      semanticIntent: 'คงความคาดหวังในความสัมพันธ์ที่อาจไม่ตรงกัน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-opening-no-commitment-noun',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.opening',
      before: 'อย่าเพิ่งใช้เป็นเหตุผลรับข้อผูกพันเพิ่ม',
      after: 'อย่าเพิ่งใช้เป็นเหตุผลรับหน้าที่หรือคำสัญญาเพิ่ม',
      semanticIntent: 'คงการไม่รับภาระหรือคำมั่นเพิ่มจากเหตุการณ์ครั้งเดียว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-checkpoint-finance-no-commitment-noun',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.financeCheckpoint',
      before: 'อย่าเพิ่มรายจ่ายผูกพันเพราะตัวเลขดีเพียงครั้งเดียว',
      after: 'อย่าเพิ่มรายจ่ายที่ต้องจ่ายต่อเนื่องเพราะตัวเลขดีเพียงครั้งเดียว',
      semanticIntent: 'คงการไม่เพิ่มรายจ่ายต่อเนื่องจากผลดีครั้งเดียว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-checkpoint-relationship-no-commitment-noun',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.relationshipCheckpoint',
      before:
          'หากพฤติกรรมยังไม่ตรงกับข้อตกลง ให้ทบทวนสิ่งที่คุยกันและชะลอข้อผูกพันใหม่ก่อน',
      after:
          'ถ้าการกระทำยังไม่ตรงกับสิ่งที่คุยกัน ให้กลับมาคุยใหม่และยังไม่ผูกพันมากขึ้น',
      semanticIntent: 'คงการทบทวนและชะลอการผูกพันเมื่อพฤติกรรมไม่ตรงข้อตกลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-source-summary-once',
      sourceTemplate: 'ThaiMirrorConsumerCopy.dataUsedWithoutBirthTime',
      before:
          'รายงานนี้ไม่มีเวลาเกิด จึงเว้นข้อสรุปที่ต้องพึ่งตำแหน่งตามนาฬิกาเกิด',
      after: 'หัวข้อที่ต้องใช้เวลาเกิดจึงไม่แสดงในรายงาน',
      semanticIntent:
          'คงการเว้นหัวข้อที่ต้องใช้เวลาเกิดโดยไม่ย้ำข้อมูลที่อธิบายแล้ว',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-source-parenthesis',
      sourceTemplate: 'ThaiMirrorConsumerCopy.analysisSource',
      before:
          'ใช้วัน เดือน ปีเกิด และจังหวัดที่เกิดจากโปรไฟล์ของคุณ (ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด)',
      after:
          'ใช้วัน เดือน ปีเกิด และจังหวัดที่เกิดจากโปรไฟล์ของคุณ (รายงานเว้นหัวข้อที่ต้องใช้เวลาเกิด)',
      semanticIntent: 'คงการเว้นหัวข้อโดยลดการย้ำว่าไม่มีเวลาเกิด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-agreement-follow-through-generic',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.closing',
      before: 'รักษาการทำตามข้อตกลงไว้',
      after: 'ดูว่าทุกฝ่ายยังทำตามที่คุยกันไว้ได้จริง',
      semanticIntent: 'คงการตรวจการทำตามข้อตกลงด้วยภาษาที่ระบุผู้กระทำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-next-observable-generic',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.nextLife',
      before: 'โดยยังไม่ผูกผลลัพธ์กับเวลาที่ไม่ได้บันทึก',
      after: 'โดยดูจากสิ่งที่เกิดขึ้นจริง',
      semanticIntent:
          'คงขอบเขต Unknown ให้ใช้สิ่งที่สังเกตได้จริงโดยไม่ย้ำข้อมูลเวลาเกิด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-decision-support-natural',
      sourceTemplate: 'LifeMapCurrentPeriodComposer.elementContext',
      before: 'ประกอบการตัดสินใจ',
      after: 'ช่วยให้ตัดสินใจ',
      semanticIntent:
          'คงบทบาทของข้อมูลหรือความเข้าใจในการช่วยตัดสินใจด้วยคำกริยาธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-omission-summary-natural',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(summary)',
      before:
          'สรุปตัวคุณแบบตรง ๆ — ไม่มีเวลาเกิด จึงไม่สรุปบุคลิกจากตำแหน่งที่ต้องคำนวณด้วยเวลาเกิด',
      after: 'รายงานไม่สรุปบุคลิกจากลัคนาหรือตำแหน่งที่ต้องคำนวณด้วยเวลาเกิด',
      semanticIntent: 'คงการเว้นบุคลิกจากลัคนาและตำแหน่งที่ต้องใช้เวลาเกิด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-omission-work-natural',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(work)',
      before:
          'คำอ่านการงานที่ต้องใช้เวลาเกิด — รายงานเว้นรายละเอียดส่วนนี้แทนการสร้างข้อมูลที่ยืนยันไม่ได้',
      after: 'รายงานไม่เติมรายละเอียดการงานที่ยืนยันไม่ได้หากไม่มีเวลาเกิด',
      semanticIntent: 'คงการเว้นรายละเอียดการงานที่ต้องใช้เวลาเกิด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-omission-money-natural',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(money)',
      before:
          'รายละเอียดการเงินที่ต้องใช้เวลาเกิด — ไม่มีข้อมูลเพียงพอสำหรับยืนยันรายละเอียดส่วนนี้',
      after: 'รายงานไม่แสดงรายละเอียดการเงินที่ต้องคำนวณจากเวลาเกิด',
      semanticIntent: 'คงการเว้นรายละเอียดการเงินที่ต้องใช้เวลาเกิด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-omission-relationship-natural',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(relationships)',
      before:
          'มุมความสัมพันธ์ที่ต้องใช้เวลาเกิด — รายงานเว้นส่วนที่ต้องคำนวณจากตำแหน่งเฉพาะ',
      after: 'รายงานไม่แสดงมุมความสัมพันธ์ที่ต้องคำนวณจากเวลาเกิด',
      semanticIntent: 'คงการเว้นมุมความสัมพันธ์ที่ต้องใช้เวลาเกิด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-omission-health-natural',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(wellbeing)',
      before:
          'รายละเอียดสุขภาวะที่ต้องใช้เวลาเกิด — รายงานไม่เติมรายละเอียดที่ข้อมูลยังรองรับไม่เพียงพอ',
      after:
          'รายงานไม่เติมรายละเอียดสุขภาวะที่ต้องใช้เวลาเกิดและยังไม่มีข้อมูลรองรับ',
      semanticIntent:
          'คงการเว้นรายละเอียดสุขภาวะที่ต้องใช้เวลาเกิดและไม่มีหลักฐาน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or1-unknown-omission-closing-natural',
      sourceTemplate: 'ThaiBirthProfileCoreReading.omissions(closing)',
      before:
          'คำชี้หลักจากพื้นดวง — ข้อมูลไม่ครบพอที่จะสรุปจุดแข็ง ความเสี่ยง และแนวทางจากหลักฐานชุดเดียวกัน',
      after:
          'รายงานไม่สรุปจุดแข็ง ความเสี่ยง และแนวทางจากพื้นดวง เพราะข้อมูลชุดเดียวกันยังไม่ครบ',
      semanticIntent: 'คงการเว้นข้อสรุปเมื่อหลักฐานชุดเดียวกันไม่ครบ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-known-opening-tradeoff-complete',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.opening',
      before:
          'งานยังมีโอกาสเดินหน้าต่อ แต่ถ้ารับเรื่องใหม่เพิ่ม คุณอาจเหลือเวลาให้คนรอบตัวน้อยลง',
      after:
          'งานยังมีโอกาสเดินหน้าต่อ แต่ถ้ารับงานเพิ่ม คุณอาจมีเวลาให้คนรอบตัวน้อยลง ก่อนตัดสินใจ ลองดูว่าคุณยังมีเวลาอธิบายงานให้ทุกคนเข้าใจตรงกันหรือไม่',
      semanticIntent: 'คงโอกาสด้านงานและผลแลกเปลี่ยนเรื่องเวลาและความชัดเจน',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-recurring-routine-natural',
      sourceTemplate: 'ThaiBirthProfileCoreReading.closing',
      before:
          'ให้เริ่มจากการวางระบบที่ทำตามได้อย่างต่อเนื่องและกำหนดเวลาพักไว้ล่วงหน้า แล้วใช้ผลจริงตัดสินว่าจะรักษาอะไรไว้',
      after:
          'จัดตารางงานและเวลาพักแบบที่ทำตามได้จริง แล้วลองใช้สักระยะ จากนั้นค่อยดูว่าอะไรควรทำต่อและอะไรควรตัดออก',
      semanticIntent: 'คงการทดลองใช้ระบบงานและเวลาพักก่อนเลือกสิ่งที่ทำต่อ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-known-current-one-work-item',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentDecision',
      before:
          'ตอนนี้ ให้เลือกตัดสินใจเรื่องงานเพียงหนึ่งเรื่อง ดูว่างานหลักยังมีคุณภาพ และอย่าละเลยสิ่งที่ตกลงกันไว้',
      after:
          'ตอนนี้ เลือกเรื่องงานที่สำคัญที่สุดมาจัดการก่อนเพียงเรื่องเดียว แล้วดูว่างานหลักยังทำได้ดี และคุณยังทำตามที่รับปากคนอื่นไว้ได้หรือไม่',
      semanticIntent:
          'คงการเลือกงานหนึ่งเรื่อง คุณภาพงานหลัก และการทำตามข้อตกลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-finance-liquid-income-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer._forecastClaim(finance)',
      before:
          'รายรับที่เพิ่มขึ้นจะช่วยได้จริงเมื่อยังเหลือเป็นเงินพร้อมใช้ ถ้ารายจ่ายประจำเพิ่มตามทันที ควรชะลอแผนใหม่ไว้ก่อน',
      after:
          'รายรับที่เพิ่มขึ้นจะช่วยให้มั่นคงขึ้นก็ต่อเมื่อหักรายจ่ายแล้ว ยังมีเงินเหลือเก็บหรือใช้ยามจำเป็น ถ้ารายจ่ายประจำเพิ่มตามทันที ให้ชะลอแผนใหม่ไว้ก่อน',
      semanticIntent:
          'คงเงื่อนไขเงินคงเหลือและการชะลอแผนเมื่อรายจ่ายประจำเพิ่ม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-minimum-reserve-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.supportingLongTermContext',
      before:
          'กันเงินขั้นต่ำไว้ส่วนหนึ่งและไม่ใช้ก้อนนี้ เพื่อให้ยังมีทางเลือกเมื่อมีรายจ่ายเร่งด่วน',
      after:
          'แยกเงินสำรองจำนวนหนึ่งไว้สำหรับเรื่องจำเป็น เพื่อให้คุณยังมีทางเลือกเมื่อมีรายจ่ายเร่งด่วน',
      semanticIntent:
          'คงเงินสำรองสำหรับรายจ่ายเร่งด่วนและทางเลือกในการตัดสินใจ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-unknown-report-opening',
      sourceTemplate: 'ThaiBirthProfileCoreReading.header',
      before:
          'คำอ่านจากวันและสถานที่เกิด พร้อมบอกตรง ๆ ว่าหัวข้อใดต้องตัดออกเมื่อไม่มีเวลาเกิด',
      after:
          'รายงานนี้ใช้วันเกิดและสถานที่เกิดเท่าที่มี ส่วนหัวข้อที่ต้องใช้เวลาเกิดจะไม่แสดง',
      semanticIntent: 'คงข้อมูลที่ใช้และการเว้นหัวข้อที่ต้องใช้เวลาเกิด',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-unknown-observable-boundary-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.unknownBoundary',
      before: 'คำอ่านต่อไปนี้จึงยึดสิ่งที่สังเกตได้จริงเป็นหลัก',
      after:
          'เพราะไม่มีเวลาเกิด ส่วนนี้จึงใช้สิ่งที่เกิดขึ้นจริงเป็นหลัก และจะไม่ระบุว่าเหตุการณ์ต้องเกิดเมื่อไร',
      semanticIntent:
          'คงขอบเขต Unknown จากสิ่งที่สังเกตได้และไม่ระบุเวลาเหตุการณ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-unknown-current-work-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentCareer',
      before:
          'ตัดสินใจเรื่องงานจากคุณภาพของงานหลักที่เห็นจริง และดูว่าคุณกับคนที่เกี่ยวข้องยังทำตามสิ่งที่คุยกันไว้หรือไม่',
      after:
          'ก่อนรับงานเพิ่ม ให้ดูว่างานหลักยังทำได้ดีเหมือนเดิมหรือไม่ และทุกฝ่ายยังทำตามที่คุยกันไว้ได้จริงหรือไม่',
      semanticIntent: 'คงคุณภาพงานหลักและการทำตามข้อตกลงก่อนรับงานเพิ่ม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-unknown-work-log-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentCareer',
      before:
          'จดเวลาทำงานจริงหนึ่งสัปดาห์ แล้วเก็บไว้เฉพาะหน้าที่ที่ไม่ทำให้งานหลักแย่ลง หลังรับงานใหม่ ลองถามว่างานหลักยังได้มาตรฐานเดิมหรือไม่',
      after:
          'ลองจดเวลาทำงานจริงสักหนึ่งสัปดาห์ แล้วตัดงานที่ทำให้งานหลักแย่ลงออก หลังรับงานใหม่ ลองดูว่างานหลักยังได้มาตรฐานเดิมหรือไม่',
      semanticIntent: 'คงการจดเวลางานและตัดหน้าที่ที่ลดคุณภาพงานหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-checkpoint-work-natural',
      sourceTemplate: 'ThaiBetaNarrativeComposer.annualCareer',
      before:
          'งานที่ทำได้ดีซ้ำ ๆ อาจนำไปสู่หน้าที่ใหม่ เก็บตัวอย่างผลงานไว้ แล้วเลือกบทบาทจากงานที่คุณยังรักษาคุณภาพเดิมได้',
      after:
          'งานที่คุณทำได้ดีอย่างสม่ำเสมออาจนำไปสู่หน้าที่ใหม่ เก็บตัวอย่างผลงานไว้ แล้วเลือกบทบาทที่คุณยังรักษาคุณภาพงานเดิมได้',
      semanticIntent: 'คงผลงานสม่ำเสมอ หน้าที่ใหม่ และการรักษาคุณภาพเดิม',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-checkpoint-timing-neutral',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.careerCheckpoint',
      before:
          'เมื่อถึงรอบส่งมอบงานกลางปี ให้ทบทวนว่าจะรับบทบาทเดิมเพิ่ม หยุดรับ หรือปรับแผน',
      after:
          'เมื่อถึงรอบส่งมอบงานสำคัญ ให้ทบทวนว่าจะรับบทบาทเดิมเพิ่ม หยุดรับ หรือปรับแผน',
      semanticIntent:
          'คงหมุดทบทวนรอบส่งมอบงานโดยไม่ระบุช่วงเดือนที่หลักฐานไม่รองรับ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-infographic-known-opportunity-distinct',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.opportunity',
      before: 'รับงานเพิ่มได้ทีละขั้น แต่ต้องไม่ทำให้งานหลักเสียคุณภาพ',
      after: 'ค่อย ๆ รับงานที่ช่วยยกระดับผลงาน โดยดูว่างานหลักยังดีเหมือนเดิม',
      semanticIntent: 'คงโอกาสรับงานทีละขั้นที่ช่วยผลงานโดยรักษาคุณภาพงานหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-infographic-unknown-theme-no-system-voice',
      sourceTemplate: 'ThaiBetaAnnualInfographicData.theme',
      before:
          'ใน 12 เดือนนี้ ให้ดูว่าหน้าที่เปลี่ยนไปอย่างไร และแต่ละฝ่ายทำตามที่คุยกันได้จริงหรือไม่ โดยไม่สรุปเหตุการณ์ล่วงหน้า',
      after:
          'ใน 12 เดือนนี้ ให้ดูว่าหน้าที่เปลี่ยนไปอย่างไร และแต่ละฝ่ายทำตามที่คุยกันได้จริงหรือไม่',
      semanticIntent:
          'คงการดูหน้าที่และการทำตามข้อตกลง โดยย้ายข้อจำกัดไปส่วนหลัก',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-hanging-overcapacity-boundary',
      sourceTemplate: 'ThaiBetaReportNarrativePlan',
      before: 'เกินกำลัง ก่อนรับ',
      after: 'เกินกำลัง. ก่อนรับ',
      semanticIntent:
          'คงคำเตือนเรื่องกำลังและแยกคำแนะนำก่อนรับเรื่องใหม่เป็นประโยคสมบูรณ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-hanging-principal-boundary',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.finance',
      before: 'เงินก้อนหลัก ก่อนตัดสินใจ',
      after: 'เงินก้อนหลัก. ก่อนตัดสินใจ',
      semanticIntent:
          'คงการป้องกันเงินก้อนหลักและแยกคำแนะนำก่อนตัดสินใจเป็นประโยคสมบูรณ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-closing-observable-choice',
      sourceTemplate: 'ThaiBirthProfileCoreReading.closing',
      before: 'แล้วใช้ผลจริงตัดสินว่าจะรักษาอะไรไว้',
      after: 'แล้วลองดูว่าอะไรควรทำต่อและอะไรควรตัดออก',
      semanticIntent:
          'คงการตัดสินใจจากสิ่งที่เกิดขึ้นจริงด้วยการกระทำที่เห็นภาพ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-hanging-principal-before-accept',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.finance',
      before: 'เงินก้อนหลัก ก่อนรับ',
      after: 'เงินก้อนหลัก. ก่อนรับ',
      semanticIntent:
          'คงการป้องกันเงินก้อนหลักและแยกคำแนะนำก่อนรับภาระเป็นประโยคสมบูรณ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-hanging-principal-before-add',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.finance',
      before: 'เงินก้อนหลัก ก่อนเพิ่ม',
      after: 'เงินก้อนหลัก. ก่อนเพิ่ม',
      semanticIntent:
          'คงการป้องกันเงินก้อนหลักและแยกคำแนะนำก่อนเพิ่มภาระเป็นประโยคสมบูรณ์',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-checkpoint-label-neutral',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.checkpointLabel',
      before: 'รอบส่งมอบงานกลางปี',
      after: 'รอบส่งมอบงานสำคัญ',
      semanticIntent:
          'คงหมุดรอบส่งมอบงานโดยไม่สร้างช่วงเวลาเฉพาะที่หลักฐานไม่รองรับ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-known-opening-remove-repeated-question',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.opening',
      before:
          ' ก่อนตัดสินใจ ลองดูว่าคุณยังมีเวลาอธิบายงานให้ทุกคนเข้าใจตรงกันหรือไม่ คำถามคือ งานที่กำลังขยายยังเหลือเวลาและความชัดให้คนที่เกี่ยวข้องหรือไม่',
      after:
          ' ก่อนตัดสินใจ ลองดูว่าคุณยังมีเวลาอธิบายงานให้ทุกคนเข้าใจตรงกันหรือไม่',
      semanticIntent:
          'คงคำถามเรื่องเวลาและความชัดเจนไว้ครั้งเดียวโดยตัดคำถามซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-known-current-decision-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentDecision',
      before:
          'ตอนนี้ เลือกตัดสินใจเรื่องงานเพียงเรื่องเดียว แล้วดูว่างานหลักยังทำได้ดีและสิ่งที่คุยกับคนอื่นไว้ยังไม่ถูกละเลย',
      after:
          'ตอนนี้ เลือกเรื่องงานที่สำคัญที่สุดมาจัดการก่อนเพียงเรื่องเดียว แล้วดูว่างานหลักยังทำได้ดี และคุณยังทำตามที่รับปากคนอื่นไว้ได้หรือไม่',
      semanticIntent:
          'คงการเลือกงานหนึ่งเรื่อง คุณภาพงานหลัก และการทำตามข้อตกลง',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-opening-question-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.opening',
      before:
          'คำถามคือ งานที่กำลังขยายยังเหลือเวลาและความชัดให้คนที่เกี่ยวข้องหรือไม่',
      after:
          'ลองดูว่างานที่กำลังขยายยังเหลือเวลาและความชัดให้คนที่เกี่ยวข้องหรือไม่',
      semanticIntent:
          'คงคำถามเรื่องเวลาและความชัดเจนด้วยถ้อยคำสนทนาที่เป็นธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-overcapacity-sentence-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan',
      before: 'เกินกำลัง. ก่อนรับโอกาสใหม่ ให้ดู',
      after: 'เกินกำลัง หากมีโอกาสใหม่ ให้ดู',
      semanticIntent:
          'คงคำเตือนเรื่องกำลังและการตรวจข้อมูลก่อนรับโอกาสใหม่ด้วยประโยคไทยธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-principal-sentence-natural',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.finance',
      before: 'เงินก้อนหลัก. ก่อนตัดสินใจเรื่องเงิน ให้ดู',
      after: 'เงินก้อนหลัก เมื่อต้องตัดสินใจเรื่องเงิน ให้ดู',
      semanticIntent:
          'คงการป้องกันเงินก้อนหลักและการตรวจเงินพร้อมใช้ก่อนตัดสินใจ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-unknown-work-log-no-repeat',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentCareer',
      before:
          'ลองจดเวลาทำงานจริงสักหนึ่งสัปดาห์ แล้วตัดงานที่ทำให้งานหลักแย่ลงออก หลังรับงานใหม่ ลองดูว่างานหลักยังได้มาตรฐานเดิมหรือไม่',
      after:
          'ลองจดเวลาทำงานจริงสักหนึ่งสัปดาห์ แล้วเก็บไว้เฉพาะงานที่ไม่ทำให้งานหลักแย่ลง',
      semanticIntent: 'คงการจดเวลางานและรักษาคุณภาพงานหลักโดยไม่กล่าวซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-long-term-relationship-no-repeat',
      sourceTemplate:
          'ThaiBetaReportNarrativePlan.supportingLongTermRelationship',
      before:
          'สิ่งที่ทำได้จริงสำคัญกว่าคำสัญญา ในระยะยาว ให้ดูว่าทั้งสองฝ่ายแบ่งเวลาและหน้าที่กันได้จริง ไม่ใช่แค่พูดตกลงกันไว้',
      after: 'สิ่งที่ทำได้จริงสำคัญกว่าคำสัญญา',
      semanticIntent:
          'คงการดูการแบ่งเวลาและหน้าที่จากสิ่งที่ทำได้จริงโดยตัดความหมายซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-known-long-term-work-no-repeat',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.supportingLongTermCareer',
      before:
          'ต่อไปควรรับงานให้น้อยลงแต่ดูแลคุณภาพให้มากขึ้น เลือกเก็บงานที่ใช้ประสบการณ์ของคุณเต็มที่ และส่งต่องานที่ทำให้ต้องแบ่งแรงหลายทาง ในระยะยาว ให้เลือกว่างานใดควรเก็บไว้ทำต่อ และงานใดควรส่งต่อให้คนอื่น',
      after:
          'ต่อไปควรรับงานให้น้อยลงแต่ดูแลคุณภาพให้มากขึ้น เลือกเก็บงานที่ใช้ประสบการณ์ของคุณเต็มที่ และส่งต่องานที่ทำให้ต้องแบ่งแรงหลายทาง',
      semanticIntent:
          'คงการเลือกงานจากประสบการณ์และส่งต่องานที่แบ่งแรงโดยตัดข้อสรุปซ้ำ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-known-long-term-relationship-natural',
      sourceTemplate:
          'ThaiBetaReportNarrativePlan.supportingLongTermRelationship',
      before:
          'เมื่อหน้าที่เปลี่ยนไป ให้คุยกันใหม่ว่าใครมีเวลาแค่ไหน ใครรับผิดชอบอะไร และแต่ละคนต้องการพื้นที่ส่วนตัวเท่าไร ในระยะยาว ให้ดูว่าทั้งสองฝ่ายแบ่งเวลาและหน้าที่กันได้จริง ไม่ใช่แค่พูดตกลงกันไว้',
      after:
          'เมื่อหน้าที่เปลี่ยนไป ให้คุยกันใหม่ว่าใครมีเวลาแค่ไหน ใครรับผิดชอบอะไร และแต่ละคนต้องการพื้นที่ส่วนตัวเท่าไร แล้วดูว่าทั้งสองฝ่ายทำได้จริง ไม่ใช่แค่พูดตกลงกันไว้',
      semanticIntent:
          'คงการแบ่งเวลา หน้าที่ และพื้นที่ส่วนตัวจากการปฏิบัติจริงด้วยคำเชื่อมธรรมชาติ',
    ),
    ThaiBetaReaderCopyRule(
      id: 'or2-final-unknown-current-finance-no-repeat',
      sourceTemplate: 'ThaiBetaReportNarrativePlan.currentFinance',
      before:
          'ก่อนรับรายจ่ายที่ต้องจ่ายต่อเนื่อง ให้ดูรายรับ รายจ่าย และเงินคงเหลือจริง ก่อนตัดสินใจเรื่องเงิน ให้ดูว่าเมื่อจ่ายรายการจำเป็นแล้ว คุณยังเหลือเงินพร้อมใช้เท่าไร',
      after:
          'ก่อนรับรายจ่ายที่ต้องจ่ายต่อเนื่อง ให้ดูรายรับ รายจ่าย และเงินคงเหลือจริง หลังจ่ายรายการจำเป็นแล้ว คุณยังเหลือเงินพร้อมใช้เท่าไร',
      semanticIntent:
          'คงการตรวจรายรับ รายจ่าย เงินคงเหลือ และเงินพร้อมใช้ก่อนรับภาระต่อเนื่องโดยไม่ใช้คำซ้ำ',
    ),
  ];

  static String refine(String value) => refineForField(value);

  static String refineForField(String value, {String fieldPath = ''}) {
    var result = value;
    for (final rule in rules) {
      if (!rule.appliesTo(fieldPath)) continue;
      result = result.replaceAll(rule.before, rule.after);
    }
    result = result
        .replaceAll(
          'และการลงมือปรากฏตรงไหน',
          'และช่วงใดที่คุณเริ่มลงมือเลือกเส้นทางด้วยตัวเอง',
        )
        .replaceAll(
          'และการเติบโตปรากฏตรงไหน',
          'และช่วงใดที่คุณเริ่มเติบโตจากทางเลือกของตัวเอง',
        );
    result = result.replaceFirstMapped(
      RegExp(
        r'ลองย้อนดูว่า (.+?)ใน(.+?)อาจเทียบได้กับความทรงจำเรื่องบ้าน ผู้ดูแล ความปลอดภัย การเรียนรู้ การเล่น และการได้รับการยอมรับ ลองนึกว่าฐานใดยังติดตัวมาถึงวันนี้',
      ),
      (match) =>
          'ลองทบทวน${match.group(2)}ผ่านความทรงจำเรื่องบ้าน ผู้ดูแล ความปลอดภัย การเรียนรู้ การเล่น และการได้รับการยอมรับ แล้วสังเกตว่า${match.group(1)}และฐานใดยังติดตัวมาถึงวันนี้',
    );
    result = result.replaceFirstMapped(
      RegExp(r'แล้วสังเกตว่า(.+?)และฐานใดยังติดตัวมาถึงวันนี้'),
      (match) =>
          'แล้วสังเกตว่า${match.group(1)}หรือพื้นฐานใดยังมีผลต่อคุณในวันนี้',
    );
    result = result.replaceFirstMapped(
      RegExp(
        r'ลองย้อนดูว่า ใน(.+?) ลองมอง(.+?)ผ่านการเรียน เพื่อน กฎ ความคาดหวัง และการเริ่มเลือกด้วยเสียงของตัวเอง',
      ),
      (match) =>
          'ลองทบทวน${match.group(1)}ผ่านการเรียน เพื่อน กฎ และความคาดหวัง แล้วสังเกตว่า${match.group(2)}เกี่ยวข้องกับการเริ่มเลือกด้วยเสียงของตัวเองอย่างไร',
    );
    result = result.replaceFirstMapped(
      RegExp(
        r'ลองย้อนดูว่า (.+?)ของ(.+?)อยู่ในบริบทของการเป็นอิสระ การศึกษา การเริ่มงาน ความสัมพันธ์ และ(?:ทรัพยากรที่ต้องจัดการเองมากขึ้น|เงิน เวลา หรือสิ่งที่ต้องรับผิดชอบเองมากขึ้น) ลองแยกสิ่งที่คุณเลือกเองจากสิ่งที่รับตามแรงรอบตัว',
      ),
      (match) =>
          'เมื่อนึกถึง${match.group(2)} ลองทบทวนเรื่องการเป็นอิสระ การศึกษา การเริ่มงาน ความสัมพันธ์ เงิน เวลา และสิ่งที่ต้องรับผิดชอบด้วยตัวเอง แล้วแยกดูว่าสิ่งใดเป็นทางเลือกของคุณ และสิ่งใดเกิดจากความคาดหวังรอบตัว',
    );
    result = result.replaceFirstMapped(
      RegExp(
        r'ลองย้อนดูว่า ลองวาง(.+?)ของ(.+?)ไว้ข้างงาน เงิน ความสัมพันธ์ ความรับผิดชอบ และบทบาทที่อาจต้องจัดใหม่ แล้วดูว่าเกณฑ์เดิมส่วนใดยังควรรักษา',
      ),
      (match) =>
          'ลองทบทวน${match.group(2)}โดยมองงาน เงิน ความสัมพันธ์ ความรับผิดชอบ และบทบาทที่ต้องจัดใหม่ แล้วดูว่า${match.group(1)}มีผลอย่างไร และหลักเดิมข้อใดยังใช้ได้กับชีวิตตอนนี้',
    );
    result = result
        .replaceAll(
          'และการลงมือปรากฏตรงไหน',
          'และช่วงใดที่คุณเริ่มลงมือเลือกเส้นทางด้วยตัวเอง',
        )
        .replaceAll(
          'และการเติบโตปรากฏตรงไหน',
          'และช่วงใดที่คุณเริ่มเติบโตจากทางเลือกของตัวเอง',
        );
    result = result
        .replaceAll(
          'ลองทบทวนช่วงวางรากฐานผ่านความทรงจำเรื่องบ้าน ผู้ดูแล ความปลอดภัย การเรียนรู้ การเล่น และการได้รับการยอมรับ แล้วสังเกตว่าความมั่นคงหรือพื้นฐานใดยังมีผลต่อคุณในวันนี้',
          'เมื่อนึกถึงวัยนั้น ลองดูว่าเรื่องบ้าน คนที่ดูแล ความรู้สึกปลอดภัย การเรียนรู้ การเล่น หรือการได้รับการยอมรับ เรื่องใดยังมีผลต่อคุณในวันนี้',
        )
        .replaceAll(
          'ลองทบทวนช่วงเปล่งประกายผ่านความทรงจำเรื่องบ้าน ผู้ดูแล ความปลอดภัย การเรียนรู้ การเล่น และการได้รับการยอมรับ แล้วสังเกตว่าการยอมรับหรือพื้นฐานใดยังมีผลต่อคุณในวันนี้',
          'เมื่อนึกถึงวัยนั้น ลองดูว่าเรื่องบ้าน คนที่ดูแล ความรู้สึกปลอดภัย การเรียนรู้ การเล่น หรือการได้รับการยอมรับ เรื่องใดยังมีผลต่อคุณในวันนี้',
        )
        .replaceAll(
          'ลองทบทวนช่วงดูแลใจผ่านการเรียน เพื่อน กฎ และความคาดหวัง แล้วสังเกตว่าความรู้สึกเกี่ยวข้องกับการเริ่มเลือกด้วยเสียงของตัวเองอย่างไร',
          'เมื่อนึกถึงช่วงดูแลใจ ลองดูว่าการเรียน เพื่อน กฎ และความคาดหวังรอบตัวมีผลต่อความรู้สึกของคุณอย่างไร และเมื่อไรที่คุณเริ่มเลือกสิ่งที่ตัวเองต้องการ',
        )
        .replaceAll(
          'ลองทบทวนช่วงพลิกผันและเปลี่ยนผ่านโดยมองงาน เงิน ความสัมพันธ์ ความรับผิดชอบ และบทบาทที่ต้องจัดใหม่ แล้วดูว่าการเปลี่ยนแปลงมีผลอย่างไร และหลักเดิมข้อใดยังใช้ได้กับชีวิตตอนนี้',
          'เมื่อนึกถึงช่วงพลิกผันและเปลี่ยนผ่าน ลองดูว่างาน เงิน ความสัมพันธ์ ความรับผิดชอบ หรือบทบาทใดเปลี่ยนไป และหลักเดิมข้อใดยังใช้ได้กับชีวิตตอนนี้',
        );
    return result;
  }

  static List<ThaiBetaReaderCopyRule> matchingRules(
    String value, {
    String fieldPath = '',
  }) {
    var result = value;
    final matched = <ThaiBetaReaderCopyRule>[];
    for (final rule in rules) {
      if (!rule.appliesTo(fieldPath) || !result.contains(rule.before)) continue;
      matched.add(rule);
      result = result.replaceAll(rule.before, rule.after);
    }
    return List.unmodifiable(matched);
  }
}

class ThaiBetaReaderCopyRule {
  const ThaiBetaReaderCopyRule({
    required this.id,
    required this.sourceTemplate,
    required this.before,
    required this.after,
    required this.semanticIntent,
    this.fieldPathPrefix,
  });

  final String id;
  final String sourceTemplate;
  final String before;
  final String after;
  final String semanticIntent;
  final String? fieldPathPrefix;

  bool appliesTo(String fieldPath) =>
      fieldPathPrefix == null || fieldPath.startsWith(fieldPathPrefix!);
}
