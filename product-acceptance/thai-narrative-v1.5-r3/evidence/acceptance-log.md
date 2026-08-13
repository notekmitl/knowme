# Acceptance log

- R1: `V1.5 R1 OWNER ACCEPTANCE REJECTED` — historical packet preserved unchanged.
- R2: `V1.5 R2 OWNER ACCEPTANCE REJECTED` — correctness/coverage passed, consumer freshness failed. Measured exact reuse was 60/84 strong-claim instances (71.43%); excluding the explicit 00:03 regression twin, 36/66 (54.55%). R2 artifacts remain immutable historical evidence.
- R3: ready for Owner reading only. Automated gates and artifact QA pass; this is not an Owner Acceptance claim.

No merge, deploy, or Production change occurred. Production remains V1.4.
