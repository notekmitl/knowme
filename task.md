# Task: Thai Life Map V1.2.6 age-stage boundary closure

Fix the Production QA defect where a child inside a long astrology period
(for example age 11 in the 11–29 period) receives young-adult narrative.

Requirements:

- Keep life-period engine boundaries, calculations, Frozen Canon, and scores unchanged.
- Derive current-period narrative from the user's actual age.
- Derive past/future period narrative from the nearest period boundary age.
- Add regression coverage for 7/12/13/17/18/29 boundaries and long periods.
- Preserve V1.2.5 feedback authorization and Evidence Badge `invited_beta`.
- Run focused/regression/security tests, analyze, Local Gates, and web release build.
- Merge, deploy from `main`, verify Production ages 5/11/15/23/35/55/70, then update docs.
