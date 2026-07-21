# KnowMe MBTI Architecture

**Purpose:** MBTI progressive system, session model, storage contracts.  
**Canonical entry:** [`HANDOFF.md`](HANDOFF.md) routing + [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md) paths.  
**Last updated:** June 2026

---

## Scope

| System | Package | Role |
|--------|---------|------|
| MBTI Progressive | `lib/features/tests/mbti/` | Behavioral preference — "how you tend to operate" |
| MBTI Cognitive | `lib/features/tests/mbti_cognitive/` | Processing style — "how your mind tends to work" |
| MBTI Summary Fusion | `lib/features/tests/mbti_summary/` | Deterministic synthesis of MBTI + Cognitive — **frozen v1.3** |

Cognitive is **not** identity label; Progressive is **not** deep cognition.

---

## Progressive Philosophy

**Checkpoints:** 16 → 40 → 80 questions

| Checkpoint | Constant | Confidence | Purpose |
|------------|----------|------------|---------|
| Mini | `mbtiMiniCheckpoint = 16` | Low | Fast onboarding, funnel recovery path |
| Standard | `mbtiStandardCheckpoint = 40` | Medium | Most users may stop here |
| Accurate | `mbtiAccurateCheckpoint = 80` | High | Deep profile |

**Product flow:** finish checkpoint → show result → optional continue CTA (same page, no routing reset).

---

## Session Architecture

**Primary file:** `lib/features/tests/mbti/application/mbti_session_state.dart`

**Responsibilities:** `initialize()`, resume, continue, restart, `saveProgress()`, `finish()`

**Pattern:** load session → resolve question set → restore answers → answer → save progress → finish → save result

### Continue behavior (critical)

Continue does **not** reset answers.

| Transition | Behavior |
|------------|----------|
| 16 → 40 | Answers preserved; question set expands; `index` jumps to 16; resume at Q17 |
| 40 → 80 | Same pattern; resume at Q41 |
| Restart | Clear session; fresh mini start; protected by confirmation dialog |

### Scoring

**Primary file:** `lib/features/tests/mbti/application/mbti_scorer.dart`

**Axes:** E/I, S/N, T/F, J/P → type (ESTJ, INFP, etc.)

**Output:** `MbtiResultSummary` — `type`, `dimensions`, `scoredQuestionCount`, scores, meta

`scoredQuestionCount` = how many questions contributed (16, 40, or 80). Used for confidence, timeline, fusion — see [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md).

---

## Firestore Contracts

### Session — `users/{uid}/tests/mbti_mini`

```json
{
  "answered": 40,
  "total": 80,
  "completed": false,
  "index": 40,
  "answers": { "mbti_1": 4, "mbti_2": 2 }
}
```

| Field | Meaning |
|-------|---------|
| `answered` | Questions completed |
| `total` | Current checkpoint target (16, 40, 80) |
| `completed` | Checkpoint result exists |
| `index` | Resume position (e.g. 40 → resume Q41) |
| `answers` | Source of truth for continuation — never wipe on continue |

### Result — `users/{uid}/results/mbti_mini`

```json
{
  "type": "ESTJ",
  "dimensions": { "E": 72, "I": 48, "S": 63, "N": 57, "T": 65, "F": 55, "J": 75, "P": 45 },
  "scoredQuestionCount": 80,
  "testId": "mbti_mini",
  "scoringVersion": 1
}
```

---

## MBTI Cognitive

**Session:** `users/{uid}/tests/mbti_cognitive` — same progressive philosophy as MBTI.

**Result:** `users/{uid}/results/mbti_cognitive` — `scores`, `topFunctions`, `stackTypeHints`, `scoredQuestionCount`. Probabilistic function profile; **no hard type claim**.

**Checkpoints:** 16 = 2/function, 40 = 5/function, 80 = 10/function (deterministic round-robin).

---

## MBTI Summary Fusion

- **No Firestore writes** — derived interpretation only.
- **Availability:** requires both MBTI and Cognitive results; guest → locked.
- **Confidence:** weakest-of-two `scoredQuestionCount` (e.g. 80 + 16 → 16).
- **Status:** stable / frozen-ish — blocker fixes only.

---

## Regression Checklists

Run before major MBTI merges.

### Progressive (B1)

- [ ] Q16/Q40/Q80 complete → result shown, confidence correct
- [ ] Continue 16→40: resumes Q17, answers preserved, `total` becomes 40
- [ ] Continue 40→80: resumes Q41, answers preserved
- [ ] Q80: no continue CTA; restart works
- [ ] Reload safety at Q7, Q35, Q68, and after finish
- [ ] Guest: `pendingAnswersForContinue` preserved locally

### Result page (B2)

- [ ] Strengths, cautions, careers, relationships, trait section, progress timeline
- [ ] Localization; restart dialog safe

### Cognitive (B3)

- [ ] Checkpoints 16/40/80; continuation preserves answers
- [ ] Top 4 / bottom 4 render; confidence labels correct

### Summary (B4)

- [ ] Locked without MBTI or Cognitive; available when both exist
- [ ] Legacy `scoredQuestionCount` null heals correctly

---

## Key Files

```
lib/features/tests/mbti/
  application/mbti_session_state.dart
  application/mbti_scorer.dart
  data/mbti_firestore_repository.dart
  presentation/mbti_mini_test_page.dart
  presentation/mbti_result_page.dart
  mbti_routes.dart
```
