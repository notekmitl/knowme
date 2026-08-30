# Thai Mahabhut Predictive Rule Extraction Matrix V1

Date: 2026-08-30

Status: **PARTIAL — 12 RULES EXTRACTED FROM 2537 SCAN; 2539 PAGE MAP AND 48 LIFE-PERIOD CONTEXTS REMAIN**

Every extracted rule is in
`knowledge/canon/proposed/mahabhut_predictive_rules_v2.json`. The source PDF
and relevant page image were read, then OCR was used only as a cross-check.
The corpus is proposed, edition-scoped and not connected to runtime.

## Priority-page disposition

| Source pages | Material | Disposition | Result |
|---|---|---|---|
| 17 | rise/fall house sets | `EXTRACTED_GENERAL_RULE` | 2 rules |
| 17 | stronger fall boundary | `EXTRACTED_CONDITIONAL_RULE` | 1 rule; exact source window retained |
| 18 | eight planetary age durations | `NOT_EVENT_RULE` | page image resolves all 8; no frozen-unit mutation |
| 39 | eight Taksa role meanings | `NOT_EVENT_RULE` | domain vocabulary mapped; no event movement inferred |
| 40 | ordinary weak-house effect | `EXTRACTED_CONDITIONAL_RULE` | 1 rule |
| 40 | Kalakini in weak houses | `EXTRACTED_EXCEPTION` | 1 rule; reverses ordinary polarity |
| 41 | ordinary strong-house effect | `EXTRACTED_CONDITIONAL_RULE` | 1 rule |
| 41 | Kalakini in strong houses | `EXTRACTED_EXCEPTION` | 1 rule; reverses ordinary polarity |
| 40–41 | Jupiter/learning applications | `EXTRACTED_CONDITIONAL_RULE` | 2 rules; no school/degree/date claim |
| 290 | remainder-0 Saturday, Rahu ages 30–41 | `EXAMPLE_ONLY` | 1 exact-context rule |
| 291 | remainder-0 Saturday, Venus ages 42–62 | `EXAMPLE_ONLY` | 1 exact-context rule with hostility caveat |
| 291–292 | Venus entry/exit ages 42–43 and 61–62 | `EXAMPLE_ONLY` | 1 exact-context boundary rule |
| 44–289 and other blocks in 290–292 | remaining archetype/day narratives | `SOURCE_AMBIGUOUS` | 48 of 49 contexts not yet modeled as complete conditional rules |
| 293–305 | remedies/mantras | `OUT_OF_SCOPE` | not predictive narrative scope |

## Extracted rules

| Rule | Type | Page | Exact conditions | Allowed conclusion | Prohibited escalation | Event family | Known/Unknown |
|---|---|---:|---|---|---|---|---|
| `MPR2-RISE-POSITION` | general | 17 | active period planet in 4 strong houses | classify period as rising | named event, actor, amount, date | life-period transition | Known only |
| `MPR2-FALL-POSITION` | general | 17 | active period planet in 3 weak houses | classify period as falling | death, illness, named loss | life-period transition | Known only |
| `MPR2-FALL-BOUNDARY-INTENSITY` | conditional | 17 | falling period + stated boundary | stronger fall pressure | month or guaranteed loss | expense/obligation pressure | Known only |
| `MPR2-WEAK-HOUSE-EFFECT` | conditional | 40 | non-Kalakini planet/role in weak house | lower strength/reliability | domain event without rule | none | Known only |
| `MPR2-KALAKINI-WEAK-EXCEPTION` | exception | 40 | Kalakini in weak house | reduced obstacle pressure | obstacle-free guarantee | none | Known only |
| `MPR2-STRONG-HOUSE-EFFECT` | conditional | 41 | non-Kalakini planet/role in strong house | higher strength/support | guaranteed wealth/promotion | none | Known only |
| `MPR2-KALAKINI-STRONG-EXCEPTION` | exception | 41 | Kalakini in strong house | increased obstacle pressure | specific adverse event | none | Known only |
| `MPR2-JUPITER-LEARNING-WEAK` | conditional | 40 | Jupiter in weak house | learning difficulty/interruption | dropout, institution, date | education transition | Known only |
| `MPR2-JUPITER-LEARNING-STRONG` | conditional | 41 | Jupiter in Thongchai | steadier learning progress | guaranteed graduation | education transition | Known only |
| `MPR2-MAHASETTHI-SAT-RAHU-30-41` | life-period example | 290 | remainder 0 + Saturday + age 30–41 | exact past period status | generalization or invented event | life-period transition | Known only |
| `MPR2-MAHASETTHI-SAT-VENUS-42-62` | life-period example | 291 | remainder 0 + Saturday + age 42–62 | work/money/support tendency with caveat | guaranteed job/profit | career opportunity | Known only |
| `MPR2-MAHASETTHI-SAT-VENUS-BOUNDARIES` | life-period example | 291–292 | exact context + age 42–43 or 61–62 | narrow gain/speech caution | fire at age 44–60 or a month | expense/obligation | Known only |

All 12 excerpts are short, page-scoped and available in the JSON corpus. All
12 have `OWNER_REVIEW_REQUIRED`; none is silently Canon-approved.

## OCR recovery accounting

The old Phase D blocker file has 49 records. Four are p.18 duration digits;
the page image now resolves Sun 6, Moon 15, Mars 8, Mercury 17, Jupiter 19,
Venus 21, Saturn 10 and Rahu 12 years. The old Phase E blocker for the p.41
Jupiter example is also resolved by direct image review. These five recoveries
are recorded in SA1 only; the frozen foundation is intentionally unchanged.

The remaining 45 Phase D records stay `OCR_BLOCKED` until their own page
images and context boundaries are reviewed. The 48 unmodeled archetype/day
blocks are not declared silent Canon.

## Generalization boundary

Pages 290–292 describe one remainder/day context. They do not authorize a
rule for another remainder or Thai day. Likewise, p.39 maps role meaning but
does not transform “ศรี relates to assets” into “income will increase.” The
source's general rules and its examples remain separately typed.
