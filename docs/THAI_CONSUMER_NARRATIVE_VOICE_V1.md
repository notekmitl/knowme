# Thai Consumer Narrative Voice V1

## Status — Reading Flow and Friendly Voice amendment

Status: `PENDING PRODUCT ACCEPTANCE` on branch `agent/thai-report-reading-flow-v1`, based on `c34a1c088b555160707577308c281570b570752a`. Round 9 remains the completed historical Production release and is not rewritten by this amendment.

## Reader-facing order

1. ดวงจากวันเกิดของคุณ
2. สรุปตัวคุณแบบตรง ๆ
3. จุดเด่น จุดที่ควรระวัง และคำแนะนำหลัก
4. การงาน
5. การเงิน
6. ความรักและความสัมพันธ์
7. สุขภาพและพลังชีวิต
8. คำชี้หลักจากพื้นดวง
9. แผนที่ชีวิต
10. อดีตของคุณ
11. ช่วงปัจจุบัน
12. แนวโน้ม 12 เดือนข้างหน้า
13. ช่วงชีวิตถัดไป
14. แนวโน้มระยะยาว
15. รายงานนี้ดูจากอะไร — collapsed by default on Web
16. Disclaimer, explicit omissions, and limitations

## Voice rules

Reader-facing Thai speaks directly to `คุณ`, uses short familiar sentences, states practical meaning before technical reason, and keeps soft certainty. Avoid academic labels, mystical certainty, threats, daily-horoscope tone, and formulaic horizon/domain repetition. Natural labels such as `เรื่องนี้มีผลกับคุณอย่างไร`, `สิ่งที่ควรระวัง`, and `สิ่งที่ทำได้ตอนนี้` may present the same typed fields without changing their semantics.

## Preserved contracts

- Web and PDF consume the same `ThaiBetaAnalysis` and shared presentation state.
- Forecast Claim, Risk, Decision Impact, Action, and uncertainty remain separately typed; copy is never parsed to infer intent.
- Known-time astrological facts, exact birth inputs, day boundary, ascendant, houses, timeline ranges, and factual provenance do not change.
- Unknown time remains fail-closed: no assumed clock, Lagna, house, or astrological-day conclusion.
- Work, money, relationship, health, and fortune remain separate semantic owners.
- No internal Canon/ontology IDs, debug markers, QA labels, or source prose appear in the consumer report.

## Transparency

`หลักการนับวันทางโหราศาสตร์ไทย` and `โครงสร้างดวงหลัก` are no longer opening sections. Their facts remain available near the end under progressive disclosure together with submitted birth data, calculation method, important chart points, provenance, meaning, and limitations.

The task is not release-complete and has no merge, deployment, or readiness claim until Owner Product Acceptance passes.
