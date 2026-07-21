# Thai Canon Evidence Alignment QA

> **Scope:** QA/reporting only — no engine, Mirror copy, Canon data, or public UI changes.
>
> **Prerequisites:** Canon Freeze · Evidence Mapping · Report Evidence Upgrade · Review Panel

Status: **COMPLETE** · Deterministic audit runner + validation tests.

---

## 1 · Purpose

Answer for each Canon evidence attachment:

**Does this Canon evidence actually support the report section/signal it is attached to?**

Not merely: *can the system find related Canon evidence?*

Implementation: `lib/features/astrology/thai/knowledge/canon/integration/qa/`

Run locally:

```bash
dart run tool/run_canon_evidence_alignment_audit.dart
```

(requires Flutter test binding — or invoke `ThaiCanonEvidenceAlignmentRunner.run()` from tests)

---

## 2 · Fixture set

| Fixture id | Source | Notes |
|---|---|---|
| `qa_sample` | `ThaiMirrorPipeline.sampleQaBirthData()` | Bangkok 1972-04-04 02:00 ICT |
| `harness_a` … `harness_h` | `ThaiQaHarnessProfiles` | One profile per weekday + low-coverage case |

**9 fixtures total** — no random data, no current date, no Firestore/network.

**Low-coverage fixture:** `harness_h` (no birth time) — 15 attachments vs 30 on `qa_sample`; lagna/lord keys absent; most Mirror sections without evidence.

---

## 3 · Coverage metrics (aggregate)

| Metric | Value |
|---|---|
| Fixtures audited | 9 |
| Total report sections | 72 |
| Section rows with STRONG_MATCH evidence | 55 |
| Section rows with RELATED_BUT_WEAK evidence | 9 |
| Section rows with no evidence | 26 |
| Unmapped signals (total) | 99 |
| Skipped remedy count (aggregate) | 783 (87 × 9 fixtures) |
| Skipped Taksa count (aggregate) | 819 (91 × 9 fixtures) |
| Skipped periodStatus notes | 18 (2 × 9 fixtures) |
| Canon unit ids used | 432 |

### Classification totals

| Classification | Count |
|---|---|
| STRONG_MATCH | 177 |
| RELATED_BUT_WEAK | 9 |
| UNMAPPED_SIGNAL | 99 |
| SKIPPED_REMEDY | 9 |
| SKIPPED_TAKSA | 9 |
| SKIPPED_PERIOD_STATUS | 18 |

---

## 4 · Alignment classification definitions

| Class | Meaning |
|---|---|
| **STRONG_MATCH** | Evidence subject/object/context directly matches the report signal |
| **RELATED_BUT_WEAK** | Related by planet/domain/position but does not directly prove the section |
| **UNMAPPED_SIGNAL** | Report signal has no deterministic Canon mapping |
| **INTERNAL_ONLY** | Reserved — all current attachments are internal; structural class used instead |
| **SKIPPED_REMEDY** | Remedy Canon intentionally not attached (count only) |
| **SKIPPED_TAKSA** | Taksa Canon exists; runtime lacks deterministic Taksa keys |
| **SKIPPED_PERIOD_STATUS** | periodStatus Canon exists; runtime mapping incomplete |

---

## 5 · Per-fixture summary (attachments)

| Fixture | Lagna / Lord | Attachments | Refs | Sections w/ evidence |
|---|---|---:|---:|---|
| qa_sample | libra / venus | 30 | 977 | 7 of 8 |
| harness_a | cancer / moon | 23 | 810 | 5 of 8 |
| harness_b | scorpio / mars | 23 | 777 | 5 of 8 |
| harness_c | cancer / moon | 17 | 533 | 5 of 8 |
| harness_d | aquarius / saturn | 23 | 733 | 6 of 8 |
| harness_e | cancer / moon | 18 | 611 | 5 of 8 |
| harness_f | scorpio / mars | 18 | 644 | 5 of 8 |
| harness_g | cancer / moon | 19 | 642 | 5 of 8 |
| **harness_h** | **— / —** | **15** | **489** | **3 of 8** |

---

## 6 · Top unmapped runtime/report keys

| Signal key | Fixture hits |
|---|---|
| `thinkingStyle:myanmar_seven_3` | 6 |
| `coreSelf:myanmar_seven_3` | 5 |
| `strengths:myanmar_seven_3` | 5 |
| `coreSelf:lagna_cancer` | 4 |
| `coreSelf:myanmar_seven_1` | 4 |
| `emotionalWorld:lagna_cancer` | 4 |
| `emotionalWorld:mahabhuta_thaya` | 4 |
| `profile:mahabhuta_position:mahabhuta_thaya` | 4 |
| `relationships:lagna_cancer` | 4 |

**Canon-side unused domains (by unit count):** Remedies (87), Lookup Tables (55) — intentionally not attached.

---

## 7 · False confidence risks

1. **Mahabhut STRONG_MATCH + legacy copy** — structural keys match Canon while Mirror sections still render hardcoded prose.
2. **Life-period structural evidence** — attaches to timeline anchors, not narrative prediction sections consumers read.
3. **Bulk periodStatus prediction rules** — internal metadata only; does not support full prediction prose.
4. **Planet attribute-only refs** — 9 RELATED_BUT_WEAK attachments where attribute evidence could imply stronger section support than exists.

---

## 8 · Integration readiness

| Domain | Readiness |
|---|---|
| Mahabhut position evidence | READY_FOR_INTERNAL_BADGE |
| planet/domain evidence | READY_FOR_INTERNAL_BADGE |
| planet attribute evidence | NEEDS_BETTER_MAPPING |
| life-period structural evidence | READY_FOR_INTERNAL_BADGE |
| prediction rule evidence | INTERNAL_ONLY |
| Taksa evidence | DO_NOT_DISPLAY |
| remedy evidence | DO_NOT_DISPLAY |
| lookup table evidence | INTERNAL_ONLY |

---

## 9 · Remedy / Taksa / periodStatus safety

- Remedy: **SKIPPED_REMEDY** on every fixture (87 units); never attached; never user-facing.
- Taksa: **SKIPPED_TAKSA** (91 units/fixture); `taksaRole.*` in unmapped Canon candidates.
- periodStatus: **SKIPPED_PERIOD_STATUS** (2 notes/fixture); bulk prediction-rule attach is RELATED_BUT_WEAK only.

---

## 10 · Proof public output unchanged

- `ThaiReportCanonEvidenceEnricher.userFacingFingerprint()` unchanged after enrichment (tested).
- Alignment QA code lives under `integration/qa/` — not imported by `ThaiBetaReportPage` or Mirror result UI.
- Full Thai suite: **338 / 338 pass** (327 prior + 11 alignment tests).

---

## 11 · Recommended next phase

**Improve Evidence Mapping**

Rationale: the largest alignment gap is **UNMAPPED_SIGNAL** (99) dominated by lagna sign, Myanmar seven, and `mahabhuta_thaya` runtime keys — not yet wired to frozen Canon. Planet attribute attachments are **RELATED_BUT_WEAK**. Taksa/periodStatus/remedy remain correctly skipped until dedicated runtime mapping phases; weak mapping should be tightened before any internal badge or user-facing seam.

---

## 12 · Related documents

| Document | Role |
|---|---|
| [`THAI_BETA_CANON_EVIDENCE_REVIEW_PANEL.md`](THAI_BETA_CANON_EVIDENCE_REVIEW_PANEL.md) | Internal review UI |
| [`THAI_REPORT_CANON_EVIDENCE_UPGRADE.md`](THAI_REPORT_CANON_EVIDENCE_UPGRADE.md) | Enrichment layer |
