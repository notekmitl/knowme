# Thai Beta Canon Evidence Review Panel

> **Scope:** Internal QA/review tooling only — no engine, Mirror copy, or Canon changes.
>
> **Prerequisites:** Canon Freeze `2a44ac4` · Evidence Mapping `4c5a584` · Report
> Evidence Upgrade `4467ca8`

Status: **COMPLETE** · Admin-guarded internal route only.

---

## 1 · What the panel shows

Route: **`/internal/thai-canon-evidence`**

Guard: [`ThaiResearchAdminGuard`](../../lib/features/thai_beta/presentation/admin/thai_research_admin_guard.dart) (same allow-list as `/internal/thai-beta` and `/internal/knowledge`).

| Section | Content |
|---|---|
| **Header** | Sample QA birth profile summary, attachment/ref totals |
| **Coverage cards** | Counts by evidence type + skipped/unmapped metrics |
| **Evidence table** | Flattened refs: section, signal, type, subject, relation, object, context, page, user-facing flag |
| **Trace panel** | Signals without evidence, unmapped candidates, remedy/Taksa/periodStatus skips |

Default data source: `ThaiMirrorPipeline.sampleQaBirthData()` enriched via
`ThaiReportCanonEvidenceEnricher`.

No source prose is displayed — page references only.

---

## 2 · Access boundary

- **Not linked** from consumer Home, Thai beta report, or Thai Mirror result UI.
- Reachable only by navigating to `/internal/thai-canon-evidence` directly.
- Requires signed-in admin (`ThaiResearchAccess.admin`).
- Signed-out users see login; non-admins see access denied.

Files:

- `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_review_page.dart`
- `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_canon_evidence_routes.dart`
- Registered in `main.dart` `onGenerateRoute` chain.

---

## 3 · Remedy safety boundary

- Remedy Canon is **not** attached to report sections.
- Panel shows **skipped count only** (`Remedy skipped: 87`) — not procedure text.
- Trace label: *"Remedy evidence skipped (internal count only — not advice)"*.
- All table rows show `UF: no` (`userFacingAllowed: false`).
- No remedy recommendation copy is generated.

---

## 4 · What remains unmapped (visible in trace)

| Category | Visible as |
|---|---|
| Lagna / Myanmar signals | `signalsWithoutCanonEvidence` list |
| `taksaRole.*` | `unmappedCanonEvidenceCandidates` + Taksa skipped count |
| `periodStatus.*` | `skippedPeriodStatusNotes` |
| `planet.ketu` | `unmappedCanonEvidenceCandidates` |
| Remedy units | Skipped count only (not listed as attachments) |

---

## 5 · Report areas with / without Canon evidence

**With evidence (QA sample profile):**

- Mahabhut position keys (section + profile signals)
- Lagna-lord planet significations (`owns` + `attribute.*`)
- Life timeline periods (`located_in` @ `life_period`)
- Prediction rules (internal attachment)

**Still hardcoded (no Canon attachment):**

- Mirror narrative / hero / insight copy
- Lagna sign prose
- Myanmar seven prose
- Consumer prediction display text

---

## 6 · Proof user-facing output did not change

Tests (`thai_canon_evidence_review_panel_test.dart`):

- `userFacingFingerprint` identical before/after enrichment
- `ThaiBetaReportPage` and `ThaiMirrorResultPage` do **not** import review panel
- Full Thai suite: **327 / 327 pass** (317 prior + 10 panel tests)

Enrichment runs **after** pipeline generation; pipeline objects are not mutated.

---

## 7 · Recommended next phase

**Thai Engine Canon Integration (evidence-only seam)**

Optional metadata slot on engine signals / interpretation facts referencing
`ThaiCanonEvidenceAttachment` — still without changing calculations or Mirror copy.

Alternatively: QA-flagged source-transparency UI that reads attachments only when
explicitly enabled internally.

---

## 8 · Related documents

| Document | Role |
|---|---|
| [`THAI_REPORT_CANON_EVIDENCE_UPGRADE.md`](THAI_REPORT_CANON_EVIDENCE_UPGRADE.md) | Enrichment layer |
| [`THAI_CANON_EVIDENCE_MAPPING_LAYER.md`](THAI_CANON_EVIDENCE_MAPPING_LAYER.md) | Loader / index / mapper |
