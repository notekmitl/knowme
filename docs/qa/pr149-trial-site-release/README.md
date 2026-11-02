# PR #149 dedicated trial Hosting release — 2026-11-02

Owner authorized **“Deploy เลย”** after accepting the PC trial landing.
Starting branch HEAD `e82e869927f44058586ed8a7ab9e6e587e1265a3` was clean.
The accepted application is `130cdfa7d028ba6a7da13361d8fa1321fbe7dbf8`;
the difference to starting HEAD is documentation only. [CI for starting
HEAD](https://github.com/notekmitl/knowme/actions/runs/41394879766) passed.

## Release and isolation

Before this release, [Firebase site inventory and rollback baseline](baseline.json)
showed only the default Hosting site `knowme-app-694e1`. The [after
inventory](sites-after.json) shows a new USER_SITE `knowme-trial-694e1` in
the same project. Its live channel had no
previous release. The guarded `tool/build_trial_web.py` build
`trial-pr149-130cdfa` disabled web plugin registration and embedded only the
existing calculator `https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`.
The disposable deployment config contained only Hosting; target `trial`
mapped only to `knowme-trial-694e1`, and the command selected only
`hosting:trial`. No main-site, Auth, Firestore, IAM, rules or billing deploy
was issued.

**Working URL:** <https://knowme-trial-694e1.web.app/beta/thai>

| Site | Live release | Version |
| --- | --- | --- |
| Dedicated trial | `1793599203756000` | `c0ad58f8d39f8731` |
| Main KnowMe, before and after | `1790074568414000` | `d32e72678324e634` |

The [trial index/bootstrap/main JS hashes](trial-hashes.json) equal the
[guarded build hashes](trial-build-evidence.json) byte for byte. The main
site's [before](main-before-hashes.json) and [after](main-after-hashes.json)
index/bootstrap/main JS hashes and cache headers are identical. The trial
entry files have `no-cache` / `no-cache, must-revalidate` headers. Fresh
Chrome first-load and reload checks at 390×844 and 1280×800, and normal/CPU
checks at 1920×911, painted the artwork and retained one start button with
no app error or horizontal overflow. No service worker controlled those
reload contexts. The new trial landing at 1920, 1280 and 390 matches the
Owner-reviewed Preview screenshot pixel for pixel.

The existing separate calculator rejected the new exact trial origin at both
`/v1/calculate-bazi` and `/v1/calculate-chart` before the change (OPTIONS
400). Only `https://knowme-trial-694e1.web.app` was appended to
`CALCULATOR_ALLOWED_ORIGINS`. Cloud Run revision changed from
`knowme-overall-pr149-preview-00003-5lg` to
`knowme-overall-pr149-preview-00004-kt9`; the image digest, service account,
`PREVIEW_ORIGIN`, other origins and env stayed unchanged. [CORS before](cors-before.json),
[after](cors-after.json), and [config comparison](cors-update.json) show both
endpoints now return OPTIONS 200 with that exact allow-origin, preserve the
old Preview origin, and continue rejecting an unapproved origin with 400.
The application's two calculator POSTs still use the original `a.run.app`
URL and return 200.

## Hosted QA from the released site

The [synthetic journey harness](journey_trial.py) captured requests before
initial load. Fresh 390×844 and 1280×800 known-time journeys in ordinary
Chrome and CPU/WebGL-disabled Chrome reached the form, Overall, Thai,
Chinese, Western, and returned to Overall. Each made **exactly two**
successful calculator POSTs total; reader switches and detail disclosures
added none. Unknown-time journeys at 390 ordinary Chrome and 1280 CPU
stopped with the [existing explanation](unknown-result-hosted-unknown-390-chrome.png)
and **zero** POSTs. Every run found zero Auth/Firestore SDK/API or Production
API requests, other writes, failed requests, app errors and horizontal
overflow. Request domains were only the trial site, the separate calculator,
Google Fonts and Flutter CanvasKit assets. [Sanitized QA signals](hosted-qa-summary.json)
omit birth inputs, request bodies and reading text.

| Actual trial-site screen | Screenshot |
| --- | --- |
| PC landing 1920×911 | [normal Chrome](initial-1920-chrome.png) · [CPU fallback](initial-1920-cpu.png) |
| PC landing 1280×800 | [normal Chrome](initial-1280-chrome.png) |
| Mobile landing 390×844 | [normal Chrome](initial-390-chrome.png) |
| Overall report | [390 normal Chrome](overall-hosted-a-390-chrome.png) · [1280 CPU fallback](overall-hosted-a-1280-cpu.png) |

The landing art painted on first load and reload in all checked contexts.
In the 390 px ordinary Chrome journey, Thai and Western reader artwork was
blank in the immediate capture roughly half a second after switching, then
painted in the settled capture. This transient reader timing observation is
recorded rather than treated as an instant-paint guarantee. The settled
readers, calculation flow and privacy gate passed; no rollback was needed.

## Scoped rollback retained

There was no prior live release on the newly created trial site. If a
critical issue requires stopping the trial, publish the prepared static
[holding page](rollback/rollback-web/index.html) using its [Hosting-only,
site-specific config](rollback/firebase.json) from that `rollback` directory:

```powershell
firebase deploy --only hosting --config firebase.json --project knowme-app-694e1 --non-interactive
```

This keeps the trial Hosting site and leaves the main KnowMe site untouched.
If the trial calculator CORS addition must also be removed, first stop the
trial page, then route the same calculator service to the retained prior
revision (which already allowed the previous Preview origins):

```powershell
gcloud run services update-traffic knowme-overall-pr149-preview --region asia-southeast1 --project knowme-app-694e1 --to-revisions knowme-overall-pr149-preview-00003-5lg=100
```

These rollback commands were prepared, not executed. PR #149 remains Draft
and unmerged. Owner acceptance of the PC landing does not certify the full UI.
