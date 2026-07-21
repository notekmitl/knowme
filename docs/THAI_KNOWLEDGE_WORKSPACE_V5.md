# Thai Astrology Research Workspace V5

> An internal, **read-only** workspace for researchers (not users) to browse and
> audit the knowledge / research / evidence layers (V1–V4). Admin-only.

Status: **CURRENT** · Internal admin tool · **Deployed (admin only)**.
Decision Log **D-047**. Builds on Evidence Linking **V4** (D-046).

---

## Goal

Give researchers a safe surface to explore what the knowledge base currently
contains — relationships, research records and evidence — without any ability to
edit, and without touching the engine, runtime or prediction.

---

## Feature

`lib/features/knowledge_workspace/`

```
application/knowledge_workspace_data.dart   # read-only aggregation + filters + view-models
presentation/knowledge_workspace_page.dart  # tabs / filters / relationship detail (read-only)
knowledge_workspace_routes.dart             # /internal/knowledge behind the admin guard
```

### Route & access

- Route: **`/internal/knowledge`** (web deep link + `onGenerateRoute`).
- Access: reuses the existing **`ThaiResearchAdminGuard`** (same `admins/{uid}`
  allow-list enforced by `firestore.rules`, fail-closed). Non-admins see the
  login / access-denied screens; only admins reach the workspace.
- Not linked from any user surface; the production boot flow is unchanged.

---

## Capabilities (read-only)

- **Browse** evidence, research and relationships (three tabs).
- **Filter** by School · Author · Book · Relationship · Status · Planet.
- **Coverage** header: Total · Unknown · Candidate · Verified · Disputed (the V2
  knowledge status split) plus Friend/Enemy/Neutral.
- **Relationship detail**: Current Matrix value · Knowledge status · Conflicts ·
  Research records · Evidence (joined through `evidenceIds`).

No editing anywhere — the workspace only reads the bundled knowledge assets.

---

## Boundary / validation

- **Knowledge layer only.** The workspace depends on the V1–V4 knowledge layers
  and **not** on the runtime, prediction, decision, question or mirror runtime
  (enforced by a test that scans the source imports).
- The "Current Matrix" value is read from the V2 knowledge record's `relation`
  (which mirrors the frozen matrix), so the workspace does not import the engine
  matrix directly.
- Today the research/evidence corpora are empty, so the workspace shows the 56
  relationships with status `unknown` and no research/evidence yet — the honest
  current state.

---

## Tests

`test/features/knowledge_workspace/knowledge_workspace_test.dart`:

- Aggregation builds one view per V2 relationship (56) carrying the matrix value
  and joins research + evidence onto the linked pair.
- Filters by planet / relation / school / author / book.
- Page renders (with injected data); admin guard shows the workspace only for
  admins; the `/internal/knowledge` route resolves.
- Decoupling guard: no runtime/prediction/decision/question/mirror-runtime
  imports.

---

## Related documents

- [`THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md`](THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md) · [`THAI_KNOWLEDGE_RESEARCH_V3.md`](THAI_KNOWLEDGE_RESEARCH_V3.md) · [`THAI_KNOWLEDGE_IMPORTER_V2.md`](THAI_KNOWLEDGE_IMPORTER_V2.md) · [`THAI_KNOWLEDGE_FOUNDATION_V1.md`](THAI_KNOWLEDGE_FOUNDATION_V1.md).
- [`DECISION_LOG.md`](DECISION_LOG.md) — D-047. [`ARCHITECTURE.md`](ARCHITECTURE.md) · [`ROADMAP.md`](ROADMAP.md).
