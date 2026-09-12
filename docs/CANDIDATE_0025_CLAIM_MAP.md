# Candidate 0025 — sentence-level claim map

**PENDING OWNER COPY AND EDITORIAL-INTERPRETATION REVIEW — NOT IMPLEMENTED — NOT ACCEPTED**

Every reader-visible sentence or standalone factual line is mapped below. Sentence function and evidence class are separate: function states what the sentence does for the reader, while evidence class states its authority status. Candidate 0025 has no exact SHA or golden.

| ID | Section | Function | Evidence class | Exact reader text | Meaning units | Evidence / support |
|---|---|---|---|---|---|---|
| C25-PROFILE-01 | ข้อมูลดวง | METHODOLOGY | SOURCE_FACT | เกิดวันที่ 6 มิถุนายน 2525 เวลา 00:35 น. จังหวัดเชียงใหม่ | profile.birth_time_place | fixture.birthDate; fixture.birthTime; fixture.province |
| C25-PROFILE-02 | ข้อมูลดวง | METHODOLOGY | SOURCE_FACT | เพศชาย · วันทางโหราศาสตร์เป็นวันเสาร์ | profile.sex_thai_day | fixture.sex; thai-day.runtime |
| C25-PROFILE-03 | ข้อมูลดวง | METHODOLOGY | SOURCE_FACT | ลัคนาราศีกุมภ์ 19°19′ | profile.ascendant_0035 | ascendant.runtime.00:35 |
| C25-OVERVIEW-01 | ภาพรวมเส้นทางชีวิต | INTENTIONAL_SUMMARY | INTENTIONAL_SUMMARY_TO_DETAIL | วัยเด็กของคุณเป็นช่วงที่ชีวิตต้องเดินตามข้อจำกัดและความพร้อมของครอบครัวอยู่มาก | life.childhood_family_constraints | source.T0003-SRC-0-10-FAMILY-CONSTRAINT |
| C25-OVERVIEW-02 | ภาพรวมเส้นทางชีวิต | INTENTIONAL_SUMMARY | INTENTIONAL_SUMMARY_TO_DETAIL | เมื่อพ้นช่วงนั้น ภาพชีวิตค่อย ๆ เปิดออกในวัย 11–29 ปี ทั้งด้านการเรียนและการเริ่มสร้างทางงานของตัวเอง | life.11_29_improves; life.11_29_learning; life.11_29_career_start | source.T0003-SRC-11-62-RISING-BLOCK; canon.mahabhut.p220.jupiter_owns_learning; canon.mahabhut.p220.jupiter_owns_career |
| C25-OVERVIEW-03 | ภาพรวมเส้นทางชีวิต | INTENTIONAL_SUMMARY | INTENTIONAL_SUMMARY_TO_DETAIL | พอเข้าสู่อายุ 30–41 ปี งานและความรับผิดชอบก็มีน้ำหนักมากขึ้น | life.30_41_work_responsibility | source.T0003-SRC-30-41-PLACEMENT; canon.mahabhut.p39.det_owns_career |
| C25-OVERVIEW-04 | ภาพรวมเส้นทางชีวิต | INTENTIONAL_SUMMARY | INTENTIONAL_SUMMARY_TO_DETAIL | เรื่องสำคัญหลายอย่างในวัยนั้นต้องอาศัยการตัดสินใจของคุณเองมากกว่าเดิม | life.30_41_self_decision | source.T0003-SRC-30-41-PLACEMENT |
| C25-OVERVIEW-05 | ภาพรวมเส้นทางชีวิต | INTENTIONAL_SUMMARY | INTENTIONAL_SUMMARY_TO_DETAIL | ตั้งแต่อายุ 42 ปีถึงปัจจุบัน ภาพรวมชีวิตยังเดินไปในทางที่ดีขึ้น โดยเรื่องที่ต้องลงมือ พูดคุย และตัดสินใจมีอุปสรรคน้อยลง | current.42_62_rising; current.action_speech_decision_flow | source.T0003-SRC-11-62-RISING-BLOCK; source.T0003-SRC-42-62-FLOW |
| C25-OVERVIEW-06 | ภาพรวมเส้นทางชีวิต | INTENTIONAL_SUMMARY | INTENTIONAL_SUMMARY_TO_DETAIL | เมื่อมองชีวิตตอนอายุ 44 ปี งานและการเงินยังเดินหน้า ขณะที่ความสัมพันธ์สำคัญและแรงช่วยเหลือจากคนรอบตัวเป็นอีกสองด้านที่เด่นในช่วงเดียวกัน | current.work; current.finance; current.relationship; current.support | source.T0003-SRC-42-62-WORK; source.T0003-SRC-42-62-FINANCE; source.T0003-SRC-42-62-SUPPORT; typed.current.relationship |
| C25-PAST-0-10-01 | อายุ 0–10 ปี | CORE_PREDICTION | INTERPRETIVE_PARAPHRASE | ช่วงอายุ 0–10 ปี ผู้ปกครองของคุณต้องรับมือปัญหาหลายด้าน ทั้งสุขภาพ การงาน และการเงิน ทำให้การดูแลคุณอาจทำได้ไม่เต็มที่ | life.childhood_guardian_constraints | source.T0003-SRC-0-10-FAMILY-CONSTRAINT; canon.mahabhut.p28.saturn_owns_family |
| C25-PAST-0-10-02 | อายุ 0–10 ปี | CORE_PREDICTION | INTERPRETIVE_PARAPHRASE | ชีวิตในวัยนั้นจึงขึ้นอยู่กับเงื่อนไขและความพร้อมของครอบครัวเป็นหลัก | life.childhood_family_constraints | source.T0003-SRC-0-10-FAMILY-CONSTRAINT |
| C25-PAST-11-29-01 | อายุ 11–29 ปี | CONTEXTUAL_TRANSITION | INTERPRETIVE_PARAPHRASE | เมื่อพ้นวัยเด็ก ช่วงอายุ 11–29 ปีเป็นช่วงที่ชีวิตค่อย ๆ ดีขึ้นและเปิดทางมากกว่าเดิม | life.11_29_improves | source.T0003-SRC-11-62-RISING-BLOCK |
| C25-PAST-11-29-02 | อายุ 11–29 ปี | CORE_PREDICTION | SOURCE_FACT | การเรียนให้ผลดี ขณะเดียวกันคุณก็เริ่มสร้างเส้นทางงานของตัวเอง | life.11_29_learning; life.11_29_career_start | canon.mahabhut.p220.jupiter_owns_learning; canon.mahabhut.p220.jupiter_owns_career |
| C25-PAST-30-41-01 | อายุ 30–41 ปี | CONTEXTUAL_TRANSITION | INTERPRETIVE_PARAPHRASE | ต่อมาในช่วงอายุ 30–41 ปี งานและความรับผิดชอบมีมากขึ้นกว่าช่วงก่อน | life.30_41_work_responsibility | source.T0003-SRC-30-41-PLACEMENT; canon.mahabhut.p39.det_owns_career |
| C25-PAST-30-41-02 | อายุ 30–41 ปี | CORE_PREDICTION | INTERPRETIVE_PARAPHRASE | เรื่องสำคัญหลายอย่างในวัยนี้ต้องอาศัยการตัดสินใจของคุณเองมากขึ้น | life.30_41_self_decision | source.T0003-SRC-30-41-PLACEMENT |
| C25-CURRENT-01 | คำทำนายปัจจุบัน — อายุ 44 ปี | CORE_PREDICTION | INTERPRETIVE_PARAPHRASE | เมื่ออายุ 44 ปี คุณยังอยู่ในช่วงที่ภาพรวมชีวิตเดินไปในทางที่ดีขึ้น เรื่องที่ต้องลงมือเอง การพูดคุยกับคนอื่น และการตัดสินใจสำคัญมีอุปสรรคน้อยกว่าวัยก่อน จึงจัดการเรื่องที่อยู่ตรงหน้าได้ต่อเนื่องมากขึ้น | current.action_speech_decision_flow | source.T0003-SRC-11-62-RISING-BLOCK; source.T0003-SRC-42-62-FLOW |
| C25-WORK-01 | การงาน | CORE_PREDICTION | SOURCE_FACT | งานยังมีเข้ามาอย่างต่อเนื่อง และคุณยังรับผิดชอบงานหลักที่อยู่ในมือได้เต็มที่ | current.work_continuity_and_capacity | source.T0003-SRC-42-62-WORK; typed.current.career |
| C25-WORK-02 | การงาน | LIVED_MEANING | OWNER_EDITORIAL_INTERPRETATION_PENDING / PENDING | จุดเด่นของช่วงนี้จึงอยู่ที่ความต่อเนื่องของงานและการประคองสิ่งที่อยู่ในมือให้เดินต่อ มากกว่าการเปลี่ยนเส้นทางแบบฉับพลัน | current.work_sustainment_not_abrupt_change | C25-WORK-01 |
| C25-FINANCE-01 | การเงิน | CORE_PREDICTION | SOURCE_FACT | เรื่องเงินในช่วงนี้คล่องตัวขึ้น โดยคุณมีเงินใช้และมีโชคลาภเข้ามา | current.finance_liquidity; current.finance_funds_and_luck | source.T0003-SRC-42-62-FINANCE; typed.current.finance |
| C25-FINANCE-02 | การเงิน | LIVED_MEANING | OWNER_EDITORIAL_INTERPRETATION_PENDING / PENDING | ในชีวิตประจำวัน ภาพนี้อาจหมายถึงคุณมีพื้นที่รับมือรายจ่ายจำเป็นได้สบายมือขึ้น แต่ไม่ได้ระบุจำนวนหรือที่มาของเงิน | current.finance_daily_room_and_scope_limit | C25-FINANCE-01 |
| C25-RELATIONSHIP-01 | ความรักและความสัมพันธ์ | CORE_PREDICTION | SOURCE_FACT | ความสัมพันธ์ที่สำคัญของคุณจะแน่นแฟ้นขึ้น | current.relationship_tightening | typed.current.relationship |
| C25-RELATIONSHIP-02 | ความรักและความสัมพันธ์ | LIVED_MEANING | OWNER_EDITORIAL_INTERPRETATION_PENDING / PENDING | ในชีวิตประจำวัน ภาพนี้อาจหมายถึงความสัมพันธ์เหล่านั้นเป็นพื้นที่ที่คุณไว้วางใจได้มากขึ้น โดยไม่ได้ชี้ว่าจะมีคนใหม่หรือเกิดเหตุการณ์ความรักแบบใดโดยเฉพาะ | current.relationship_trust_space_and_scope_limit | C25-RELATIONSHIP-01 |
| C25-HEALTH-01 | สุขภาพ | CORE_PREDICTION | SOURCE_FACT | ภาพรวมร่างกายยังมีกำลังสำหรับกิจกรรมตามปกติ | current.health_capacity | typed.current.health |
| C25-HEALTH-02 | สุขภาพ | CORE_PREDICTION | SOURCE_FACT | อย่างไรก็ตาม เมื่อพักไม่พอ ร่างกายจะฟื้นช้าลงและทำกิจกรรมต่อเนื่องได้น้อยลง | current.health_low_rest_recovery | typed.current.health |
| C25-SUPPORT-01 | โชคลาภและแรงสนับสนุน | CORE_PREDICTION | SOURCE_FACT | ช่วงนี้ คุณจะได้รับแรงช่วยเหลือจากครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่าย | current.support_groups | source.T0003-SRC-42-62-SUPPORT |
| C25-SUPPORT-02 | โชคลาภและแรงสนับสนุน | LIVED_MEANING | OWNER_EDITORIAL_INTERPRETATION_PENDING / PENDING | ในชีวิตประจำวัน แรงหนุนนี้อาจปรากฏเป็นคนที่ช่วยให้มุมมองหรือช่วยประคองเรื่องที่กำลังรับมือ โดยไม่ได้ระบุว่าความช่วยเหลือนั้นจะนำไปสู่ผลลัพธ์ใด | current.support_forms_and_outcome_limit | C25-SUPPORT-01 |
| C25-ROLLING12-01 | คำทำนาย 12 เดือนข้างหน้า | CORE_PREDICTION | SOURCE_FACT | ระหว่างวันที่ 9 กันยายน 2569 ถึง 8 กันยายน 2570 ขอบเขตงานของคุณจะกว้างขึ้น และรายรับจะเพิ่มขึ้นในกรอบเวลาเดียวกัน | rolling12.work_scope_widens; rolling12.income_increases | typed.next12.career; typed.next12.finance; asOf.2026-09-09 |
| C25-ROLLING12-02 | คำทำนาย 12 เดือนข้างหน้า | LIVED_MEANING | OWNER_EDITORIAL_INTERPRETATION_PENDING / PENDING | ในชีวิตประจำวัน ขอบเขตงานที่กว้างขึ้นอาจหมายถึงวงของเรื่องที่ต้องดูแลมากกว่าเดิม โดยไม่จำเป็นต้องตีความว่าเป็นการเปลี่ยนงาน | rolling12.work_scope_daily_meaning | C25-ROLLING12-01 |
| C25-ROLLING12-03 | คำทำนาย 12 เดือนข้างหน้า | DISCLOSURE | METHODOLOGY | ส่วนรายรับ ให้เข้าใจเพียงแนวโน้มว่าจะเพิ่มขึ้นในช่วงดังกล่าว โดยไม่ได้ระบุจำนวน ที่มา หรือผูกว่าการเพิ่มนี้เกิดจากงาน | rolling12.income_scope_and_causality_limit | typed.next12.finance; blocked.no_work_to_income_causality |
| C25-ADVICE-01 | คำแนะนำ | ADVICE | ADVICE | ถ้ามีงานเข้ามาเพิ่ม ควรกำหนดขอบเขตให้ชัดก่อนตอบตกลง และดูยอดเงินคงเหลือหลังรายจ่ายจำเป็นก่อนขยายแผน | advice.work_scope; advice.finance_buffer | C25-WORK-01; C25-FINANCE-01 |
| C25-ADVICE-02 | คำแนะนำ | ADVICE | ADVICE | เรื่องสุขภาพ ควรกันเวลาพักไว้ล่วงหน้าเพื่อให้ร่างกายมีเวลาฟื้นแรง | advice.health_rest | C25-HEALTH-02 |
| C25-LIMIT-01 | ข้อจำกัด | DISCLOSURE | METHODOLOGY | คำทำนายนี้เป็นการตีความตามหลักโหราศาสตร์และความเชื่อ ใช้ประกอบการพิจารณาร่วมกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ | disclosure.belief | report.disclaimer.belief |
| C25-LIMIT-02 | ข้อจำกัด | DISCLOSURE | METHODOLOGY | ข้อความด้านสุขภาพใช้เพื่อการทบทวนทั่วไป ไม่ใช่การวินิจฉัยโรคหรือคำแนะนำทางการแพทย์ | disclosure.health | report.disclaimer.health |
| C25-PSYCH-INTRO-01 | พื้นดวงและมุมมองด้านจิตวิทยา | DISCLOSURE | METHODOLOGY | เนื้อหาต่อไปนี้กล่าวถึงลักษณะพื้นฐานเท่านั้น แยกจากคำทำนายและคำแนะนำ | disclosure.personality_boundary | report.section_boundary.personality |
| C25-PERSONALITY-01 | ลักษณะพื้นฐาน | LIVED_MEANING | INTERPRETIVE_PARAPHRASE | คุณคิดเป็นระบบและทำได้ดีเมื่อรู้ว่าขั้นต่อไปต้องทำอะไร | personality.systematic_thinking | typed.personality |
| C25-PERSONALITY-02 | ลักษณะพื้นฐาน | LIVED_MEANING | INTERPRETIVE_PARAPHRASE | ความอดทนช่วยให้คุณค่อย ๆ สร้างสิ่งต่าง ๆ ให้มั่นคง จึงเป็นคนที่คนอื่นพึ่งพาได้ | personality.patience_and_reliability | typed.personality |
| C25-SOURCE-INTRO-01 | ที่มาและวิธีอ่าน | DISCLOSURE | METHODOLOGY | ข้อมูลและหลักที่ใช้ประกอบรายงาน แยกจากคำทำนาย | disclosure.source_boundary | report.section_boundary.source |
| C25-METHOD-01 | รายงานนี้ดูจากอะไร | METHODOLOGY | METHODOLOGY | ข้อมูลวัน เวลา และสถานที่เกิด | method.profile_inputs | fixture.birthDate; fixture.birthTime; fixture.province |
| C25-METHOD-02 | รายงานนี้ดูจากอะไร | METHODOLOGY | METHODOLOGY | วิธีนับวันทางโหราศาสตร์ไทย | method.thai_day_basis | thai-day.runtime |
| C25-METHOD-03 | รายงานนี้ดูจากอะไร | METHODOLOGY | METHODOLOGY | วันเกิดตามสูติบัตรยังเป็นวันที่ 1982-06-06 ตามเดิม ส่วนการอ่านตามหลักโหราศาสตร์ไทยใช้วันเสาร์ (วันที่ 1982-06-05) เป็นวันทางโหราศาสตร์ | method.civil_date_and_thai_day | thai-day.runtime |
| C25-METHOD-04 | รายงานนี้ดูจากอะไร | METHODOLOGY | METHODOLOGY | เวลาเกิดอยู่ก่อนพระอาทิตย์ขึ้นเวลา 05:46 จึงใช้วันก่อนหน้าตามกฎที่นับวันใหม่เมื่อพระอาทิตย์ขึ้น โดยไม่เปลี่ยนวันเกิดตามสูติบัตร | method.sunrise_day_rule | thai-day.runtime.sunrise |
| C25-METHOD-05 | รายงานนี้ดูจากอะไร | METHODOLOGY | METHODOLOGY | ลัคนา (ภาพบุคลิกตั้งต้นที่คำนวณจากนาฬิกาเกิดและพิกัดจังหวัด) อยู่ที่ราศีกุมภ์ | method.ascendant_definition | ascendant.runtime.00:35 |
| C25-METHOD-06 | รายงานนี้ดูจากอะไร | METHODOLOGY | METHODOLOGY | รายงานเลือกเรื่องที่เกี่ยวกับชีวิตคุณชัดที่สุดขึ้นมาก่อน จากนั้นจึงอธิบายสิ่งที่ควรระวังและใช้ตัดสินใจ | method.report_ordering | report.reader_ordering |
| C25-CHART-01 | โครงสร้างดวงหลัก | METHODOLOGY | SOURCE_FACT | วันทางโหราศาสตร์: วันเสาร์ | chart.thai_day | thai-day.runtime |
| C25-CHART-02 | โครงสร้างดวงหลัก | METHODOLOGY | SOURCE_FACT | ลัคนา: ราศีกุมภ์ 19°19′ | chart.ascendant_0035 | ascendant.runtime.00:35 |
| C25-CHART-03 | โครงสร้างดวงหลัก | METHODOLOGY | SOURCE_FACT | เจ้าเรือนลัคนา: ดาวเสาร์ | chart.ascendant_ruler | chart.runtime.ascendant_ruler |
| C25-CHART-04 | โครงสร้างดวงหลัก | METHODOLOGY | SOURCE_FACT | เรือนการงาน: ราศีพิจิก · เจ้าเรือนดาวอังคาร | chart.work_house | chart.runtime.work_house |
| C25-CHART-05 | โครงสร้างดวงหลัก | METHODOLOGY | SOURCE_FACT | เรือนการเงิน: ราศีมีน · เจ้าเรือนดาวพฤหัสบดี | chart.finance_house | chart.runtime.finance_house |
| C25-CHART-06 | โครงสร้างดวงหลัก | METHODOLOGY | SOURCE_FACT | เรือนความสัมพันธ์: ราศีสิงห์ · เจ้าเรือนดาวอาทิตย์ | chart.relationship_house | chart.runtime.relationship_house |
| C25-CHART-07 | โครงสร้างดวงหลัก | METHODOLOGY | SOURCE_FACT | เรือนสุขภาวะ: ราศีกรกฎ · เจ้าเรือนดาวจันทร์ | chart.health_house | chart.runtime.health_house |
| C25-SOURCE-01 | ที่มาของผลวิเคราะห์ | METHODOLOGY | METHODOLOGY | ใช้วัน เดือน ปีเกิด เวลาเกิด และจังหวัดที่เกิดจากโปรไฟล์ของคุณ | source.profile_inputs | fixture.birthDate; fixture.birthTime; fixture.province |
| C25-SOURCE-02 | ที่มาของผลวิเคราะห์ | METHODOLOGY | METHODOLOGY | นำข้อมูลวันเกิดของคุณมาประมวลผลตามหลักดวงไทย แล้วแปลงเป็นภาษาที่อ่านเข้าใจง่าย โดยไม่แสดงรายละเอียดเชิงเทคนิค | source.processing_and_plain_language | report.methodology |

## Accounting

- Sentence/factual-line entries: **52**
- Distinct meaning-unit identifiers: **55**
- Intentional summary relations: **6** with **11** destination links
- Owner editorial interpretations pending: **5**
- Same-level reader-perceived duplicates: **0**
- Blocked claims / negative-control classes: **6**

Validator PASS checks exact coverage, deterministic semantic ownership and declared boundaries. It is not Owner Content PASS.
