# Thai Consumer Narrative Voice V1 — Round 7

## Status

Round 7 implementation and local acceptance evidence are complete. Product Acceptance remains pending owner review. Draft PR #86 must remain Draft; no merge or deployment is authorized.

## Delivered contract

- `ForecastMaterialFingerprint` is typed and canonical for horizon, domain, band, risk domain, evidence availability, and transition span; its compact string form is audit-only.
- Claim, Risk, Decision, and Action consume explicit field projections. Action consumes the same block's Claim, Risk, decision impact, real availability, and transition authority.
- Evidence availability comes from `PredictionIntelligence.context.hasLagna`; unknown time fails closed and explicitly states that lagna evidence is unavailable.
- Transition uses one `spansTransition` authority and serializes as `t`; no `p` parser remains.
- The cross-mode gate pairs exact horizon/domain identities over all four fields, excludes disclaimer text, checks exact/containment/normalized similarity, requires non-zero differences and material coverage, and rejects band/risk/availability/transition/one-cell/vacuous mutations.
- Round 6 horizon ownership, taxonomy, age language, pagination, day-boundary facts, Web/PDF data identity, and unknown-time limitations are preserved.

No Engine/Canon/calculation, evidence meaning, route, flag, deployment, Production state, or Thai Mirror default changed.

## Verification facts

- Source-tested commit: `6a61e8bdfd6d632030136158646f634632609d6b`.
- Targeted narrative + synthetic: 20 passed; synthetic audit 300/300.
- Focused narrative/core/export/pipeline: 240 passed.
- Full required suite: 1,521 passed (required minimum 1,518).
- Analyze: exit 0; 299 pre-existing findings; no new changed-file diagnostics.
- Gate self-test: 9/9 passed.
- PreCommit gate: PASS.
- Actual same-civil-profile matrix: 96 cells; 52 equal fingerprints; 44 different fingerprints; 24 justified shared outputs; 0 violations; band and availability coverage.
- Artifact generator: base, desktop, and mobile invocations passed.
- Web/PDF text parity: exact for known and unknown fixtures.
- Known-time PDF: 16 A4 pages; SHA-256 `BD4AEE92C0114DC2A8053E91C97B0565915D13ABB0B56E0286A657185E1E5723`.
- Unknown-time PDF: 15 A4 pages; SHA-256 `4565F9141D2765747840E792D0FD6D3DB064760482CF4D9ABAC06965E9EC9AA5`.
- Every PDF page was rendered at 120 dpi and visually inspected; no clipping, overlap, blank trailing page, or missing content was found.
- Immutable packet directory: `C:\Users\USER\Documents\Knowme\product-acceptance\thai-consumer-narrative-voice-v1-round7-6a61e8b`.

The packet ZIP hash, final remote HEAD, PostCommit gate, Draft PR state, and GitHub status/workflow facts are recorded in the PR and delivery response after publication; a Git commit cannot truthfully self-contain its own final object ID.

## Historical acceptance

Rounds 3–6 failed Product Acceptance and are historical only; they are not current readiness claims.
