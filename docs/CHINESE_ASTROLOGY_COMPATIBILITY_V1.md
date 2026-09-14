# KnowMe BaZi Compatibility V1 Contract

**Contract id:** `knowme_bazi_compatibility_v1`

**Contract name:** `KnowMe BaZi Compatibility V1`

**Status:** implemented for Owner testing in Draft PR #122

## Contract boundary

This contract makes the repository's pinned BaZi engine behavior explicit and
reproducible. It is a KnowMe compatibility definition, not a claim that every
BaZi school uses the same rules.

The calculation is deterministic code. AI output is never an input to a pillar,
animal, element count, ambiguity decision or input fingerprint.

## Calculation rules

1. Parse a Gregorian date and optional time as local civil fields.
2. Require and validate an IANA timezone identifier as the local-civil context.
3. Pass the civil fields unchanged to `lunar_python@1.4.8`; do not convert to
   UTC and do not apply longitude or true-solar correction.
4. Use the engine's exact Li Chun result for the Year pillar.
5. Use the engine's Jie solar terms for the Month pillar.
6. Set EightChar `sect=2`, so the Day pillar changes at local civil 00:00.
7. For Known time, emit all four pillars.
8. For Unknown time, compare the start and end of the local civil date. Always
   omit Hour and hour-dependent outputs; omit Year/animal and/or Month when the
   corresponding pillar differs across the date.

Chinese New Year does not independently change the Year pillar under this
contract. The Year pillar follows Li Chun.

## Fingerprint and traceability

The canonical fingerprint payload has these keys in sorted order:

```json
{"birth_date":"YYYY-MM-DD","birth_time":"HH:mm or null","timezone":"Area/City","version":"knowme_bazi_compatibility_v1"}
```

The stored SHA-256, contract id, engine version, policy, input context,
completeness, ambiguity flags and suppressed fields make each result auditable.
Coordinates are absent from the hash because V1 records but does not calculate
with them.

## API security contract

- New clients call `/v1/generate-bazi` and `/v1/generate-chart`.
- `Authorization: Bearer <Firebase ID token>` is mandatory on both v1 routes.
- The backend verifies the ID token with revoked-token checking.
- The body UID must match the verified UID or the request is rejected with 403.
- Both Firestore writes use only the verified UID.
- Missing or invalid authentication returns 401 without disclosing token detail.

The compatibility `/generate-bazi` path remains authenticated. The older
Western `/generate-chart` path predates this contract and remains temporarily
available for released clients; the new client never calls it. Retirement is a
post-adoption release action, not part of this Draft.

## Report contract

The report shows calculated inputs, available pillars, Day Master, Year animal,
visible element counts, method/version information, separated source ledgers
and limitations. It also projects the separately versioned
`knowme_bazi_symbolic_reading_v1` contract:

- one deterministic profile for each of the ten Day Master stems;
- a natural-image metaphor, symbolic tendency, constructive expression,
  balance point and practical reflection; and
- five broad visible-element relationship families relative to the Day Master;
  and
- five reader-facing natal areas (strengths, work, money/resources,
  relationships and cautions/development) for complete four-/three-pillar
  context, with the exact Day Master and joint-highest visible family/count
  disclosed beneath every area.

This interpretation never changes a chart fact. A visible count is not a
strength or favourability score, and the copy does not assert that the reader
must have a trait or that a future outcome will occur. Full mapping, source and
Known/Unknown rules are in `CHINESE_ASTROLOGY_INTERPRETATION_V1.md`.

The report must not show unsupported concrete relationship, career, health,
finance or event predictions. Health, medical, financial, investment, legal and
future-guarantee cautions form the final section. Signed-in Web, Owner fixture
Web, plain text and PDF/export are projections of the same report object.

The PDF projection embeds static `NotoSansSC-Regular` for Chinese glyphs. It
must not substitute a Thin variable-font instance, and Unknown variants must not
recover time, Hour or boundary-ambiguous values during layout/export.

## Owner manual QA boundary

Owner manual testing covers the Known, ordinary Unknown, Li Chun Unknown and
Jie Unknown fixtures plus Web/PDF parity. The no-write fixture route does not
test authentication. Token/UID/revoked-token enforcement, regeneration and
Fusion freshness are automated engineering gates.

## Fusion freshness contract

The Fusion source version includes the governed BaZi input fingerprint, not
only the Day Master. A fingerprint change invalidates the Fusion snapshot even
when the Day Master remains the same. If a BaZi lens becomes unavailable, the
version comparison is outdated rather than equal. This closes Known -> Unknown
fail-closed transitions without retaining a prior Hour pillar or other
time-dependent lens data.

## Release sequencing

No release is authorized by this contract. The earlier client-first then
immediate backend-enforcement proposal is insufficient because cached or
already-open legacy clients may continue to use the old Western write route.
PR #122 now contains the migration implementation:

1. authenticated versioned endpoints exist beside compatibility endpoints;
2. new BaZi and Western clients send bearer tokens to those endpoints;
3. the backend must be deployed and verified before the client is released;
4. adoption must be verified after the client release; and
5. the legacy Western endpoint is retired only after that gate passes.

No step in that deployment sequence is authorized or performed by this PR.

## Explicit exclusions

V1 excludes true-solar time, hidden stems, rooting/seasonal strength, Useful
God, polarity-specific Ten Gods, combinations/clashes, Da Yun/luck pillars,
annual timing, two-person relationship compatibility and event prediction. The
implemented five broad relationship families are visible-element categories,
not full Ten Gods or strength analysis. Adding any excluded feature requires a
new sourced and Owner-approved contract.
