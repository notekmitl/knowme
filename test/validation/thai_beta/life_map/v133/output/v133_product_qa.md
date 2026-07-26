# Thai Life Map V1.3.3 — Product QA Artifact

Synthetic fixtures only (no PII).

Production-equivalent Life Map: weekday=7 (Sunday) age=39 seed=17

## V1.3.2 residual product failures (must be fixed)

1. Hero still personality-only
2. Past shared sentence skeletons
3. Current internal semantic headings overload

## A. Opening card — ดวงไทยของคุณ

### After (V1.3.3)

- badge: `ดวงไทยของคุณ`
- headline: พื้นฐานจากดวงไทยคู่กับจังหวะช่วงเรียนรู้และเชื่อมโยงที่เน้นการเรียนรู้
- subtitle: จากดวงไทยตามวันเกิดของคุณ
- tags: อยากรู้ / รู้สึกลึก / มุ่งมั่น
- summary:

เบื้องหลังนั้น คุณยังต้องการโครงสร้างที่ชัดก่อนจะลงมือจริง

เส้นทางชีวิตเดินเป็นช่วงตามดาวเสวยอายุ — อิทธิพลหลักตอนนี้คือพลังธาตุดิน ที่ส่งเสริมพื้นฐานในตัวคุณ คุณจึงได้เป็นตัวเองมากขึ้น

ช่วงชีวิตตอนนี้อยู่ในช่วงเรียนรู้และเชื่อมโยง และเรื่องสำคัญหมุนรอบการเรียนรู้

จุดที่ควรใส่ใจในช่วงนี้คือเป็นช่วงยาวที่ค่อย ๆ วางโครงให้ชีวิตของคุณไปอีกหลายปี

- signatureInsight empty: true
- incomplete subtitle: ไม่มีเวลาเกิด — วิเคราะห์ได้เฉพาะภาพรวมจากวันเกิด ไม่ใช่ภาพละเอียดเต็มรูปแบบ

### Product checks

- personality-only: false
- has janghwa/life dimension: true
- separate core card absent: true
- complete-data banner absent: true

## B. Past — 8-period board (age 39 past subset + full board notes)

### PAST — อิทธิพลดาวอาทิตย์ • การยอมรับ (1–6)

theme/keyword: การยอมรับ

คุณถูกผลักให้เลือกทางของตัวเองท่ามกลางคนรอบตัว สิ่งที่ถนัดกับสิ่งที่คนรอบตัวคาดหวังไม่ตรงกัน

คนอื่นเห็นคุณชัดขึ้น และหน้าที่ของคุณเปลี่ยนตาม คุณเริ่มกล้าเลือกทางของตัวเองมากขึ้นแม้คนรอบตัวจะมองต่าง

คุณต้องเลือกทางที่ถนัดท่ามกลางความคาดหวังของคนรอบตัว

- soft opener ในช่วงนั้น: false
- vague relationship: false

### PAST — อิทธิพลดาวจันทร์ • ความรู้สึก (7–21)

theme/keyword: ความรู้สึก

ทางเลือกเยอะจนเลือกลำดับความสำคัญได้ยาก ร่างกายและใจถูกใช้จนสุดแรง

ความใกล้ชิดถูกทดสอบเรื่องความจริงใจและการอยู่ร่วม คุณต้องจัดชีวิตให้พักได้โดยไม่เสียสุขภาพ

คุณเริ่มรู้ว่าต้องรักษาแรงไว้ ไม่ใช่ผลักทุกเรื่องพร้อมกัน

- soft opener ในช่วงนั้น: false
- vague relationship: false

### PAST — อิทธิพลดาวอังคาร • การลงมือ (22–29)

theme/keyword: การลงมือ

จากจังหวะก่อนหน้าที่ส่งต่อมา คุณยังทำงานในแบบที่คุ้นเคยและรู้ว่าต้องทำอะไรต่อไป คุณอยากใกล้ชิด แต่ก็ยังต้องการพื้นที่ส่วนตัว

งานที่เคยทำแบบเดิมเริ่มเปลี่ยนไป คุณเริ่มมองหน้าที่และความรับผิดชอบต่างจากเดิม

คุณมองอนาคตต่างจากเดิม

- soft opener ในช่วงนั้น: false
- vague relationship: false

### CURRENT — อิทธิพลดาวพุธ • การเรียนรู้ (30–46)

theme/keyword: การเรียนรู้

#### Domains shown

**การดำเนินชีวิต**

จากช่วงลงมือและบุกเบิกสู่ช่วงเรียนรู้และเชื่อมโยง โฟกัสย้ายจากการลงมือไปการเรียนรู้

- evidenceKeys: domain:transitionRebuild, role:transition

**การงาน**

ตอนนี้มีทางเลือกมากขึ้น แต่ทุกทางแลกด้วยหน้าที่ที่เพิ่มขึ้น คุณเลือกทางที่ถนัดชัดขึ้น

- evidenceKeys: domain:opportunityExpand, role:situation, domain:opportunityExpand, role:consequence

**สุขภาพ**

คุณฝืนตัวเองจนสะสมความล้า

- evidenceKeys: domain:healthEnergy, role:pressure

#### Domains omitted (no sufficient evidence / filtered)

- ความรัก

#### Legacy semantic headings (must be absent from UI hierarchy)

- วิถีทาง / เรื่องสำคัญของช่วงนี้ / สรุปช่วงนี้ / สิ่งที่ทำให้ลำบาก / ผลต่อชีวิตในช่วงนี้ / ความเปลี่ยนแปลงจากช่วงก่อน
- shown domain count: 3

### FUTURE — อิทธิพลดาวเสาร์ • ความมั่นคง (47–56)

theme/keyword: ความมั่นคง

summary: ต่อไปงานที่เคยทำแบบเดิมเริ่มเปลี่ยนไป
harder: คุณอยากใกล้ชิด แต่ก็ยังต้องการพื้นที่ส่วนตัว
advice: คุณต้องจัดลำดับชีวิตใหม่และหยุดบางอย่างที่ถ่วงไว้
lifeDomains empty: true

### FUTURE — อิทธิพลดาวพฤหัสบดี • การเติบโต (57–75)

theme/keyword: การเติบโต

summary: ต่อไปมีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก
harder: คุณอยากใกล้ชิด แต่ก็ยังต้องการพื้นที่ส่วนตัว
advice: คุณออกจากวิธีเดิมและตัดสินใจด้วยตัวเองมากขึ้น
lifeDomains empty: true

### FUTURE — อิทธิพลดาวราหู • การเปลี่ยนแปลง (76–87)

theme/keyword: การเปลี่ยนแปลง

summary: ต่อไปชีวิตที่เคยคุ้นเคยเปลี่ยน และคุณต้องแยกจากวิธีเดิม
harder: คุณคาดหวังเงียบ ๆ โดยไม่คุยจนเกิดระยะห่าง
advice: คุณต้องจัดลำดับชีวิตใหม่และหยุดบางอย่างที่ถ่วงไว้
lifeDomains empty: true

### FUTURE — อิทธิพลดาวศุกร์ • ความสุขและความสัมพันธ์ (88–108)

theme/keyword: ความสุขและความสัมพันธ์

summary: ต่อไปคุณต้องเลือกว่าจะให้เวลากับงานหรือกับคนใกล้ตัวก่อน
harder: คุณฝืนตัวเองจนสะสมความล้า
advice: คุณต้องบอกคนใกล้ตัวว่าเรื่องใดรับได้ และเรื่องใดยังรับไม่ได้
lifeDomains empty: true

### Past opener diversity

- openers: คุณถูกผลักให้เลื | ทางเลือกเยอะจนเล | จากจังหวะก่อนหน้
- unique openers: 3

## C. Final Product Language Gate

- hero holistic: PASS
- past opener variety: PASS
- current domain hierarchy: PASS
- future unchanged slots: PASS
- owner interactive Production visual: PENDING

