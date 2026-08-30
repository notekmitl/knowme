# Thai Report Product Predictive Rulebook V1.1

สถานะ: **CALIBRATED REDUCTION — PENDING OWNER APPROVAL — NO EVENT RULE SET — NOT IMPLEMENTATION READY**

V1.1 ถอด product-event rules ทั้ง 13 ข้อเพราะ authority audit ไม่พบ Canon/engine rule ที่รองรับ event movement และไม่มี outcome dataset สำหรับ calibration ค่า 64, 68, 46, fixed 75/80 และ atom-confidence formula ไม่ถูกเก็บไว้ การถอดไม่ใช่การลด threshold และไม่พยายามทำให้ Owner fixture มีข้อความครบ

## Global boundaries

- Retained rules 3: exact life-period fact 1 และ engine-semantic tendency projection 2
- Retained event predictions 0
- `engine confidence` แสดงใน trace ภายในชื่อ `engineProximityStructuralScore` เท่านั้น ไม่แสดงเป็น probability หรือความแม่น
- current/rolling tendency เลือกจาก engine `ranked` ordering ที่มีอยู่ ไม่ตั้ง cutoff ใหม่
- rolling 12 months เป็น horizon รวม หาก future event rule ใช้ Annual Taksa ต้องทำ birthday segmentation ก่อน แต่ V1.1 ไม่มี event atom ดังกล่าว
- `monthlyTimelineAvailable=false`; ไม่มี early/middle/late, half-year, monthly, good/caution month หรือ exact event date
- ทุกข้อยัง `PENDING_OWNER_APPROVAL`; ห้ามสร้าง runtime/expected-output จากเอกสารนี้

## V11-F01 — Exact life-period boundary

- `ruleId`: `PPR11-LIFE-PERIOD-FACT-001`
- `ruleClass`: `CLASSICAL_CANON_RULE`
- `eventFamily`: `life_period_transition` fact only
- `horizon`: current and next life period
- `required inputs`: normalized Known-time Thai astrological date, age/asOf, generated 1–108 timeline
- `independent evidence signals`: normalized Thai-day basis; exact generated period ring/boundary
- `calculation fields / source paths`: `LifePeriodEngine`; `PeriodState.startAge/endAge/planet`
- `exact threshold/range`: target period exists; no score cutoff
- `timing/life-period condition`: report inclusive age boundaries exactly as generated
- `positive conditions`: valid Known birth basis and period exists
- `negative conditions`: none
- `exclusion conditions`: Unknown V1.1; missing/invalid normalized birth
- `conflict resolution`: generated fact overrides editorial theme; no external consequence may attach
- `output movement`: period begins/ends only
- `allowed outcome vocabulary`: อยู่ในรอบดาว X ช่วงอายุ A–B; รอบถัดไปเริ่มอายุ C
- `strength/convergence`: not applicable; exactness flag `boundaryExact=true`
- `Known/Unknown behavior`: Known only; Unknown omits once at report level
- `provenance`: engine path, normalized basis, period index, inclusive boundary
- `failure/omit behavior`: omit without replacement prediction
- `example positive case`: Venus 42–62 and Sun 63–68 emits both boundaries
- `example negative case`: Unknown has no asserted Thai day and emits no period fact

## V11-T01 — Current top-domain tendency

- `ruleId`: `PPR11-CURRENT-TENDENCY-001`
- `ruleClass`: `ENGINE_SEMANTIC_SUPPORTED`
- `eventFamily`: none; tendency only
- `horizon`: current
- `required inputs`: Known time and `PredictionIntelligence.current`
- `independent evidence signals`: engine-composed strength and proximity/structural score; source evidence remains attached but is not recounted
- `calculation fields / source paths`: `PredictionIntelligence.ranked`; `PredictionScore.weighted/strength`; category and evidence trace
- `exact threshold/range`: none; select first ranked category using the engine stable tie order
- `timing/life-period condition`: current prediction window only
- `positive conditions`: current window and at least one category exist
- `negative conditions`: none
- `exclusion conditions`: Unknown; missing prediction window
- `conflict resolution`: emit one top category; runner-up stays trace-only; no event movement inferred
- `output movement`: none
- `allowed outcome vocabulary`: เรื่อง X มีน้ำหนักเด่นในภาพรวมช่วงนี้; ห้ามใช้ เกิดขึ้น/เริ่ม/จบ/เพิ่ม/ลด เป็น event assertion
- `strength/convergence`: retain raw strength and `engineProximityStructuralScore` internally; do not expose as confidence
- `Known/Unknown behavior`: Known only
- `provenance`: prediction category, window, ranked index, raw score components and evidence IDs
- `failure/omit behavior`: omit current tendency
- `example positive case`: relationship ranks first and is described only as the leading domain tendency
- `example negative case`: no window emits no replacement event

## V11-T02 — Rolling 12-month top-domain tendency

- `ruleId`: `PPR11-ROLLING-TENDENCY-001`
- `ruleClass`: `ENGINE_SEMANTIC_SUPPORTED`
- `eventFamily`: none; rolling tendency only
- `horizon`: one rolling 12-month range
- `required inputs`: Known time, exact rolling start/end, `PredictionIntelligence.next12Months`
- `independent evidence signals`: engine prediction window and ranked structured score; no Annual Taksa event rule
- `calculation fields / source paths`: `PredictionIntelligence.ranked` filtered to next12Months; exact civil date range
- `exact threshold/range`: none; stable first-ranked category
- `timing/life-period condition`: whole rolling horizon only; birthday segments retained in design trace but cannot produce subwindow copy without an approved atom rule
- `positive conditions`: next12 window exists
- `negative conditions`: if meaning equals the current tendency, do not repeat it as a second paragraph
- `exclusion conditions`: Unknown; missing window
- `conflict resolution`: dedupe against `PPR11-CURRENT-TENDENCY-001`; omit repeated meaning rather than manufacture specificity
- `output movement`: none
- `allowed outcome vocabulary`: ภาพรวม 12 เดือนให้น้ำหนักกับ X; no event or subwindow vocabulary
- `strength/convergence`: raw engine fields internal only; no confidence claim
- `Known/Unknown behavior`: Known only
- `provenance`: exact date range, category/window/rank/evidence IDs; segmentation trace A/B
- `failure/omit behavior`: omit or state one concise evidence limitation; never create empty subheadings
- `example positive case`: rolling top domain differs from current and receives one tendency sentence
- `example negative case`: same top domain as current is omitted to prevent reader-visible repetition

## Removed V1 rules

`PPR-PAST-FAMILY-DUTY-001`, `PPR-PAST-EDUCATION-SOCIAL-001`, `PPR-PAST-DOMAIN-TRANSITION-001`, all career/income/expense/relationship/health/recovery event rules are absent from V1.1 Their V1 data remains in the authority and population audit only

Result: retained fields complete 3/3; unsourced retained thresholds 0; arbitrary fixed confidence 0; unsupported event claims 0; event rules ready for implementation 0
