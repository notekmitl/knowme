# Task: Thai Life Map V1.2.4 — Real-User Accuracy Audit

## Goal
Run a deterministic multi-chart accuracy audit (≥20 synthetic fixtures, ≥160 periods) across Life Map / Mahabhut / consumer paths. Document results. Fix production code only if a data-flow bug is found.

## Status
- Audit sample: 22 fixtures / 176 periods — known 139 / unknown 37; no data-flow anomalies
- Focused Life Map suite: 36/36 (14 assertion cases in V1.2.4 file alone ≠ sample size)
- Compile fixes were test-only (`static final` DateTime; nullable badge coalesce)
- No `lib/` / Frozen Canon / formula changes → no Firebase deploy

## Non-goals
- Do not modify Frozen Canon or Mahabhut formulas
- Do not invent placement tables
- Do not open Public Evidence Badge
- Do not redeploy if only tests/docs change
