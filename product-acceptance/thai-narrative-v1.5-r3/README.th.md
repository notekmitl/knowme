# ชุดตรวจรับ Thai Narrative V1.5 R3

สถานะ: `V1.5 R3 READY FOR OWNER ACCEPTANCE` บน Draft PR #92 เท่านั้น ยังไม่ผ่าน Owner Acceptance ห้าม merge/deploy และ Production ยังคง V1.4

`V1.5 R2 OWNER ACCEPTANCE REJECTED` เพราะ R2 แม้คืน 4 domains × 3 horizons ได้ครบ แต่ strong claims ซ้ำ 60/84 instances (71.43%) และเมื่อตัด regression 00:03 ยังซ้ำ 36/66 (54.55%) พร้อมภาษาระบบ, raw-test evidence ที่ไม่ใช่ raw output, checksum BOM และ page-count statement ที่ผิด

R3 ย้ายการวางเรื่องขึ้นเป็น report-level plan: เปิดด้วย “ลายเซ็นของคำอ่าน”, เลือก primary motifs ไม่เกินสองเรื่อง, แยกหน้าที่ปัจจุบัน/12 เดือน/ช่วงถัดไป และเปลี่ยนอดีตเป็น cautious synthesis ที่ให้ผู้อ่านเทียบกับความทรงจำจริง

PDF สำหรับ owner คือ `evidence/owner-known-0035-report.pdf` และ `evidence/owner-unknown-report.pdf` (6 หน้าทั้งคู่) ส่วน `regression-known-0003-report.pdf` ยืนยัน 00:03 เท่านั้น เอกสาร comparison กรุงเทพฯ/ขอนแก่นใช้ตรวจ freshness ข้าม fixture

ผลอัตโนมัติสำคัญ: 4×3 ครบทุก fixture, exact duplicate ภายในรายงาน 0, callback without new information 0, system-language hit 0, unsupported biography hit 0, strong-claim exact reuse ใน materially different fixtures 0/26 (0.00%, gate ≤25%), Web/PDF canonical parity 5/5 และไม่มี blanket evidence-signature exemption

หลักฐานอยู่ใน `evidence/`; render รายหน้าจริง 30 PNG และ contact sheets 5 ภาพอยู่ใน `renders/`. `SHA256SUMS.txt` เป็น UTF-8 ไม่มี BOM และตรวจทุกรายการด้วย `sha256sum -c` โดยไม่มี warning
