# Repetition and distinctness

ตัวตรวจ R5 ใช้ Unicode character trigram Dice similarity โดยไม่พึ่ง whitespace/tokenization ภาษาไทย แยก `past-theme` และ `past-question`, ตัด prefix มาตรฐาน และ normalize อายุ ชื่อช่วง และชื่อธีมก่อนคำนวณ พร้อมตรวจ repeated skeleton

Threshold ภายในรายงานคือ `< 0.78`.

| Fixture | Theme max | Question max | Flagged pairs | Repeated skeletons |
|---|---:|---:|---:|---:|
| owner-known-0035 | 0.2544 | 0.2393 | 0 | 0 |
| owner-unknown | 0.2244 | 0.2581 | 0 | 0 |
| regression-known-0003 | 0.2544 | 0.2393 | 0 | 0 |
| comparison-known-bangkok | 0.1135 | 0.2393 | 0 | 0 |
| comparison-known-khon-kaen | 0.2925 | 0.2393 | 0 | 0 |

R4 Known/Unknown theme และ question template pairs ถูกใช้เป็น negative fixtures; gate ใหม่ flag ได้ทุกคู่ที่ทดสอบ

Freshness source เดียว:

| Version | Total units | Counted | Excluded | Reused | Groups | Rate |
|---|---:|---:|---:|---:|---:|---:|
| R4 immutable text replayed with corrected classifier | 554 | 222 | 332 | 62 | 23 | 27.93% |
| R5 | 554 | 216 | 338 | 57 | 22 | 26.39% |

R4→R5 ลด 1.54 percentage points หรือ 5.51% relative. ตัวเลขนี้มาจาก counted units โดยตรง; ไม่มีการสุ่ม paraphrase core interpretations ที่ใช้ evidence เดียวกัน
