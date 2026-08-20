# Authoritative command inventory

All Flutter commands used
`C:\Users\USER\Documents\Knowme\flutter-3.41.1-sdk\bin\flutter.bat`.
Raw UTF-8 output and exit-code companions are under `logs/`.

## Fresh gates

- Focused copy/layout and 300-profile ledger: focused validation test files with
  `flutter test --no-pub --reporter expanded` — exit 0.
- Known/Unknown, screenshot, Life Map, matrix, and exact R7 scopes:
  `flutter test --no-pub --reporter expanded <scoped files>` — exit 0.
- Live-asOf/canonical/S008 scope: `flutter test --no-pub --reporter expanded
  test/validation/thai_beta/live_asof` — exit 0.
- Scoped analyzer: `flutter analyze --no-pub <six approved paths>` — exit 0.
- Full analyzer: `flutter analyze --no-pub` — exit 1 with the exact 297 accepted
  diagnostic identities and new delta 0.
- Full suite: `flutter test --no-pub --reporter expanded` — exit 1 with 2,941
  passed and the exact 37 accepted failure identities; branch-only 0.
- VM/Chrome determinism: the repository's report-vNext and live-asOf manifest
  runners were each executed VM×2 and real Chrome×2; final comparators exit 0.

Invalid wrapper, sandbox, encoding-preflight, and dependency-preflight attempts
are retained under explicit failure suffixes. They are not used as gate results.

## Build and Firebase

- `flutter build web --release --no-pub` — exit 0; executed once only.
- `npx --yes firebase-tools hosting:clone knowme-app-694e1:live
  knowme-app-694e1:pr100-rpt-rollback-20260820 --project knowme-app-694e1
  --json` — exit 0.
- `npx --yes firebase-tools hosting:channel:deploy
  pr100-rpt-release-20260820 --only hosting --project knowme-app-694e1
  --expires 7d --json` — exit 0.
- `npx --yes firebase-tools hosting:channel:list --project
  knowme-app-694e1 --json` — exit 0 before and after the Preview failure.

No `firebase deploy` to the live channel, Hosting release/clone to `live`, or
non-Hosting Firebase command was run.

## Browser and PDF QA

Real installed Chrome was driven through Playwright against the actual Preview
URL. The five canonical forms and one mobile form were entered through the
Flutter semantics UI. Downloads were saved from the browser's real download
events. Chrome's print-media PDF output was captured from the application's
semantic print DOM. The output was rendered with PDFium and inspected page by
page. `logs/preview-canonical-five-browser-qa.json`,
`logs/preview-pdf-png-verification.json`, and
`logs/preview-pdf-render-result.json` are the authoritative machine records.

The in-app browser-client initialization failed at its trusted-RPC dependency
boundary before a browser binding was created. No result from that failed
initialization is claimed; installed Chrome/Playwright supplied the actual QA.

