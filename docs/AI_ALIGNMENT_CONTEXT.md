# AI Alignment Context

**Status:** CURRENT — permanent alignment document.
**Audience:** Any AI agent (or human) doing work in this repository.
**Last updated:** June 2026

> This is the **primary alignment file** for every AI session on KnowMe. Read it
> first. It encodes how this project thinks, what is frozen, what the source of
> truth is, and what you must never do. When this file and a prompt disagree about
> safety/stability, follow this file and surface the conflict.

---

## 0. The one-paragraph orientation

KnowMe is a deterministic, multi-lens **self-understanding** product (astrology +
personality tests → human-readable reflection). It contains legacy systems, parallel
architectures, partial migrations, and intentionally duplicated subsystems. **The
implementation is the single source of truth.** Most subsystems are **frozen**. Your
default posture is *minimal, additive, traceable change* — not redesign.

---

## 1. Required reading order (for any AI)

1. **`AI_ALIGNMENT_CONTEXT.md`** (this file) — how to behave.
2. **`PROJECT_INDEX.md`** — what every document is and whether it's current.
3. **`EXECUTIVE_SUMMARY.md`** — fastest way to understand the whole project.
4. **`KNOWME_MASTER_CONTEXT.md`** — vision, philosophy, subsystem map.
5. **`CURRENT_STATUS.md`** — what's done, active focus, risks, tech debt.
6. **`ARCHITECTURE.md`** — pipeline layers and code organization.
7. **`GOVERNANCE.md`** + **`PROJECT_FREEZE.md`** — what you may and may not change.
8. **`ROADMAP.md`** — completed / active / future.
9. **`DOMAIN_MODEL.md`** — highest-level conceptual model (engines, ownership, flow).
10. **`DECISION_LOG.md`** — why major decisions were made (read before reopening one).
11. Domain docs as needed (`HANDOFF.md`, `FIRESTORE_SCHEMA.md`, `MBTI_ARCHITECTURE.md`,
    `ASTROLOGY_QA_HARNESS_V1.md`, etc. — see `PROJECT_INDEX.md`).

Do not start editing before steps 1–7.

---

## 2. Source-of-truth rules

1. **Code > docs.** If a document disagrees with the implementation, the
   implementation wins; then fix the document.
2. **`PROJECT_INDEX.md` is the map.** It classifies every doc as CURRENT / HISTORICAL
   / SUPERSEDED / ARCHIVED / DEPRECATED. Trust CURRENT docs; treat the rest as records.
3. **Firestore is the runtime source of truth** for user data — see `FIRESTORE_SCHEMA.md`
   (`tests/*` vs `results/*`, `astrology/chinese_bazi` etc.). Do not guess paths.
4. **Never invent scope.** If something is not in `/docs/` or the code, it does not
   exist. Do not fabricate roadmap items, metrics, datasets, or version numbers.

---

## 3. Decision hierarchy

When priorities conflict, resolve in this order:

> **stability > correctness > architecture purity > speed**

Corollaries:
- A working-but-imperfect system beats a clean rewrite that risks production.
- **Duplication is preferable to a premature/bad abstraction** until duplication is
  demonstrably painful.
- Prefer **additive** new folders/files over rewriting existing systems.

---

## 4. Product philosophy

- KnowMe is a **digital mirror for self-understanding** — not a horoscope app, quiz
  app, MBTI clone, or clinical dashboard.
- **Hybrid strategy:** outside it feels like astrology that understands you; inside it
  uses structured tests to personalize reflection.
- **Insight > label.** Labels (ESTJ, sun sign) are entry points; value is reflective
  insight.
- **Self-understanding > entertainment.** Grounded, plausible, emotionally resonant.
- **Progressive understanding:** low friction first, depth later
  (Astrology → MBTI → EQ/Big Five → Fusion + Narrative).
- **Believable reflection > scientific over-complexity.** Before polishing, ask:
  *Does this meaningfully improve user understanding or product value?* If no, move on.

Full detail: `KNOWME_MASTER_CONTEXT.md` §1–§3.

---

## 5. Architecture philosophy

- **Deterministic before AI.** No LLM dependency in core astrology, MBTI summary
  fusion, or narrative runtime. Output must be predictable, debuggable, explainable.
- **Layered pipeline; downstream never bypasses upstream contracts.**
  Lens → Mirror (MV1/MV2) → GF1 → GF2 → Human Model → Human Pattern → Narrative → Home.
- **Copy boundary:** engines emit structure + evidence; only presenters/copy composers
  emit user-facing prose (especially the Thai consumer report).
- **Parallel architectures coexist on purpose** (e.g., Thai V1 production path vs V2
  structural stack; `UniversalTestPage` vs feature-specific tests). Do not "unify" them
  without an explicit request and a migration plan.
- **Module IDs may be inconsistent** across legacy/new code. Always inspect actual IDs
  before modifying scoring or navigation.

Full detail: `ARCHITECTURE.md`, `EXECUTIVE_SUMMARY.md`.

---

## 6. Coding philosophy

1. **Analyze before editing** — trace flow, dependencies, navigation, Firestore paths,
   and existing providers/services first.
2. **Prefer minimal safe changes** — no unnecessary rewrites; don't replace working
   systems.
3. **Never create duplicate systems blindly** — reuse existing services (e.g.
   `QuestionService`, `ScoringRouter`, existing loaders) when possible.
4. **Preserve the production flow:** `main.dart` → `AuthGate` → `ProfileGate` → `HomePage`.
5. **Small, focused files; deterministic helpers; presentation isolation.** Avoid
   1000-line god files.
6. **Feature owns its logic** — avoid cross-feature leakage.
7. **Explain before major changes** — current implementation, risks, minimal approach.
8. **Safe workflow:** branch → small implementation → manual test → commit only after
   confirmation.
9. **Debug by root cause** — inspect caller chain and data flow; do not patch randomly.

---

## 7. Freeze rules

- Many systems are **frozen / maintenance-only**. The authoritative registry is
  `PROJECT_FREEZE.md` (full detail) and `GOVERNANCE.md` (policy).
- On a frozen system, allowed changes are limited to: **blocker fixes, serious
  usability issues, analytics-driven improvements, production incidents.**
- **Avoid:** architecture rewrites, polish loops, copy/spacing churn without product
  reason, reopening frozen contracts.
- **Before any frozen-system change**, ask: *Does this meaningfully improve user
  understanding or product value?* If no, stop.
- Additive exception programs exist (e.g. Chinese Zodiac Personality Expansion, Funnel
  Recovery, the Thai Consumer Report presentation layer) — additive only, no engine
  rewrites.

---

## 8. UX principles

- **TH-first tendency language.** Prefer "คุณมัก… / มีแนวโน้ม… / หลายครั้ง… / อาจ…".
  Avoid "คุณคือ… / คุณต้อง… / ดวงกำหนด… / เกิดมาเพื่อ…" and any certainty/authority tone.
- **No fate/destiny/determinism.** No overclaiming. No false precision (`78.4%`).
- **Speak the user's language on product surfaces.** Architecture terms (Global Fusion,
  Mirror Platform) belong in dev docs, never in Home copy.
- **Avoid over-therapy tone** (healing/inner child/trauma) unless intentional.
- Full rules: `KNOWME_MASTER_CONTEXT.md` §2.1.

---

## 9. Content principles

- Every user-facing claim must be **traceable to evidence** (chart keys, lens signals,
  pattern activations).
- Prefer **diversity and naturalness**; avoid templated repetition (validated by
  similarity/diversity audits and story-coverage gates).
- Reflection, not prediction. Tendencies, not verdicts.
- Personalize via combination (e.g. Thai evidence composer, lagna tone), not via
  generic horoscope text.

---

## 10. Testing & QA philosophy

- **Validate before claiming.** Synthetic-population gates (200 → 1000 humans) precede
  production claims; real-user replay measures the funnel.
- **The QA harness renders the real production pipeline and page** — never a duplicate
  UI. See `ASTROLOGY_QA_HARNESS_V1.md`.
- **Presentation changes must pass** screenshot regression + story-coverage CI before
  deploy (Thai consumer report).
- Determinism is testable: same input → same output. Pin time-dependent outputs (e.g.
  Life Timeline `asOf`) in tests.
- Do not add tests that over-fixate on a single surface unless asked.

---

## 11. Documentation rules

1. **Implementation is the source of truth**; docs must match it.
2. **Never delete historical records.** Reclassify instead (see §12) and add a banner.
3. Every CURRENT doc cross-links related docs; **no orphan documentation.**
4. New docs are registered in `PROJECT_INDEX.md`.
5. Keep version/status markers honest. If a spec ships, update its status and point to
   the implementation record.
6. Don't invent dates, metrics, or versions. Use "none" if unknown.

---

## 12. Documentation classification taxonomy

| Class | Meaning | Banner required |
|-------|---------|-----------------|
| **CURRENT** | Living reference, kept up to date | Optional (status in `PROJECT_INDEX.md`) |
| **HISTORICAL** | Point-in-time record, still valid as a record | Yes |
| **SUPERSEDED** | Replaced by a newer doc (which must be named) | Yes |
| **ARCHIVED** | One-off investigation, no longer maintained | Yes |
| **DEPRECATED** | Describes something no longer true or in use | Yes |

---

## 13. Roadmap philosophy

1. **Evidence before expansion** — gates before production claims.
2. **Funnel before features** — real-user conversion is the current bottleneck, not
   engine diversity.
3. **Freeze what works** — maintenance-only on stable systems.
4. **No invented work** — if it isn't in `/docs/` or code, it isn't on the roadmap.

---

## 14. Prompting rules (how to work a task here)

- **Trace first, then propose, then edit.** State current implementation, risks, and
  the minimal approach before large changes.
- **Confirm scope** for anything destructive, cross-cutting, or that reopens a frozen
  system.
- **Batch independent reads/searches**; don't edit blindly.
- **Use the QA harness / tests** to verify presentation and pipeline changes.
- **Update docs in the same change** when behavior changes.
- **Surface conflicts** between a request and these rules instead of silently complying.

---

## 15. Things AI must NEVER do

1. **Never assume architecture consistency.** Legacy + new coexist; module IDs vary.
2. **Never rewrite or "clean up" a frozen system** without an explicit request + plan.
3. **Never create duplicate scoring/navigation/services** when one exists — reuse.
4. **Never bypass the production flow** (`AuthGate → ProfileGate → HomePage`).
5. **Never duplicate the report UI** — render through the production pipeline/page.
6. **Never break the copy boundary** (engines must not emit user-facing prose).
7. **Never invent** scope, metrics, datasets, versions, or roadmap items.
8. **Never delete historical docs** — reclassify with a banner.
9. **Never commit secrets** (`serviceAccountKey.json`, PII exports are gitignored).
10. **Never update git config**, force-push to main, or skip hooks.
11. **Never overclaim in user copy** (no fate/destiny/false precision).
12. **Never deploy presentation changes** that fail screenshot regression or story
    coverage.

---

## 16. Documentation Policy

Documentation is part of the definition of done — not an afterthought.

1. **Definition of done.** A feature is complete only when **all four** are complete:
   - implementation
   - tests
   - deployment
   - documentation
2. **No feature is finished if its documentation is outdated.** If behavior changed and
   the docs did not, the work is not done.
3. **Record decisions.** Every major architectural or product decision must be recorded
   in [`DECISION_LOG.md`](DECISION_LOG.md) (append-only; supersede, never delete).
4. **Model new modules.** Every new module/engine/lens must appear in
   [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) (with ownership + data flow) and be registered
   in [`PROJECT_INDEX.md`](PROJECT_INDEX.md).
5. **Roadmap sync.** Every roadmap change must update both
   [`CURRENT_STATUS.md`](CURRENT_STATUS.md) and [`ROADMAP.md`](ROADMAP.md).
6. **Freeze sync.** Every freeze/unfreeze must update
   [`GOVERNANCE.md`](GOVERNANCE.md) and [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md).
7. **Classify, don't delete.** Historical docs get a classification banner and stay
   (see §12). Update [`PROJECT_INDEX.md`](PROJECT_INDEX.md) when a doc's class changes.
8. **Source of truth.** Code wins over docs; when they disagree, fix the doc and (if the
   cause was a decision) log it in `DECISION_LOG.md`.
9. **No orphans.** Every major doc cross-links its related docs.

---

## 17. Related governance & reference docs

- `GOVERNANCE.md` — freeze policy, active/deferred programs, exception programs.
- `PROJECT_FREEZE.md` — per-system freeze registry with modification policy + future
  replacement plans.
- `DECISION_LOG.md` — why major architectural/product decisions were made.
- `DOMAIN_MODEL.md` — highest-level conceptual model (engines, ownership, data flow).
- `KNOWME_MASTER_CONTEXT.md` — canonical vision/philosophy/subsystem map.
- `CURRENT_STATUS.md` — risks + technical debt register.
- `EXECUTIVE_SUMMARY.md` — architecture, freeze map, tech debt, decisions, roadmap.
- `PROJECT_INDEX.md` — the full documentation map and reading order.
