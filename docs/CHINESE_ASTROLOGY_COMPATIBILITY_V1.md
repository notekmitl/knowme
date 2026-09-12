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

- `Authorization: Bearer <Firebase ID token>` is mandatory.
- The backend verifies the ID token with revoked-token checking.
- The body UID must match the verified UID or the request is rejected with 403.
- Both Firestore writes use only the verified UID.
- Missing or invalid authentication returns 401 without disclosing token detail.

## Report contract

The report may show calculated inputs, available pillars, Day Master as a
structural stem, Year animal, visible element counts, method/version information
and limitations. Technical terms must be explained in plain language.

The report must not show unsupported personality, strengths, weaknesses,
relationship, career, health, finance or event predictions. Health, medical,
financial, investment, legal and future-guarantee cautions form the final
section. Signed-in Web, Owner fixture Web and PDF/export are projections of the
same report object.

## Explicit exclusions

V1 excludes true-solar time, hidden stems, rooting/seasonal strength, Useful
God, Ten Gods, combinations/clashes, Da Yun/luck pillars, annual timing,
relationship compatibility and event prediction. Adding any of these requires
a new sourced and Owner-approved contract.
