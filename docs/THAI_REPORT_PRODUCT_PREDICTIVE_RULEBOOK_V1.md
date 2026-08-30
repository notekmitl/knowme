# Thai Report Product Predictive Rulebook V1

สถานะ: **OWNER REJECTED AS IMPLEMENTATION RULE SET — HISTORICAL V1 AUDIT BASELINE ONLY**

OR3 พบ timing defect จาก `currentAge + 1` แบบ blanket, unsourced thresholds 64/68/46, fixed 75/80 ที่ไม่ใช่ predictive confidence และ event movements ที่ Canon/engine ไม่รองรับ ห้ามใช้กฎชุดนี้สร้าง runtime หรือ expected output ดู Authority Audit, Population Calibration และ Rulebook V1.1

Owner เลือก Option B Candidate 0004 เป็น content direction เท่านั้น Rulebook นี้เสนอ deterministic product inferences จาก calculation outputs ที่มีจริง ไม่กล่าวอ้างว่าเป็นกฎโหราศาสตร์ดั้งเดิมเมื่อ Canon ไม่มี และไม่ได้สร้าง expected-output baseline

## Global rules

- Event atom ห้ามเกิดจาก score, weighted หรือ band ค่าเดียว
- ทุก product-inference rule ต้องผ่าน `G_PERIOD_TIMING`, `G_ANNUAL_TAKSA`, `G_NATAL_STRUCTURE` และ domain resolver ที่ระบุ
- Score/band/weighted เป็น eligibility family เดียว Canon provenance อย่างเดียวไม่ใช่ calculation rule
- Narrative, motif, advice, Candidate และ final copy ไม่ใช่ evidence
- Output ห้ามเติม actor, event count, amount, exact date หรือ source ที่ calculation ไม่ได้สร้าง
- Current ใช้ annual age `currentAge`; rolling 12 months ใช้ `currentAge + 1` หลัง clamp 1–108 และยังเป็น horizon เดียว
- `monthlyTimelineAvailable=false`; ไม่มี early/middle/late, half-year หรือ month atom
- ทุก product inference ด้านล่างมี approval status `OWNER_RULE_REVIEW_REQUIRED`

Common source paths: `life_period_engine.dart`, `annual_taksa_engine.dart`, `period_intelligence.dart`, `prediction_intelligence_engine.dart`, `prediction_evidence.dart`, `prediction_score.dart`, `prediction_reason.dart`, `house_engine.dart`, `thai_astrology_profile.dart` และ Canon production JSON สำหรับ reference provenance เท่านั้น

Common atom calculations:

```text
atomStrength = min(prediction.strength, selectedDomainMagnitude)
atomConfidence = min(prediction.confidence, 60 + 5 * distinctCalculationGroups)
conflict winner = higher atomConfidence, then higher atomStrength, then lexical ruleId
equal opposing movements = omit both and record conflict trace
missing required field = omit atom and record missing field names
```

## R-P01 — Family duty or constraint

- `ruleId`: `PPR-PAST-FAMILY-DUTY-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `family_duty_or_constraint`
- `horizon`: past, age intersection 1–10
- `required inputs`: Known Thai-day basis, life timeline, birth ruler, lagna lord
- `independent evidence signals`: life-period age intersection; annual Taksa roles; period-to-natal/lagna harmony
- `calculation fields / source paths`: `PeriodState.startAge/endAge/isPast`; `AnnualTaksaYear.roleByPlanet`; `PeriodIntelligence.natalHarmonyScore`
- `exact threshold/range`: period is past and intersects 1–10; `natalHarmonyScore <= 0`; at least 2 years in the intersection have period ruler role บริวาร or กาฬกิณี
- `timing/life-period condition`: evaluate each past period intersection and dedupe to age band 1–10
- `positive conditions`: all thresholds pass
- `negative conditions`: no negative condition beyond failed thresholds
- `exclusion conditions`: Unknown time; no past intersection; missing Taksa year; psychology wording requested
- `conflict resolution`: duty movement owns `past.family.1_10`; no career rule may replace it
- `output movement`: constraint becomes active or family duty increases
- `allowed outcome vocabulary`: ภาระในบ้านเพิ่ม, กฎหรือข้อจำกัดมีน้ำหนัก
- `strength/confidence`: `strength=min(round(100*roleHitYears/intersectionYears), min(100,abs(harmony)*20))`; `confidence=75`
- `Known/Unknown behavior`: Known only; Unknown omits section
- `provenance`: product inference over the three source fields; Canon role references may be attached but are not the rule
- `failure/omit behavior`: omit without reflection question
- `example positive case`: past intersection 1–10, harmony -2, role-hit years 2 of 10 fires one family atom without count language
- `example negative case`: harmony +2 omits even when Taksa role threshold passes

## R-P02 — Education or social transition

- `ruleId`: `PPR-PAST-EDUCATION-SOCIAL-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `education_or_social_transition`
- `horizon`: past, boundary age 11–29
- `required inputs`: Known Thai-day basis, life periods, annual Taksa, previous-period bond
- `independent evidence signals`: exact period boundary; Taksa role at boundary; previous-period relationship
- `calculation fields / source paths`: `PeriodState.startAge/isPast`; `AnnualTaksaYear.roleByPlanet`; `PeriodIntelligence.previousBond.score`
- `exact threshold/range`: `startAge in 11..29`; period is past; `abs(previousBond.score) >= 1`; incoming period ruler role is เดช, อุตสาหะ or มนตรี
- `timing/life-period condition`: event boundary equals `startAge`, output uses the whole age band and never an exact civil date
- `positive conditions`: all thresholds pass
- `negative conditions`: none beyond threshold failure
- `exclusion conditions`: Unknown time; missing previous bond/Taksa; career-only wording
- `conflict resolution`: owns `past.educationSocial.<band>`; career rule needs its own career resolver
- `output movement`: education/social setting changes
- `allowed outcome vocabulary`: เส้นทางการเรียนเปลี่ยน, กลุ่มสังคมหรือเครือข่ายเปลี่ยน
- `strength/confidence`: `strength=min(100,40+20*abs(previousBond.score))`; `confidence=75`
- `Known/Unknown behavior`: Known only; Unknown omits
- `provenance`: product inference; no classical event rule found in Canon
- `failure/omit behavior`: retain period fact only
- `example positive case`: start age 22, previous bond score -2, role มนตรี fires transition without event count
- `example negative case`: role ศรี omits despite the same boundary

## R-P03 — Past domain ending or transition

- `ruleId`: `PPR-PAST-DOMAIN-TRANSITION-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: resolves to `career_ending_or_transfer`, `expense_or_obligation` or `relationship_ending`
- `horizon`: past, boundary age 30–41
- `required inputs`: Known Thai-day basis, life period, annual Taksa, previous bond, period-planet affinity
- `independent evidence signals`: period boundary; annual role; negative previous-period bond; domain affinity resolver
- `calculation fields / source paths`: `PeriodState.startAge/isPast/planet`; `previousBond.score`; `roleByPlanet`; `LifePlanetData.affinity`
- `exact threshold/range`: `startAge in 30..41`; past; `previousBond.score < 0`; role กาฬกิณี, มูละ or อุตสาหะ; domain=`argmax(career,money,love)` with tie order career then money then love
- `timing/life-period condition`: output belongs to the boundary age band, not an exact date
- `positive conditions`: all thresholds and one domain resolve
- `negative conditions`: equal opposing atom with same owner
- `exclusion conditions`: Unknown; missing bond/Taksa; domain outside career/money/love
- `conflict resolution`: emit one domain only; map money to obligation transition, never all three domains
- `output movement`: closing or transition
- `allowed outcome vocabulary`: งานหรือหน้าที่จบ/ส่งต่อ; ภาระเงินเปลี่ยน; ความสัมพันธ์จบ/ถอย ตาม resolved domain
- `strength/confidence`: `strength=min(periodPlanetAffinity(resolvedDomain),min(100,40+20*abs(previousBond.score)))`; `confidence=80`
- `Known/Unknown behavior`: Known only
- `provenance`: product inference; Canon has relations but no event resolver
- `failure/omit behavior`: show life-period transition fact only
- `example positive case`: boundary 34, bond -2, role มูละ, money affinity highest emits finance-domain transition
- `example negative case`: positive previous bond omits

## R-C01 — Career role change

- `ruleId`: `PPR-CAREER-ROLE-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `career_role_change`
- `horizon`: current or next12Months
- `required inputs`: Known time, prediction(career,horizon), current period, natal/lagna harmony, annual Taksa
- `independent evidence signals`: period timing; annual role; natal structure; career affinity
- `calculation fields / source paths`: timing/transition evidence; `roleByPlanet`; `natalHarmonyScore`; career strength/confidence/categoryAffinity
- `exact threshold/range`: timing present; strength ≥68; confidence ≥60; affinity ≥60; harmony ≥0; role เดช, อุตสาหะ or มนตรี
- `timing/life-period condition`: annual age helper for selected horizon; no subwindow
- `positive conditions`: all thresholds pass
- `negative conditions`: career ending rule wins with higher confidence
- `exclusion conditions`: Unknown; missing lagna; unavailable horizon
- `conflict resolution`: opposing role-change/ending uses common conflict rule
- `output movement`: increasing; authority/duty scope increases
- `allowed outcome vocabulary`: หน้าที่เพิ่ม, ขอบเขตงานเปลี่ยน, อำนาจตัดสินใจเพิ่ม
- `strength/confidence`: common formula with affinity; 4 distinct groups
- `Known/Unknown behavior`: Known only V1
- `provenance`: product inference; no classical event mapping claimed
- `failure/omit behavior`: retain career tendency only
- `example positive case`: strength 80, confidence 94, affinity 61, harmony 4, role อุตสาหะ fires
- `example negative case`: same scores with role มูละ omits

## R-C02 — Career opportunity

- `ruleId`: `PPR-CAREER-OPPORTUNITY-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `career_opportunity`
- `horizon`: current or next12Months
- `required inputs`: Known time, career prediction/opportunity, timing, Taksa, natal harmony
- `independent evidence signals`: period timing; annual role; natal structure; career opportunity
- `calculation fields / source paths`: career strength/confidence; opportunity magnitude/domain; harmony; role
- `exact threshold/range`: timing present; strength ≥64; confidence ≥60; career opportunity ≥60; harmony >0; role ศรี, มนตรี or เดช
- `timing/life-period condition`: horizon-level annual age only
- `positive conditions`: all thresholds pass
- `negative conditions`: ending atom with higher confidence
- `exclusion conditions`: Unknown; opportunity domain not career
- `conflict resolution`: common conflict rule; role-change and opportunity may coexist only with distinct owners
- `output movement`: opening; career opportunity opens
- `allowed outcome vocabulary`: โอกาสงานเปิด, ผลงานถูกเห็นชัดขึ้น
- `strength/confidence`: common formula with career opportunity magnitude; 4 groups
- `Known/Unknown behavior`: Known only
- `provenance`: product inference
- `failure/omit behavior`: omit event source
- `example positive case`: strength 93, opportunity 80, harmony 4, role ศรี fires
- `example negative case`: harmony 0 omits

## R-C03 — Career ending or transfer

- `ruleId`: `PPR-CAREER-ENDING-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `career_ending_or_transfer`
- `horizon`: current or next12Months
- `required inputs`: Known time, career risk, timing, Taksa, natal harmony
- `independent evidence signals`: period timing; annual role; natal challenge; career risk
- `calculation fields / source paths`: career risk magnitude; harmony; role; timing evidence
- `exact threshold/range`: timing present; max career risk ≥46; harmony <0; role เดช or อายุ
- `timing/life-period condition`: horizon-level annual age only
- `positive conditions`: all thresholds pass
- `negative conditions`: role-change/opportunity atom wins by common conflict rule
- `exclusion conditions`: Unknown; missing risk
- `conflict resolution`: common conflict rule; unresolved equal opposition omits both
- `output movement`: decreasing; duty scope contracts
- `allowed outcome vocabulary`: ภาระงานลดลง; “จบ” และ “ส่งต่อ” prohibited until a separate movement resolver is approved
- `strength/confidence`: common formula with risk; 4 groups
- `Known/Unknown behavior`: Known only
- `provenance`: product inference
- `failure/omit behavior`: show risk only
- `example positive case`: risk 52, harmony -4, role เดช fires contraction atom
- `example negative case`: role ศรี omits

## R-F01 — Income change

- `ruleId`: `PPR-INCOME-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `income_change`
- `horizon`: current or next12Months
- `required inputs`: Known time, finance prediction/opportunity, timing, Taksa, natal harmony
- `independent evidence signals`: period timing; annual role; natal structure; money opportunity
- `calculation fields / source paths`: finance strength; money opportunity; harmony; role
- `exact threshold/range`: timing present; finance strength ≥64; money opportunity ≥60; harmony ≥0; role ศรี, มูละ or มนตรี
- `timing/life-period condition`: horizon-level only
- `positive conditions`: all thresholds pass
- `negative conditions`: expense atom wins by common conflict rule
- `exclusion conditions`: Unknown; missing money-domain opportunity
- `conflict resolution`: common conflict rule
- `output movement`: income increases; stabilization requires separate movement evidence and is not emitted V1
- `allowed outcome vocabulary`: รายรับขยับขึ้น
- `strength/confidence`: common formula with money opportunity; 4 groups
- `Known/Unknown behavior`: Known only
- `provenance`: product inference
- `failure/omit behavior`: retain finance tendency
- `example positive case`: strength 79, money opportunity 80, harmony 4, role ศรี fires
- `example negative case`: strength 57 omits

## R-F02 — Expense or obligation

- `ruleId`: `PPR-EXPENSE-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `expense_or_obligation`
- `horizon`: current or next12Months
- `required inputs`: Known time, finance risk, timing, Taksa, natal harmony
- `independent evidence signals`: period timing; annual role; natal challenge; finance risk
- `calculation fields / source paths`: finance strength/risk; harmony; role
- `exact threshold/range`: timing present; finance strength ≥48; risk ≥46; harmony ≤0; role เดช or อายุ
- `timing/life-period condition`: horizon-level only
- `positive conditions`: all thresholds pass
- `negative conditions`: income atom with higher confidence
- `exclusion conditions`: Unknown; missing risk
- `conflict resolution`: common conflict rule
- `output movement`: obligation or expense pressure increases
- `allowed outcome vocabulary`: ภาระจ่ายเพิ่ม, ข้อผูกพันทางเงินมีน้ำหนักขึ้น
- `strength/confidence`: common formula with risk; 4 groups
- `Known/Unknown behavior`: Known only
- `provenance`: product inference
- `failure/omit behavior`: omit category, amount and source
- `example positive case`: strength 59, risk 52, harmony -4, role เดช fires
- `example negative case`: harmony +2 omits

## R-R01 — Relationship clarity

- `ruleId`: `PPR-RELATIONSHIP-CLARITY-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `relationship_clarity`
- `horizon`: current or next12Months
- `required inputs`: Known time, relationship prediction/opportunity, timing, Taksa, natal harmony; relationship status optional
- `independent evidence signals`: period timing; annual role; natal structure; love opportunity
- `calculation fields / source paths`: relationship strength; love opportunity; harmony; role
- `exact threshold/range`: timing present; strength ≥64; love opportunity ≥60; harmony ≥0; role ศรี, มนตรี, บริวาร or อุตสาหะ
- `timing/life-period condition`: horizon-level only
- `positive conditions`: all thresholds pass
- `negative conditions`: relationship ending wins by common conflict rule
- `exclusion conditions`: Unknown; missing love opportunity
- `conflict resolution`: common conflict rule
- `output movement`: ambiguity resolves or agreement becomes clear
- `allowed outcome vocabulary`: เรื่องที่ค้างคำตอบชัดขึ้น, ข้อตกลงชัดขึ้น
- `strength/confidence`: common formula with love opportunity; 4 groups
- `Known/Unknown behavior`: Known only; `not_disclosed` copy cannot imply partner
- `provenance`: product inference
- `failure/omit behavior`: omit relationship event
- `example positive case`: strength 100, love opportunity 90, harmony 4, role อุตสาหะ fires
- `example negative case`: strength 55 omits

## R-R02 — Relationship entry

- `ruleId`: `PPR-RELATIONSHIP-ENTRY-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `relationship_entry`
- `horizon`: current or next12Months
- `required inputs`: all `PPR-RELATIONSHIP-CLARITY-001` inputs plus explicit `relationshipStatus=single`
- `independent evidence signals`: period timing; annual role; natal structure; love opportunity; explicit user status
- `calculation fields / source paths`: clarity atom trace; relationshipStatus input contract
- `exact threshold/range`: clarity rule fires and status exactly `single`
- `timing/life-period condition`: same horizon as clarity atom
- `positive conditions`: both conditions pass
- `negative conditions`: relationship ending prohibited for single
- `exclusion conditions`: partnered, married, complicated, not_disclosed, Unknown
- `conflict resolution`: entry owns its event family; clarity may remain as supporting trace but one reader paragraph owns both
- `output movement`: new connection enters
- `allowed outcome vocabulary`: ความสัมพันธ์ใหม่เริ่มเข้ามา; no actor/source
- `strength/confidence`: equal to parent clarity atom, capped at 80
- `Known/Unknown behavior`: Known only and explicit status required
- `provenance`: product inference plus user-provided status
- `failure/omit behavior`: omit; never infer single
- `example positive case`: clarity fires and status single emits entry
- `example negative case`: clarity fires and status not_disclosed omits entry

## R-R03 — Relationship ending

- `ruleId`: `PPR-RELATIONSHIP-ENDING-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `relationship_ending`
- `horizon`: current or next12Months
- `required inputs`: Known time, relationship risk, timing, Taksa, harmony, explicit relationship status
- `independent evidence signals`: period timing; annual role; natal challenge; relationship risk; user status
- `calculation fields / source paths`: relationship risk; harmony; role; status input
- `exact threshold/range`: timing present; risk ≥46; harmony <0; role เดช or อายุ; status partnered/married/complicated
- `timing/life-period condition`: horizon-level only
- `positive conditions`: all thresholds pass
- `negative conditions`: entry prohibited; clarity conflict uses common rule
- `exclusion conditions`: single, not_disclosed, Unknown
- `conflict resolution`: common conflict rule
- `output movement`: connection withdraws or relationship closes; exact cause prohibited
- `allowed outcome vocabulary`: ความสัมพันธ์ถอยออก, ความสัมพันธ์สิ้นสุด
- `strength/confidence`: common formula with risk; 4 groups plus input
- `Known/Unknown behavior`: Known and explicit status only
- `provenance`: product inference plus user status
- `failure/omit behavior`: omit without coaching
- `example positive case`: risk 46, harmony -2, role เดช, status married fires
- `example negative case`: same signals with status not_disclosed omits

## R-H01 — Health load

- `ruleId`: `PPR-HEALTH-LOAD-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `health_load`
- `horizon`: current or next12Months
- `required inputs`: Known time, health risk, timing, Taksa, harmony
- `independent evidence signals`: period timing; annual role; natal challenge; health risk
- `calculation fields / source paths`: health risk; harmony; role; timing evidence
- `exact threshold/range`: timing present; risk ≥46; harmony ≤0; role เดช or อายุ
- `timing/life-period condition`: horizon-level only
- `positive conditions`: all thresholds pass
- `negative conditions`: recovery-easing movement cannot coexist
- `exclusion conditions`: Unknown; medical symptom/diagnosis request
- `conflict resolution`: health load owns load; recovery owns recovery and may coexist only when movements do not oppose
- `output movement`: activity/rest load rises
- `allowed outcome vocabulary`: ภาระต่อการพักเพิ่มขึ้น, ตารางใช้พลังมากขึ้น
- `strength/confidence`: common formula with risk; 4 groups
- `Known/Unknown behavior`: Known only
- `provenance`: product inference; no medical evidence
- `failure/omit behavior`: omit and retain medical disclaimer once
- `example positive case`: risk 52, harmony -4, role อายุ fires
- `example negative case`: harmony +2 omits

## R-H02 — Recovery pressure

- `ruleId`: `PPR-RECOVERY-001`
- `ruleClass`: `OWNER_APPROVED_PRODUCT_INFERENCE`
- `eventFamily`: `recovery_pressure`
- `horizon`: current or next12Months
- `required inputs`: Known time, health strength/risk, timing, Taksa, harmony
- `independent evidence signals`: period timing; annual role; natal challenge; health risk/strength family
- `calculation fields / source paths`: health strength; risk; harmony; role
- `exact threshold/range`: timing present; health strength <68; risk ≥46; harmony <0; role เดช or อายุ
- `timing/life-period condition`: horizon-level only; no half-year movement
- `positive conditions`: all thresholds pass
- `negative conditions`: recovery easing is not implemented because no rule calculates it
- `exclusion conditions`: Unknown; diagnosis/treatment outcome
- `conflict resolution`: common conflict rule
- `output movement`: recovery pressure rises
- `allowed outcome vocabulary`: การคืนแรงใช้เวลามากขึ้น, แรงกดต่อการฟื้นตัวเพิ่มขึ้น
- `strength/confidence`: common formula with risk; 4 groups
- `Known/Unknown behavior`: Known only
- `provenance`: product inference
- `failure/omit behavior`: omit; never claim recovery improves
- `example positive case`: strength 50, risk 52, harmony -4, role เดช fires
- `example negative case`: strength 88 omits

## R-T01 — Life-period transition

- `ruleId`: `PPR-LIFE-PERIOD-TRANSITION-001`
- `ruleClass`: `CLASSICAL_CANON_RULE`
- `eventFamily`: `life_period_transition`
- `horizon`: past/current/nextLifePeriod where boundary is calculated
- `required inputs`: normalized Thai astrological date, age/asOf, life-period ring
- `independent evidence signals`: normalized Thai-day birth basis; exact life-period boundary/ring calculation; Canon planet-strength reference supports the calculation contract
- `calculation fields / source paths`: `LifePeriodEngine`, `PeriodState.startAge/endAge/planet`
- `exact threshold/range`: target boundary exists in the generated 1–108 timeline
- `timing/life-period condition`: output exact inclusive age boundary only
- `positive conditions`: valid normalized Known-time Thai-day basis and period exists
- `negative conditions`: none
- `exclusion conditions`: Unknown V1 because report must not assert Thai day; missing/invalid birth
- `conflict resolution`: calculated boundary fact overrides editorial theme
- `output movement`: period begins or ends
- `allowed outcome vocabulary`: เข้าสู่รอบดาว, สิ้นสุดรอบดาว
- `strength/confidence`: 100/100 for boundary fact; no external event certainty
- `Known/Unknown behavior`: Known only in V1
- `provenance`: engine path plus approved Canon period/strength units; no event consequence inferred
- `failure/omit behavior`: omit boundary
- `example positive case`: calculated Venus 42–62 and Sun 63–68 emits boundary at age 63
- `example negative case`: no normalized Thai-day basis omits

## Rulebook decision boundary

All `OWNER_APPROVED_PRODUCT_INFERENCE` rules are proposals evaluated for robustness, not approved product behavior Owner must accept ontology, thresholds, role sets, vocabulary and safety boundaries before any runtime class or expected-output test is created Candidate 0005 demonstrates the proposed result only
