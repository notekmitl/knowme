# Thai Life Map V1.2.9 — Semantic Verdict Fix

**Status:** Merged + hosted @ `7ca091f` (PR #42) — product-failure fix over V1.2.8  
**Runtime predecessor:** V1.2.8 @ `4b42f95` failed Product Acceptance on Production UI

## Root cause (proven)

`PastRetrospectiveComposer` openings were literal templates:

- `$keyword กลายเป็นแกนของชีวิต…มากกว่าเรื่องอื่นในช่วงใกล้เคียง`
- `บรรยากาศหลักโยงกับเรื่อง$keyword…มีน้ำหนักต่างจากจังหวะอื่น`

V1.2.8 removed hedges/labels but left this meta-language. Tests asserted form (no `อาจ`, has `ช่วง`) not falsifiable life claims. Path: `TimelinePresenter` → `PeriodNarrativeComposer` → UI `summary`.

## Semantic architecture

| Piece | Role |
|-------|------|
| `LifeMapSemanticMapper` | Evidence → structured claims (situation / domain / pressure / consequence IDs) |
| `LifeMapVerdictSemantics` | Testable payload + meta-language bans |
| Past / Current / Future composers | Render Thai from claims; slots must not share semantic fingerprint |

## Product contract

Every primary body must include **situation + affected domain + consequence/transition**, without unsupported catastrophic events.

## QA

See generated artifact: `test/validation/thai_beta/life_map/v129/output/v129_product_qa.md` (synthetic, no PII).

### V1.2.8 failure → V1.2.9 (Sunday/age 25-class past, production path)

**Before:** `…เรื่องการยอมรับ กลายเป็นแกนของชีวิตในวัยเด็กเล็ก…มากกว่าเรื่องอื่นในช่วงใกล้เคียง`

**After:** `ช่วงนั้นตัวตนถูกผลักให้เลือกทางของตนเองภายใต้ความคาดหวังรอบข้าง ผลกระทบหลักอยู่ที่ตัวตนและการยอมรับ` (+ consequence about recognition/role)

## Unchanged

Canon, formulas, period math, Past/Current/Future classification, Auth, Firestore, invited_beta, Evidence Badge.
