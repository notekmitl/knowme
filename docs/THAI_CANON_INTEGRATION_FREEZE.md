# Thai Canon Integration Freeze

**Phase:** Thai Canon Integration Freeze  
**Status:** **FROZEN / INTERNAL-ONLY**  
**Freeze date:** July 2026  
**Prerequisite commit:** `be82c71` — Internal Evidence Mapping Refresh  
**Validation artifact:** `tool/output/thai_internal_evidence_qa_summary.json`

---

## 1. Freeze declaration

**Thai Canon Integration is frozen as an internal-only evidence and QA baseline.**

This freeze ratifies the completed post-Mahabhut Canon integration stack — from frozen Canon data through evidence mapping, report enrichment, internal review, runtime metadata, Taksa/Khumsap internal mapping, and the final evidence mapping refresh.

**No public Canon evidence display is authorized.**

Evidence attachments, badges, source page references, Taksa rotation metadata, Khumsap internal keys, remedy units, and runtime blockers remain **internal QA metadata only**. They must not appear on consumer Thai report surfaces, Mirror copy, Daily Mirror, or any public UI without an approved disclosure policy phase.

---

## 2. Final validation state

Verified from repository data (`tool/output/thai_internal_evidence_qa_summary.json`) and `flutter test test/validation/thai/` on freeze date:

| Metric | Value | Source |
|--------|------:|--------|
| Thai validation suite | **667 / 667 pass** | `test/validation/thai/` |
| Canon atomic count | **834** | `mappingCoverage.canonAtomicCount` |
| Fixtures audited | **9** | `qa_sample`, `harness_a` … `harness_h` |
| Total evidence attachments | **276** | `evidenceRefresh.totalAttachments` |
| Total evidence refs | **5,494** | `evidenceRefresh.totalEvidenceRefs` |
| Badge mismatches | **0** | `badgeQa.mismatches` |
| Provenance gaps | **0** | `provenanceQa.gaps` |
| All evidence `userFacingAllowed` | **false** | QA pass tests |
| Remedy report attachments | **0** | `remedySafety.remedyAttachmentsOnReport` |
| Remedy public/advice rows | **0** | `remedySafety.remedyUserFacingRows` |
| Skipped remedy units (aggregate) | **783** (87 × 9) | `remedySafety.skippedRemedyCountAggregate` |
| Public fingerprint unchanged | **confirmed** | `userFacingFingerprint` before/after enrichment |
| Consumer timeline unchanged | **confirmed** | No ดวงขึ้น / ดวงตก in public copy |
| Overall QA audit | **passed** | `overallPassed: true` |

---

## 3. Final mapping coverage

| Domain | Coverage | Notes |
|--------|----------|-------|
| Planets | **8 / 9** | `planet.ketu` remains unmapped |
| Mahabhut positions | **7 / 7** | All positions mapped internally |
| Taksa roles | **8 / 8** | Internal metadata keys |
| periodStatus | **2 / 2** | `ดวงขึ้น` / `ดวงตก` internal only |
| Khumsap | **Mapped** | `mahabhutPosition.khumsap` ↔ `mahabhuta_khumsap` |
| `mahabhuta_thaya` | **OUT_OF_CANON_SCOPE** | Not equivalent to Khumsap |
| Remedies | **87 units / fixture** | Internal/hidden only |
| Lookup tables | **56 units** | Reference-only |
| Archetype charts (ontology) | **7 entities** | Canon vocabulary |
| rotationIndex (ontology) | **7 entities** | Canon vocabulary |

### Evidence attachment summary (9 fixtures)

| Metric | Aggregate |
|--------|----------:|
| Out-of-canon-scope signals | **99** |
| Trace-only candidates | **9** |
| Unmapped Canon candidates | **`planet.ketu` only** |
| Taksa evidence attached | **24** |
| Taksa evidence trace-only | **921** |
| Khumsap evidence attached | **112** |
| Khumsap Canon candidates | **387** |

### Badge summary (9 fixtures)

| Badge | Count |
|-------|------:|
| `CANON_SUPPORTED` | 177 |
| `RUNTIME_METADATA_SUPPORTED` | 65 |
| `CANON_DERIVED_INTERNAL` | 10 |
| `OUT_OF_CANON_SCOPE` | 99 |
| `BLOCKED_AMBIGUOUS` | 36 |
| `BLOCKED_SOURCE_CONFLICT` | 12 |
| `INTERNAL_ONLY` | 24 |
| `PARTIAL_CANON_SUPPORT` | 9 |
| `REMEDY_HIDDEN` | 9 |
| `NO_CANON_EVIDENCE` | 0 |

---

## 4. Frozen integration stack (18 components)

| # | Component | Doc |
|---|-----------|-----|
| 1 | Mahabhut Canon frozen dataset | [`THAI_MAHABHUT_CANON_FREEZE.md`](THAI_MAHABHUT_CANON_FREEZE.md) |
| 2a | Post-freeze Patch 001 (remainder6 → นักวิชาการ) | [`THAI_MAHABHUT_CANON_POST_FREEZE_PATCH_001.md`](THAI_MAHABHUT_CANON_POST_FREEZE_PATCH_001.md) |
| 2b | Post-freeze Patch 002 (Monday Taksa rotation) | [`THAI_MAHABHUT_CANON_POST_FREEZE_PATCH_002.md`](THAI_MAHABHUT_CANON_POST_FREEZE_PATCH_002.md) |
| 3 | Canon Evidence Mapping Layer | [`THAI_CANON_EVIDENCE_MAPPING_LAYER.md`](THAI_CANON_EVIDENCE_MAPPING_LAYER.md) |
| 4 | Thai Report Canon Evidence Upgrade | [`THAI_REPORT_CANON_EVIDENCE_UPGRADE.md`](THAI_REPORT_CANON_EVIDENCE_UPGRADE.md) |
| 5 | Internal Canon Evidence Review Panel | [`THAI_BETA_CANON_EVIDENCE_REVIEW_PANEL.md`](THAI_BETA_CANON_EVIDENCE_REVIEW_PANEL.md) |
| 6 | Alignment QA | [`THAI_CANON_EVIDENCE_ALIGNMENT_QA.md`](THAI_CANON_EVIDENCE_ALIGNMENT_QA.md) |
| 7 | Mapping Precision Pass | [`THAI_CANON_EVIDENCE_MAPPING_PRECISION_PASS.md`](THAI_CANON_EVIDENCE_MAPPING_PRECISION_PASS.md) |
| 8 | Period Status Mapping | [`THAI_CANON_PERIOD_STATUS_MAPPING.md`](THAI_CANON_PERIOD_STATUS_MAPPING.md) |
| 9 | Remainder Calculation Metadata | [`THAI_REMAINDER_RUNTIME_METADATA.md`](THAI_REMAINDER_RUNTIME_METADATA.md) |
| 10 | Archetype Context Metadata | [`THAI_ARCHETYPE_CONTEXT_METADATA.md`](THAI_ARCHETYPE_CONTEXT_METADATA.md) |
| 11 | Life Period Position Metadata | [`THAI_LIFE_PERIOD_POSITION_METADATA.md`](THAI_LIFE_PERIOD_POSITION_METADATA.md) |
| 12 | Rise/Fall Runtime Metadata | [`THAI_ENGINE_LIFE_PERIOD_RISE_FALL_METADATA_RERUN.md`](THAI_ENGINE_LIFE_PERIOD_RISE_FALL_METADATA_RERUN.md) |
| 13 | Internal Evidence Badge Prototype | [`THAI_INTERNAL_EVIDENCE_BADGE_PROTOTYPE.md`](THAI_INTERNAL_EVIDENCE_BADGE_PROTOTYPE.md) |
| 14 | Internal Evidence QA Pass | [`THAI_INTERNAL_EVIDENCE_QA_PASS.md`](THAI_INTERNAL_EVIDENCE_QA_PASS.md) |
| 15 | Taksa Runtime Mapping | [`THAI_TAKSA_RUNTIME_MAPPING.md`](THAI_TAKSA_RUNTIME_MAPPING.md) |
| 16 | Taksa Rotation Mapping | [`THAI_TAKSA_ROTATION_MAPPING_FREEZE.md`](THAI_TAKSA_ROTATION_MAPPING_FREEZE.md) |
| 17 | Khumsap Runtime Mapping | [`THAI_KHUMSAP_RUNTIME_MAPPING.md`](THAI_KHUMSAP_RUNTIME_MAPPING.md) |
| 18 | Internal Evidence Mapping Refresh | [`THAI_INTERNAL_EVIDENCE_MAPPING_REFRESH.md`](THAI_INTERNAL_EVIDENCE_MAPPING_REFRESH.md) |

**Internal route:** `/internal/thai-canon-evidence` (admin-guarded)

**Key implementation paths:**

- `lib/features/astrology/thai/knowledge/canon/integration/` — mapping, enrichment, QA
- `lib/features/astrology/thai/knowledge/canon/integration/presentation/` — review panel + badges
- `lib/features/astrology/thai/knowledge/canon/integration/qa/` — alignment + internal evidence QA
- `knowledge/canon/production/foundation_v1.knowme.json` — frozen Canon data (834 atomic units)

---

## 5. Taksa frozen state

### Supported (source-backed)

| Weekday | Status |
|---------|--------|
| Monday (2) | Rotation assignments active (`harness_d`) |
| Tuesday (3) | Rotation assignments active (`qa_sample`, `harness_b`) |

### Blocked / unsupported

| Weekday | Status |
|---------|--------|
| Sunday (1) | `PARTIAL_SOURCE_REVIEW_REQUIRED` — human review required (`harness_g`) |
| Wednesday daytime (4) | `NOT_IN_SOURCE` — separate case (`harness_e`) |
| Wednesday night / Rahu (4) | `NOT_IN_SOURCE` — separate case, not merged with daytime |
| Thursday (5) | `NOT_IN_SOURCE` (`harness_f`) |
| Friday (6) | `NOT_IN_SOURCE` (`harness_c`) |
| Saturday (7) | `NOT_IN_SOURCE` (`harness_a`, `harness_h`) |

**Wednesday daytime and Wednesday night / Rahu remain separate cases.**

**No unsupported weekday is inferred.**

Taksa evidence: 24 attached (Mon/Tue fixtures), 921 trace-only. All Taksa evidence rows `userFacingAllowed = false`.

---

## 6. Khumsap frozen state

| Item | Status |
|------|--------|
| `mahabhutPosition.khumsap` | Mapped to internal key `mahabhuta_khumsap` |
| `mahabhuta_thaya` | **Not** mapped to Khumsap — `OUT_OF_CANON_SCOPE` |
| ทายะ ≠ ขุมทรัพย์ | Explicitly retained — no equivalence |
| Public Khumsap copy | **None added** |
| Public UI | **Unchanged** |
| Khumsap in unmapped candidates | **Removed** (only `planet.ketu` remains) |

Khumsap evidence: 112 attached aggregate across legitimate Mahabhut placement / life-period paths. Zero attachments via `mahabhuta_thaya`.

---

## 7. Runtime metadata frozen state

| Metric | Value |
|--------|------:|
| Remainder metadata | Source-backed from p19 |
| Archetype context metadata | Available |
| Life period position metadata | Partially available |
| Rise/fall runtime metadata | Partially available |
| `lifePeriodsWithRuntimeStatus` | **65** |
| `lifePeriodsWithoutRuntimeStatus` | **21** |
| Ambiguous archetype+planet blockers | **18** |
| Source-conflict blockers | **3** |
| Unique conflicted pair | **1** (`archetypeChart.nakwichakan:planet.jupiter` — ดวงนักวิชาการ Jupiter conflict retained) |

---

## 8. Frozen boundaries

The following boundaries are **mandatory** for all work after this freeze:

- Evidence is **internal QA metadata only**
- Badges are **internal QA indicators only**
- Evidence is **not** prediction copy
- Badges are **not** public confidence scores
- Remedies are **not** user-facing advice
- Source prose is **not** displayed
- Public Thai report output **remains unchanged**
- No public **ดวงขึ้น / ดวงตก** display is authorized
- No public **Taksa** display is authorized
- No public **Khumsap** display is authorized

---

## 9. Known retained limitations

These limitations are **explicitly retained** — not hidden:

| Limitation | Status |
|------------|--------|
| `planet.ketu` | Unmapped Canon candidate |
| Sunday Taksa rotation | Partial / human review required |
| Wednesday daytime Taksa | Not in source |
| Wednesday night / Rahu Taksa | Not in source (separate from daytime) |
| Thursday–Saturday Taksa | Not in source |
| `mahabhuta_thaya` | Out of Canon scope |
| Ambiguous archetype+planet placements | **18** period anchors |
| Source-conflict period anchors | **3** |
| ดวงนักวิชาการ Jupiter conflict | Retained (`archetypeChart.nakwichakan:planet.jupiter`) |
| Life periods without runtime status | **21** |
| Lookup tables | Reference-only (56 units) |
| Remedies | Internal/hidden only (87 units / fixture) |

---

## 10. Post-freeze rules

Future changes to this integration baseline require an **explicit new phase**. Silent changes are forbidden.

| Approved future phase | Scope |
|-----------------------|-------|
| Public Evidence Disclosure Policy | Define what evidence may be shown publicly |
| Taksa Public Presentation Policy | Define public Taksa display rules |
| Remedy Safety / Presentation Policy | Define remedy exposure rules |
| Sunday Taksa Human Source Review | Resolve Sunday partial rotation |
| Ketu Source Review | Resolve `planet.ketu` mapping gap |
| Thai Canon Integration V2 | Major integration revision |
| Mahabhut Canon Post-Freeze Patch 003 | New Canon data patch only |

**No public exposure without approved policy phase.**

**No silent changes** to evidence assignment rules, badge rules, Canon data, engine calculations, or public output.

---

## 11. Recommended next phase

**Public Evidence Disclosure Policy**

**Rationale:** The internal Canon integration stack is now frozen. Before any evidence, badge, or source reference can be shown to users, a public disclosure policy is required to define what can be shown, what must remain hidden, and how to avoid turning Canon evidence into overconfident claims.

**Do not implement public display without that policy phase.**

---

## Related

- [`THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md`](THAI_INTERNAL_EVIDENCE_REVIEW_FREEZE.md) — prior internal evidence stack freeze
- [`THAI_INTERNAL_EVIDENCE_MAPPING_REFRESH.md`](THAI_INTERNAL_EVIDENCE_MAPPING_REFRESH.md) — final QA refresh before this freeze
- [`THAI_MAHABHUT_CANON_FREEZE.md`](THAI_MAHABHUT_CANON_FREEZE.md) — frozen Canon data baseline
- [`THAI_TAKSA_ROTATION_MAPPING_FREEZE.md`](THAI_TAKSA_ROTATION_MAPPING_FREEZE.md) — Taksa rotation partial freeze
- [`THAI_KHUMSAP_RUNTIME_MAPPING.md`](THAI_KHUMSAP_RUNTIME_MAPPING.md) — Khumsap internal mapping record
