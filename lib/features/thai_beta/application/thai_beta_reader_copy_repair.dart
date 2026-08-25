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
        r'ลองย้อนดูว่า (.+?)ของ(.+?)อยู่ในบริบทของการเป็นอิสระ การศึกษา การเริ่มงาน ความสัมพันธ์ และทรัพยากรที่ต้องจัดการเองมากขึ้น ลองแยกสิ่งที่คุณเลือกเองจากสิ่งที่รับตามแรงรอบตัว',
      ),
      (match) =>
          'ลองทบทวน${match.group(2)}ผ่านเรื่องการเป็นอิสระ การศึกษา การเริ่มงาน ความสัมพันธ์ และทรัพยากรที่ต้องจัดการเอง แล้วแยกดูว่าสิ่งใดเป็นทางเลือกของคุณเอง สิ่งใดเกิดจากความคาดหวังรอบตัว และ${match.group(1)}ปรากฏตรงไหน',
    );
    result = result.replaceFirstMapped(
      RegExp(
        r'ลองย้อนดูว่า ลองวาง(.+?)ของ(.+?)ไว้ข้างงาน เงิน ความสัมพันธ์ ความรับผิดชอบ และบทบาทที่อาจต้องจัดใหม่ แล้วดูว่าเกณฑ์เดิมส่วนใดยังควรรักษา',
      ),
      (match) =>
          'ลองทบทวน${match.group(2)}โดยมองงาน เงิน ความสัมพันธ์ ความรับผิดชอบ และบทบาทที่ต้องจัดใหม่ แล้วดูว่า${match.group(1)}และเกณฑ์เดิมส่วนใดยังควรรักษา',
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
