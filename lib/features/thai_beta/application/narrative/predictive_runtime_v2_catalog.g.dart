// GENERATED FILE — source: Candidate 0011 immutable oracle + resolved rule map.
// Regenerate with: node tool/generate_predictive_runtime_v2_catalog.mjs
part of 'predictive_runtime_v2.dart';

const runtimePredictiveV2OracleSha256 = "6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E";
const runtimePredictiveV2AcceptedContext = "mahabhut2537.rem0.saturday";
const runtimePredictiveV2EvidenceIds = <String>{
  "canon.mahabhut.p16.venus_owns_relationship_male",
  "canon.mahabhut.p220.jupiter_owns_career",
  "canon.mahabhut.p220.jupiter_owns_learning",
  "canon.mahabhut.p28.mercury_owns_family",
  "canon.mahabhut.p28.saturn_owns_family",
  "canon.mahabhut.p28.venus_owns_relationship",
  "canon.mahabhut.p33.mercury_relates_attribute_profession_นักพูด",
  "canon.mahabhut.p35.venus_relates_attribute_disease_ความเจ็บป่วยอันเนื่องมาจากร่างกายไม่ได้รับการพักผ่อน",
  "canon.mahabhut.p39.det_owns_career",
  "canon.mahabhut.p39.sri_owns_finance",
  "certainty.product-interpretation-contract-v1",
  "conflict.T0003-SRC-42-43-61-62-EXCEPTION",
  "conflict.contract-boundaries",
  "domain.runtime.current.career",
  "domain.runtime.current.finance",
  "domain.runtime.current.health",
  "domain.runtime.nextLifePeriod.career",
  "domain.runtime.nextLifePeriod.finance",
  "fixture.target-0003",
  "selector.mahabhut2537.rem0.saturday.jupiter.11_29",
  "selector.mahabhut2537.rem0.saturday.mercury.63_79",
  "selector.mahabhut2537.rem0.saturday.rahu.30_41",
  "selector.mahabhut2537.rem0.saturday.saturn.0_10",
  "selector.mahabhut2537.rem0.saturday.venus.42_62",
  "source.T0003-SRC-0-10-FAMILY-CONSTRAINT",
  "source.T0003-SRC-11-62-RISING-BLOCK",
  "source.T0003-SRC-30-41-PLACEMENT",
  "source.T0003-SRC-42-62-FINANCE",
  "source.T0003-SRC-42-62-FLOW",
  "source.T0003-SRC-42-62-SUPPORT",
  "source.T0003-SRC-42-62-WORK",
  "source.T0003-SRC-63-79-PLACEMENT",
  "timing.rolling-12-month-label",
  "typed.current.career",
  "typed.current.finance",
  "typed.current.health",
  "typed.current.relationship",
  "typed.next12Months.career",
  "typed.next12Months.finance",
  "typed.next12Months.relationship",
  "typed.nextLifePeriod.career",
  "typed.nextLifePeriod.finance",
  "RC11-K-OVERVIEW-01",
  "RC11-K-PAST-01",
  "RC11-K-PAST-02",
  "RC11-K-PAST-03",
  "RC11-K-PAST-04",
  "RC11-K-PAST-05",
  "RC11-K-CURRENT-01",
  "RC11-K-WORK-01",
  "RC11-K-WORK-02",
  "RC11-K-FINANCE-01",
  "RC11-K-FINANCE-02",
  "RC11-K-RELATIONSHIP-01",
  "RC11-K-RELATIONSHIP-02",
  "RC11-K-HEALTH-01",
  "RC11-K-HEALTH-02",
  "RC11-K-SUPPORT-01",
  "RC11-K-SUPPORT-02",
  "RC11-K-HORIZON-01",
  "RC11-K-HORIZON-02",
  "RC11-K-HORIZON-03",
  "RC11-K-NEXT-01",
  "RC11-K-NEXT-02",
};

const runtimePredictiveV2Rules = <RuntimePredictiveRule>[
  RuntimePredictiveRule(
    id: "RC11-K-OVERVIEW-01",
    section: "ภาพรวมเส้นทางชีวิต",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "ชีวิตเดินเป็นช่วงชัดเจน วัยเด็กอยู่ใต้เงื่อนไขของบ้าน ช่วงอายุ 11–29 ได้ออกไปพบโลกที่กว้างขึ้น ช่วงอายุ 30–41 เจอการเปลี่ยนครั้งใหญ่ และหลังอายุ 42 ประสบการณ์ที่สั่งสมมาเริ่มให้ผลกับชีวิต",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "0-62",
    domain: "life_path",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.saturn.0_10",
      "selector.mahabhut2537.rem0.saturday.jupiter.11_29",
      "selector.mahabhut2537.rem0.saturday.rahu.30_41",
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-0-10-FAMILY-CONSTRAINT",
      "canon.mahabhut.p220.jupiter_owns_learning",
      "canon.mahabhut.p39.det_owns_career",
      "source.T0003-SRC-42-62-FLOW",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-0-10-FAMILY-CONSTRAINT",
      "source.T0003-SRC-11-62-RISING-BLOCK",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.saturn.0_10",
      "selector.mahabhut2537.rem0.saturday.jupiter.11_29",
      "selector.mahabhut2537.rem0.saturday.rahu.30_41",
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-PAST-01",
    section: "อายุ 1–10 ปี",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "วัย 1–10 ปีมีเงื่อนไขจากครอบครัวและผู้ใหญ่เข้ามากำหนดชีวิตมากกว่าวัยอื่น บางช่วงต้องเปลี่ยนความเคยชินหรือช่วยรับภาระในบ้านเร็วกว่าวัย ความสบายในวัยเด็กจึงถูกแบ่งด้วยหน้าที่ที่หลีกเลี่ยงไม่ได้",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "1-10",
    domain: "support_and_family",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.saturn.0_10",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-0-10-FAMILY-CONSTRAINT",
      "canon.mahabhut.p28.saturn_owns_family",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-0-10-FAMILY-CONSTRAINT",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.saturn.0_10",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-PAST-02",
    section: "อายุ 11–29 ปี",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "ช่วงอายุ 11–29 ชีวิตเปิดกว้างขึ้นผ่านการเรียน งาน และสังคมใหม่ เส้นทางเดิมขยายออกเพราะได้พบคนที่มีประสบการณ์กว่า พร้อมกับการเปลี่ยนแวดวงหรือเปลี่ยนวิธีมองหาโอกาสจากเดิม",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "11-29",
    domain: "education_social",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.jupiter.11_29",
    ],
    domainRefs: <String>[
      "canon.mahabhut.p220.jupiter_owns_learning",
      "canon.mahabhut.p220.jupiter_owns_career",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-11-62-RISING-BLOCK",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.jupiter.11_29",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-PAST-03",
    section: "อายุ 11–29 ปี",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "ช่วงปลายของรอบนี้เริ่มรับผิดชอบเรื่องงานและเงินจริงจังขึ้น ความสัมพันธ์บางส่วนเปลี่ยนจากการคบหาตามสถานการณ์มาเป็นการตกลงว่าใครจะอยู่ต่อ ใครจะห่างออก และเรื่องใดต้องจัดการด้วยตัวเอง",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "11-29",
    domain: "responsibility_relationship",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.jupiter.11_29",
    ],
    domainRefs: <String>[
      "canon.mahabhut.p220.jupiter_owns_career",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-11-62-RISING-BLOCK",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.jupiter.11_29",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-PAST-04",
    section: "อายุ 30–41 ปี",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "ช่วงอายุ 30–41 งานเปลี่ยนทิศอย่างชัดเจน หน้าที่ชุดใหม่เข้ามาแทนวิธีทำงานเดิม และผลงานที่ทำต่อเนื่องพาไปสู่ขอบเขตงานที่กว้างขึ้น",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "30-41",
    domain: "work",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.rahu.30_41",
    ],
    domainRefs: <String>[
      "canon.mahabhut.p39.det_owns_career",
      "source.T0003-SRC-30-41-PLACEMENT",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-11-62-RISING-BLOCK",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.rahu.30_41",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-PAST-05",
    section: "อายุ 30–41 ปี",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "ในช่วงเดียวกัน งานหรือข้อตกลงสำคัญเปลี่ยนรูปแบบ ทางที่เดินต่อได้กลายเป็นฐานของรอบปัจจุบัน ส่วนภาระที่กินแรงแต่ไม่พาชีวิตไปข้างหน้าค่อย ๆ จบลงหรือมีคนอื่นรับช่วงต่อ",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "30-41",
    domain: "work_and_commitment",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.rahu.30_41",
    ],
    domainRefs: <String>[
      "canon.mahabhut.p39.det_owns_career",
      "source.T0003-SRC-30-41-PLACEMENT",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-11-62-RISING-BLOCK",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.rahu.30_41",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-CURRENT-01",
    section: "คำทำนายปัจจุบัน — อายุ {{currentAge}} ปี",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "อายุ {{currentAge}} เป็นปีเปลี่ยนผ่าน ภาระเก่าต้องได้ข้อสรุป ขอบเขตที่เคยปล่อยค้างจะถูกจัดใหม่ และชีวิตเริ่มกันพื้นที่ไว้ให้เรื่องที่สำคัญกว่าเดิม",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "age44",
    domain: "work",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "fixture.target-0003",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-FLOW",
      "domain.runtime.current.career",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-42-62-FLOW",
      "typed.current.career",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "fixture.target-0003",
    ],
    conflictRefs: <String>[
      "conflict.T0003-SRC-42-43-61-62-EXCEPTION",
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-WORK-01",
    section: "การงาน",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "หน้าที่การงานขยับจากการทำตามโจทย์ไปสู่การกำหนดทางเดินของงาน คุณจะรับผิดชอบผลลัพธ์มากขึ้น ได้ตัดสินใจเรื่องที่กระทบคนอื่น และถูกเรียกใช้ในงานที่ต้องอาศัยประสบการณ์มากกว่าการลงแรงอย่างเดียว",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "work",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-WORK",
      "domain.runtime.current.career",
    ],
    directionRefs: <String>[
      "typed.current.career",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "typed.current.career",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-WORK-02",
    section: "การงาน",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "โอกาสงานใหม่จะมาจากผลงานที่คนเคยเห็นและเชื่อมือ ส่วนงานเดิมที่ซ้ำ เสียเวลา หรือให้ภาระมากกว่าผลตอบแทนจะลดบทบาทลง สุดท้ายงานจะเหลือน้อยประเภทแต่แต่ละเรื่องมีน้ำหนักมากขึ้น",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "work",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-WORK",
      "domain.runtime.current.career",
    ],
    directionRefs: <String>[
      "typed.current.career",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "typed.current.career",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-FINANCE-01",
    section: "การเงิน",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "รายได้ขยับตามบทบาทและผลงาน เงินหลักมาจากงานที่ทำสำเร็จและทักษะที่ใช้ได้จริง ไม่ใช่การเสี่ยงโดยไม่มีข้อมูลรองรับ",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "finance",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-FINANCE",
      "canon.mahabhut.p39.sri_owns_finance",
      "domain.runtime.current.finance",
    ],
    directionRefs: <String>[
      "typed.current.finance",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "typed.current.finance",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-FINANCE-02",
    section: "การเงิน",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "เงินหมุนคล่องขึ้น แต่รายจ่ายก้อนสำคัญเกี่ยวกับงาน บ้าน หรือภาระที่ต้องจัดการให้จบจะเข้ามาพร้อมกัน ฐานการเงินจะค่อย ๆ นิ่งเมื่อเงินไม่ต้องไหลไปเลี้ยงภาระที่ไม่สร้างผลต่อเนื่อง",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "finance",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-FINANCE",
      "domain.runtime.current.finance",
    ],
    directionRefs: <String>[
      "typed.current.finance",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "typed.current.finance",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-RELATIONSHIP-01",
    section: "ความรักและความสัมพันธ์",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "ความสัมพันธ์ที่คลุมเครือจะชัดขึ้นจากการกระทำและข้อตกลง คนที่พร้อมเดินต่อจะแสดงความรับผิดชอบให้เห็น ส่วนคนที่มีแต่คำพูดจะเว้นระยะหรือหลุดออกจากชีวิตเอง",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "relationship",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "canon.mahabhut.p16.venus_owns_relationship_male",
      "canon.mahabhut.p28.venus_owns_relationship",
    ],
    directionRefs: <String>[
      "typed.current.relationship",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "typed.current.relationship",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-RELATIONSHIP-02",
    section: "ความรักและความสัมพันธ์",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "บทสนทนาเรื่องเวลา หน้าที่ เงิน และพื้นที่ส่วนตัวจะตรงไปตรงมาขึ้น บางความสัมพันธ์จึงแน่นแฟ้นกว่าเดิม ขณะที่บางความสัมพันธ์เปลี่ยนระยะเพื่อให้แต่ละฝ่ายกลับไปจัดการชีวิตของตัวเอง",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "relationship",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "canon.mahabhut.p16.venus_owns_relationship_male",
      "canon.mahabhut.p28.venus_owns_relationship",
    ],
    directionRefs: <String>[
      "typed.current.relationship",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "typed.current.relationship",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-HEALTH-01",
    section: "สุขภาพ",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "ภาระงานที่เพิ่มขึ้นทำให้ความเครียดและการพักไม่พอแสดงผลชัด ร่างกายใช้เวลาฟื้นจากวันที่ทำงานต่อเนื่องนานกว่าเดิม และแรงจะหมดเร็วเมื่อรับหลายเรื่องพร้อมกัน",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "health",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "canon.mahabhut.p35.venus_relates_attribute_disease_ความเจ็บป่วยอันเนื่องมาจากร่างกายไม่ได้รับการพักผ่อน",
      "domain.runtime.current.health",
    ],
    directionRefs: <String>[
      "typed.current.health",
      "typed.current.career",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "typed.current.health",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-HEALTH-02",
    section: "สุขภาพ",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "พอภาระเบาลงและเรื่องค้างลดลง กำลังจะค่อย ๆ กลับมา วันที่ได้นอนและพักต่อเนื่องจะฟื้นตัวได้ดีกว่าการหยุดสั้น ๆ แล้วกลับไปเร่งงานเหมือนเดิม",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "health",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "canon.mahabhut.p35.venus_relates_attribute_disease_ความเจ็บป่วยอันเนื่องมาจากร่างกายไม่ได้รับการพักผ่อน",
      "domain.runtime.current.health",
    ],
    directionRefs: <String>[
      "typed.current.health",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "typed.current.health",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-SUPPORT-01",
    section: "โชคลาภและแรงสนับสนุน",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "แรงหนุนมาจากผู้ใหญ่ ครู เพื่อน และคนที่เคยทำงานร่วมกัน คนเหล่านี้จะช่วยเปิดทาง แนะนำโอกาส หรือพาเรื่องที่ติดขัดกลับมาเดินได้อีกครั้ง",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "support",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-SUPPORT",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-42-62-SUPPORT",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-SUPPORT-02",
    section: "โชคลาภและแรงสนับสนุน",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "โอกาสเด่นจะมาจากงานเก่า คนรู้จักเดิม หรือเรื่องที่เคยทำสำเร็จ ชื่อเสียงจากผลงานจะพาโอกาสกลับมา มากกว่าการได้สิ่งใหญ่จากการเสี่ยงโดยไม่มีฐานรองรับ",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62|age44",
    domain: "luck",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-SUPPORT",
      "source.T0003-SRC-42-62-WORK",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-42-62-SUPPORT",
      "typed.current.career",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-HORIZON-01",
    section: "คำทำนาย 12 เดือนข้างหน้า",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "ระหว่างวันที่ {{horizonStart}} ถึง {{horizonEnd}} งานที่ค้างจะได้ข้อสรุป และหน้าที่ชุดใหม่จะเริ่มเข้าที่ ภายในรอบนี้คุณจะรู้ชัดว่างานใดอยู่ต่อและงานใดต้องส่งต่อ",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "2026-08-29/2027-08-28|age44-45",
    domain: "work",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-WORK",
      "domain.runtime.current.career",
    ],
    directionRefs: <String>[
      "typed.next12Months.career",
    ],
    timingRefs: <String>[
      "typed.next12Months.career",
      "timing.rolling-12-month-label",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-HORIZON-02",
    section: "คำทำนาย 12 เดือนข้างหน้า",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "ในช่วงเดียวกัน รายรับและภาระทางเงินจะขยับขึ้นพร้อมกัน ส่วนข้อตกลงสำคัญในความสัมพันธ์จะได้คำตอบจากการแบ่งเวลาและหน้าที่ให้ชัด",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "2026-08-29/2027-08-28|age44-45",
    domain: "finance_relationship",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-FINANCE",
      "canon.mahabhut.p16.venus_owns_relationship_male",
    ],
    directionRefs: <String>[
      "typed.next12Months.finance",
      "typed.next12Months.relationship",
    ],
    timingRefs: <String>[
      "typed.next12Months.finance",
      "typed.next12Months.relationship",
      "timing.rolling-12-month-label",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-HORIZON-03",
    section: "คำทำนาย 12 เดือนข้างหน้า",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "แรงหนุนที่มีอยู่จะช่วยให้การเจรจาและการปิดเรื่องค้างเดินเร็วขึ้น อุปสรรคที่เคยทำให้งานชะงักจะลดลงภายในรอบนี้",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "2026-08-29/2027-08-28|age44-45",
    domain: "support",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-42-62-SUPPORT",
    ],
    directionRefs: <String>[
      "source.T0003-SRC-42-62-SUPPORT",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.venus.42_62",
      "timing.rolling-12-month-label",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-NEXT-01",
    section: "ช่วงชีวิตถัดไป — อายุ 63–79 ปี",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "เมื่ออายุ 63 ปี ชีวิตเข้าสู่ช่วงสร้างฐานระยะยาว สิ่งที่สะสมจากงานจะกลายเป็นบ้าน ทรัพย์ หรือฐานการเงินที่มั่นคงขึ้น",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "63-79",
    domain: "foundation",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.mercury.63_79",
    ],
    domainRefs: <String>[
      "source.T0003-SRC-63-79-PLACEMENT",
      "canon.mahabhut.p28.mercury_owns_family",
      "domain.runtime.nextLifePeriod.finance",
    ],
    directionRefs: <String>[
      "typed.nextLifePeriod.finance",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.mercury.63_79",
      "typed.nextLifePeriod.finance",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-NEXT-02",
    section: "ช่วงชีวิตถัดไป — อายุ 63–79 ปี",
    kind: RuntimePredictiveKind.prediction,
    textTemplate: "บทบาทงานจะขยับไปทางวางระบบ ให้ทิศทาง และถ่ายทอดประสบการณ์ งานที่ใช้ความคิด การเจรจา หรือการจัดการข้อมูลจะมีน้ำหนักกว่างานที่ต้องลงแรงทุกขั้นด้วยตัวเอง",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "63-79",
    domain: "work",
    selectorRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.mercury.63_79",
    ],
    domainRefs: <String>[
      "canon.mahabhut.p33.mercury_relates_attribute_profession_นักพูด",
      "domain.runtime.nextLifePeriod.career",
    ],
    directionRefs: <String>[
      "typed.nextLifePeriod.career",
    ],
    timingRefs: <String>[
      "selector.mahabhut2537.rem0.saturday.mercury.63_79",
      "typed.nextLifePeriod.career",
    ],
    conflictRefs: <String>[
      "conflict.contract-boundaries",
    ],
    certaintyRefs: <String>[
      "certainty.product-interpretation-contract-v1",
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-SUMMARY-01",
    section: "สรุปคำทำนาย",
    kind: RuntimePredictiveKind.summary,
    textTemplate: "ชีวิตกำลังเปลี่ยนจากรอบที่ต้องรับมือหลายอย่างพร้อมกัน ไปสู่รอบที่เลือกได้ชัดขึ้นว่าอะไรควรอยู่ต่อ เมื่อจัดภาระลงตัวแล้ว เส้นทางข้างหน้าจะนิ่งและต่อยอดเป็นฐานระยะยาวได้",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62",
    domain: "life_path",
    selectorRefs: <String>[
    ],
    domainRefs: <String>[
    ],
    directionRefs: <String>[
    ],
    timingRefs: <String>[
    ],
    conflictRefs: <String>[
    ],
    certaintyRefs: <String>[
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-ADVICE-01",
    section: "คำแนะนำสั้น ๆ",
    kind: RuntimePredictiveKind.advice,
    textTemplate: "รับงานใหม่เมื่อขอบเขตและอำนาจตัดสินใจชัด เก็บเงินส่วนหนึ่งไว้รองรับรายจ่ายก้อนสำคัญ พูดข้อตกลงกับคนใกล้ตัวให้ตรง และจัดวันพักจริงก่อนที่ความล้าจะสะสมจนกระทบงาน",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62",
    domain: "advice",
    selectorRefs: <String>[
    ],
    domainRefs: <String>[
    ],
    directionRefs: <String>[
    ],
    timingRefs: <String>[
    ],
    conflictRefs: <String>[
    ],
    certaintyRefs: <String>[
    ],
  ),
  RuntimePredictiveRule(
    id: "RC11-K-DISCLOSURE-01",
    section: "คำแนะนำสั้น ๆ",
    kind: RuntimePredictiveKind.disclosure,
    textTemplate: "คำทำนายนี้เป็นมุมมองตามความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ",
    contextId: "mahabhut2537.rem0.saturday",
    periodBinding: "42-62",
    domain: "disclosure",
    selectorRefs: <String>[
    ],
    domainRefs: <String>[
    ],
    directionRefs: <String>[
    ],
    timingRefs: <String>[
    ],
    conflictRefs: <String>[
    ],
    certaintyRefs: <String>[
    ],
  ),
];
