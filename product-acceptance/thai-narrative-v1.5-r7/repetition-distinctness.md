# Repetition and distinctness

R7 ไม่บังคับ cross-profile exact reuse เป็นศูนย์ การใช้ข้อความร่วมกันยอมรับเมื่อ material signature และความหมายเหมือนกันจริงเท่านั้น

gate บังคับตรวจ literal motif/phase frequency, normalized substring ยาวอย่างน้อย 18 อักขระที่เกิดในสาม prose units ขึ้นไป, noun-as-agent, คำซ้ำ, `หาก` ที่ขาดคำเชื่อม, domain leakage และ encoding โดยไม่ตัด motif/phase หรือ consumer prose ออกจากการตรวจ

ผล final:

- motif 2 ครั้งและ phase prose 2 ครั้งในทุก fixture; failures 0
- within-report exact duplicate forecast bodies 0 และ n-gram pairs ≥0.72 เป็นศูนย์
- exact forecast-body conflicts ระหว่าง material signatures ที่ต่างกันเป็น 0
- consumer-unit audit นับ 219 จาก 553 units; พบ broad exact reuse 71/219 (32.4201%, 26 groups)

ตัวเลข broad reuse ไม่ถูกบิดให้เป็นศูนย์ เพราะ R7 ให้ความสำคัญกับภาษาไทยธรรมชาติและความหมายที่ตรงหลักฐานมากกว่าการบังคับความแตกต่างเชิงตัวเลข
