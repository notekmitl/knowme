# Task: Thai Required Full-Suite Baseline Contract Repair

Repair the 70 reproducible test-contract failures on immutable PR #81 HEAD
`b0a5b4c541f86d82a1fe7fecbae070ffea8a4b2e` without changing production
source, runtime behavior, Engine, Canon, prediction semantics, feature flags,
or Production data.

The Required scope is the complete Thai, Thai Beta, and Thai Mirror QA harness
validation directories. Tests may not be skipped, filtered, or weakened. The
repair must align stale assertions with the authoritative current producer and
presentation contracts, then pass all 1,439 tests with zero failures.

The Narrative intended diff is preserved separately and must not be mixed into
this prerequisite. The 28 tracked files rewritten by the diagnostic Full-suite
run are generated QA artifacts only and were restored individually to the base
commit after exact-path and blob verification.

This task ends at a Draft PR stacked onto the PR #81 head branch. Do not merge,
deploy, change feature flags, or mutate Production data.
