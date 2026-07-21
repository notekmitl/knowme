# Thai Public Evidence Badge Rollout Monitoring

**Phase:** Public Evidence Badge Rollout Monitoring  
**Status:** **ACTIVE / INVITED BETA ONLY**  
**Date:** July 2026  
**Prerequisite commit:** `7265c5f` — Public Evidence Badge Invited Beta Activation Freeze  
**Freeze source:** [`THAI_PUBLIC_EVIDENCE_BADGE_INVITED_BETA_ACTIVATION_FREEZE.md`](THAI_PUBLIC_EVIDENCE_BADGE_INVITED_BETA_ACTIVATION_FREEZE.md)  
**Monitoring template:** `tool/output/thai_public_evidence_badge_rollout_monitoring_template.json`  
**Implementation:** `lib/features/thai_beta/application/thai_evidence_badge_rollout_monitoring.dart`

---

## 1. Monitoring objective

Track invited-beta usage and safety signals after LEVEL 1 evidence badge activation — **without expanding rollout**.

Goals:

- Detect misunderstanding (badge interpreted as guarantee / ฟันธง)
- Detect safety signals (remedy requests, source text requests, overconfidence)
- Track aggregate technical health (render counts, errors, leakage)
- Maintain rollback readiness at all times

**Not in scope:** public rollout, all-user rollout, new surfaces, Canon/engine/copy changes.

---

## 2. Current active state

| Item | Status |
|------|--------|
| Feature flag | `thai_public_evidence_badge_beta` = **`invited_beta`** |
| Invited beta activation | **active** (frozen) |
| Public release | **not active** |
| All-user rollout | **not active** |
| Active surface | `ThaiBetaReportPage` (`/beta/thai`) only |
| Active audience | signed-in uid on `ThaiBetaInvitedTesterRegistry` allow-list |
| Anonymous / normal / admin-not-on-list | **no badge** |

---

## 3. Metrics to monitor

### User understanding (qualitative)

Track whether invited beta testers interpret the badge as:

| Correct understanding | Misinterpretation |
|----------------------|-------------------|
| มีแหล่งอ้างอิง | แม่นแน่นอน |
| ตรวจสอบที่มาได้ | ฟันธง |
| เพิ่มความน่าเชื่อถือพอดี | การันตีผล |
| | ถูก 100% |

### Technical (aggregate only)

| Metric | Description |
|--------|-------------|
| `badgeRenderedCount` | Total LEVEL 1 badge renders on `/beta/thai` |
| `eligibleBadgeCount` | Eligible CANON_SUPPORTED badges per session aggregate |
| `hiddenCategoryCount` | Remedy/Taksa/Khumsap/rise-fall blocked count |
| `featureFlagState` | Must remain `invited_beta` unless rollback |
| `invitedBetaAudienceCount` | Count of uids on allow-list (aggregate) |
| `errorCount` | Render/gate errors |
| `leakageIncidents` | Badge or forbidden content outside `/beta/thai` |
| `rollbackReadiness` | Flag can be set to `off` immediately |

### Feedback aggregates

| Metric | Description |
|--------|-------------|
| `confusionReports` | Reports of not understanding Canon / badge |
| `overconfidenceReports` | Reports badge felt like guarantee |
| `remedySourceRequests` | Requests for remedy or source text after seeing badge |

---

## 4. Safety signals

Monitor and escalate if observed:

- User asks how to **fix chart / remedy** after seeing badge
- User asks for **source text / book page image**
- User believes badge = **guaranteed accuracy**
- User feels result is **too deterministic / ฟันธง**
- User confused about what **Canon** means
- Increase in support tickets mentioning **การันตี** or **100%**
- Any telemetry suggesting badge on non-beta route

---

## 5. Feedback questions

Thai questions for invited beta feedback sessions:

1. คุณเข้าใจ badge “มีแหล่งอ้างอิงใน Canon” ว่าอย่างไร?
2. คุณคิดว่า badge นี้หมายถึง “แม่นแน่นอน” หรือไม่?
3. badge นี้ช่วยให้คุณไว้ใจที่มาของการวิเคราะห์มากขึ้นไหม?
4. badge นี้ทำให้ผลดูฟันธงเกินไปไหม?
5. คุณอยากเห็นแค่ badge พอไหม หรืออยากเห็นหน้าอ้างอิงด้วย?
6. มีส่วนไหนที่ทำให้เข้าใจผิดไหม?

Record only **aggregate themes** — not verbatim answers with PII in monitoring payloads.

---

## 6. Stop criteria

**Immediate rollback** — set `thai_public_evidence_badge_beta` to **`off`** if any occur:

| Stop criterion | ID |
|----------------|-----|
| Badge leaked to public surface | `badge_leaked_to_public_surface` |
| Normal user saw badge | `normal_user_saw_badge` |
| Anonymous saw badge | `anonymous_saw_badge` |
| Source prose leaked | `source_prose_leaked` |
| Remedy leaked | `remedy_leaked` |
| Taksa / Khumsap / rise-fall leaked | `taksa_khumsap_rise_fall_leaked` |
| Majority interprets badge as guarantee | `majority_interprets_badge_as_guarantee` |
| Forbidden wording appeared | `forbidden_wording_appeared` |
| Fingerprint regression failed | `fingerprint_regression_failed` |
| Feature flag or allow-list bypass | `feature_flag_or_allow_list_bypass` |

---

## 7. Rollback rule

**Rollback = set flag to `off`**

```text
--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=off
```

Or clear `ThaiEvidenceBadgeActivation.configuredState`.

After rollback:

- Invited beta → no badge
- Admin → no badge (unless flag switched to `internal_only` separately)
- Normal / anonymous → no badge
- No Canon / engine / copy / public UI rollback required

Set `rollbackNeeded: true` in monitoring report when any stop criterion triggers.

---

## 8. Data privacy boundary

**Forbidden in monitoring payloads, telemetry, and reports:**

| Category | Examples |
|----------|----------|
| Birth data | birth date, birth time, exact birth place |
| Canon internals | raw unit id, ontology id, source page |
| Content | source prose, prediction text |
| Sensitive domains | remedy data, Taksa, Khumsap |
| Identity | email, uid, userId (use aggregate counts only) |

**Allowed:** aggregate counts, flag state, surface name, date, boolean flags, theme categories.

Enforced by `ThaiEvidenceBadgeRolloutMonitoring.isPayloadPrivacySafe()`.

Existing beta telemetry remains limited to:

- `thai_evidence_badge_rendered` (sectionId only)
- `thai_evidence_badge_seen` (sectionId only)
- `thai_evidence_badge_feedback_started` (no props)

---

## 9. Monitoring report format

Use `tool/output/thai_public_evidence_badge_rollout_monitoring_template.json` as the base.

### Required fields per cycle

| Field | Type | Notes |
|-------|------|-------|
| `reportDate` | ISO date | Monitoring cycle date |
| `testerCount` | int | Invited testers active in period |
| `badgeRenderedCount` | int | Aggregate renders |
| `confusionReports` | int | Thematic confusion count |
| `overconfidenceReports` | int | Guarantee misinterpretation count |
| `remedySourceRequests` | int | Remedy/source request count |
| `leakageIncidents` | int | Must be 0 |
| `rollbackNeeded` | bool | true if any stop criterion hit |

### Example report naming

`tool/output/thai_public_evidence_badge_rollout_monitoring_report_01.json`

---

## 10. Recommended next phase

**Invited Beta Monitoring Report 01**

Rationale: Monitoring framework is active. The next step is to produce the first real aggregate report from invited-beta usage — not expand to public rollout.

---

## Validation

| Metric | Value |
|--------|------:|
| Thai validation suite | **919 / 919 pass** |
| Rollout monitoring tests | `thai_public_evidence_badge_rollout_monitoring_test.dart` |
| Payload privacy | enforced by code + tests |
| Public fingerprint | unchanged |

---

**Public Thai output unchanged for non-invited users. Monitoring active. Not public release.**
