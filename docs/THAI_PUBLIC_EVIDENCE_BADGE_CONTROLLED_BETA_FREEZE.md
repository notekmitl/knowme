# Thai Public Evidence Badge Controlled Beta Freeze

**Phase:** Public Evidence Badge Controlled Beta Freeze  
**Status:** **FROZEN / FLAGGED OFF BY DEFAULT**  
**Freeze date:** July 2026  
**Prerequisite commit:** `bd11c3d` — Public Evidence Badge Controlled Beta QA  
**Policy source:** [`THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md`](THAI_PUBLIC_EVIDENCE_DISCLOSURE_POLICY_FREEZE.md)  
**QA artifact:** `tool/output/thai_public_evidence_badge_controlled_beta_qa_summary.json`

---

## 1. Freeze declaration

**Public Evidence Badge Controlled Beta is frozen as FLAGGED OFF BY DEFAULT.**

This freeze ratifies the official controlled-beta baseline — feature flag, audience gating, Thai Beta Research Result surface, LEVEL 1 badge renderer, eligibility filter, safety copy, data leakage guard, telemetry safety, rollback behavior, and QA report — as completed safe infrastructure.

**No public rollout is active.**

Public evidence display on consumer Thai surfaces remains forbidden. The feature flag `thai_public_evidence_badge_beta` remains **off** by default. No tester activation is authorized inside this freeze.

---

## 2. Final validation record

Verified from repository data (`tool/output/thai_public_evidence_badge_controlled_beta_qa_summary.json`) and `flutter test test/validation/thai/` on freeze date:

| Metric | Value | Source |
|--------|------:|--------|
| Thai validation suite | **791 / 791 pass** | `test/validation/thai/` |
| Fixtures audited | **9** | `qa_sample`, `harness_a` … `harness_h` |
| Eligible beta badges (aggregate) | **91** | QA JSON `totalEligibleBetaBadges` |
| Feature flag QA | **PASS** | QA JSON `flagQaPassed: true` |
| Audience gating QA | **PASS** | QA JSON `audienceGatingPassed: true` |
| Surface isolation QA | **PASS** | QA tests + import audits |
| Eligibility QA | **PASS** | QA JSON `totalEligibilityViolations: 0` |
| Copy safety QA | **PASS** | QA JSON `totalCopySafetyViolations: 0` |
| Data leakage QA | **PASS** | QA JSON `totalDataLeakageViolations: 0` |
| Telemetry safety QA | **PASS** | QA JSON `telemetrySafe: true` |
| Rollback QA | **PASS** | QA tests + `defaultFlagOff: true` |
| Public output regression | **PASS** | QA JSON `publicFingerprintUnchanged: true` |
| Remedies hidden | **true** | QA JSON `remediesHidden: true` |
| Default flag state | **off** | QA JSON `defaultFlagState: "off"` |
| Overall QA audit | **PASS** | QA JSON `overallPassed: true` |

### Per-fixture eligible beta badges

| Fixture | Eligible beta badges | QA passed |
|---------|---------------------:|-----------|
| qa_sample | 19 | yes |
| harness_a | 12 | yes |
| harness_b | 12 | yes |
| harness_c | 7 | yes |
| harness_d | 13 | yes |
| harness_e | 8 | yes |
| harness_f | 8 | yes |
| harness_g | 8 | yes |
| harness_h | 4 | yes |
| **Aggregate** | **91** | **yes** |

---

## 3. Frozen feature flag behavior

| Item | Value |
|------|-------|
| Flag name | `thai_public_evidence_badge_beta` |
| Default state | **off** |
| Allowed states | `off`, `internal_only`, `invited_beta` |

### Rules (frozen)

| Condition | Behavior |
|-----------|----------|
| Missing flag | `off` |
| Invalid flag | `off` |
| `off` | No badges anywhere |
| `internal_only` | Badge renders only for internal tester audience on Thai Beta Research Result |
| `invited_beta` | Badge renders only for invited beta tester audience on Thai Beta Research Result |
| Anonymous users | Blocked for all non-off states |
| Normal users | Blocked for all non-off states |
| Internal tester under `invited_beta` | Blocked unless in invited-beta audience |

Implementation: `lib/features/thai_beta/application/thai_evidence_badge_feature_flag.dart`, `thai_public_evidence_badge_beta_gate.dart`

---

## 4. Frozen surface boundary

### Allowed surface

| Surface | Route context | Condition |
|---------|---------------|-----------|
| `ThaiBetaReportPage` | Thai Beta Research Result (`/beta/thai`) | Flag + audience allow |

### Forbidden surfaces (no badge import or render)

| Surface | Status |
|---------|--------|
| `ThaiMirrorResultPage` | forbidden |
| Home (`home_page.dart`) | forbidden |
| Daily Mirror (`daily_mirror_section.dart`) | forbidden |
| Public profile/result routes | forbidden |
| Other astrology result pages | forbidden |
| All non-beta routes | forbidden |

Public route imports must not pull beta badge UI into public main result.

---

## 5. Frozen eligibility boundary

### Allowed (LEVEL 1 only)

| Requirement | Rule |
|-------------|------|
| Internal badge | `CANON_SUPPORTED` only |
| Evidence type | `mahabhutPosition` or `planetSignification` |
| Disclosure level | LEVEL 1 — public summary badge |
| Beta label | Fixed: `มีแหล่งอ้างอิงใน Canon` |

### Forbidden (never produce beta badge)

| Category | Status |
|----------|--------|
| Khumsap | forbidden |
| Taksa | forbidden |
| Rise/fall (ดวงขึ้น / ดวงตก) | forbidden |
| Remedies | forbidden |
| Lookup tables | forbidden |
| `RUNTIME_METADATA_SUPPORTED` | forbidden |
| `CANON_DERIVED_INTERNAL` | forbidden |
| `PARTIAL_CANON_SUPPORT` | forbidden |
| `OUT_OF_CANON_SCOPE` | forbidden |
| `BLOCKED_AMBIGUOUS` | forbidden |
| `BLOCKED_SOURCE_CONFLICT` | forbidden |
| `INTERNAL_ONLY` | forbidden |
| `REMEDY_HIDDEN` | forbidden |
| `NO_CANON_EVIDENCE` | forbidden |

Implementation: `thai_public_evidence_badge_beta_mapper.dart` (wraps frozen preview mapper)

---

## 6. Frozen badge copy

### Allowed badge label

> มีแหล่งอ้างอิงใน Canon

### Required caution copy (every badge panel)

> ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์

### Forbidden in badge output

- Certainty language (แม่นแน่นอน, ฟันธง, พิสูจน์แล้ว, การันตี, แน่นอน, etc.)
- Confidence percentages
- Page references
- Source prose
- Raw Canon unit ids
- Raw ontology ids
- Remedy text
- Taksa labels
- Khumsap labels
- ดวงขึ้น / ดวงตก

**Exception:** Negated `การันตี` in required caution copy (`ไม่ใช่การการันตีผลลัพธ์`) is policy-approved.

---

## 7. Frozen telemetry boundary

| Item | Rule |
|------|------|
| Production analytics | **Not enabled** |
| Default hook | `ThaiEvidenceBadgeBetaTelemetry.onEvent` = null (local/stub only) |

### Allowed event names only

- `thai_evidence_badge_rendered`
- `thai_evidence_badge_seen`
- `thai_evidence_badge_feedback_started`

### Allowed props

- `sectionId` only

### Forbidden in telemetry

- Canon unit ids
- Raw evidence refs
- Source pages
- Source prose
- Remedy data
- Birth date / birth time / exact birth place
- User sensitive data
- Prediction content

Implementation: `lib/features/thai_beta/application/thai_evidence_badge_beta_telemetry.dart`

---

## 8. Rollback rule

**Rollback = set flag to `off`.**

After rollback:

1. Badge disappears from Thai Beta Research Result
2. No Canon rollback needed
3. No engine rollback needed
4. No copy rollback needed
5. Thai validation suite remains green
6. Public fingerprint remains unchanged

No other rollback steps are required.

---

## 9. Known retained risks

| Risk | Severity | Notes |
|------|----------|-------|
| Accidental global flag enablement | medium | Default remains `off`; activation requires explicit phase |
| Invited tester registry misconfiguration | low | Anonymous always blocked; registry is explicit |
| Future surface expansion without re-QA | medium | Import audits and surface tests in CI |
| Telemetry wired to production without review | low | Stub-only default documented |
| Public users may misinterpret badge if rollout copy is changed later | medium | Copy is frozen; changes require explicit phase |

---

## 10. Post-freeze rules

Future changes require an explicit phase. **No silent changes. No flag activation inside this freeze.**

| Authorized future phase | Purpose |
|-------------------------|---------|
| Controlled Beta Activation — Internal Only | Enable flag for internal testers only |
| Controlled Beta Activation — Invited Beta | Enable flag for invited beta testers |
| Public Evidence Badge UX Review | Copy/layout review before wider exposure |
| Public Evidence Badge Rollback Drill | Operational rollback validation |
| Public Evidence Badge V2 | Next implementation iteration |
| Public Evidence Disclosure Policy V2 | Policy revision |

Changes to eligibility rules, evidence rules, Canon data, engine logic, public UI surfaces, or default flag state are **not authorized** without a named phase.

---

## 11. Recommended next phase

**Controlled Beta Activation — Internal Only**

**Rationale:** The implementation and QA are frozen. The safest next step is to enable the feature only for internal testers first (`internal_only`), not invited beta users yet. Do not activate the flag in this freeze commit.

---

## Frozen stack inventory

| Component | Path |
|-----------|------|
| Feature flag | `lib/features/thai_beta/application/thai_evidence_badge_feature_flag.dart` |
| Audience gating | `lib/features/thai_beta/application/thai_beta_evidence_badge_audience.dart` |
| Beta gate | `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart` |
| Beta mapper | `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_mapper.dart` |
| Beta view model | `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_view_model.dart` |
| Badge panel | `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart` |
| Surface | `lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart` |
| Telemetry | `lib/features/thai_beta/application/thai_evidence_badge_beta_telemetry.dart` |
| QA validator | `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_controlled_beta_qa_validator.dart` |
| QA runner | `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_controlled_beta_qa_runner.dart` |
| QA report | `lib/features/astrology/thai/knowledge/canon/integration/qa/thai_public_evidence_badge_controlled_beta_qa_report.dart` |
| QA tests | `test/validation/thai/thai_public_evidence_badge_controlled_beta_qa_test.dart` |

---

**Public Thai output unchanged when flag is off. Public evidence badge is NOT released to all users. Controlled beta is NOT active.**
