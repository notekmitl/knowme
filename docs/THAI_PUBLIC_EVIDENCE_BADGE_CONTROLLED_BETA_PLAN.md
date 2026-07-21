# Thai Public Evidence Badge Controlled Beta Plan

**Phase:** Public Evidence Badge Controlled Beta Plan  
**Status:** **DRAFTED** (plan only — not implemented)  
**Date:** July 2026  
**Prerequisite commit:** `5618d6e` — Public Evidence Badge Prototype Freeze  
**Policy source:** [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md)  
**Prototype source:** [`THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_FREEZE.md`](THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_FREEZE.md)

---

## Controlled beta principle

The beta must answer:

> Can users understand the badge as “traceability” without misreading it as “guaranteed accuracy”?

The beta must **not** make the product sound more certain than it is.

---

## 1. Beta declaration

**This is a rollout plan only.**

**No public evidence badge is implemented or enabled by this document.**

Current state remains unchanged:

- Public Evidence Badge Prototype: **FROZEN / INTERNAL BETA ONLY**
- Internal preview route: `/internal/thai-public-evidence-preview` (admin-guarded)
- Controlled beta: **not started**
- Public release: **not authorized**
- Thai validation suite: **716 / 716 pass**

---

## 2. Beta objective

The controlled beta exists to validate user understanding and safety before any broader rollout.

| Objective | Success signal |
|-----------|----------------|
| Test user understanding of Canon traceability badge | Majority interpret as traceability, not guarantee |
| Verify no increase in overconfidence | Low “guaranteed accuracy” interpretation rate |
| Verify no confusion with prediction certainty | Low “ฟันธง / แม่นแน่นอน” association rate |
| Verify no expectation of source prose or remedy advice | No remedy/source-text requests triggered by badge |
| Verify public UI remains safe and reversible | Feature flag off removes badge with no data rollback |

---

## 3. Eligible surface

**Recommended first beta surface (exactly one):**

### Thai Beta Research Result only

**Reason:**

- Already experimental / research-oriented
- Easier to gate than main consumer surfaces
- Safer than public `ThaiMirrorResultPage`
- Feedback loop already exists via Thai beta research tooling
- Not the main product surface

**Explicitly excluded from first beta:**

| Surface | Reason |
|---------|--------|
| Home | Main product entry — too broad |
| Daily Mirror | Consumer daily surface — too broad |
| `ThaiMirrorResultPage` (public) | Primary consumer result — defer until beta succeeds |
| General user profile / result routes | Uncontrolled audience |

---

## 4. Eligible audience

| Stage | Audience | Authorization |
|-------|----------|---------------|
| Stage 0 | Internal testers | Research admin / engineering |
| Stage 1 | Limited invited Thai beta testers | Explicit invite list only |
| **Not in scope** | Anonymous public rollout | Forbidden |
| **Not in scope** | All-user rollout | Forbidden |
| **Not in scope** | Paid / premium rollout | Forbidden |

Beta participants must be identifiable and revocable.

---

## 5. Feature gate

**Required feature flag:** `thai_public_evidence_badge_beta`

| Value | Behavior |
|-------|----------|
| `off` | **Default** — no badge on any surface |
| `internal_only` | Badge visible only to internal testers on Thai Beta Research Result |
| `invited_beta` | Badge visible to invited beta testers on Thai Beta Research Result |

**Rules:**

- Default: **OFF**
- No default-on behavior
- Flag must be checked at render time on beta surface only
- Flag state must be logged for technical metrics

---

## 6. Rollback plan

Rollback must be immediate and low-risk.

| Step | Action |
|------|--------|
| 1 | Set `thai_public_evidence_badge_beta` → `off` |
| 2 | Badge disappears from Thai Beta Research Result |
| 3 | No Canon data rollback required |
| 4 | No engine rollback required |
| 5 | No report copy rollback required |
| 6 | Run `flutter test test/validation/thai/` — must remain green |

Rollback must be possible **without redeploying Canon data**.

No schema migration, no `foundation_v1.knowme.json` change, no evidence rule change on rollback.

---

## 7. Allowed badge content

LEVEL 1 only — frozen from prototype and policy.

| Element | Allowed content |
|---------|-----------------|
| Badge label | **มีแหล่งอ้างอิงใน Canon** (single label for beta — no rotation) |
| Caution copy | ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์ |
| Page references | **No** |
| Source prose | **No** |
| Raw ids | **No** |
| Confidence score | **No** |

Eligibility unchanged from frozen prototype:

- `CANON_SUPPORTED` + `mahabhutPosition` / `planetSignification` only

---

## 8. Forbidden beta content

Must **not** display during controlled beta:

| Category | Examples |
|----------|----------|
| References | Page references, source prose, source scans |
| Internal ids | Raw Canon unit ids, ontology ids |
| Scores | Confidence percentages |
| Hidden Canon | Remedies, Taksa, Khumsap, ดวงขึ้น / ดวงตก |
| Lookup data | Lookup table values |
| Blockers | Ambiguity / conflict details as advice |
| Certainty language | แม่นแน่นอน · ฟันธง · 100% · พิสูจน์แล้ว |
| Advice wording | ต้องทำ · ห้ามทำ · ควรสะเดาะเคราะห์ |

---

## 9. Metrics

### Safety metrics

| Metric | Collection method |
|--------|-------------------|
| Users who interpret badge as guaranteed accuracy | Beta feedback survey |
| Users who ask for remedy instructions after seeing badge | Support / feedback log |
| Users who ask for source text / prose | Support / feedback log |
| Users who feel badge makes prediction too certain | Beta feedback survey |
| Reports of confusion | Qualitative feedback + support tickets |

### UX metrics

| Metric | Collection method |
|--------|-------------------|
| Badge noticed | In-app observation / survey |
| Badge understood | Survey question |
| Badge ignored | Survey / session notes |
| Badge increases trust appropriately | Survey (traceability trust, not accuracy) |
| Badge creates clutter | Survey / reviewer notes |
| Badge improves willingness to give feedback | Survey |

### Technical metrics

| Metric | Source |
|--------|--------|
| Badge rendered count | Client analytics (beta only) |
| Eligible section count | Mapper output per session |
| Hidden category count | Internal summary (counts only) |
| Feature flag state | Remote config / flag service |
| Error count | Error logging |
| Public leakage outside beta route | Automated isolation tests + manual audit |

---

## 10. Feedback questions (Thai — draft)

Beta feedback form must include:

1. **คุณเข้าใจ badge นี้ว่าอย่างไร?**
2. **คุณคิดว่า badge นี้หมายถึง “แม่นแน่นอน” หรือไม่?**
3. **badge นี้ช่วยให้คุณไว้ใจที่มาของการวิเคราะห์มากขึ้นไหม?**
4. **badge นี้ทำให้ผลดูฟันธงเกินไปไหม?**
5. **คุณอยากเห็นแค่ badge หรืออยากเห็นหน้าอ้างอิงด้วย?**
6. **มีส่วนไหนที่ทำให้เข้าใจผิดไหม?**

Optional follow-up (internal only): request to show page references is logged as LEVEL 2 interest — not implemented in beta.

---

## 11. Success criteria

Beta may be considered successful only if **all** criteria pass:

| Criterion | Threshold |
|-----------|-----------|
| No public policy violations | 0 violations |
| No remedy exposure | 0 incidents |
| No Taksa / Khumsap / rise-fall exposure | 0 incidents |
| No confidence wording on surface | 0 incidents |
| Public fingerprint regression | Pass on every release candidate |
| Tester understanding | Majority interpret badge as traceability, **not** accuracy guarantee |
| Critical confusion | 0 critical confusion reports |

---

## 12. Stop criteria

Beta must **stop immediately** if any of the following occur:

| Stop trigger | Response |
|--------------|----------|
| Any remedy text exposed | Flag off + incident review |
| Any source prose exposed | Flag off + incident review |
| Badge appears on non-beta public surface | Flag off + hotfix |
| High rate of “guarantee” interpretation | Pause beta + copy review |
| Forbidden wording appears on surface | Flag off + copy fix |
| Public output regression fails | Block release |
| Evidence rule violation found | Flag off + engineering review |
| Admin guard / feature flag bypass | Flag off + security review |

---

## 13. Required implementation gates (future phase)

Before **Public Evidence Badge Controlled Beta Implementation**, all gates must pass:

| Gate | Requirement |
|------|-------------|
| Plan accepted | This document explicitly approved |
| Feature flag design | `thai_public_evidence_badge_beta` with `off` default |
| Route / surface gating tests | Badge only on Thai Beta Research Result when flag on |
| Public copy tests | Allowed label + caution copy only |
| Forbidden wording tests | No certainty language on beta surface |
| No data leakage tests | No page refs, ids, prose, remedies |
| Rollback test | Flag off removes badge; suite green |
| Beta feedback logging plan | Survey + incident log defined |
| Validation suite | `flutter test test/validation/thai/` green |

---

## 14. Recommended next phase

**Public Evidence Badge Controlled Beta Implementation**

**Implementation may proceed only after this plan is accepted.**

Do not implement in this commit.

---

## Related

- [`THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_FREEZE.md`](THAI_PUBLIC_EVIDENCE_BADGE_PROTOTYPE_FREEZE.md)
- [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md)
- [`THAI_PUBLIC_EVIDENCE_BADGE_QA.md`](THAI_PUBLIC_EVIDENCE_BADGE_QA.md)
