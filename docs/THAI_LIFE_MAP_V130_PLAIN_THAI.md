# Thai Life Map V1.3.0 — Plain Thai Narrative

**Status:** Merged + hosted @ `ad1e948` (PR #44) — product-failure fix over V1.2.9  
**Runtime predecessor:** V1.2.9 @ `7ca091f` failed Product Acceptance (system prose / repeated `ช่วงนั้น`)

## Root cause (proven)

1. `LifeMapSemanticMapper._frameSituation` prefixed **every** situation with `ช่วงนั้น` / `ขณะนี้` / `ช่วงถัดไป`.
2. `PastRetrospectiveComposer` appended `ผลกระทบหลักอยู่ที่${domain.labelTh}` and `ควบคู่กับด้าน…` — domain dump.
3. Domain labels were compound jargon (`งานและบทบาท`, `โอกาสและการขยายบทบาท`).
4. Duplicate checks compared semantic IDs, not UI paraphrase; readability gates never existed.
5. Word-budget pad re-injected more `ช่วงนั้น` report language.

## Architecture

| Layer | Role |
|-------|------|
| Evidence → `LifeMapSemanticMapper` | Structured claims (IDs + plain body text) |
| `LifeMapPlainThaiRenderer` | UI assembly: ≤1 time marker/card, no domain tails, drop duplicate slots |
| Composers / widget | Past body + Current/Future summary/harder/advice; label `สิ่งที่เกิดขึ้น` |

## Product Language Gate

Asserts on **final UI text**: marker count, banned system phrases, jargon, slot distinctness, tense language, 8-period coverage.

## Unchanged

Canon, formulas, period math, Past/Current/Future classification, Auth, Firestore, invited_beta, Evidence Badge.
