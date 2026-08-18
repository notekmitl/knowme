# Annual infographic data provenance

Infographic อ่านจาก `ThaiBetaAnnualInfographicData` ซึ่งสร้างจาก next-12-month prediction window ใน shared presentation model เท่านั้น

| Field | Source / rule |
|---|---|
| ปี พ.ศ. | `analysis.asOf.year + 543`; `asOf` ถูกตรึงเป็น Bangkok civil date ใน fixture |
| ธีม/ภาพรวม | annual window summary และ timeframe label |
| การงาน/การเงิน/ความรัก/สุขภาพ | decision impact ของ domain เดิม พร้อม material/evidence trace IDs |
| โอกาสดี | `topOpportunity` หรือ evidence-backed domain ที่มี band สูงสุด |
| ควรระวัง | `topRisk` หรือ risk/caution ของ evidence-backed domain |
| คำแนะนำ | detailed closing advice หรือ closing advice เดิม |
| Unknown | ใช้เฉพาะ field ที่ engine รองรับ; disclaimer ระบุว่าไม่มีเวลาเกิด |
| Timeline เดือน | ไม่แสดง เพราะไม่มี validated month evidence |

PNG Known/Unknown สร้างจาก widget/model เดียวกับ Web แล้วส่ง byte เดียวกันเข้า dedicated PDF และ browser-print HTML ขนาด 1080×1920, 9:16, Noto Sans Thai/Noto Sans, vector glyphs, ไม่มี emoji และไม่มีวันเกิด เวลาเกิด หรือสถานที่เกิด

VM/Chrome manifest ตรงกันแบบ byte-for-byte 134,732 bytes; SHA-256 `E961E1DEE62B3A16FE6DD0245D1EFE8376E93F294F65590A65D900EDDF8C2780`.
