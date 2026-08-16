# Repetition and distinctness

R6 แยก consumer narrative เป็น sentence และ clause แล้ว normalize whitespace, punctuation, phase, horizon, domain และ variable slots. Clause ที่ยาวอย่างน้อย 18 อักขระถูกตรวจ exact, prefix, suffix, skeleton และ Unicode similarity; threshold near-duplicate คือ `< 0.78`.

- R5 negative fixtures 3/3 ถูกตรวจพบ
- R6 counted consumer units: 222
- Exact reused instances: 0; groups: 0; rate: 0.00%
- Cross-profile exact reused sentences: 0
- Clause/suffix/skeleton/near-duplicate flagged pairs: 0 ในทุก fixture
- Callbacks without new information: 0
- Consumer-prose blanket exemptions: 0

Past similarity สูงสุดยังต่ำกว่า threshold: Owner Known theme 0.2983 / question 0.2395; Owner Unknown theme 0.4064 / question 0.2924; flagged pairs 0.

Keyword frequency ถูกบันทึกแม้ไม่ทำให้ gate fail:

| Fixture | ภาระ | ช่วงถัดไป | งานหลัก | ข้อตกลง | ต้อง | ควร |
|---|---:|---:|---:|---:|---:|---:|
| owner-known-0035 | 4 | 2 | 2 | 6 | 25 | 11 |
| owner-unknown | 3 | 1 | 1 | 2 | 19 | 10 |

Freshness ใช้ `evidence/consumer-unit-audit.json` เป็น source-of-truth เดียว. Static headings, methodology, medical disclosure และ evidence disclosure แยกได้ตามประเภท แต่ consumer narrative ไม่ถูก exclude เพื่อทำให้ผลผ่าน.
