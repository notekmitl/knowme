# Thai Public Evidence Badge Internal Only Activation Freeze

**Phase:** Internal Only Activation Freeze  
**Status:** **FROZEN / ACTIVE INTERNAL ONLY**  
**Freeze date:** July 2026  
**Prerequisite commit:** `1e01fee` — Public Evidence Badge Rollback Drill  
**Activation source:** [`THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION.md`](THAI_PUBLIC_EVIDENCE_BADGE_INTERNAL_ONLY_ACTIVATION.md)  
**QA artifact:** `tool/output/thai_public_evidence_badge_internal_only_activation_qa_summary.json`  
**Rollback artifact:** `tool/output/thai_public_evidence_badge_rollback_drill_summary.json`

---

## 1. Freeze declaration

**Public Evidence Badge Internal Only Activation is frozen.**

This freeze ratifies the official active baseline for LEVEL 1 Canon evidence badges visible only to research admins on Thai Beta Research Result.

**Current state:**

| Item | Status |
|------|--------|
| Internal admin activation | **active** |
| Invited beta | **not active** |
| Public rollout | **not active** |
| Public evidence release | **not authorized** |

---

## 2. Final validation record

Verified from repository data and `flutter test test/validation/thai/` on freeze date:

| Metric | Value | Source |
|--------|------:|--------|
| Thai validation suite | **857 / 857 pass** | `test/validation/thai/` |
| Internal-only activation QA | **PASS** | `thai_public_evidence_badge_internal_only_activation_qa_summary.json` |
| Rollback drill | **PASS** | `thai_public_evidence_badge_rollback_drill_summary.json` |
| Public output unchanged | **PASS** | QA + rollback drill |
| Leakage violations | **0** | Both artifacts |
| Eligibility violations | **0** | Activation QA |
| Copy safety violations | **0** | Activation QA |
| Data leakage violations | **0** | Activation QA |
| Fixtures audited | **9** | 91 eligible beta badges aggregate |
| Rollback off | **PASS** | Rollback drill |
| Re-enable `internal_only` | **PASS** | Rollback drill |

---

## 3. Active configuration

| Item | Value |
|------|-------|
| Feature flag | `thai_public_evidence_badge_beta` |
| **Current active state** | **`internal_only`** |
| Rollback state | `off` |
| Allowed states | `off`, `internal_only`, `invited_beta` |

**Only `internal_only` is active in this freeze.** `invited_beta` is defined but not enabled.

Configuration layers:

1. `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=<state>` (deploy override)
2. `ThaiEvidenceBadgeActivation.configuredState` = `internal_only`
3. Fallback parse → `off`

Implementation: `lib/features/thai_beta/application/thai_evidence_badge_activation.dart`, `thai_evidence_badge_feature_flag.dart`

---

## 4. Active audience

| Audience | Badge visible |
|----------|---------------|
| Research admin (`admins/{uid}`) | **yes** |
| Normal signed-in user | **no** |
| Anonymous user | **no** |
| Invited-beta-only user | **no** |

Resolution: `ThaiBetaEvidenceBadgeAudienceResolver` maps `ThaiResearchAccess.admin` → internal tester.

---

## 5. Active surface

### Active

| Surface | Route |
|---------|-------|
| `ThaiBetaReportPage` | `/beta/thai` (Thai Beta Research Result) |

### Not active

| Surface | Status |
|---------|--------|
| `ThaiMirrorResultPage` | no badge |
| Home | no badge |
| Daily Mirror | no badge |
| Public profile/result routes | no badge |
| Other astrology result pages | no badge |
| All non-beta routes | no badge |

---

## 6. Badge content

### Shown to admin (LEVEL 1 only)

| Element | Content |
|---------|---------|
| Label | **มีแหล่งอ้างอิงใน Canon** |
| Caution copy | ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์ |

### Not shown

- Source page
- Source prose
- Raw Canon unit id
- Ontology id
- Confidence score / percentage
- Remedies
- Taksa
- Khumsap
- ดวงขึ้น / ดวงตก
- Lookup tables / conflict / ambiguity detail

Eligible evidence: `CANON_SUPPORTED` + `mahabhutPosition` / `planetSignification` only.

---

## 7. Rollback record

**Rollback = set flag to `off`**

Proven by rollback drill (`1e01fee`):

| Result | Status |
|--------|--------|
| Admin badge hidden | pass |
| Normal / anonymous / invited-only still blocked | pass |
| Canon rollback required | **no** |
| Engine rollback required | **no** |
| Copy rollback required | **no** |
| Public UI rollback required | **no** |
| Re-enable `internal_only` restores admin badge | pass |

Methods: `ThaiEvidenceBadgeActivation.configuredState = null`, or `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=off`

---

## 8. Frozen boundaries

This freeze is **not**:

- Public release
- Invited beta release
- All-user rollout

Still **forbidden**:

- Source page display
- Source prose display
- Remedy display
- Taksa display
- Khumsap display
- Rise/fall (ดวงขึ้น / ดวงตก) display
- Evidence rule changes without named phase
- Badge eligibility rule changes without named phase

---

## 9. Known retained risks

| Risk | Severity |
|------|----------|
| Accidental global flag enablement (`invited_beta` or unintended `off`) | medium |
| Invited tester registry misconfiguration | low |
| Future surface expansion without re-QA | medium |
| Telemetry production wiring without review | low |
| Public misunderstanding if badge copy changes later | medium |

---

## 10. Post-freeze rules

Future changes require an explicit named phase. **No silent changes.**

| Authorized future phase | Purpose |
|-------------------------|---------|
| Controlled Beta Activation — Invited Beta Plan | Plan invited beta (not implement in freeze) |
| Controlled Beta Activation — Invited Beta | Enable invited beta testers |
| Public Evidence Badge UX Review | Copy/layout review |
| Public Evidence Badge Rollback Drill V2 | Operational re-validation |
| Public Evidence Badge Public Rollout Policy | Policy for any public exposure |
| Public Evidence Disclosure Policy V2 | Policy revision |

---

## 11. Recommended next phase

**Controlled Beta Activation — Invited Beta Plan**

**Rationale:** After internal-only activation is frozen, the safest next step is to **plan** invited beta exposure — not enable it immediately.

**Do not implement invited beta in this freeze commit.**

---

## Frozen stack inventory

| Component | Path |
|-----------|------|
| Activation config | `lib/features/thai_beta/application/thai_evidence_badge_activation.dart` |
| Feature flag | `lib/features/thai_beta/application/thai_evidence_badge_feature_flag.dart` |
| Audience resolver | `lib/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart` |
| Beta gate | `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart` |
| Report surface | `lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart` |
| Activation QA | `test/validation/thai/thai_public_evidence_badge_internal_only_activation_qa_test.dart` |
| Rollback drill | `test/validation/thai/thai_public_evidence_badge_rollback_drill_test.dart` |

---

**Public Thai output unchanged for non-admin users. Internal-only activation frozen. Not public release.**
