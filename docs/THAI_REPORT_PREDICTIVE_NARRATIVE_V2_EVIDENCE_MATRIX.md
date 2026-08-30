# Thai Report Predictive Narrative V2 — Evidence Support Matrix

ฐานตรวจ: `d857308eb8635899e468dab5e22a3a53f87fced1` · Fixture `1982-06-06 00:03 Chiang Mai` · `asOf = 2026-08-29 Asia/Bangkok`

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
