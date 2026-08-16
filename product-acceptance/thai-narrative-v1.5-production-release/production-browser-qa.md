# Production browser, runtime, responsive, and access QA

## V1.5 before rollback

- Existing pre-deploy V1.4 tab: reload completed after V1.5 deploy; Thai research landing rendered; no stale service-worker loop or white screen; console warnings/errors 0.
- Fresh desktop: 1280 × 720 viewport; document width 1280; horizontal overflow false; signed-out research/privacy/voluntary-participation copy and analysis-start action exposed; console warnings/errors 0.
- Fresh mobile: 390 × 844 viewport; document width 390; horizontal overflow false; sticky analysis-start action remained visible; Thai copy and icons rendered; console warnings/errors 0.
- Signed-out policy: only the existing public research entry flow was exposed. No admin or invited-only feedback control was exposed on the signed-out landing/report.
- Production form: required name, birth date, time/unknown-time, province, optional gender, input confirmation, and report flow were operational for the first fixture.
- Screenshots: `production-browser-desktop.png`, `production-browser-mobile-390x844.png`.

## V1.4 after rollback

- Existing tab reload: complete signed-out research landing; console warnings/errors 0.
- Fresh cache-bypassed tab: complete signed-out research landing; document width 1280; horizontal overflow false; console warnings/errors 0.
- Screenshot: `rollback-browser-smoke.png`.

No Auth, Firestore, user-data, audience flag, or feature policy was changed by this release task.
