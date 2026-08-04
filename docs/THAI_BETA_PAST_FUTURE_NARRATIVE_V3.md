# Thai Beta Past-to-Future Narrative V3

**Status:** Recovered; Local Gate PreCommit passed; Draft delivery pending  
**Base:** `3671b62fba86fc83365fdba597b695b1f3324c6b`  
**Production:** Not released

## Product contract

Thai Beta V3 expands the computed life-period presentation without changing
the Thai Astrology Engine. Every available past period, the current period,
the next 12 months, the next turning point, and later computed periods through
the available range (up to age 108) provide deterministic work, money, love,
and health narratives. Web and PDF consume the same presentation state.

Narratives may express tendencies, risks, and practical actions grounded in
computed evidence. They must not invent events, marriage/separation dates,
disease, diagnosis, or unsupported facts.

## Isolation

Shared Thai Mirror presenters/widgets enable V3 detail only through explicit
Thai Beta opt-in parameters. Standalone Thai Mirror retains its previous
default behavior. Engine, Canon, Birth Normalization, Auth, evidence
eligibility, Feedback, Firebase rules/data, and other systems are unchanged.

## Recovery and baseline

PR #80 repaired the QA harness baseline and merged at
`3671b62fba86fc83365fdba597b695b1f3324c6b`. V3 was then recovered from the
validated archive `knowme-v3-recovery-2026-08-04.zip` (SHA-256
`9a1119ea07ab75b4d88724aef5dc77514013824c7c4de0339d32c8c0062ed3ec`) into a
new worktree based on that merge.

The separate `test/goldens/thai_mirror_consumer_page.png` remains a known
32.63% / 305,379-pixel failure. It is not modified or included in the V3 scoped
suite and requires a separate repair task.

## Acceptance

- V3 narrative/UI, export, readability, future-domain, parity, synthetic,
  pipeline, layout, V8, V10, story coverage, and QA screenshot suites pass.
- Flutter 3.41.1 analyze reports no fatal errors.
- Local Gate PreCommit and PostCommit pass.
- No Production release occurs from the Draft PR task.

The recovered V3 narrative/UI suite passed 6/6, export passed 37 tests,
future-domain compatibility passed, eight-fixture readability reported zero
issues, Web/PDF parity passed, story coverage passed A-H, and the repaired QA
screenshot regression passed 24/24 before Local Gate.

Gate self-test passed 9/9. PreCommit passed analyze with no fatal errors,
focused tests, and the required 135-test scoped suite plus the V1.3.3
future-domain compatibility case.
