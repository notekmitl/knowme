# Real User Runtime Validation V1

**Program:** Real User Runtime Validation V1  
**Authority:** [`docs/KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md), [`docs/GOVERNANCE.md`](GOVERNANCE.md)  
**Scope:** Validation only — no production code changes, no synthetic users, no fixtures  
**Status:** COMPLETE — real Firestore population audited  
**Date:** 2026-06-21

---

## Executive Summary

Synthetic validation (Narrative V5) reached **1000/1000 unique narratives** on a fully-populated 1000-human factory. Real Firestore users tell a different story: the production pipeline is **architecturally sound but data-sparse**. Of **38 real users**, only **1 user (2.6%)** reaches Narrative. The primary break point is **missing personality test completion**, not narrative collapse or engine failure.

| Dimension | Synthetic (1000) | Real (38) | Match? |
|---|---:|---:|---|
| Narrative reach rate | 100% | **2.6%** | NO |
| Unique narratives (absolute) | 1000 | **1** | N/A (sample size) |
| Collapse severity | 0 profiles | **0 profiles** | YES |
| Max cluster | 1 | **1** | YES |
| Deterministic replay | 100% | **100%** | YES |
| Active patterns | 30 | **8** (on 1 user) | NO |
| Personality coverage | 100% factory | **MBTI 1, Big Five 0, EQ 2** | NO |

**Conclusion:** Synthetic validation proves engine diversity and determinism. Real users prove the **acquisition funnel** — not the narrative layer — is the current bottleneck.

---

## Method

### Data source

Read-only export from production Firestore (`users/*`) using service account credentials.

```bash
python test/validation/real_user_runtime_v1/export/firestore_user_export.py
dart run test/validation/real_user_runtime_v1/analysis/real_user_runtime_validation_v1_runner.dart
```

### Pipeline replay

For each exported user, validation replays the production stack with GF2 recovery enabled:

```
Profile + Results + Astrology docs
  → Mirror (Thai + BaZi astrology, MBTI/Big Five/EQ personality)
  → GF1 Foundation
  → GF2 Recovery
  → Human Model
  → Human Pattern
  → Narrative V5
```

No synthetic profiles. No fixture injection. Users without required inputs are recorded in the failure audit.

### Artifacts

| Artifact | Path |
|---|---|
| Firestore export | `test/validation/real_user_runtime_v1/output/firestore_user_export.json` |
| Validation output | `test/validation/real_user_runtime_v1/output/real_user_runtime_validation_v1.json` |
| Export script | `test/validation/real_user_runtime_v1/export/firestore_user_export.py` |
| Analysis runner | `test/validation/real_user_runtime_v1/analysis/real_user_runtime_validation_v1_runner.dart` |

---

## 1. Runtime Funnel

Population: **38 Firestore users** (includes 11 automation/e2e accounts).

| Stage | Count | Rate |
|---|---:|---:|
| Total users | 38 | 100% |
| Profile present | 31 | 81.6% |
| Thai birth input (computable) | 31 | 81.6% |
| BaZi chart stored | 25 | 65.8% |
| Western natal chart stored | 33 | 86.8% |
| MBTI result | 1 | 2.6% |
| Big Five result | 0 | **0%** |
| EQ result (any module) | 2 | 5.3% |
| **Reaching Mirror** (astrology + personality inputs) | 2 | 5.3% |
| Reaching GF1 | 2 | 5.3% |
| Reaching GF2 | 2 | 5.3% |
| Reaching Human Model | 2 | 5.3% |
| **Reaching Human Pattern** (≥1 activation) | 1 | 2.6% |
| **Reaching Narrative** (≥1 paragraph) | 1 | 2.6% |

### Funnel visualization

```
38 total users
 ├─ 31 profile + Thai birth
 │    ├─ 25 BaZi
 │    └─ 33 western (stored, not in Mirror path)
 ├─ 1 MBTI  |  0 Big Five  |  2 EQ
 └─ 2 dual-input (astrology + personality)
      └─ 1 full stack → Narrative (uid: XfoMYQ78m7fCzgmlimHbmYzplrw2)
```

### Primary funnel break

**Stage 1 break:** 7 users without profile/birth data (automation accounts + incomplete signup).

**Stage 2 break (dominant):** 29 users with astrology-capable profiles but **no completed personality tests** in `users/{uid}/results/*`. Pipeline requires both mirror inputs.

**Stage 3 break:** 1 user (`k80ff6ciZPUwXicboeOFtWNRgCm1`) reaches Mirror/GF/HM but produces **zero Human Pattern activations** — fusion cross-mirror agreement insufficient for pattern registry.

---

## 2. Pattern Distribution

Measured on the **1 user** reaching Human Pattern + Narrative.

| Metric | Synthetic 1000 | Real (pipeline-complete) |
|---|---:|---:|
| Total activations | 13,732 | **8** |
| Active patterns | 30 | **8** |
| Dead patterns | 0 | **33** |
| Top pattern share | ~3.3% avg | **12.5%** |
| Pattern families touched | broad | 5 families |

### Active patterns (real, n=1 user)

| Pattern | Activations |
|---|---:|
| accountable_operator | 1 |
| decisive_actor | 1 |
| directional_meaning | 1 |
| independent_decision_maker | 1 |
| progressive_builder | 1 |
| self_directed_identity | 1 |
| stable_accountability | 1 |
| structured_operator | 1 |

### Pattern family distribution

| Family | Count |
|---|---:|
| decision_style | 3 |
| theme_coverage_pattern | 2 |
| meaning_style | 1 |
| growth_style | 1 |
| identity_style | 1 |

**Comparison:** Synthetic population activates all 30 registry patterns with balanced density. Real users — with only one pipeline-complete profile — activate 8/30 patterns. This reflects **sparse input**, not registry failure.

---

## 3. Narrative Diversity

| Metric | Synthetic | Real |
|---|---:|---:|
| Unique narratives | 1000 | **1** |
| Duplicate narratives | 0 | 37 (no narrative output) |
| Profiles in collapse (≥3 identical) | 0 | **0** |
| Max cluster | 1 | **1** |
| Evidence fingerprints | 999 | **1** |
| Topology fingerprints | 1000 | **1** |
| Deterministic replay | 100% | **100%** |

On the single pipeline-complete user:

- **6 narrative paragraphs**
- **0 collapse** (cannot collapse with n=1)
- **100% determinism** on replay

Narrative V5 behavior is **consistent with synthetic validation** on the one user who reaches it. The gap is **reach rate**, not narrative quality on reached users.

---

## 4. Lens Contribution

Counts reflect signal/finding/evidence contributions accumulated across all users with partial or full pipeline inputs.

### Mirror layer (signal counts)

| Lens | Contributions |
|---|---:|
| BaZi | **229** |
| Thai Astrology | **193** |
| Chinese Zodiac (BaZi animal) | **23** |
| EQ | 5 |
| MBTI | 4 |
| Big Five | **0** |

Astrology mirrors dominate because **31/38 users** have computable Thai birth data. Personality mirrors are nearly absent.

### Fusion layer

| Lens | Contributions |
|---|---:|
| Thai Astrology | 6 |
| MBTI | 2 |
| BaZi | 0 |
| Big Five | 0 |
| EQ | 0 |
| Chinese Zodiac | 0 |

Cross-mirror fusion requires **both** mirror roles. With personality data on only 2 users, fusion is overwhelmingly astrology-internal or thin cross-mirror on the one complete user.

### Human Model → Narrative

| Layer | Thai | BaZi | MBTI | Big Five | EQ |
|---|---:|---:|---:|---:|---:|
| Human Model | 7 | 0 | 0 | 0 | 0 |
| Human Pattern | 6 | 9 | 0 | 0 | 0 |
| Narrative | 13 | 0 | 0 | 0 | 0 |

### Under-contributing systems

| System | Status |
|---|---|
| **Big Five** | **Zero production results** — completely absent |
| **MBTI** | 1 user — minimal cross-mirror contribution |
| **EQ** | 2 users — minimal downstream propagation |
| **Chinese Zodiac** | Present in BaZi charts but weak downstream attribution |
| **Western Astrology** | Stored for 33 users but **not wired into Mirror path** |

### Most-contributing systems

| System | Role |
|---|---|
| **Thai Astrology** | Dominant Mirror signal source (31 users with birth profiles) |
| **BaZi** | Strong Mirror signals where chart exists (25 users) |
| **Thai + BaZi combined** | Primary path to Human Pattern on the one complete user |

---

## 5. Failure Audit

| Failure class | Count | Notes |
|---|---:|---|
| Pipeline blocked — missing inputs | **36** | Almost always missing personality tests |
| Empty narrative | 0 | No user reached Narrative with empty text |
| Low pattern coverage (<8 activations) | 0 | Only 1 user reaches patterns (exactly 8) |
| No GF2 benefit | 0 | GF2 adds agreements on complete users |
| Missing lineage | 0 | Lineage complete on pipeline-complete user |
| Abnormal concentration | 0 | No single-pattern dominance on reached user |

### Blocked user breakdown

| Root cause | Users |
|---|---:|
| Missing personality tests only | 29 |
| Missing profile/birth (automation) | 7 |
| Mirror reached, zero pattern activations | 1 (`k80ff6ciZPUwXicboeOFtWNRgCm1`) |

### Automation accounts (11/38)

UIDs containing `test`, `verify`, `cors`, `e2e`, or `audit`. These inflate total user count but do not represent product users. Excluding automation accounts: **27 product-like users**, **1 reaches Narrative (3.7%)**.

### Pipeline-complete user

**`XfoMYQ78m7fCzgmlimHbmYzplrw2`**

- Profile + Thai birth + BaZi
- Personality tests completed (MBTI and/or EQ — sole MBTI holder in population)
- 8 pattern activations, 6 narrative paragraphs
- GF2: 4 supplemental agreements
- Deterministic replay: PASS

---

## 6. Synthetic vs Real Comparison

| Metric | Synthetic V5 | Real V1 | Delta |
|---|---:|---:|---:|
| Population | 1000 | 38 | — |
| Narrative reach | 100% | 2.6% | **−97.4 pp** |
| Unique narratives / capita | 1.00 | 0.026 | **−0.974** |
| Active patterns | 30 | 8* | −22 |
| Total activations | 13,732 | 8* | −13,724 |
| Collapse | 0 | 0 | 0 |
| Max cluster | 1 | 1 | 0 |
| Determinism | 100% | 100% | 0 |

\*On pipeline-complete users only (n=1).

### What matches synthetic validation

- **Deterministic replay** — 100% on real users who reach Narrative
- **No narrative collapse** — max cluster 1 (insufficient sample for collapse test)
- **GF2 / lineage integrity** — no failures on complete pipeline runs
- **Narrative V5 engine behavior** — consistent on the one complete profile

### What does not match

- **Input completeness** — synthetic factory guarantees MBTI + Big Five + EQ + BaZi + Thai; real users mostly have profile + astrology only
- **Pipeline reach** — 100% synthetic vs 2.6% real
- **Pattern utilization** — 30/30 synthetic vs 8/30 real
- **Personality lens contribution** — factory-weighted vs near-zero in production

---

## REAL_WORLD_READINESS_STATUS

### Does synthetic validation match reality?

**Partially.**

Synthetic validation accurately validates **engine determinism, narrative diversity mechanics, GF2 recovery, and collapse elimination** under full-input conditions. It does **not** predict real-world reach rates because the synthetic factory assumes **100% personality + astrology completion**, which production users do not have.

The engines work. The **data funnel** does not yet feed them.

### What breaks first in real users?

1. **Personality test completion** — 36/38 users blocked before Mirror (29 have astrology profile but zero personality results)
2. **Big Five absence** — 0 production results; entire lens unused
3. **Pattern activation gap** — 1 user reaches Mirror but fails Human Pattern (insufficient cross-mirror signal)
4. **Profile completeness** — 7 users lack birth profile (mostly automation accounts)

Narrative collapse is **not** a real-world failure mode at current scale (n=1 narrative user, 0 collapse).

### What system contributes least?

**Big Five** — zero Firestore results, zero Mirror/Fusion/Pattern/Narrative contribution.

Secondary under-contributors: **MBTI** (1 user), **EQ** (2 users), **Western Astrology** (stored but not in Mirror pipeline).

### What system contributes most?

**Thai Astrology + BaZi** — available for 31 and 25 users respectively; dominate Mirror signal counts and are the only systems driving the one successful end-to-end user.

### Is KnowMe ready for broader user acquisition?

**Not yet for full-stack KnowMe experience.**

| Ready | Not ready |
|---|---|
| Mirror engine (Thai + BaZi) | Personality onboarding funnel |
| GF1 / GF2 / HM / HP stack (proven on complete user) | Big Five adoption (0 users) |
| Narrative V5 (deterministic, no collapse on reached user) | Cross-mirror density at real-user scale |
| Deterministic replay | Sufficient sample to validate narrative diversity (n=1) |

**Recommendation before broad acquisition:**

1. **Personality completion program** — drive MBTI + Big Five + EQ completion for users who already have profiles (31 astrology-ready users waiting)
2. **Funnel telemetry** — track `profile → personality test → mirror → narrative` in production
3. **Re-run Real User Validation V2** after personality adoption reaches ≥30% of profile-complete users
4. **Filter automation UIDs** from production analytics dashboards

### Recommended Next Program

**Production Funnel Recovery V1** — optimize onboarding to close the personality gap for the 29 astrology-ready users with no `results/*` documents. Target: narrative reach ≥25% of profile-complete users before scaling acquisition.

Secondary: **Real User Validation V2** — re-audit when real population ≥100 users with ≥30% personality completion.

---

## Validation Gates (Real User V1)

| Gate | Target | Actual | Result |
|---|---|---|:---:|
| Real data only | Required | Firestore export | PASS |
| No synthetic users | Required | 0 synthetic | PASS |
| No production changes | Required | Validation-only | PASS |
| Funnel report | Required | Section 1 | PASS |
| Pattern audit | Required | Section 2 | PASS |
| Narrative audit | Required | Section 3 | PASS |
| Lens audit | Required | Section 4 | PASS |
| Failure audit | Required | Section 5 | PASS |
| Synthetic comparison | Required | Section 6 | PASS |

---

## Re-run Commands

```bash
# Step 1 — refresh Firestore export (read-only)
python test/validation/real_user_runtime_v1/export/firestore_user_export.py

# Step 2 — replay pipeline + generate report
dart run test/validation/real_user_runtime_v1/analysis/real_user_runtime_validation_v1_runner.dart
```

Output JSON is consumed by this document's metrics. Re-export before re-run if production data has changed.
