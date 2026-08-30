# Thai Report Predictive Narrative V2 — Evidence Support Matrix

## OR3 final rule-validity gate (2026-08-30)

Owner retains Option B and accepts the Event Ontology/Evidence Architecture for further design, but rejects Rulebook V1 and Candidate 0005 Known/Unknown as implementation, content, or expected-output targets. V1 has a blanket `currentAge+1` rolling-timing defect, unsourced 64/68/46 thresholds, arbitrary fixed 75/80 confidence labels, and event movements without sufficient Canon/engine authority.

The corrected rolling design splits at the actual birthday and passed boundary/coverage checks 300/300. Population calibration used the repository 300-case matrix: Known 225, Unknown 75, all eight supported start planets, opening/peak/closing, all harmony directions, and all five relationship-status design values. It measures selectivity only; semantic validity is not established and predictive accuracy cannot be measured without historical outcomes.

Rulebook V1.1 retains one exact life-period fact rule and two engine-semantic tendency projections, with product event rules 0, unsourced retained thresholds 0, arbitrary fixed confidence 0, and unsupported event claims 0. Candidate 0006 Known therefore has exact facts 2, tendencies 1, event predictions 0, visible duplicates 0 and Golden supported-content coverage 2/4. Unknown is a short reduced report with one limitation, empty predictive headings 0 and duplicate hits 0.

Final decision: **NO-GO — DOMAIN AUTHORITY OR CALIBRATION BLOCKER RECORDED**. Runtime implementation and expected-output creation remain blocked pending an expert-authored/approved event mapping or a validated outcome dataset. `monthlyTimelineAvailable=false`; G05/G10 remain blocked; no application, engine, UI, generator, report, infographic, PDF/export, Firebase/Production or `product-acceptance/` change is authorized.


ฐานตรวจ: `d857308eb8635899e468dab5e22a3a53f87fced1` · Fixture `1982-06-06 00:03 Chiang Mai` · `asOf = 2026-08-29 Asia/Bangkok`

OR1 disposition: Golden เป็น style target; Candidate 0003 ถูก Owner ปฏิเสธเป็น implementation/expected-output/acceptance target ตารางเดิมด้านล่างบันทึก current support ส่วนตาราง OR1 architecture extension บันทึก atom ที่ต้องมีและ Owner decision โดยไม่สร้าง evidence จาก Golden

OR2 disposition: Owner selected Option B Candidate 0004 is content direction only Product Rulebook V1 proposes event rules labeled `OWNER_APPROVED_PRODUCT_INFERENCE`; none is approved or runtime-authorized Candidate 0005 is pending Owner rule/content review

## ผลรวม

| Decision | Paragraphs |
|---|---:|
| `SUPPORTED` | 1 |
| `SUPPORTED_WITH_REWRITE` | 18 |
| `REQUIRES_NEW_EVIDENCE` | 18 |
| `MUST_NOT_IMPLEMENT` | 2 |
| รวม | 39 |

คำว่า source ด้านล่างหมายถึง class, field, evidence key หรือ source path ที่มีอยู่จริง หากระบบไม่มี atom รองรับ จะระบุว่าไม่มีแทนการสร้าง trace ID ใหม่

## Matrix ระดับย่อหน้า

| ID | Golden paragraph identity | Horizon / domain | Role / certainty | Engine fact, atom และ traceable source | Current support / new evidence / editorial inference | Decision |
|---|---|---|---|---|---|---|
| G00 | Birth input, Saturday Thai day, Aquarius 9°24′ | Input / chart | Fact / exact | `ThaiBetaInput` → `BirthNormalizer` → `ThaiEngineAdapter` → `ThaiMirrorPipeline`; regression `thai_beta_input_fixture_separation_test.dart` | yes / no / no | `SUPPORTED` |
| G01 | Life is non-linear; early responsibility; repeated midlife changes; harvest after 42 | Whole life / overview | Prediction / direct | Life-period sequence supports Saturn 1–10, Jupiter 11–29, Rahu 30–41, Venus 42–62; no event or early-responsibility atom | partial / no for period sequence, yes for events / yes | `SUPPORTED_WITH_REWRITE` |
| G02 | From 42, move from struggle to valuable stable choices; work leads | Current / cross-domain | Prediction / direct | Current Venus 42–62; `ThaiBetaReportNarrativePlan.primary=career`; current materials have career strong, finance strong, relationship strong, health strong | partial / no / yes | `SUPPORTED_WITH_REWRITE` |
| G03 | Ages 44–46 are a major reordering point; work expands and is cut | Current subrange / career | Prediction / exact age bucket | Current age 44 is known, but no 44–46 calculation window or cut-event atom exists | no / yes: age-bucket timing and event evidence / yes | `REQUIRES_NEW_EVIDENCE` |
| G04 | Childhood rules, adult expectations, early responsibility, emotional endurance | Past 1–10 / family | Prediction / direct | Life period only provides Saturn, stability, age 1–10; `ThaiBetaPastReflection` intentionally produces reflection copy, not historical events | no / yes: past-event evidence / yes | `REQUIRES_NEW_EVIDENCE` |
| G05 | Childhood created survival and self-reliance personality | Past 1–10 / psychology | Personality conclusion / direct | No engine event atom; statement belongs to psychological interpretation and violates the requested report boundary | no / no / yes | `MUST_NOT_IMPLEMENT` |
| G06 | Ages 11–29 changed school, work, circle or society at least once | Past 11–29 / cross-domain | Prediction / event claim | Jupiter growth and age range exist; no event count, setting, or social-change atom | no / yes: past-event evidence / yes | `REQUIRES_NEW_EVIDENCE` |
| G07 | Late in 11–29 assumed work, money and relationship responsibility and separated from expectations | Past 11–29 / cross-domain | Prediction / event claim | No late-period subdivision or decision-event atom | no / yes: subperiod and domain-event evidence / yes | `REQUIRES_NEW_EVIDENCE` |
| G08 | Ages 30–41 were among the strongest changes across work, role, relationship or money | Past 30–41 / cross-domain | Prediction / event claim | Rahu and change theme exist; magnitude and affected-domain events do not | no / yes: past-event magnitude and domain evidence / yes | `REQUIRES_NEW_EVIDENCE` |
| G09 | At least one event forced a stability-versus-new-path choice and ended or reshaped something | Past 30–41 / cross-domain | Prediction / counted event | No event-count or outcome atom exists | no / yes: event and outcome evidence / yes | `REQUIRES_NEW_EVIDENCE` |
| G10 | Late in 30–41 learned suitable work, people and burdens | Past 30–41 / psychology | Personality and self-knowledge conclusion / direct | No engine atom; conclusion shifts astrological report into personality analysis | no / no / yes | `MUST_NOT_IMPLEMENT` |
| G11 | Current Venus 42–62; shift from proving through hard work to valuable choices | Current / overview | Prediction / direct | Exact phase and planet are supported by life-period output; forecast planning supports work as primary and boundaries in other domains | partial / no / yes | `SUPPORTED_WITH_REWRITE` |
| G12 | Age 44 brings old and new; right things return fame, money and satisfaction | Current / cross-domain | Prediction / event and outcome | No old-versus-new object atom, fame atom, or combined return atom | no / yes: event source and outcome evidence / yes | `REQUIRES_NEW_EVIDENCE` |
| G13 | Work is strongest; larger role and responsibility; more key decisions | Current / career | Prediction / direct | `prediction.career.current.strong`; claim `บทบาทงานก้อนใหม่มีแรงส่ง`; source ownership `lagna-house-and-life-period-score` | partial / no / yes | `SUPPORTED_WITH_REWRITE` |
| G14 | Experience, management, systems and quality outperform labor; others seek decisions | Current / career | Prediction / specific mechanism | Quality and experienced-work motifs exist across current and next-life claims; requests from others and comparative performance do not | no as written / yes: event and comparative outcome / yes | `REQUIRES_NEW_EVIDENCE` |
| G15 | Burdens without decision authority become problems and leave life | Current / career | Prediction / outcome | `prediction.career.next12Months.strong` supports wider duty plus unchanged authority harming quality; forced removal is unsupported | partial / no for risk, yes for removal / yes | `SUPPORTED_WITH_REWRITE` |
| G16 | Income follows work, not luck; new money from old skills, clients, work or contacts | Current / finance and luck | Prediction / source claim | `prediction.finance.current.strong` supports available money and reserve; current life-map output separates work income from random luck; named old sources are absent | partial / yes for named sources / yes | `SUPPORTED_WITH_REWRITE` |
| G17 | Major expense for business, home, family or quality of life; money churns quickly | Current / finance | Prediction / event claim | Finance risk says obligations can reduce decision space; no expense category, amount, or churn atom | no / yes: expense event and category / yes | `REQUIRES_NEW_EVIDENCE` |
| G18 | Finances stabilize after stopping unproductive obligations | Current / finance | Prediction / causal outcome | Finance material supports protecting ready cash and delaying unsupported obligations; exact cause and end-state need softer wording | partial / no / yes | `SUPPORTED_WITH_REWRITE` |
| G19 | Ambiguous relationships become clear; inconsistent people leave; ready people plan | Current / relationship | Prediction / outcome | `prediction.relationship.current.strong` supports clarity from agreements and consistent actions; leaving and future-planning events are absent | partial / yes for event outcomes / yes | `SUPPORTED_WITH_REWRITE` |
| G20 | Paired readers reorganize duties and space and discuss avoided issues | Current / relationship | Prediction / conditional | Current and next-life relationship claims support clarity of time, duties and space; partner status and avoided-topic event are not inputs | partial / yes for status-specific event / yes | `SUPPORTED_WITH_REWRITE` |
| G21 | Single readers meet someone through work, business, society or referral | Current / relationship | Prediction / conditional event | No relationship-status input and no meeting-source evidence | no / yes: status input plus encounter evidence / yes | `REQUIRES_NEW_EVIDENCE` |
| G22 | Main health pressure is insufficient rest and accumulated stress shown by fatigue, sleep and longer recovery | Current / health | Prediction / direct | `prediction.health.current.strong`; claim and risk support recovery time and insufficient rest, but not diagnosis or a single main medical cause | partial / no / yes | `SUPPORTED_WITH_REWRITE` |
| G23 | Expanding work without rest accumulates fatigue | Current / health and career | Prediction / causal risk | Career pressure and health recovery materials support workload-versus-recovery boundary | partial / no / yes | `SUPPORTED_WITH_REWRITE` |
| G24 | Luck comes from work, old contacts and prior work, not gambling | Current / luck | Prediction / source claim | Current life-map says income comes from work and ability rather than chance; old contacts and clients are absent | partial / yes for named sources / yes | `SUPPORTED_WITH_REWRITE` |
| G25 | Important opportunity arrives as collaboration, returning work or a role based on competence | Current / career and luck | Prediction / event claim | No invitation, returning-work, or referral event atom | no / yes: opportunity event source / yes | `REQUIRES_NEW_EVIDENCE` |
| G26 | In the 12-month date range, work leads and money and relationship follow the new role | Next 12 months / cross-domain | Prediction / direct | Rolling dates are exact; career is primary and all four known-time bands are strong; strict causal dependency is not encoded | partial / no / yes | `SUPPORTED_WITH_REWRITE` |
| G27 | Early round has old and new work collision, urgency or an offer | Next 12 months early / career | Prediction / timed event | `monthlyTimelineAvailable=false`; no early bucket, offer, collision, or urgency atom | no / yes: within-year timing and event evidence / yes | `REQUIRES_NEW_EVIDENCE` |
| G28 | Early round transfers others' problems and changes status from helper to main decision maker | Next 12 months early / career | Prediction / timed role event | No early bucket or transferred-problem/status-transition atom | no / yes: within-year timing and role event / yes | `REQUIRES_NEW_EVIDENCE` |
| G29 | Middle round turns work into income and brings continuing expense or investment | Next 12 months middle / finance | Prediction / timed event | Annual finance strong material exists, but no middle bucket, money-event, expense or investment atom | no / yes: within-year timing and finance event / yes | `REQUIRES_NEW_EVIDENCE` |
| G30 | Middle round decides relationship status and separates stable from uncertain ties | Next 12 months middle / relationship | Prediction / timed outcome | Annual relationship strong material supports repeated agreements; no middle bucket or status outcome | no / yes: within-year timing and relationship outcome / yes | `REQUIRES_NEW_EVIDENCE` |
| G31 | Late round judges and recognizes work and ends or transfers low-value work | Next 12 months late / career | Prediction / timed outcome | No late bucket, recognition event, termination or transfer atom | no / yes: within-year timing and outcome / yes | `REQUIRES_NEW_EVIDENCE` |
| G32 | Late round leaves fewer but heavier and better-paid work types and steadier finances | Next 12 months late / career and finance | Prediction / timed outcome | No late bucket, work-count or return magnitude atom | no / yes: within-year timing and measured outcome / yes | `REQUIRES_NEW_EVIDENCE` |
| G33 | Ages 42–62 create happiness and stability from reputation, knowledge, network and prior work | Current life period / cross-domain | Prediction / long-range | Venus 42–62 and harvest theme are exact; specific asset sources and returns are not | partial / yes for named sources / yes | `SUPPORTED_WITH_REWRITE` |
| G34 | Current period continually filters people and work; relationships reduce but stabilize; work shifts to management and transfer | Current life period / work and relationship | Prediction / long-range outcome | Next-life work material supports quality, experience and delegation; relationship material supports time and duty boundaries; numeric reduction and stability outcome do not | partial / yes for reduction outcome / yes | `SUPPORTED_WITH_REWRITE` |
| G35 | Ages 63–68 are Sun period; role shifts to direction, recognition and experience over labor | Next life period / career | Prediction / direct | Life-period output supports `ช่วงเปล่งประกาย (63–68)`, Sun and acceptance; next-life career strong supports experience and quality; fame is broader than current evidence | partial / no / yes | `SUPPORTED_WITH_REWRITE` |
| G36 | This year clearly changes work status, decision authority and later income | Summary / career and finance | Prediction / direct | Career and finance next-12-month strong materials support wider duty, authority-quality boundary and available-money test; exact status and income sequence need rewrite | partial / no / yes | `SUPPORTED_WITH_REWRITE` |
| G37 | Ambiguous relationship becomes clear; ready people plan; unready people leave | Summary / relationship | Prediction / outcome | Relationship strong material supports clarity from consistent agreements; planning and leaving events are absent | partial / yes for event outcomes / yes | `SUPPORTED_WITH_REWRITE` |
| G38 | At the end of 12 months fewer work and relationship items remain, but they are more stable and valuable | Summary / timed cross-domain | Prediction / timed outcome | No end-of-year bucket, item-count, stability or value result atom | no / yes: within-year timing and measured outcome / yes | `REQUIRES_NEW_EVIDENCE` |

## Existing evidence keys used by the Candidate

Known 00:03 exposes these real keys through `ForecastMaterialFingerprint.evidenceKey` with `sourceOwnership=lagna-house-and-life-period-score`:

- `prediction.career.current.strong`
- `prediction.finance.current.strong`
- `prediction.relationship.current.strong`
- `prediction.health.current.strong`
- `prediction.career.next12Months.strong`
- `prediction.finance.next12Months.strong`
- `prediction.relationship.next12Months.strong`
- `prediction.health.next12Months.strong`
- `prediction.career.nextLifePeriod.strong`
- `prediction.finance.nextLifePeriod.active`
- `prediction.relationship.nextLifePeriod.quiet`
- `prediction.health.nextLifePeriod.active`

Unknown uses the same key shape only where date-based evidence remains available, with `sourceOwnership=life-period-score-without-lagna`, `e=noLagna`, and `td=false`. These are existing serialized values, not IDs created for this review.

## OR1 predictive-architecture extension

`Current source` เป็นข้อมูลที่มีจริง `Proposed deterministic rule` เป็นเพียงชนิดของกฎที่ต้องได้รับอนุมัติ ไม่ใช่สูตรที่อนุมัติแล้ว ทุกแถวที่ไม่มี approved Canon method ระบุ `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` และห้ามใช้เป็น runtime claim

| ID | Exact required atom | Current source | Missing component | Proposed deterministic rule | Approved Canon basis | Legitimate certainty | Known / Unknown | Owner decision needed |
|---|---|---|---|---|---|---|---|---|
| G00 | normalized birth/chart fact | adapter → profile | none | existing normalization/calculation | existing calculation tests | exact fact | Known full; Unknown omits time fields | none |
| G01 | life-period sequence only | `LifePeriodEngine` | early-responsibility event | existing boundaries; no event rule proposed | period boundaries only | exact period, theme as interpretation | date/day availability constrained | accept rewrite only |
| G02 | current period + primary domain tendency | period + forecast plan | stable-choice outcome | existing period and forecast ordering | none for outcome | direct fact plus tendency | both with source ownership | accept rewrite only |
| G03 | `career_role_change`, age 44–46 | age 44, annual Taksa, career score | 44–46 subrange and cut/expand event resolver | Product Rulebook has horizon-level role rule but no 44–46 subrange | none for subrange mapping | none until approved | Known only V1 | remains blocked |
| G04 | past duty/family-rule event | Saturn period 1–10; Canon life-period/Taksa positions | event family, actor, outcome | Owner-approved past-event resolver from period + annual Taksa; must prove negative cases | Canon has positions, no event mapping | none until approved | Known; Unknown omitted absent date-only rule | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G05 | survival/self-reliance psychology | none | outside product boundary | no rule permitted in this report | none | none | prohibited both | route separate psychological report; `MUST_NOT_IMPLEMENT` |
| G06 | past school/work/social setting change | Jupiter period 11–29 | event family, setting, count | Owner-approved past-event resolver with explicit setting enum and count rule | none for event mapping | none until approved | Known; Unknown blocked | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G07 | late-period responsibility/expectation separation | same period | late subperiod, domains, decision outcome | Owner-approved subperiod + cross-domain event resolver | none | none until approved | Known; Unknown blocked | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G08 | past high-magnitude cross-domain change | Rahu period 30–41 | magnitude, affected domains, event | Owner-approved magnitude threshold + event resolver | none | none until approved | Known; Unknown blocked | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G09 | counted ending/reshaping event | same period | event count and outcome | Owner-approved event detection with stable event identity/dedupe | none | none until approved | Known; Unknown blocked | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G10 | learned suitable people/burdens psychology | none | outside product boundary | no rule permitted in this report | none | none | prohibited both | route separate psychological report; `MUST_NOT_IMPLEMENT` |
| G11 | Venus 42–62 + current work tendency | life period + career forecast | proving/valuable-choice causal story | rewrite to exact period and tendency only | period facts only | fact/tendency | both per evidence | accept rewrite only |
| G12 | old/new return + fame/money/satisfaction | cross-domain strong bands | event source and three outcomes | Owner-approved cross-domain event resolver with one outcome per atom | none | none until approved | Known; Unknown blocked | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G13 | career movement tendency | career current score/evidence | role-change event | proposed `PPR-CAREER-ROLE-001`; Owner approval required | none for event | none until approved | Known only V1 | review Rulebook |
| G14 | competence/management/quality opportunity | career score, house facts, opportunity magnitude | mechanism, requester, comparative outcome | proposed `PPR-CAREER-OPPORTUNITY-001`; named requester remains prohibited | none | none until approved | Known only V1 | review Rulebook |
| G15 | overload/authority risk | career risk/material | forced removal outcome | retain risk wording; ending needs approved atom | none for ending | risk only | both per evidence | accept risk rewrite |
| G16 | income tendency/source | finance score + current work-income separation | named old clients/contacts/source | retain non-luck tendency; named source needs resolver | none | tendency only | both per evidence | accept rewrite or rule |
| G17 | `expense_or_obligation` event/category | finance risk | expense event, category, movement | Owner-approved finance resolver from annual Taksa + house + risk with enum/negative cases | none for event mapping | none until approved | Known; Unknown only non-time rule | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G18 | finance obligation risk | finance material | causal final stability | keep decision-space risk, not guaranteed outcome | none for outcome | risk/tendency | both | accept rewrite |
| G19 | relationship clarity tendency | relationship score/material | leaving/planning outcomes | retain agreement tendency; outcomes await atoms | none | tendency only | both | accept rewrite or rule |
| G20 | partnered-duty branch | relationship material | relationship-status input | branch only from explicit input plus approved rule | none | no status claim | neither until input exists | input/product decision |
| G21 | `relationship_entry` + encounter source | relationship score | relationship status, person/source event | add explicit status input, then Owner-approved encounter resolver; never infer status | none | none until both exist | Known/Unknown after input; time dependency explicit | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` + input decision |
| G22 | health-load tendency | health score/risk | primary medical cause | safe non-diagnostic tendency only | none for diagnosis | risk/tendency | both per evidence | medical-safety acceptance |
| G23 | workload/recovery risk | career+health risk | exact causal event | bounded risk composition with no diagnosis | none for event | risk only | both | accept rewrite |
| G24 | work-linked opportunity tendency | life-map work vs chance | old contact/client event | retain work-linked tendency; source awaits resolver | none | tendency only | both | accept rewrite or rule |
| G25 | `career_opportunity` source event | generic opportunity magnitude | collaboration/return/referral source and outcome | `PPR-CAREER-OPPORTUNITY-001` allows generic opportunity only; named source remains blocked | none | none until approved | Known only V1 | approve generic rule or request source resolver |
| G26 | rolling range + primary domain | exact dates + four bands | strict causal sequence | existing horizon and ranking only | none for causality | direct tendency | both per evidence | accept rewrite |
| G27 | early-window work collision/offer | annual career band | within-year boundary, event source, event | no rule; annual-band splitting prohibited | none | none | neither | remains blocked by Timing Contract |
| G28 | early role-transfer event | annual career band | boundary, transferred issue, role outcome | horizon-level `PPR-CAREER-ROLE-001` cannot claim early timing | none | none | neither for timed claim | remains blocked |
| G29 | middle income/expense event | annual finance band | boundary, two finance events | approved timing + income/obligation atoms | none | none until approved | Known; Unknown blocked absent rule | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G30 | middle relationship-status outcome | annual relationship band | boundary, status input/outcome | approved timing + status input + clarity atom | none | none until approved | both only after explicit status/rule | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G31 | late recognition/ending/transfer | annual career band | boundary, recognition and ending outcomes | approved timing + separate opportunity and ending atoms; no bundled inference | none | none until approved | Known; Unknown blocked absent rule | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G32 | late work-count/pay/stability result | career+finance bands | boundary, counts, pay magnitude, outcome | approved timing + measurable work/income atoms with thresholds | none | none until approved | Known; Unknown blocked absent rule | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |
| G33 | Venus period + asset-source return | current life period | reputation/network/prior-work outcomes | keep period fact; sources await event resolver | none | period fact only | both per evidence | accept rewrite or rule |
| G34 | work/relationship filtering outcomes | next-life material | item counts and stability outcome | keep delegation/boundary tendencies; event outcomes await rules | none | tendency only | both per evidence | accept rewrite or rule |
| G35 | Sun 63–68 boundary + career tendency | next period + career score | recognition outcome | existing boundary; role outcome needs approved rule | period boundary only | fact plus tendency | both per evidence | accept rewrite |
| G36 | work status then income sequence | annual career/finance bands | event identities and causal order | separate approved role/income atoms; ordering only from timing contract | none | tendency until approved | both per evidence | choose rewrite vs rule |
| G37 | relationship plan/ending outcomes | relationship band | status and ending atoms | retain clarity tendency or add approved atoms/input | none | tendency until approved | both per evidence | choose rewrite vs rule |
| G38 | end-window fewer/more valuable outcomes | annual bands | end boundary, counts, value/stability measure | approved timing window + typed outcome metrics; no summary-only invention | none | none until approved | Known; Unknown blocked absent rule | `OWNER_ASTROLOGY_RULE_DECISION_REQUIRED` |

## Architecture accounting

- Golden coverage remains 39/39 rows, G00–G38
- G05/G10 remain `MUST_NOT_IMPLEMENT` and map to `PROHIBITED_PSYCHOLOGY`
- No unsupported event row is labeled `CURRENTLY_DERIVABLE`
- Current exact score and evidence list are more detailed than serialized band, but no row treats that detail as an event resolver
- No external astrology source or formula was added; proposed methods require explicit Owner decision before implementation

## OR2 rule linkage for Golden gaps

| Golden IDs | OR2 rule candidate | What becomes expressible after approval | What remains blocked |
|---|---|---|---|
| G04 | `PPR-PAST-FAMILY-DUTY-001` | family duty/constraint without actor/count | exact household event, psychology |
| G06–G07 | `PPR-PAST-EDUCATION-SOCIAL-001` | education/social setting transition | event count, named school/work/source |
| G08–G09 | `PPR-PAST-DOMAIN-TRANSITION-001` | one resolved career/finance/relationship movement | bundled domains, counted event, exact outcome |
| G12 | none | no combined old/new/fame/money/satisfaction claim | entire bundled claim |
| G14 | `PPR-CAREER-OPPORTUNITY-001` | generic career opportunity | requester, comparative performance, specific mechanism |
| G17 | `PPR-EXPENSE-001` | obligation/expense pressure movement | expense category, amount, source |
| G21 | `PPR-RELATIONSHIP-ENTRY-001` | generic entry after explicit single input | encounter source, actor, exact date |
| G25 | `PPR-CAREER-OPPORTUNITY-001` | generic opportunity | collaboration/return/referral source |
| G27–G32, G38 | none | no sub-horizon output | early/middle/late, half-year, counts and end-state |

All linked rules remain `OWNER_RULE_REVIEW_REQUIRED`; unsupported-as-approved count is 0
