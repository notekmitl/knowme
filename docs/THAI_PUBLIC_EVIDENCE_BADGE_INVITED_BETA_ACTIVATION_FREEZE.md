# Thai Public Evidence Badge Invited Beta Activation Freeze

**Phase:** Invited Beta Activation Freeze  
**Status:** **FROZEN / ACTIVE INVITED BETA**  
**Freeze date:** July 2026  
**Prerequisite commit:** `dce5931` — Public Evidence Badge Invited Beta Activation QA  
**Activation source:** [`THAI_PUBLIC_EVIDENCE_BADGE_INVITED_BETA_IMPLEMENTATION.md`](THAI_PUBLIC_EVIDENCE_BADGE_INVITED_BETA_IMPLEMENTATION.md)  
**QA artifact:** `tool/output/thai_public_evidence_badge_invited_beta_activation_qa_summary.json`  
**Rollback artifact:** `tool/output/thai_public_evidence_badge_rollback_drill_summary.json`

---

## 1. Freeze declaration

**Public Evidence Badge Invited Beta Activation is frozen.**

This freeze ratifies the official active baseline for LEVEL 1 Canon evidence badges visible only to signed-in invited beta testers on Thai Beta Research Result.

**Current state:**

| Item | Status |
|------|--------|
| Invited beta activation | **active** |
| Public rollout | **not active** |
| All-user rollout | **not active** |
| Public evidence release | **not authorized** |

---

## 2. Final validation record

Verified from repository data and `flutter test test/validation/thai/` on freeze date:

| Metric | Value | Source |
|--------|------:|--------|
| Thai validation suite | **907 / 907 pass** | `test/validation/thai/` |
| Invited Beta Activation QA | **PASS** | `thai_public_evidence_badge_invited_beta_activation_qa_summary.json` |
| Rollback drill | **PASS** | `thai_public_evidence_badge_rollback_drill_summary.json` |
| Public output unchanged | **PASS** | Activation QA + rollback drill |
| Eligibility violations | **0** | Activation QA |
| Copy safety violations | **0** | Activation QA |
| Data leakage violations | **0** | Activation QA |
| Fixtures audited | **9** | 91 eligible beta badges aggregate |
| Rollback `off` | **PASS** | Activation QA + rollback drill |
| `internal_only` admin gate preserved | **PASS** | Activation QA |

---

## 3. Active configuration

| Item | Value |
|------|-------|
| Feature flag | `thai_public_evidence_badge_beta` |
| **Current active state** | **`invited_beta`** |
| Rollback state | `off` |
| Allowed states | `off`, `internal_only`, `invited_beta` |

**Only `invited_beta` is active in this freeze.** Public rollout and all-user rollout are not enabled.

Configuration layers:

1. `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=<state>` (deploy override)
2. `ThaiEvidenceBadgeActivation.configuredState` = `invited_beta`
3. Fallback parse → `off`

Implementation: `lib/features/thai_beta/application/thai_evidence_badge_activation.dart`, `thai_evidence_badge_feature_flag.dart`

---

## 4. Active audience

| Audience | Badge visible under `invited_beta` |
|----------|----------------------------------|
| Signed-in invited beta tester (on allow-list) | **yes** |
| Anonymous user | **no** |
| Normal signed-in user (not on list) | **no** |
| Research admin (not on invite list) | **no** |

Resolution: `ThaiBetaEvidenceBadgeAudienceResolver` + `ThaiBetaInvitedTesterRegistry.isInvited(uid)`.

Admin does not inherit invited-beta access unless explicitly on the allow-list. Restore admin-only visibility by switching flag to `internal_only`.

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

### Shown to invited beta tester (LEVEL 1 only)

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

Proven by activation QA and rollback drill:

| Result | Status |
|--------|--------|
| Invited beta badge hidden | pass |
| Admin badge hidden | pass |
| Normal user badge hidden | pass |
| Anonymous badge hidden | pass |
| Canon rollback required | **no** |
| Engine rollback required | **no** |
| Copy rollback required | **no** |
| Public UI rollback required | **no** |
| Re-enable `internal_only` restores admin-only badge | pass |

Methods: `ThaiEvidenceBadgeActivation.configuredState = null`, or `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=off`

---

## 8. Frozen boundaries

This freeze is **not**:

- Public release
- All-user rollout
- Premium or global badge rollout

Still **forbidden**:

- Source page display
- Source prose display
- Remedy display
- Taksa display
- Khumsap display
- Rise/fall (ดวงขึ้น / ดวงตก) display
- Evidence rule changes without named phase
- Badge eligibility rule changes without named phase
- Feature flag logic changes without named phase

---

## 9. Known retained risks

| Risk | Severity |
|------|----------|
| Invited tester registry misconfiguration | medium |
| Accidental all-user flag enablement | medium |
| Future surface expansion without re-QA | medium |
| Telemetry production wiring without review | low |
| Public misunderstanding if badge copy changes later | medium |
| Firestore-backed registry not yet wired — manual uid seeding required | medium |

---

## 10. Post-freeze rules

Future changes require an explicit named phase. **No silent changes.**

| Authorized future phase | Purpose |
|-------------------------|---------|
| Public Evidence Badge Rollout Monitoring | Monitor invited-beta usage in production |
| Public Evidence Badge UX Review | Copy/layout review |
| Public Evidence Badge Rollback Drill V2 | Operational re-validation |
| Public Evidence Badge Public Rollout Plan | Plan any public exposure |
| Public Evidence Disclosure Policy V2 | Policy revision |

---

## 11. Recommended next phase

**Public Evidence Badge Rollout Monitoring**

**Rationale:** After invited beta activation is frozen, the safest next step is to **monitor real invited-beta usage** before any public expansion — not enable public rollout immediately.

**Do not implement public rollout in this freeze commit.**

---

## Frozen stack inventory

| Component | Path |
|-----------|------|
| Activation config | `lib/features/thai_beta/application/thai_evidence_badge_activation.dart` |
| Feature flag | `lib/features/thai_beta/application/thai_evidence_badge_feature_flag.dart` |
| Invited tester registry | `lib/features/thai_beta/application/thai_beta_invited_tester_registry.dart` |
| Audience resolver | `lib/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart` |
| Beta gate | `lib/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart` |
| Report surface | `lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart` |
| Activation QA | `test/validation/thai/thai_public_evidence_badge_invited_beta_activation_qa_test.dart` |
| Rollback drill | `test/validation/thai/thai_public_evidence_badge_rollback_drill_test.dart` |

---

**Public Thai output unchanged for non-invited users. Invited-beta activation frozen. Not public release.**
