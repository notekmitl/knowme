# Thai Beta Past-to-Future Narrative V3

**Status:** Recovered; Local Gate passed; Draft PR #81 open
**Base:** `3671b62fba86fc83365fdba597b695b1f3324c6b`  
**Implementation:** `468827ffec9ef845db91a498f7287e52c925ab57`
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

## Production-candidate review

The 2026-08-04 review inspected complete deterministic fixture text A-H,
Desktop known-time and Mobile no-time report renders, and actual PDF exports
(11 and 10 pages) from the shared exporter. Layout, ordering, Web/PDF semantic
parity, long-range coverage, fail-closed no-time behavior, and public-copy
safety passed visual and automated review.

Future statements derived only from score/band evidence now use cautious
tendency or conditional wording. Specific certainty phrases about new roles,
income increases, a destined partner, forced relationship decisions, and
health outcomes are not permitted. This hardening changes presentation copy
only; it does not change evidence, Engine, Canon, or calculations.

The recovered V3 narrative/UI suite passed 6/6, export passed 37 tests,
future-domain compatibility passed, eight-fixture readability reported zero
issues, Web/PDF parity passed, story coverage passed A-H, and the repaired QA
screenshot regression passed 24/24 before Local Gate.

Gate self-test passed 9/9. PreCommit passed analyze with no fatal errors,
focused tests, and the required 135-test scoped suite plus the V1.3.3
future-domain compatibility case.

PostCommit Gate passed, the implementation was pushed, and Draft PR #81 was
opened at https://github.com/notekmitl/knowme/pull/81. No merge or deployment
was performed.
