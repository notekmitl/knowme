# Thai Public Evidence Badge Internal Only Activation

**Phase:** Controlled Beta Activation — Internal Only  
**Status:** **ACTIVE / INTERNAL ONLY**  
**Activation date:** July 2026  
**Prerequisite commit:** `060789b` — Public Evidence Badge Controlled Beta Freeze  
**Freeze source:** [`THAI_PUBLIC_EVIDENCE_BADGE_CONTROLLED_BETA_FREEZE.md`](THAI_PUBLIC_EVIDENCE_BADGE_CONTROLLED_BETA_FREEZE.md)

---

## 1. Activation status

**LEVEL 1 Public Evidence Badge is ACTIVE for internal testers only.**

| Item | State |
|------|-------|
| Public rollout | **NOT active** |
| Invited beta | **NOT active** |
| All-user rollout | **NOT active** |
| Public evidence release | **NOT authorized** |

---

## 2. Flag state

| Item | Value |
|------|-------|
| Flag name | `thai_public_evidence_badge_beta` |
| Active state | **`internal_only`** |
| Default parse fallback | `off` (when activation config cleared) |
| Invalid / missing | `off` |

### Configuration layers (priority order)

1. **Build-time override:** `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=<state>`
2. **Checked-in activation:** `ThaiEvidenceBadgeActivation.configuredState` = `internal_only`
3. **Fallback:** `off`

### Runtime application

`main()` calls `ThaiEvidenceBadgeFeatureFlag.applyConfiguredState()` at startup.

### Deploy setting

`scripts/deploy_web.ps1` passes:

```
--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=internal_only
```

Emergency rollback without code change:

```
--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=off
```

---

## 3. Allowed audience

| Audience | Badge visible |
|----------|---------------|
| Research admin (`admins/{uid}` allow-list) | **yes** |
| Signed-in normal user | **no** |
| Anonymous user | **no** |
| Invited beta tester (non-admin) | **no** |

Audience resolution: `ThaiBetaEvidenceBadgeAudienceResolver` maps `ThaiResearchAccess.admin` → internal tester. All other access levels → anonymous (blocked).

---

## 4. Allowed surface

| Surface | Badge renders |
|---------|---------------|
| `ThaiBetaReportPage` (Thai Beta Research Result `/beta/thai`) | yes (internal tester + flag) |

### Forbidden surfaces (unchanged)

- `ThaiMirrorResultPage`
- Home
- Daily Mirror
- Public profile/result routes
- Other astrology result pages
- All non-beta routes

---

## 5. Badge content

### Allowed

| Element | Content |
|---------|---------|
| Badge label | **มีแหล่งอ้างอิงใน Canon** |
| Caution copy | ข้อมูลอ้างอิงนี้ใช้เพื่อตรวจสอบที่มาของการวิเคราะห์ ไม่ใช่การการันตีผลลัพธ์ |

### Eligible evidence

- `CANON_SUPPORTED` only
- `mahabhutPosition` or `planetSignification` only

---

## 6. Hidden categories

Not shown during internal-only activation:

- Page references
- Source prose
- Raw Canon unit ids
- Raw ontology ids
- Evidence count
- Confidence scores
- Remedies
- Taksa
- Khumsap
- Rise/fall (ดวงขึ้น / ดวงตก)
- Lookup tables
- Restricted internal badge categories

---

## 7. Rollback method

**Set flag to `off`:**

1. Code rollback: set `ThaiEvidenceBadgeActivation.configuredState` to `null` and redeploy, **or**
2. Deploy override: `--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=off`

After rollback:

- Badge disappears for internal testers on Thai Beta Research Result
- No Canon rollback required
- No engine rollback required
- No copy rollback required
- `flutter test test/validation/thai/` must remain green

---

## 8. Validation result

Verified on activation date:

| Metric | Result |
|--------|--------|
| Thai validation suite | **810 / 810 pass** |
| Activation guard tests | pass |
| Controlled beta QA (frozen baseline) | 0 violations |
| Public fingerprint (non-internal audience) | unchanged |
| Remedies | hidden/internal |

Test file: `test/validation/thai/thai_public_evidence_badge_internal_only_activation_test.dart`

---

## 9. Public isolation proof

| Check | Result |
|-------|--------|
| Normal user on Thai Beta Research Result | no badge panel |
| Anonymous user | no badge panel |
| `ThaiMirrorResultPage` | no badge import/render |
| Home | no badge import |
| Daily Mirror | no badge import |
| Consumer Mirror copy | unchanged |
| `userFacingAllowed` on all evidence | `false` |
| Gate blocks anonymous when flag is `internal_only` | verified |

Public users see the same Thai Beta Research Result mirror content as before. Only the optional badge panel above the mirror renders for research admins.

---

## 10. Recommended next phase

**Internal Only Activation QA**

**Rationale:** The flag is now active for internal testers in code and deploy config. The next step is a focused QA pass on real internal-tester sessions before considering invited beta or any broader exposure.

---

## Implementation inventory

| Component | Path |
|-----------|------|
| Activation config | `lib/features/thai_beta/application/thai_evidence_badge_activation.dart` |
| Feature flag | `lib/features/thai_beta/application/thai_evidence_badge_feature_flag.dart` |
| Audience resolver | `lib/features/thai_beta/application/thai_beta_evidence_badge_audience_resolver.dart` |
| Report surface | `lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart` |
| Startup hook | `lib/main.dart` |
| Deploy config | `scripts/deploy_web.ps1` |

---

**Not public release. Invited beta not active. Normal users unchanged.**
