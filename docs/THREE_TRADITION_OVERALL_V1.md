## 2026-10-06 Owner approval ? limited small-group trial handed off

Owner explicitly approved the existing Preview for a small-group, time-limited
trial ending **12 October 2026 at 13:30 Asia/Bangkok** (06:30 UTC).
Approval covers sharing the existing canonical link only, not merge, another
deployment, permanent release, live changes or Firestore/IAM/Auth/rules changes.
Owner will share the invitation personally; no external message was sent.

Canonical link:
https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai

Before handoff, authenticated Hosting metadata confirmed version
`8c0fe2f95d66d02d`; freshly downloaded index/bootstrap/main JS SHA-256 all
matched both the retained build and the previously accepted QA evidence.
Build source remains `11ffc58f092ac19d70d2add370239b67a707f968`.
Preview bytes were not rebuilt/redeployed. Prior fresh journey/privacy QA
remains applicable; no repeat journey was needed for this docs-only change.
Live remains `d32e72678324e634`. Pre-update HEAD `065249b` has successful
CI run [37412840281](https://github.com/notekmitl/knowme/actions/runs/37412840281).
This approval commit is documentation only; it does not claim its own CI passed.
PR stays Open/Draft and unmerged.

Operational sharing cutoff is 13:30 sharp; Firebase currently expires at
13:30:21.083714850 on that day. No expiry extension or mutation was performed.
Stop sharing by the approved cutoff even if the URL remains available briefly.
Rollback/stop is withdrawing the link; channel deletion requires separate
explicit authorization. Cached/open tabs are not guaranteed to stop immediately.
The permanent-release blockers and old-route isolation plan below still apply.

Invitation for Owner to share:
> ???????????????????? KnowMe: ???????????????????????????? ?????????? ???
> ?????????? ?????????????????????????????????????????
> https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai
> ???????????? 12 ?.?. 2026 ???? 13:30 ?. ?????????

Historical preflight wording about pending Owner approval is superseded by
this approval; it remains a record of the pre-approval state.

Verified at 2026-10-06T04:33:17.144328+00:00

# KnowMe PR #149 release preflight — 2026-10-06

Decision: **READY for a time-limited trial using the existing QA Preview link,
after Owner approval; NOT READY for a permanent live release or same-origin
integration.** PR remains Open/Draft. This preflight performs no deployment,
merge, backend configuration change, or Firestore/IAM/Auth/rules change.

## Evidence and provenance

- Clean local/remote HEAD: `056c19fd002f645149310991a1c9abda4553e6c7`.
  PR base is `main` at `aa80eabaea63b66220393e0268488f57577670b3`.
- HEAD CI [37275013346](https://github.com/notekmitl/knowme/actions/runs/37275013346)
  is completed/success: backend regression, isolated trial build, analyzer,
  normal/release-config web builds and complete Flutter suite all succeeded.
  GitHub connector returned an empty workflow list; authenticated `gh run view`
  provided the actual SHA, jobs and successful steps.
- Current authenticated Hosting read on 6 October still reports Preview
  `8c0fe2f95d66d02d` and live `d32e72678324e634`, release
  `1790074568414000`. No existing Hosting version was changed here.
- Preview expires `2026-10-12T06:30:21.083714850Z`
  (12 October 13:30:21 Asia/Bangkok). Share canonical URL only:
  https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai
- Deployed build source is `11ffc58f092ac19d70d2add370239b67a707f968`.
  `git diff 11ffc58..056c19f` contains only the three documentation files.
  Build tool, Dart/web/backend source and dependency lockfile are unchanged.
  The preflight documentation commit also does not change application bytes.
- Re-downloaded Preview assets equal retained local build and recorded QA hashes:
  main JS `e1b6629b726d5807852e899d5d230d4cb67db235e99d9bd8fac61af1632e4d23`;
  bootstrap `1d1795d381d2c3f0a5efaf9cc6a51bbde28ec06f3b76034994137ff794146e83`;
  index `c2d36a891c8960d793fa6a109a33f0b5adfaccab698d2696754adb559f271ade`.
- Reuse the accepted 5 October fresh journeys at 390x844 and 1280x800:
  known-time cases exactly two Preview calculation POSTs, both 200; unknown
  time zero POSTs; no forbidden SDK/API requests or other writes. No repeated
  browser journey is needed while these exact hosted bytes/origin remain.
  Prior screenshots/traces are in the task history, not a new raw archive.
- Targeted local preflight regression: public/guarded launch routes plus Chinese
  owner route tests passed (21 reported tests); API separation test passed
  (1 test, actual Preview calculator define). The optional chart-directory case
  returns without fixture execution when its environment variable is absent;
  do not count it as a new four-chart visual QA. Tests use mocked/local paths,
  not Production API calls. No code fix was needed.

## Entrypoint and proof of preserving the existing application

`tool/build_trial_web.py` stages a private workspace and targets
`lib/main_trial.dart`, with `KNOWME_OVERALL_PREVIEW=true`, separate calculator
URL and evidence badge off. Plugin declarations are removed only in private
dependency copies; registrant/bundle guards verify the isolated output.
`TrialApp` always displays the anonymous landing shell; it does not contain
the normal KnowMe routes/providers.

Hosting rewrites `**` to `/index.html`. Read-only GETs for `/`, `/beta/thai`,
`/beta/chinese` and `/profile` on the Preview origin all returned the identical
trial index. Therefore **cloning this Preview to `knowme-app-694e1:live` would
replace the whole existing web app**, including root/login/profile and other
deep links. A path-looking Preview URL is not path-scoped deployment.
Such a clone is excluded from the release plan.

The recommended initial release shares the existing separate Preview origin;
it changes neither live files nor rewrites nor links in the existing app.
Old `/`, `/profile`, `/beta/thai`, `/beta/chinese`, capture/admin and test routes
on the normal origin continue using the same live version/config. This is
isolation by unchanged release identity, not a claim that HTTP 200 alone
proves every protected page. Preflight did not log into or write through old
routes. Local launch tests additionally retain root Login, anonymous beta and
protected capture behavior.

Do not use the normal `lib/main.dart` + `KNOWME_OVERALL_TRIAL=true` CI build
as a substitute for the QA artifact: it preserves Firebase initialization for
the rest of KnowMe and registers the normal plugins. Its API split test proves
endpoint selection only; it does not prove the strict no-Auth/Firestore SDK
gate. A same-origin `/trial/` integration would require a separate bundle,
base-href/assets and precise rewrite/cache/service-worker scoping, plus new
affected-route regression. It is outside the approved release design here.

## Backend URL, CORS and cache

Calculator remains
`https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`.
The trial calls only `/v1/calculate-bazi` and `/v1/calculate-chart`.
Source `backend/app/preview_main.py` has exact HTTPS-origin CORS, POST/content-
type only, no credential allowance and no Firebase initialization/saved-chart
routes. Runtime OPTIONS checks (no calculation POSTs) for both paths returned:

| Origin | Result |
| --- | --- |
| Existing Preview origin | 200, exact Access-Control-Allow-Origin |
| knowme-app-694e1.web.app | 200, exact origin |
| knowme-app-694e1.firebaseapp.com | 200, exact origin |
| Proposed knowme-trial-149.web.app | 400, no allow-origin |
| untrusted.example.invalid | 400, no allow-origin |

Runtime checks establish these sampled responses, not the complete deployed
allowlist or Cloud Run revision/env audit. CORS is browser access policy,
not authentication or protection against direct non-browser requests.
Backend capacity/rate limits and continued availability still need an Owner
decision before broad public promotion; existing QA proves calculator behavior
for synthetic journeys, not load or operational readiness.

Actual Preview headers: canonical `/beta/thai` and index are `no-cache`;
bootstrap/main JS are `no-cache, must-revalidate`. Build embeds source SHA
query keys in index→bootstrap→main. Source disables service-worker registration
and unregisters old workers/clears CacheStorage on this isolated origin.
However `/` and `/profile` respond `max-age=3600` despite the index file header;
therefore only canonical `/beta/thai` is approved for the current trial link.
Do not promise immediate revocation of already-open tabs or cached alternate
paths. A future permanent site must serve all SPA entry paths `no-cache`,
retain versioned bootstrap/main URLs and avoid caching calculator responses.

## Release procedure — approval required before any release action

1. Owner approves the limited Preview-link trial, audience and wording, with
   the expiry above. Keep PR Draft. Recheck channel version and three hashes
   immediately before sharing; if changed, stop and verify the changed bytes.
2. Share the canonical QA URL through the Owner's chosen channel. No merge,
   deployment, old-site link edit or backend/CORS mutation is needed for this
   option. No external message was sent by this preflight.
3. Stop sharing before expiry. An extension is a separate explicitly approved
   Preview action with `--no-authorized-domains`; do not silently rebuild or
   redeploy a new HEAD just to renew the URL. Any new artifact must be tied to
   its SHA and checked for the changes that invalidate prior evidence.

For a permanent release, use a **dedicated Hosting site/origin**, never the
default KnowMe site's live channel. Only the default site currently exists.
After separate approval: choose/create the new site, configure its exact HTTPS
origin in the calculator CORS without changing IAM/Auth, produce a Hosting-only
config with explicit `site` and no-cache for all entry paths, and prepare a
closed/unavailable baseline. Clone the approved trial content to that site's
Preview (or build a new SHA-pinned artifact if headers/content change), verify
hashes/headers/CORS and only the affected new-origin privacy/network journey.
Record the new site's baseline version and promote only that site's reviewed
Preview to its live channel. Cross-site clone creates a new version ID; record
the mapping and verify bytes rather than expecting `8c0fe2f95d66d02d` to persist.
No such site creation, CORS update, Preview clone or live promotion was done.
The unprepared site, rejected new-origin CORS and cache hardening mean this
permanent option is **NOT READY** today.

## Rollback / stop procedure

- Existing Preview-link trial: withdraw the shared link. To stop new loads
  after Owner authorization, delete only channel `pr-149-overall-safe` with
  project/site explicitly `knowme-app-694e1`, or let it expire. No live rollback
  is needed because the original live version never changed. Deleting a channel
  is a shutdown, not an asset rollback; cached/open clients may continue until
  reload and backend access is not revoked by removing the link.
- If a later Preview update is planned, preserve the QA version in a separate
  backup Preview first and verify the backup's hashes. Restore by cloning that
  backup to `pr-149-overall-safe`; never target `:live` for Preview rollback.
  No backup channel was created during this preflight.
- Permanent dedicated site: before promotion retain its baseline Preview/version.
  On failure withdraw the link and clone that dedicated baseline to that site's
  live channel, then verify index/bootstrap/main hashes and CORS. The old KnowMe
  site remains outside both promotion and rollback commands. No rollback command
  is executable now because the dedicated site/baseline does not yet exist.
- Emergency guard only if an independently authorized future action changes
  original KnowMe live: Firebase console Hosting Release history → Roll back
  the release pointing to `d32e72678324e634` (current baseline), then verify
  release identity and saved asset hashes. Re-read baseline immediately before
  any future action; do not assume this version is forever current.
- Stop criteria: hash/version drift, wrong target/default live target, failed
  CORS, forbidden SDK/API/writes, calculation count regression or old-route
  change. Stop promotion, restore only the affected site/channel, and repeat
  only evidence invalidated by the actual change.

References: [Firebase channels/cloning/rollback](https://firebase.google.com/docs/hosting/manage-hosting-resources),
[cache behavior](https://firebase.google.com/docs/hosting/manage-cache).

Documentation update is docs-only. CI must pass on its pushed SHA before final
handoff; exact post-update run/SHA is recorded in the final handoff report,
without recursively editing tracked docs just to embed their own commit ID.


---

Historical records below are superseded by the preflight above.

## 2026-10-05 Hosting Preview and scoped privacy QA — PASS

Local Windows interactive login completed successfully after the Owner selected
and authorized the Google account in Chrome. `firebase projects:list --json`
returned success and included `knowme-app-694e1`; the authenticated Hosting
channel listing also succeeded. No OAuth code/token is included in this record.

The clean checkout and remote PR HEAD were verified at
`11ffc58f092ac19d70d2add370239b67a707f968`, Open and Draft. The retained
`2c6d036` artifact still existed with its original verified hashes, but HEAD
had advanced through documentation-only commits. To keep the deployed version
bound to current HEAD, a fresh local isolated build was produced with Flutter
3.41.3/Dart 3.11.1 using `tool/build_trial_web.py`, the actual Backend Preview
URL, `KNOWME_OVERALL_PREVIEW=true`, the trial entrypoint and Evidence Badge off.
Its generated registrant and fail-closed API/SDK bundle guards passed. `pub get`
and the build left the tracked worktree clean. No application fix was needed.
The earlier full CI at `2c6d036` is historical regression evidence; a new full
Flutter/backend suite was not run in this browser QA session.

Only Firebase Hosting channel `pr-149-overall-safe` was deployed, project
`knowme-app-694e1`, using a Hosting-only config and `--no-authorized-domains`.
Preview version: `8c0fe2f95d66d02d`; release `2026-10-05T06:30:26.861Z`;
expiry `2026-10-12T06:30:21.083714850Z`.
Review URL: https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai
Hosted downloads matched the fresh build SHA-256 for all three assets:

| Asset | SHA-256 |
| --- | --- |
| main.dart.js | e1b6629b726d5807852e899d5d230d4cb67db235e99d9bd8fac61af1632e4d23 |
| flutter_bootstrap.js | 1d1795d381d2c3f0a5efaf9cc6a51bbde28ec06f3b76034994137ff794146e83 |
| index.html | c2d36a891c8960d793fa6a109a33f0b5adfaccab698d2696754adb559f271ade |

Fresh known-time journeys were run from page reload through synthetic input,
Overall, Thai, Chinese, Western and back to Overall after each reader at
390x844 and 1280x800 CSS px. Width/height were measured in the page, not inferred
from the browser window. All four report layouts had document width equal to
the viewport, and observed screenshots showed readable layouts without
horizontal clipping. Fixtures used 1/1/2001, Bangkok, 00:00 on mobile and
12:00 on desktop; names were synthetic. Chrome's 80% desktop zoom initially
caused automation coordinate/focus mismatch; the accepted mobile run restarted
from reload at verified 390x844, and input coordinates were corrected. Earlier
sizing/input attempts are not used as accepted journey evidence.

CDP Network capture began before each accepted reload, with cache disabled.
Fresh reload reset the trial's in-memory state; no saved Firebase login was
used by the trial. All accepted traces were untruncated. For each known-time
run, exactly two POSTs were sent to the separate Backend Preview:
`/v1/calculate-bazi` and `/v1/calculate-chart`, both HTTP 200. Switching readers
and returning to Overall added zero POSTs. Both fresh unknown-time runs showed
the explicit requirement for known birth time and sent zero POSTs after form
submission attempts. The request/response relationship was checked by CDP
request ID; OPTIONS responses were not counted as calculation POST responses.

| Fresh case | CSS viewport | HTTP requests | Calculation POSTs | Forbidden requests | Other writes | Failed requests |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Known time, complete reader journey | 390x844 | 30 | 2, both 200 | 0 | 0 | 0 |
| Known time, complete reader journey | 1280x800 | 29 | 2, both 200 | 0 | 0 | 0 |
| Unknown time, fail closed | 390x844 | 18 | 0 | 0 | 0 | 0 |
| Unknown time, fail closed | 1280x800 | 18 | 0 | 0 | 0 | 0 |

Forbidden checks cover Google Sign-In SDK, Firebase Auth/Firestore SDK and
API URLs, and the Production API. Other mutation methods outside the two
Preview calculation POSTs were absent. Counts in the table are HTTP(S)
requests; local browser-extension resources were visible in the trace and
were not counted as application HTTP requests. Network absence is scoped to
these synthetic journeys, not a claim of wider Production or backend audit.
Browser emulation and cache overrides were cleared after QA.

Production Hosting `live` stayed at version `d32e72678324e634`, release
`1790074568414000`, release time `2026-09-22T10:56:08.414Z`, in authenticated
before/after/final channel reads. A final read-only download of live index,
bootstrap and main JS also matched the saved pre-deployment SHA-256 baseline.
No Production API was called for QA. No Merge, live/Production deploy,
Backend deploy, Firestore/rules/IAM/Auth configuration change occurred.
PR #149 remains Open and Draft. Owner wording/visual acceptance is separate
from this completed scoped Hosting Preview/privacy QA. This documentation
commit records evidence for the deployed source SHA above; it does not claim
that a later docs-only HEAD was rebuilt or redeployed.

## 2026-10-05 authentication recheck — STOP before Preview deployment

Rechecked the existing isolated Firebase CLI credential store and retained
terminal/debug logs without starting another login. Credentials still have
no user or tokens; only a pending remote-login state remains. CLI and Chrome
are on the same local Windows host `DESKTOP-HF53LFO`, confirmed again by
local Chrome process and host inspection. This is not a remote runner.

`firebase projects:list --json` returned exit 1 with the actual error:
`Failed to authenticate, have you run firebase login?`
It did not return a project list. Visibility of `knowme-app-694e1` and Hosting
permissions are unverified, not denied by a verified project permission check.

The latest retained localhost login log records the supported corrected
command `firebase login --reauth --interactive --debug`, detected agent
`codex_cli`, and `Waiting for authentication...`. It contains no successful
login or observed token-exchange error. The previously verified TCP listener
at localhost:9005 is now absent. Therefore the callback flow did not complete
in the recorded evidence and the old login page cannot be treated as an
active session. The exact server-side cause of the earlier generic
`auth.firebase.tools` OAuth error remains unknown; no server error code is
available. The earlier noninteractive remote flow was unsuitable for this
same-machine code-free handoff; AI-agent detection forced that mode until
`--interactive` was explicitly supplied.

No new login was started in this recheck, per Owner instruction. Stop here.
The single required Owner action, when ready, is to complete one fresh
same-machine interactive localhost login in a terminal kept running through
the Google account choice and callback; use the same isolated credential
store and `firebase login --reauth --interactive --debug`, not an old
`auth.firebase.tools` link. No token or code should be sent through chat.
Then require `firebase projects:list` containing `knowme-app-694e1` before
any Hosting operation, and rebuild/verify at current PR HEAD before Preview.

Reported log excerpts omit OAuth URL queries, tokens, codes, state and other
secrets. No Preview deploy, hosted hash verification, fresh browser journey
or QA PASS is claimed. No live, Backend, Firestore, rules, IAM, Auth
configuration or Merge change occurred. PR #149 remains Draft.

## 2026-10-04 OAuth diagnosis — localhost callback prepared, project gate not passed

CLI and Chrome run on the same local Windows host, `DESKTOP-HF53LFO`, not a
remote runner. Local process inspection confirmed Chrome at its installed
Windows executable. CLI is Firebase Tools 15.32.1 with Node v24.18.0.
The previous `login --no-localhost` terminal output generated a remote login
URL and exited after instructing completion with an authorization code. No
retained debug log for those earlier login attempts was found; the browser
reported the generic OAuth error recorded below. There is no evidence for a
more specific server-side error or a project permission denial.

Read-only `firebase projects:list --debug` failed with exit 1:
`Could not load the default credentials.`
`Failed to authenticate, have you run firebase login?`
The isolated credential store has pending login state but no user or tokens.
`knowme-app-694e1` visibility and Hosting permission are therefore unverified.
Raw logs remain outside the repository; reported diagnostics omit OAuth URLs,
tokens, codes, state, attestation and other secrets.

Installed CLI source confirms automatic AI-agent detection forces
noninteractive mode, even after removing `CI=true`; the supported
`--interactive` flag overrides it. The local-machine correction is:
`firebase login --reauth --interactive --debug`
with the same isolated credential store. This command is now waiting for
Google authorization and a TCP listener was verified at `localhost:9005`.
The new Google account chooser opened automatically; no account was selected
by the agent. It bypasses the failing remote auth proxy using the normal
same-machine OAuth callback, without asking for a code through chat.
The sole pending Owner action is to select and authorize the account in that
new Firebase CLI tab. Login success is not yet claimed.

After callback completion, require successful `firebase projects:list`
containing `knowme-app-694e1`, then verify Hosting access before deployment.
HEAD changed through status-document commits, so build and verify a fresh
trial artifact at the current HEAD before deploying only Hosting channel
`pr-149-overall-safe` with `--no-authorized-domains`. No Preview deployment,
hosted hash match, fresh mobile/desktop journey, unknown-time Network PASS,
Production release audit or QA PASS has occurred in this diagnostic step.
No live, Backend, Firestore, rules, IAM, Auth configuration or Merge change.

## 2026-10-04 Hosting Preview preflight — authentication pending, no deployment

The remote Draft PR #149 HEAD and clean isolated checkout were verified at
`2c6d036ba8c4ff7d0b7fe3c96386145399fcc9f2`. GitHub run `37181519727`
completed successfully at that exact SHA. Artifact `11295690546`
(`pr149-trial-web-2c6d036ba8c4ff7d0b7fe3c96386145399fcc9f2`) was downloaded
and its ZIP SHA-256 matched GitHub:
`0ab066d7afbd396daa8ed68a149cfa2ee5167c518f1813f13093ad67103a90a8`.
Its version and calculator URL match the current workflow and build script:
`https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`.
All three asset hashes matched `trial-build-evidence.json`:

| Asset | SHA-256 |
| --- | --- |
| main.dart.js | d4025831ba41ce34af90152da33ab49c609667a96bb08d5cac11a07a25386567 |
| flutter_bootstrap.js | 1621f7f64e6adb45daf41ac59116cb6018f9c16860d8d8dba9a62d93362d5fd5 |
| index.html | 01299520a556d3e9c86862451e99fb2a17540ec49b4c3f5e18a50f5c1d638f5f |

Literal bundle checks found none of the forbidden Google Sign-In, Firebase
Auth/Firestore SDK or API URL strings. The Production host string remains
only in the fail-closed configured-URL rejection, not as the trial endpoint.
This is static evidence only, not hosted Network QA. Preview calculator
OPTIONS returned HTTP 200 for the exact safe Preview origin.

The earlier browser login ended with the actual message:
`An OAuth error occurred during sign in. Try starting over by running the login command again:`
`firebase login --no-localhost`.
The isolated CLI subsequently reported:
`No authorized accounts, run "firebase login"`.
A fresh `firebase login --no-localhost` was started on the same machine and
its printed URL opened for the Owner to select and authorize the account.
No existing Google account session was selected automatically and no code
was requested through chat. Login completion and project access are pending.

Only a Hosting-only configuration pointing to the unmodified CI artifact has
been prepared outside the repository. No deployment command has run. The
required channel is `pr-149-overall-safe`, project `knowme-app-694e1`, with
`--no-authorized-domains`. No hosted/build hash comparison, fresh known-time
390x844/desktop journey, unknown-time zero-POST test or hosted privacy PASS
is claimed. Public live asset hashes were saved as a read-only baseline;
no authenticated live release/version verification has yet been completed.
No Merge, Production/live deploy, Backend change, IAM, Auth, Firestore or
rules change occurred. Keep PR Draft. Recheck HEAD before deploying; if HEAD
changes, rebuild and verify the new trial artifact before any deployment.

## 2026-10-04 verified trial bundle handoff — Preview QA pending

The isolated trial build at `d43c879` passed CI (run 37118099501),
including its generated web registrant and bundle guards. GitHub Actions
now exports the verified `build/web` as a short-lived artifact named with
the commit SHA. Its cache version is also the commit SHA; the export step
rechecks the three hosted entry assets against the script's SHA-256 evidence.

This makes the exact tested bundle available for a Preview-only deployment.
It is **not** a hosted privacy PASS. No new Hosting Preview deployment or
fresh 390×844/desktop browser Network journey has been performed for this
artifact; old Preview results must not be attributed to it. The remaining
gate is a fresh run from birth form through Overall and Thai/Chinese/Western:
zero Google Sign-In/Firebase Auth/Firestore SDK or API requests, zero
Production API requests and writes, two successful calculator POSTs with no
recalculation on reader switches, and the unknown-birth-time case with
zero POSTs. Compare hosted index/bootstrap/main JS SHA-256 to the artifact.
Keep PR Draft and stop before Merge or live deployment.

## 2026-10-03 isolated trial staging graph fix — CI pending

The previous isolated-trial build failed before compilation because the disposable
stage copied `.dart_tool/package_config.json` but not pub's
`.dart_tool/package_graph.json`. GitHub Actions job 111176171402 reproduced
the same missing-file error. The build script now checks for the graph produced
by the same root `flutter pub get` and copies it into the stage beside the
package configuration before calling `flutter build web --no-pub`.

This is a narrow staging repair, **not a privacy-gate PASS**. No successful
trial bundle, generated-registrant verdict, hosted hash comparison, fresh
390×844/desktop journey or Network trace is claimed yet. Keep PR #149 Draft;
do not deploy Preview unless the isolated build and static privacy guards
pass, and do not merge, deploy live or change Firestore/IAM. Preserve the
existing app build and all prior work. Recheck CI on this commit before any
Preview action.

## 2026-10-03 isolated trial build follow-up — FAIL, deployment stopped

Local work began at `0bbd2d1`; remote documentation HEAD `40568a9` was later read and preserved in the
existing isolated checkout. The Owner explicitly prohibited merge/live deploy
and required stopping if a gate fails.

Added a dedicated `lib/main_trial.dart` entrypoint with no Firebase
initialization or main-app Auth shell. `tool/build_trial_web.py` stages source
and dependency libraries in `.trial-build/`, removes plugin declarations only
from private dependency manifest copies, and intends to reject any generated
web plugin registration or forbidden Auth/Firestore SDK URL in the bundle.
The original `lib/main.dart`, root dependency manifest/lockfile, Pub cache and
main `build/web` were not changed by this build attempt. The staged dependency
libraries still include shared types; this is a registration-isolation design,
not a claim that the source import graph is Firebase-free.

**Build gate: FAIL.** Flutter 3.41.3 invoked with `--no-pub` stopped because
staging lacked `.dart_tool/package_graph.json`:
`Failed to load .../.dart_tool/package_graph.json ... Try running flutter pub get`.
The earlier staging preparation also encountered a native-only plugin without
`lib/`; optional library copying fixed that preparation issue. The subsequent
actual Flutter build failure triggered the requested stop. No compiled trial
bundle exists from this attempt, so plugin/bundle privacy checks have not run.
The new CI job `isolated-trial-build` reproduced the same missing
`package_graph.json` failure on Linux/Flutter 3.41.1 at commit `8886284`:
[CI job 111176171402](https://github.com/notekmitl/knowme/actions/runs/37113648456/job/111176171402).
The job completed with **failure**, exit code 1; its log was inspected directly.
Other regression jobs were still running when this failed gate was recorded;
no complete-suite PASS is claimed. Implementation work stopped on the failed
build gate; this subsequent commit records evidence only.

**No Preview deployment, hosted/build hash verification, fresh 390x844 or
large-screen journey, Network gate PASS, merge, or live deployment occurred.**
The existing Preview remains the preceding version `951405a94a946da3`, which
had the documented startup SDK privacy failure. This version is not evidence
for the new trial entrypoint. Previous live/calculator versions below are
historical observations, not a fresh Production audit in this follow-up.

Next prerequisite is a complete, reproducible staged dependency graph that
Flutter can consume without reintroducing plugin registration. Do not deploy
the staged trial until its build and fail-closed registrant/bundle checks pass.
Existing unrelated local changes were preserved.


## 2026-10-03 privacy gate diagnosis — PR #149 remains Draft

The Production-shaped Preview built from PR HEAD `0bbd2d1` reached Overall
and the three individual readers without Auth/Firestore API calls or writes,
but its startup still fetched Google Sign-In, Firebase Auth and Firebase
Firestore SDK scripts. The strict network gate is therefore **FAIL**. This is
not evidence that birth data was written, and it is not a reason to weaken
the gate. Hosting live and the signed-in Production API remain unchanged.

Source review confirms that `lib/main.dart` calls `Firebase.initializeApp`
before choosing the anonymous landing when `KNOWME_OVERALL_PREVIEW=false`.
Flutter's web build also generates its plugin registrant from the project's
plugin dependencies before calling the application entrypoint; selecting an
anonymous widget cannot by itself exclude a Google Sign-In web plugin from
startup. This is supported by Flutter's `WebEntrypointTarget` source, which
injects the web plugin files before generating the entrypoint. The precise
loading behavior is established by the hosted CDP network trace above.

**Next implementation target:** build the temporary trial as an isolated Web
artifact with an anonymous-only entrypoint and a dependency/plugin graph that
does not register Google Sign-In, Firebase Auth or Firestore. Share only the
calculation and reader code needed for input → Overall → Thai/Chinese/Western;
keep existing signed-in code and its normal build intact. Do not edit generated
JS or registrant output, suppress network errors with CSP, or silently treat
SDK GETs as a pass. First inspect the imports and build tooling and choose a
maintainable minimal extraction. Keep the separate zero-role calculator and
its exact-origin CORS unchanged unless tests prove a necessary adjustment.

Acceptance requires a fresh, uncached synthetic input journey at both
390×844 and desktop width: zero requests to Auth/Firestore/Google Sign-In SDKs,
zero Production API calls or writes, exactly two successful calculation POSTs
to the isolated calculator, no recalculation when switching readers, no
horizontal overflow, and the unknown-time fail-closed case with zero POSTs.
Run full Flutter/backend regression and verify the hosted asset hashes. If
any gate fails, keep PR Draft and stop before Merge or Hosting live deploy.
No code fix, new hosted build, merge, Production deploy, Firestore/IAM change,
or fresh complete journey is claimed by this diagnosis.


## 2026-10-03 release attempt from HEAD `7919f56` — BLOCKED before merge/live

The remote PR HEAD was verified as
`7919f569800588c5914d85ceb1113fb0987ce68e`, Open and Draft.
[HEAD CI run 37105209279](https://github.com/notekmitl/knowme/actions/runs/37105209279)
passed. Work used a new isolated checkout; existing checkouts and their pending
changes were not edited, stashed, reset, or committed.

Read-only preflight verified Hosting live version `d32e72678324e634`
(release `1790074568414000`) and existing Production API revision
`knowme-astrology-api-00014-j2z` at 100% traffic. Hosting release history
still exposes prior releases. The live version above is the rollback target
for any subsequent Hosting release; no rollback was executed in this attempt.
The calculator rollback revision is
`knowme-overall-pr149-preview-00001-gfn`.

The separate calculator was deployed from the persistence-free staged source
to the existing service `knowme-overall-pr149-preview`, revision
`knowme-overall-pr149-preview-00002-6ql`, at 100% traffic.
Its actual calculation URL remains
`https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`.
Runtime service account
`knowme-pr149-overall-preview@knowme-app-694e1.iam.gserviceaccount.com`
has no project IAM bindings; the project has no parent IAM scope.
The existing public invoker binding was preserved. No IAM role was added.
Project IAM policy before/after was identical.
`CALCULATOR_ALLOWED_ORIGINS` contains exactly:
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app`,
`https://knowme-app-694e1.web.app`, and
`https://knowme-app-694e1.firebaseapp.com`.
Preflight OPTIONS returned 200 with the exact matching origin for each;
`https://example.com` returned 400.

Flutter 3.41.3 built the normal Production-shaped Web release with
`KNOWME_OVERALL_TRIAL=true`, the actual calculator URL as
`OVERALL_CALC_API_BASE_URL`, the unchanged signed-in Production API as
`ASTROLOGY_API_BASE_URL`, and `THAI_PUBLIC_EVIDENCE_BADGE_BETA=off`.
`KNOWME_OVERALL_PREVIEW` was not enabled. Only Hosting Preview channel
`pr-149-overall-safe` was deployed, using `--no-authorized-domains`;
version `951405a94a946da3`, expiry October 10, 2026.
[Review Preview](https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai).
Hosted SHA-256 matched the local build for all three assets:

| Asset | SHA-256 |
| --- | --- |
| main.dart.js | 3CAE370E18147BDFD59788372DACBEA54E076DCDCB5DE9011B20AD7191384197 |
| flutter_bootstrap.js | 7DD266EEA273EE5BE4FE0A401171C47EE2C303CC559A4B5252B213E0F6B78DDB |
| index.html | 24E777DBD905DC52BAC34F4061EC9C37808EF010C8A5E5B65D8DB4AFF87680C1 |

Synthetic known-time input reached Overall, then Thai, Chinese and Western,
returning to Overall after each. Input/calculation began at 487 CSS px width
because Chrome uses 80% zoom. All four report layouts were subsequently
verified at 390x843 CSS px and 1920x911 CSS px; document width matched each
viewport and the visible report layouts had no clipping. Desktop reused the
same in-memory charts; a fresh desktop input-to-result journey and a fresh
390 px input journey were not repeated after the strict privacy failure.
Do not describe this as complete release QA.

CDP captured exactly two calculation POSTs (HTTP 200) to the isolated
calculator and successful OPTIONS preflights. Report navigation at both
widths added zero POSTs. No Auth API/token exchange, Firestore API,
Production API calculation, other mutation, or failed request was observed.
However startup fetched these three scripts by GET:
`https://accounts.google.com/gsi/client`,
`https://www.gstatic.com/firebasejs/12.7.0/firebase-auth.js`, and
`https://www.gstatic.com/firebasejs/12.7.0/firebase-firestore.js`.
**The strict no-Auth/no-Firestore Network gate therefore FAILS.**
This is a Production-shaped bundle privacy blocker, not a missing CLI or
deployment permission. `main.dart` initializes Firebase outside Preview mode,
and web plugin startup also loads Google Sign-In; entering the anonymous
shell alone does not eliminate these SDK fetches.

The URL-split test formerly hardcoded `calculator.example.invalid`; it now
checks the configured HTTPS calculator host and verifies that it differs
from the saved-chart API host. The real-URL configuration test passed 1/1;
the existing UX suite passed 4/4 with its normal defines. The first combined
trial-defined invocation failed because of the hardcoded example host and
the regular-mode CTA expectation; these are not reported as runtime failures.
No application behavior was changed by this test correction.

**PR #149 remains Draft and unmerged; Hosting live remains
`d32e72678324e634`.** Neither `deploy_all.ps1` nor `deploy_web.ps1`
was used. No Firestore rules/indexes or existing Production API were deployed.
No Production user journey or post-release rollback drill was claimed.
Next work must remove startup Auth/Firestore SDK traffic for the anonymous
trial while preserving signed-in routes, then repeat fresh mobile and desktop
input-to-Overall-to-single-reader traces. Only after those and Production
verification pass may the authorized merge and Hosting-only live release occur.


## Release preparation CI — 2026-10-03

Application commit `c6b212e8cd0e17e24404c455d7e5f04dd35e2ebe` passed
[GitHub run 37104494127](https://github.com/notekmitl/knowme/actions/runs/37104494127):
backend regression including calculator CORS, Flutter focused tests and
analyzer, regular Web build, trial-shaped Web build and its API split guard,
and the complete Flutter suite. The local worktree also passed diff whitespace
and Python syntax checks. This validates code and build only. No deployed
Production calculator, live Hosting bundle, or network journey has been
verified; no merge or Production deployment occurred. PR #149 remains Draft.

## Release preparation patch — 2026-10-03 (CI pending)

Owner authorized continuing the trial launch. This patch is scoped to the
anonymous trial: a normal Production Web build can set
`KNOWME_OVERALL_TRIAL=true` and a distinct HTTPS `OVERALL_CALC_API_BASE_URL`
while retaining `ASTROLOGY_API_BASE_URL` for signed-in readers. The existing
`KNOWME_OVERALL_PREVIEW=true` behavior is preserved for the isolated Preview.
The trial landing no longer reads Firestore participation counts or promises
research submission; it explains transient calculation. Trial Thai report
keeps its anonymous audience without Auth listeners. The standalone
persistence-free calculator supports an explicit comma-separated set of exact
HTTPS CORS origins, while the Preview's single `PREVIEW_ORIGIN` remains
supported. Tests cover the no-read landing, API separation, and CORS.
The branch workflow now checks a Production-shaped trial build and backend
regression in addition to its existing Flutter suite.

Local static checks: `git diff --check` and Python `py_compile` passed in a
clean isolated worktree. Flutter, backend runtime tests, build and hosted
network QA were not run in this execution environment. The PR stays Draft;
CI results and live Production state must be inspected before any merge or
deployment. No Firestore rules, IAM, existing signed-in endpoint, Production
Hosting, or Cloud Run service was changed by this patch.

## Active release gate — PR #149 trial launch (2026-10-03)

Owner asked to proceed with the temporary public astrology trial after reviewing
its desktop and mobile presentation. The reviewed PR HEAD was `893a982`, Open
and Draft; its GitHub validation run `36670068341` succeeded. This is a
release preparation authorization, not a claim that Production is live.

**Release gate: BLOCKED before merge or Production deploy.** The checked
application source is `d987396` (the later HEAD changes only these three
documents). The Preview build flag skips Firebase initialization for the
whole application; it cannot simply be reused as a Production build. A normal
Production build still reads Firestore participant count on the public landing
page and uses the same API base URL for anonymous calculations and signed-in
readers. **Correction to the preceding audit commit:** Backend source already
defines both anonymous endpoints in routers imported by `backend/app/main.py`;
the currently deployed Production API revision has not been verified to
include them. The isolated calculator permits only its Preview origin, so its
CORS config needs a scoped public release. The existing `deploy_all.ps1` / `deploy_web.ps1` change IAM or
Firestore rules and are unsuitable as-is for this scoped release.

The checkout used for this audit is at application `d987396` and contains
four unrelated modified binary acceptance artifacts; they were preserved.
GitHub was checked read-only for PR/CI/source. This execution environment has
no Flutter, gcloud or Firebase CLI and cannot connect to the Git remote or
verify the current live Hosting/Cloud Run state. No local runtime test, merge,
Production deploy, Firestore access, IAM change, or live rollback was made.

Next gate: implement an isolated, persistence-free calculator for the public
Production origins under a zero-project-role service account; separate its URL
from the existing signed-in API; confine anonymous trial behavior to the
public trial route; remove the participant-count read and research/storage copy
from that route; add targeted privacy, route, CORS and regression tests. Build
and inspect the actual Production bundle, pass CI, then verify live versions
and rollback targets before a controlled Backend/Hosting release and synthetic
end-to-end network check. Preserve other site routes, signed-in flows, existing
Firestore rules and IAM. Update this gate with actual results, not a planned PASS.

# Overall astrology from three traditions — V1 working branch

## 2026-09-30 desktop and mobile Hosted Preview QA — HEAD `d987396`

The release Web build used `flutter build web --release --no-wasm-dry-run` with
`KNOWME_OVERALL_PREVIEW=true`,
`ASTROLOGY_API_BASE_URL=https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`,
and `THAI_PUBLIC_EVIDENCE_BADGE_BETA=off`. The generated bootstrap and index
were pinned to `?v=d987396` to avoid the old immutable entrypoint cache. Only
`firebase hosting:channel:deploy pr-149-overall-safe --project knowme-app-694e1
--no-authorized-domains` was run. Neither the Production Web deploy script nor
a Firestore deployment was used. The channel now serves version
`ebcccf4335dd905a`, expiring `2026-10-07T04:17:55Z`, at
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai`.
Firebase Hosting `live` was `d32e72678324e634` both before and after.

The three hosted files were fetched from the channel and compared byte-for-byte
by SHA-256 against the local build:

| File | SHA-256 | Match |
| --- | --- | --- |
| `main.dart.js` | `95997D4ADF7C3ED5CB7F580268BC9F698F5B778EB0BF7C0681ACF1AD256EA413` | Yes |
| `flutter_bootstrap.js` | `76D07B6F0242A051821FEE74715611E2A20976BD2D032111346F1D735225C51B` | Yes |
| `index.html` | `7D3EBD41D59FE7D3885676E9F3BCE5FD75888323304AF93DB5D793F7D496F6F5` | Yes |

Chrome QA used synthetic birth data (15 January 2001, 12:00, Bangkok) and
followed birth input → Overall → Thai → Overall → Chinese → Overall → Western
→ Overall twice: once at a 1920×911 CSS viewport and once at 390 px CSS
width. On desktop the four report pages filled a 1920 px document width with
no horizontal overflow. Overall's four topic readings paired into two
columns; Thai's summary cards paired; BaZi placed the four pillars and
element bars beside its header; Western placed the Big Three beside element
bars. The mobile sequence stacked cleanly with no visible clipping. Exact
390×844 raster screenshots and 390×844 CSS document-width checks were captured
for all four mobile report pages. The interactive mobile run measured 390×843
CSS px because this Chrome profile is at 80% zoom; its document/body widths
were 390 px on all four report pages. The expanded Thai report also stayed at
390 px. Desktop screenshots were captured at the exact CSS viewport, with
1536×729 raster pixels due to the same zoom. All eight review screenshots
are saved outside the repository for Owner visual review; they do not constitute
Owner approval.

Each fresh journey sent exactly two HTTP 200 POSTs to the isolated Preview
Backend: `/v1/calculate-bazi` and `/v1/calculate-chart`. Switching readers
and returning added zero POSTs. The complete captured request streams had no
Firebase Auth API, Firestore API, Production API, other mutating request, or
failed request. Each fresh load fetched the Google Sign-In SDK at
`accounts.google.com/gsi/client` by GET only; there was no login or token
exchange. The prior [CI for HEAD `d987396`](https://github.com/notekmitl/knowme/actions/runs/36557612304)
passed. This QA found no implementation defect requiring a code change. Keep
PR #149 Draft for Owner visual acceptance, with no merge or Production deploy.

## 2026-09-29 desktop infographic follow-up — CI passed, Hosted Preview pending

Owner supplied four actual 1920×911 desktop screenshots of the updated
Preview. All four readers were restricted to narrow centered columns despite
the wide screen; Overall and BaZi still relied on long stacked prose. The
390 px mobile QA in the previous section did not cover this desktop issue.
This follow-up changes anonymous trial layout only: Overall uses a wider hero
and pairs life-topic readings on wide viewports; Thai widens its headline and
four-topic dashboard while retaining a readable-width full report; BaZi pairs
calculated pillars/balance with its title before the reading column; Western
pairs the Big Three with calculated element balance and keeps prose at a
readable line length. Under 1000 px the original mobile sequence remains.
A 1440 px widget regression checks the paired panels, width and absence of
Auth resolution. No prediction wording, calculation, evidence threshold,
single-reader route, or storage behavior changed. Application commit
`a1f8e53` passed focused tests, analyzer, Web build and the full Flutter suite
in [run 36556331033](https://github.com/notekmitl/knowme/actions/runs/36556331033).
Hosted Preview visual and network QA for this follow-up remain pending. Keep
PR #149 Draft; do not merge or deploy Production.

## 2026-09-29 trial reader follow-up — Hosted Preview QA

Application HEAD `38ec9e4` was built for Web release with
`KNOWME_OVERALL_PREVIEW=true` and
`ASTROLOGY_API_BASE_URL=https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`.
Only Hosting channel `pr-149-overall-safe` was deployed, using
`hosting:channel:deploy ... --no-authorized-domains`; its version is
`74f410f08aac6446` and it expires `2026-10-06T09:05:18Z`.
Review URL:
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai`.
The hosted `main.dart.js`, `flutter_bootstrap.js`, and `index.html` SHA-256
hashes match the new local build. The JavaScript hash is
`472F05CC5052312D0F9B802BB494E2CE5E9743A387937821B7EF38631FC95C5A`.
The Preview backend host appears in the bundle; the Production backend host
appears once in the negative Preview guard and was never called at runtime.
Production Hosting `live` stayed at `d32e72678324e634` before and after.

Chrome QA used synthetic birth data (15 January 2001, 12:00, Bangkok) and
followed input → Overall → Thai → Overall → Chinese → Overall → Western →
Overall. The four report pages measured 390 CSS px wide and 843 CSS px high
because this Chrome profile is at 80% zoom. Four review screenshots are
390×844 raster pixels. An exact 390×844 CSS viewport check on Overall also
showed 390 px document/body width. No visible horizontal clipping or report
overflow appeared. The expanded Thai full report remained readable at mobile
width. Thai showed four summary cards, Chinese showed four pillars and element
bars, and Western showed the Big Three and calculated element bars before its
reading. The original full Thai report remained available after expansion.

The known-time flow sent exactly two calculation POSTs, to
`/v1/calculate-bazi` and `/v1/calculate-chart` on the isolated Preview
backend; both returned HTTP 200. Their CORS OPTIONS preflights also returned
200. Reader navigation and returns sent zero additional POSTs. The captured
request stream had no Firebase Auth API, Firestore API, Production API, or
other mutating request, and no failed request or browser console error.
Resource timing did record a static GET of the Google Sign-In SDK at
`https://accounts.google.com/gsi/client`; no login or token exchange followed.
This run did not repeat the unknown-time case. CI for `38ec9e4` passed in
[run `36527236124`](https://github.com/notekmitl/knowme/actions/runs/36527236124).
PR #149 remains Draft; Owner visual approval is still pending. No Production
Hosting deployment, Production backend change, Firestore write, or merge was
performed for this QA.

## 2026-09-29 trial reader visual follow-up — implementation history

The live Preview review after `5de5dc8` found that Thai still led into the
long original report and Western returned to prose after the Big Three tiles.
This branch changes only the anonymous trial presentation: Thai now shows four
existing life-dashboard readings as distinct visual cards and keeps the full
unchanged report behind an explicit expandable control. Western promotes its
existing calculated element percentages into bars before the overview; the
expanded technical section omits only that duplicate balance panel. When
element data is absent, no invented bar or value is shown. Overall, BaZi,
calculation, wording, evidence threshold `0.6`, and standalone reader routes
are unchanged. The Thai annual infographic remains visible in the expanded
trial report, but its save-image action is hidden there; standalone export
behavior is unchanged. A mobile widget regression checks the visual cards, the
collapsed/full Thai report, Western bars, anonymous navigation and no auth
resolution, as well as the absence of trial save controls; the full CI result
passed on application HEAD `aee15a9` in
[run `36525893195`](https://github.com/notekmitl/knowme/actions/runs/36525893195),
including focused tests, analyzer, Web build, PDF dependencies and the complete
Flutter suite. The follow-up margin adjustment avoids nested horizontal
padding when Thai's full report opens on a narrow screen.

This was the implementation gate before the `38ec9e4` hosted run recorded
above. Keep PR #149 Draft; Owner visual approval remains open.

## 2026-09-28 infographic follow-up — historical Hosted Preview review

Owner's rejected screenshots showed Overall as long text cards, Chinese copy
too small and wide, and mismatched Thai/Western presentations. This follow-up
was checked against that recorded infographic brief. The earlier approved
mockup is unavailable in this checkout, so pixel-level matching and Owner
visual acceptance are **not claimed**.

From implementation baseline `8674173` (CI success in
[run `36395545054`](https://github.com/notekmitl/knowme/actions/runs/36395545054)),
the trial-only presentation was refined after actual mobile inspection.
Overall retains its calculated three-source tiles and now presents the four
unchanged life-topic readings as a numbered, color-coded reading path with
17 px body copy rather than plain white text cards. Western puts the
calculated Sun/Moon/Ascendant tiles before its unchanged overview text and
increases the tile labels. Chinese increases the trial body/row type and the
element-count note. Thai's computed headline and tags remain above the
existing full report. No prediction prose, source calculator, 0.6 evidence
threshold, conflict rule, trial navigation, or standalone reader was changed.
Focused consensus/navigation widgets passed **34/34** and changed-file
analyzer found **0 issues** before the safe release build.

Only Hosting Preview channel `pr-149-overall-safe` was updated, using
`KNOWME_OVERALL_PREVIEW=true`, the separate
`https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app` Backend,
and `--no-authorized-domains`. The review URL is
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai`.
Hosting version `fe118cb0c1ce3427` expires `2026-10-05T08:59:29Z`.
Downloaded hosted `main.dart.js` SHA-256
`6CB044521CCBE49710A803725FBEB1C240D57595D6E910B30F33E36C5EBDBE67`
matches the local build byte-for-byte; `flutter_bootstrap.js` and
`index.html` also match. The bundle contains the Preview Backend and both
calculate paths, contains no Firebase Auth/Firestore endpoint strings, and
retains the Production hostname only in the negative Preview URL guard.
Production Hosting `live` is still `d32e72678324e634` with its original
release time; Production Backend and Firestore were not deployed or edited.

Real Chrome QA used a 390 px CSS width (843 px CSS height because this Chrome
profile is zoomed to 80%); saved review images are 390×844 raster pixels.
A synthetic known-time birth input reached Overall, then Thai → Overall →
Chinese → Overall → Western → Overall. All four top views were visually
inspected, and the lower two Overall topics were inspected after scrolling.
The four topics were present, report text was readable, and the measured
document/body widths were 390 px on Overall and each individual report.
There was no visible clipping or horizontal scrolling. Screenshots are kept
as local deliverables, outside this repository, for Owner review.

The known-time submission made exactly **two POSTs**, to
`/v1/calculate-bazi` and `/v1/calculate-chart` on the separate Preview
Backend, both HTTP 200. Returning from all three readers made **0 additional
POSTs**. A second synthetic form with a known date/province but an explicitly
unknown birth time stayed on the form with an explanation and made **0
requests after submission**. Its document width remained 390 px; its body
reported 408 px because of a fixed hidden print paragraph, with no visible
overflow. The inspected request traces and resource timing had **0 Firebase
Auth API (`identitytoolkit`/`securetoken`), Firestore, Production API, or
other mutating requests**. Each fresh page load did make **one GET** for the
static `https://accounts.google.com/gsi/client` SDK; no sign-in/token
exchange followed. This fails a literal zero Auth-related URL criterion and
must remain visible in the Owner handoff. PR #149 remains Draft; no merge or
Production deploy was performed.

## 2026-09-28 Hosted overall-first trial QA from `388842e`

The safe Hosting Preview at
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai`
now serves the overall-first trial. Channel version `dd07f6b40bee762a`
expires `2026-10-05T05:13:06Z`. Its hosted `main.dart.js` SHA-256 is
`FFD128E9A851545CD3CBAA4F659EEA564A6293854671979ECC8D0FECB11DA216`,
identical to the local release build made with `KNOWME_OVERALL_PREVIEW=true`
and `ASTROLOGY_API_BASE_URL` set to the isolated Backend Preview. The
Production API hostname occurs in the bundle only in the negative URL guard;
Firebase Auth and Firestore endpoint strings do not occur. Production
Hosting `live` remains version `d32e72678324e634`.

At 390×844, a synthetic known-time form reached the combined report in
**938 ms**, then opened Thai, BaZi, and Western readings and returned to the
combined report after each. The same prepared results stayed in memory:
exactly two POSTs total, `/v1/calculate-bazi` and `/v1/calculate-chart`, both
HTTP 200 from the isolated Backend Preview; there was no recalculation on
opening or returning from any single reading. The combined report showed
all four supported topics. The trial-only Thai report needed a visible back
button; it now has one and omits its feedback and capture-route controls.
Standalone Thai report behavior is unchanged. Focused widget and Thai scroll
regression passed **12/12**, and changed-file analysis found **0 issues**.

The synthetic unknown-time form showed an inline reason, stayed on the form
after submit with a clear message, and made **0 POSTs**. Every inspected
screen had document width 390 px and horizontal scroll extent 0. The
unknown-time form's `body.scrollWidth` was 408 px because of one fixed,
hidden print paragraph outside the viewport; its document width remained
390 px and the screenshot showed no clipped content. Screenshots and raw
request traces are retained only in ignored local QA files. No private
birth values or chart placements are recorded in this document.

Network caveat: Firebase Auth API (`identitytoolkit`, `securetoken`),
Firestore, and Production API requests were **0**; the only mutations were
the two isolated calculation POSTs. The Web plugin
`google_sign_in_web` nevertheless auto-loaded the static
`https://accounts.google.com/gsi/client` script once before the trial shell
started. No login, token exchange, or user write followed. A literal
zero-Auth-related-URL criterion is therefore **not satisfied**. Keep PR #149
Draft for Owner review; do not merge or deploy Production.

## 2026-09-28 Owner-approved anonymous trial flow

Public trial `/beta/thai`: birth input → automatic combined report → optional
individual Thai, BaZi, or Western report. There is no science-selection screen
in the trial route. The form asks for the actual time and province necessary
for a three-source reading; unknown time stops before any API call. The
combined route uses its existing two calculate-only API calls, runs Thai
locally, and retains all three prepared results only while the report is open.
The Thai report receives an anonymous audience explicitly; BaZi and Western
use their read-only presentation widgets rather than the authenticated
generation pages. Back from an individual report returns to the combined
report without another calculation. The old standalone routes and their
persistence behavior are outside this change.

CI for implementation `0692342` passed focused tests, analyzer, Web build,
and the complete Flutter suite in [run `36377679228`](https://github.com/notekmitl/knowme/actions/runs/36377679228). Browser/network
validation of the new flow is still pending.

Acceptance: no sign-in dialog or Auth/Firestore/Production API request from
the trial path; zero writes; two calculation POSTs to the isolated Preview
Backend; mobile 390×844 from input to four report screens without overflow;
unchanged result content and evidence threshold. Current Hosted Preview is
the older build and is **not** proof of this new flow. Refresh the isolated
Hosting Preview and verify browser/network behavior before Owner review. PR remains
Draft, with no Production deployment or merge authorized by this change.

## 2026-09-27 four-topic Owner wording follow-up from `0016ef2`

The four public life-topic readings were edited for natural Thai natal
language. Work no longer says “บทบาทที่คุ้ม” or joins two phrases with
“กันควบคู่กัน”; it still uses the Thai house-10 lord mode, BaZi top Ten God
work focus, and Western Mercury method. Money now describes the existing
BaZi wealth-weight branch and peer-versus-wealth boundary, alongside the
Thai house-2 mode and Western Venus value. Its risk sentence follows the
same calculated BaZi branch instead of adding a generic cash-reserve claim.
Relationships no longer repeat the BaZi phrase “ความชัดเจนและความสม่ำเสมอ”
inside the combined reading. The Chinese source text and gender-specific
spouse-family calculation remain attached internally; the public sentence
uses the same weight to choose a short prominence or gradual-growth meaning.
Wellbeing now combines the Thai house-6 mode, Western Moon recovery action,
and BaZi support-band action in direct prose, without the unsupported
slow-recovery condition. No period, event, diagnosis, or new calculated fact
was added.

The calculation inputs, fail-closed source checks, reviewed main-topic
conflict guard, confidence floor **0.6**, and public hiding of source
evidence are unchanged. Regression checks that changed single-reader prose
cannot rewrite these topics, both money branches use their calculated
weights, male/female relationship branches remain distinct without the
repeated phrase, and all four readings retain their traceable semantic
fragments. Related Flutter tests across Overall and Thai, BaZi, and Western
single readers passed **111/111**; changed-file analysis found **0 issues**.
[CI for implementation commit `ab78e1a`](https://github.com/notekmitl/knowme/actions/runs/36306394788)
passed focused tests, analyzer, Web build, PDF regression gates, and the
complete Flutter suite.

Anonymous Backend Preview calculations for the Owner-requested case and two
synthetic cases produced all four headings without gaps or conflict. The
private QA records hold the full readings and source facts; no personal birth
values or chart placements are stored here.

Final 390×844 Hosted Preview runs for the Owner-requested case, two synthetic
cases, and synthetic male/female variants reached the report in
**492/915/430/928/921 ms** respectively. All five showed **การงาน, การเงิน,
ความสัมพันธ์, การดูแลพลังและกิจวัตร**, with no overflow, leaked evidence
headings, blocked request, page error, or console error. Each made only two
successful anonymous calculation POSTs to the isolated Preview Backend.
There were no Firebase Auth, Firestore, Production API, other write, or
identity/profile requests. Hosted Thai single-menu regression reached its
report with no POST, blocked request, error, or overflow.

Only Hosting Preview channel `pr-149-overall-safe` advanced, to version
`bbd5c201897d8093` expiring `2026-10-04T08:25:24Z`. Its URL is
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai`.
Hosted JavaScript matches the local safe build at SHA-256
`3C2EBF81152C552242D30317534DA8D125E5502FC9F2BC674811F2DFFF8ED958`.
The bundle contains the isolated Backend and both calculation paths, has no
Auth/Firestore endpoint strings, and contains the Production API hostname
only in the negative Preview configuration guard. Production Hosting `live`
remains `d32e72678324e634`. PR #149 remains Draft for Owner wording review.

## 2026-09-27 main-topic conflict guard from `144281d`

Code review confirmed that `ThreeTraditionMeaningAlignment.select()` only
vetoed an optional fifth topic. The four main topics were composed before
that call. The composer now checks a main topic after its three source
readings and calculation bases have qualified, but before adding its public
prediction card. A reviewed direct opposition omits only that topic and keeps
the source `LensThemeOutput` observations, confidence values, and evidence in
the internal `conflicts` model. The page gives a brief withholding notice
without showing per-tradition evidence.

The currently reviewable direct opposition is **expressive versus reserved**
on the relationship-disclosure axis. It applies to the **ความสัมพันธ์** card
only when all three independent lenses each provide exactly one direction,
each has nonempty adapter evidence and confidence at least **0.6**, and the
directions oppose. Two lenses with the same direction and a third with the
opposite are withheld; all three agreeing remain. A missing or weak third
observation does not by itself veto a source-backed topic. A lens carrying
both directions is ambiguous and also does not trigger this narrow veto.
Other relationship traits, such as loyalty and a need for personal space,
remain compatible. The available structured source meanings do not establish
a comparably direct opposite pair for work, money, or wellbeing, so the guard
does not label their different emphases as conflicts. Missing source material
still omits its own topic through the earlier fail-closed path. The agreement
threshold was not changed.

Regression for same, reviewed-near, opposed, mixed, missing, empty-evidence,
and `0.59` observations confirmed that only the conflicting relationship
prediction is withheld; the other three readings remain identical to the
baseline. The mobile widget test confirms the withholding notice and that
source theme IDs stay off the public page. Related Flutter regression across
the Overall flow and Thai, BaZi, and Western single readers passed **109/109**;
changed-file analyzer found **0 issues**. Anonymous calculation diagnostics
for the Owner-requested case and two synthetic cases showed no qualifying
conflict, kept all four topics, and their readings matched the previous
version exactly, character for character. No personal birth values or chart
placements are stored here.

The safe 390×844 Hosted Preview reached the report in **848/347/345 ms** for
those three cases. Every run displayed **การงาน, การเงิน, ความสัมพันธ์,
การดูแลพลังและกิจวัตร**, had no horizontal overflow or browser error, and
made only two successful anonymous calculation POSTs to the isolated Preview
Backend. There were no Firebase Auth, Firestore, Production API, other write,
blocked, or identity/profile requests. Hosted Thai single-menu regression
reached its report with no POST, blocked request, error, or overflow.

Only Hosting Preview channel `pr-149-overall-safe` advanced, to version
`fc83da9dd5153175` expiring `2026-10-04T04:16:37Z`. Its URL is
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai`.
Hosted JavaScript equals the local safe build at SHA-256
`1AA848B2DC95D6693F9DAC17ED8C326445CD0DED837B53919CA6AB83CA6D853B`.
The bundle contains the isolated Backend and both calculation paths, has no
Auth/Firestore endpoint strings, and contains the Production API hostname
only in the negative Preview configuration guard. Production Hosting `live`
remains `d32e72678324e634`. PR #149 remains Draft for Owner review.

## 2026-09-27 Owner follow-up from `d3ff833` — life topics on the safe Preview

The missing relationship topic came from an Overall-only `_relationships()`
guard that discarded the legitimate `male` and `female` BaZi values. The
composer now uses the existing gender-specific spouse-family calculation;
when that required weight is absent, it omits the relationship topic. The
unknown-gender branch retains its neutral reading. Tests cover both gender
values and missing evidence. Single-tradition menu routing and copy were not
changed.

The public Overall page now leads with prediction cards. It no longer shows
“คำอ่านพื้นดวงรายด้าน”, “ตรวจคำอ่านและหลักฐานต้นทาง”, “จุดร่วมที่หลักฐานรองรับ”,
or the per-tradition evidence lists. The calculated source readings, atoms,
codes, and lens observations remain in the reading model for tests and audit.
The fourth displayed topic, **การดูแลพลังและกิจวัตร**, requires the existing
Thai house-6 wellbeing claim and source atom, BaZi Reader V2 balance text and
support-band calculation, and Western Reader V2 wellbeing text and calculated
Moon sign. Missing any required source omits that topic. The Western Moon
recovery registry covers all twelve signs and matched the source reader's
existing meanings in a 48-value parity check across the relevant planet maps.

An optional fifth topic, **ทิศทางและการตัดสินใจ**, is available only when two
lenses have the same supported `independent` meaning and the third has either
the same meaning or the narrowly reviewed nearby `leadership` meaning. A
supported opposing meaning vetoes the combined prediction even if the same
lens also contains a matching observation. Missing, unrelated, or weaker
third-lens evidence cannot complete it. The existing agreement confidence
floor remains **0.6**; the near case explicitly calls itself an interpretive
composition, not exact three-way agreement. None of the three real Preview
cases qualified for this optional topic, so the page correctly showed four.

Related Flutter regression passed **95/95**, including exact, near, conflict,
mixed conflict, and missing-evidence cases; source-prose changes do not remove
Overall topics. Changed-file analysis found **0 issues** and the safe Web build
succeeded. Final 390×844 Hosted Preview runs for the Owner-requested case and
two synthetic cases reached the report in **934/418/950 ms** respectively.
Additional synthetic male/female runs took **423/926 ms** and preserved their
gender in the calculation request. All five runs displayed **การงาน, การเงิน,
ความสัมพันธ์, การดูแลพลังและกิจวัตร**, with no horizontal overflow, leaked
evidence headings, blocked request, page error, or console error. Each used
only two successful anonymous calculation POSTs to the isolated Preview
Backend. There were no Firebase Auth, Firestore, Production API, other write,
or identity/profile requests. A Hosted Thai single-menu regression reached
its report with no POST, blocked request, error, or overflow.

The safe Preview is
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai`.
Only channel `pr-149-overall-safe` advanced, to version `2aab0934c8f71d33`
expiring `2026-10-04T03:38:48Z`; Production Hosting `live` remains
`d32e72678324e634`. The hosted JavaScript matches the local safe build at
SHA-256 `B8B9C42431D045D046BE72C30A0B0E0AC054CA99FF5C66E17AEFA4FB95B5D698`.
The bundle includes the isolated Backend and both calculation paths, no
Auth/Firestore endpoint strings, and the Production API hostname only in the
negative Preview configuration guard. The Draft PR remains for Owner wording
review; no personal birth values or chart placements are stored in this file.

## 2026-09-25 structured meanings for Draft PR #149

Starting from `7dc5360`, the work, money, and relationship composer now
derives its short meaning fragments from traceable calculation codes rather
than cutting fixed phrases out of the Thai, Chinese, or Western source prose.
Thai house-lord source atoms resolve through the Thai reader's existing mode
mapping; Chinese Ten God families, support band, family weights, and day-pillar
codes resolve through the BaZi reader's mappings; Western Mercury and Venus
sign codes resolve through a V2 semantic registry. All three original source
readings and their basis remain visible. A missing source claim, atom, code,
or reader section still produces a topic-specific gap. The separate agreement
threshold remains `0.6`; interpretive composition is not labelled consensus.

Changing the three single-reader prose samples in a regression test leaves
all three Overall topic readings unchanged. The test also checks missing
Thai house evidence, missing Western planet code, missing source report text,
and registry coverage of all twelve Western signs. Related Flutter tests
passed **78/78** and changed-file analysis found **0 issues**. An anonymous
calculation diagnostic and Hosted Preview runs for the Owner-requested case
and two synthetic cases produced all three topics without a gap. Their nine
topic readings match the previous Hosted Preview **exactly**, character for
character; no personal birth values or placements are stored here.

The refreshed 390×844 Hosted Preview reached the report in
**861/910/958 ms** for those three cases. Viewport and scroll widths were
both 390 px. Each run made only two successful calculation POSTs to the
isolated Preview Backend; there were no Auth, Firestore, Production API,
other write, blocked, browser-error, or forbidden identity/profile requests.
The hosted JavaScript matches the local safe build at SHA-256
`35EE9EC5ED5436ED44D5049F4A28EEC872AE8C2266057502AFABF196C779C337`.
The bundle contains the Preview Backend URL and both calculation paths, no
Auth/Firestore endpoint strings, and the Production API hostname only in
the negative Preview configuration guard. Only Hosting Preview channel
`pr-149-overall-safe` advanced, to version `cb6e00fd1a85d187` expiring
`2026-10-02T09:48:30Z`; Production Hosting `live` remains
`d32e72678324e634`. Owner wording review remains pending.

## 2026-09-25 source-backed life-area reading for Draft PR #149

Starting from `0b60634`, the Overall route now reads the existing detailed
Thai birth-profile claims, Chinese BaZi Reader V2 life-area copy, and Western
Reader V2 sections. It composes work, money, and relationship readings only
when each source claim and its calculation basis is available. The report
labels these as **interpretive compositions**, shows all three original
readings with their basis on expansion, and keeps proven agreements in a
separate section under the unchanged `0.6` confidence threshold. Missing
source material produces a stated gap rather than invented prose. The
interpretation is natal; single-tradition current-period text is not treated
as a shared three-tradition timing prediction.

An anonymous diagnostic against the isolated Preview Backend checked the
Owner-requested known-time case and two synthetic cases. Each produced the
three life-area readings without a source gap after handling both existing
Chinese money branches. The Owner case still has **no proven common point**;
the synthetic cases retain only the agreements their adapter evidence
qualifies. The diagnostic prints every Thai house claim and evidence key,
Chinese source section, and Western section and planetary basis into local
ignored QA files. Birth values and chart placements are excluded from this
document. The focused consensus/report tests passed **24/24**, including a
mobile rendering check that separates interpretive copy from agreement.
The final anonymous Hosted Preview runs reached the report from the
selection page in **863/381/892 ms** at 390×844. Each displayed all three
life-area readings, had 390 px viewport and scroll width, and made 18 GETs
plus only two calculation POSTs to the isolated Preview Backend (both 200).
No Auth, Firestore, Production API, other write, blocked request, browser
error, or forbidden identity/profile field appeared. The Owner case still
showed no proven common point; the two synthetic cases showed only their
supported two-tradition points. The final Hosted JavaScript equals the local
safe build at SHA-256
`309E29572EB5363D751B4E5DAF98127293057D5E9ACCD4DED6E46DB75C21EA30`.
The isolated backend URL and two calculation paths occur in the bundle;
Auth/Firestore endpoint strings do not. The Production API hostname occurs
only in the negative Preview configuration guard. Only Preview channel
`pr-149-overall-safe` advanced, to version `e3062328b08f2baa` expiring
`2026-10-02T08:26:51Z`; Production Hosting `live` remains
`d32e72678324e634`.

The Owner work-topic expansion was also opened on Hosted Preview: it showed
the complete Thai house-10 source claim and sign/lord keys, the Chinese work
reader and Ten God/support keys, and the Western work section with its
planetary basis. That read-only interaction made no extra mutation request.

Changed-file Flutter analysis found **0 issues** and the release Web build
succeeded. The full local Flutter run finished with **3,125 passed, two
skipped, and one failure** in the pre-existing actual-PDF parity test because
the local Python interpreter lacks `pypdf`; this is unrelated to the Overall
route. Its generated QA files were backed up in an ignored local patch and
restored to their pre-run state. [CI for implementation commit
`289ea59`](https://github.com/notekmitl/knowme/actions/runs/36113533911)
passed focused tests, analyzer, Web build, and the complete Flutter suite.
Owner wording review remains pending; no personal birth values are included
here.

## 2026-09-25 evidence relationship reading for Draft PR #149

Starting from `dc4146b`, the report composer now examines every registered
observation in each lens before choosing a narrative path. For the
Owner-requested known-time case, it can place a Thai thinking-style
observation, a Chinese stability observation, and a Western adaptation
observation into one question about considering a choice, what to preserve,
and how to adjust if conditions change. The report explicitly calls this an
interpretive reading of different perspectives, **not a proven common point**
or a claim about actual events. The Thai observation in this case remains
below the unchanged `0.6` cross-tradition agreement threshold, so the case
still has no supported common point. Birth values, chart placements, and
personally identifying data are omitted here.

The copy has reviewed paths for a supported reliability pair plus a separate
thinking view, and for two distinct supported autonomy/growth pairs. Where
observations or proven points lack a defensible relationship, it says so
directly and leaves their evidence in the per-tradition panel. This revision
changes presentation only; adapters, calculated charts, agreement logic,
threshold, authentication, and persistence were not changed. A small prose
cleanup removes a repeated Thai evidence label without changing its source.

Focused consensus and mobile report tests passed **23/23**, including
non-leading evidence selection, honest unrelated-evidence fallback, distinct
proven points, and a 390×844 mobile layout. Changed-file Flutter analysis
found **0 issues**; the isolated release Web build succeeded. On the final
Hosted Preview at 390×844, the Owner-requested case and two synthetic cases
reached the report in **862/891/923 ms** respectively. All three had viewport
and scroll width of 390 px, no clipping or runtime errors, 18 GET requests,
and only two calculation POSTs to the isolated Preview Backend (200/200).
There were zero Auth, Firestore, Production API, other mutating, blocked, or
page/console-error requests; POST bodies contained no UID, profile, token,
or Auth field. The synthetic daytime case retained one proven two-tradition
point with the third view separate. The pre-sunrise case retained two
distinct proven two-tradition points without a three-way claim.

The final release bundle and Hosted `main.dart.js` match byte-for-byte at
SHA-256 `2CF5D9747D5CBED922088513AAA46EC94DED0083E3556D60D68E9906323C164F`.
The bundle contains the isolated Backend URL and two calculation paths, no
Auth/Firestore endpoint strings, and the Production API hostname only in its
negative Preview configuration guard. Only Hosting Preview channel
`pr-149-overall-safe` advanced to version `cd5892157c63f4a2`, expiring
`2026-10-02T07:34:08Z`. Production Hosting `live` remained
`d32e72678324e634`; the former unsafe channel remains absent. Owner wording
review and full PR CI verification are tracked on the Draft PR.

## 2026-09-25 one-reading prose revision for Draft PR #149

The report now starts with one Thai prose reading composed from the strongest
traceable observation of each available tradition. A proven agreement leads
the prose when one exists; another tradition's view is explicitly kept apart.
The agreement section follows the reading and shows the actual supporting
facts. When no agreement qualifies, the section states that limit after the
reading. Per-tradition detail remains available in a collapsed evidence panel
for review instead of forming the main report. This changes presentation only:
the adapters, source selection, and minimum agreement confidence of `0.6`
are unchanged. No synthetic fact, event, age prediction, or cross-tradition
bridge was added.

The Owner-requested known-time case was retested anonymously from selection
to report on the isolated Hosted Preview at 390×844. The report now reads as
one paragraph with a Thai view of thinking style, a Chinese view of stability,
and a Western view of adaptation, each grounded in its existing engine fact.
It then says no common topic reaches the evidence threshold. This is a
composed reading of different perspectives, not a claim that the three
traditions agree. Selection-to-report time was **894 ms** in this run; viewport
and scroll width were both 390 px, with no visible clipping. The complete
rendered paragraph was checked against the adapter outputs. Birth values and
chart placements are omitted from this document.

Two additional synthetic Hosted Preview cases exercised the other branch.
One showed **one** supported two-tradition point with the third view kept
separate (**384 ms**); a pre-sunrise case showed **two** distinct supported
two-tradition points without claiming a three-way agreement (**912 ms**).
Both longer reports scrolled to the end without horizontal overflow. The
focused Flutter selection, date-boundary, consensus, and mobile report tests
passed **34/34**; changed-file analyzer found **0 issues**.

Each Hosted Preview run made **18 GET and two calculation POST** requests to
the isolated Backend, both POST responses 200. There were zero Auth,
Firestore, Production API, or other write attempts, zero blocked requests,
and zero page/console errors. The request bodies contained no UID, name,
profile, token, or Auth field. The Preview release bundle contains the
isolated Backend URL and both calculation paths, no Auth/Firestore endpoint
string, and only the existing Production-hostname rejection guard. Hosted
`main.dart.js` matches the local release build byte-for-byte: SHA-256
`32B838493F0FEC12BD2E42AE88E824139A31029C38DD66B898F0ADC1A5C84190`.
Only safe Hosting channel `pr-149-overall-safe` advanced to version
`5d2d95d5892b9a8f` (expires `2026-10-02T06:56:24Z`); `live` remained
`d32e72678324e634`, and the unsafe old channel remains absent. PR #149
stays Draft for Owner wording review. No personal birth data, account, or
saved result was added by this revision.

## 2026-09-25 Thai evidence and anonymous Preview repair

The Owner-requested near-midnight case was traced from the Thai single-reading
runner into the Overall adapter. Both paths use the same normalized Thai
analysis and Mirror result. The Thai single report produced its complete
narrative. The normalizer correctly kept the civil birth date for the other
traditions and used the preceding Thai astrological day because the birth was
before local sunrise. No date-boundary change was needed.

The adapter previously examined only the Mirror's top three themes. None of
those themes was in the Overall Fusion registry for this case, while approved
Thai content in the Mirror sections contained registered themes and explicit
evidence rows. The adapter now also reads section supporting themes and keeps
its existing registry, source-evidence, deduplication, and confidence gates.
The Thai report's approved lagna content explicitly maps the three displayed
Thai observations. They come from one Thai source, each at confidence `0.55`;
they remain lens-specific. The `0.6` agreement threshold is unchanged, so
this case has **no supported two- or three-tradition common point**. The
Chinese and Western observations remain separate. No missing point was
invented to fill the Overall report.

The isolated Preview's Thai single report was also blank after confirmation:
its feature-flag-off branch instantiated a Firebase audience listener although
Preview deliberately has no Firebase initialization. The Preview build now
renders that report with an anonymous audience and does not create the
listener. Production-mode behavior is unchanged.

Focused adapter/consensus tests passed **23/23**. A synthetic pre-sunrise
birth test confirms section evidence survives when top themes do not map to
the Fusion registry. A synthetic daytime test confirms weak Thai evidence
stays visible without becoming an agreement. Changed-file analysis found
**0 issues**. The safe release Web bundle has SHA-256
`5E47FC67F7FED4A9BE9D91D72FFA381D3F8263BA989334F30D02FFABD7F0B7E8`;
the hosted bundle matches byte-for-byte. It contains the isolated Preview
Backend URL, both calculation paths, and no Auth/Firestore endpoint strings.
The one Production API hostname occurrence is solely in the negative Preview
configuration guard.

Only `pr-149-overall-safe` was advanced to Hosting version
`23c6890171b7618b`, expiring `2026-10-02T05:33:21Z`. The `live` Hosting
version stayed `d32e72678324e634`; the old unsafe channel remains absent.
The Owner-requested case was entered in a fresh 390×844 anonymous browser.
Thai single summary and visual report showed the preceding Thai astrological
day and a populated reading; its 18 requests were GET only. The Overall
selection-to-report time was **4,526 ms**. Its 20 requests were 18 GET and
exactly two calculation POSTs to the isolated Backend, both 200. Request
bodies had no UID, name, profile, token, or Auth field. Both routes had zero
Auth, Firestore, Production API, other mutating, blocked, page-error, or
console-error requests. At 390 px viewport, scroll width was 390 px and the
cards did not clip. The Overall text now shows three separately sourced Thai
observations and explicitly says that no common point is supported. The
Owner's wording review remains pending. Birth values and chart placements
are intentionally omitted from this document; no account or saved result was
created by the tested flows. PR #149 remains Draft.

## 2026-09-24 latest Draft PR #149 verification

The post-crash implementation commit `bd17b475` and its documentation were
pushed normally to the existing Draft branch with available credentials.
The full Flutter suite initially failed six tests. One expected the old
English Thai-evidence label; five were downstream of evidence merging in
the shared BaZi adapter helper. Implementation `b5aa038` keeps merged facts
for the Overall report and preserves the earlier single-fact behavior for
other runtime consumers. The five affected test files passed **50/50**
locally. [GitHub Actions run #35988691883](https://github.com/notekmitl/knowme/actions/runs/35988691883)
completed **successfully**, including focused tests, analyzer, Web build,
and the complete Flutter suite.

A new release Web bundle from `b5aa038` was built with
`KNOWME_OVERALL_PREVIEW=true`, Evidence Badge off, and only the isolated
Backend URL `https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`.
The hosted JS matches the local build byte-for-byte: 6,920,251 bytes,
SHA-256 `2F01AEE4677D5F299F4A7F69FF8EA278B19D134A91426F6E3098E7391786FDF2`.
It contains both calculate paths, zero Firestore/Auth API endpoint strings,
and one Production API hostname occurrence solely in the negative Preview
configuration guard. Hosting channel `pr-149-overall-safe` alone advanced
to version `dd4c850da6e99a3c`, expiring `2026-10-01T10:45:43Z`; the `live`
channel stayed on `d32e72678324e634`. The deploy used
`--no-authorized-domains`. The old unsafe channel remains absent.

The Owner-specified input was entered in two fresh 390×844 Chrome contexts
without sign-in. The selector displayed the exact requested date, time,
and province before the Overall action. Two earlier form attempts with an
incorrect hour selection were rejected by this check and are excluded.
The two accepted click-to-report timings were **4,388 ms** (first load)
and **898 ms** (repeat). Their report text was identical. The page had
390 px scroll width at 390 px viewport with readable cards and no clipping.
There were **zero supported cross-tradition agreements**; the report
explicitly said so, showed Thai as insufficient, and kept three distinct
Chinese and three distinct Western observations separate. The six
observations trace to actual response fields and existing source mappings;
no duplicate joint point, invented third-lens support, or unsupported
event/date/age claim appeared. This is source traceability, not independent
validation of astrological truth or Owner wording acceptance.

Each accepted run had **20 requests: 18 GET and exactly two POST** to
`/v1/calculate-bazi` and `/v1/calculate-chart` on the isolated Backend;
both returned 200. The POST bodies had no UID, name, profile, token, or
Auth field. There were zero Auth, Firestore, Production API, or other
mutating requests, zero blocked requests, and zero page/console errors.
No account or saved result was created by this browser flow. Exact birth
values are omitted from this document. PR #149 remains Draft pending
Owner wording review; no merge or Production/Firestore change occurred.

## Earlier Owner-specified Hosted Preview reading QA

The Owner-specified known-time input was tested in a fresh 390×844 Chrome
context with empty browser storage and no sign-in. The exact birth values and
derived chart placements are intentionally omitted from repository files. The
form preserved the requested input before the Overall action. Two accepted
runs reached the report in **814/878 ms** from click to heading. The page had
390 px scroll width at a 390 px viewport, and visual review found readable,
distinct lens sections without clipping.

This case produced **zero supported cross-tradition agreements**. The report
said so explicitly, kept the Thai lens at an insufficient-evidence state, and
showed three distinct Chinese plus three distinct Western observations only
as lens-specific material. It did not repeat a generic Chinese/Western point,
claim that the third lens agreed, or add an event/date/age prediction. The six
displayed observations were checked against live calculation response fields
and the source mapping: BaZi day master, dominant element, element balance,
and secondary year-animal signal; Western Big Three and derived modality. The
secondary animal signal was labelled as such. The Thai empty-evidence result
was observed in the report and is not presented as an independent chart fact.

The fresh-context trace contained **20 requests: 18 GET and exactly two POST**
to `/v1/calculate-bazi` and `/v1/calculate-chart` on the isolated Preview
Backend; both returned 200. The request bodies contained no UID, name,
profile, token, or Auth field. No Auth, Firestore, Production API, or other
mutating request was attempted; the protective browser route blocked zero
requests. Page and console errors were zero. No account or saved result was
created by this browser flow.

The live Hosting Preview release is version `72ddb6960c4ab6da` (09:45:49Z),
and hosted `main.dart.js` SHA-256 is
`E69C3D57A4DB379BED6668EC6359EE5027FFD7DF8AF0252396FD288FFBC2441F`.
The Production API hostname appears in the bundle only in an exact negative
guard that rejects a misconfigured Preview Backend URL; the active API URL is
the isolated Preview Backend. No Production API request was observed. The
channel expires `2026-10-01T09:45:43Z`.

After the `git.exe` crash, the correct local repo was found at the separate
KnowMe task checkout. It had clean working files, no Git lock files, and
`bd17b4753f9305823462ee4a1fdadf5f71b93a7b` exactly one commit ahead
of remote `c570a83`. A normal, non-force push with existing credentials moved
the Draft PR branch to `bd17b475`; Owner sign-in was not needed. Production
and Firestore were not changed. Owner wording acceptance remains pending.

## 2026-09-24 evidence-led wording revision — Owner review pending

The previously reported Hosted Preview wording (one common card, repeated
Chinese and Western text) was not accepted. The safe Hosted Preview now serves
the revised wording on the separate Backend. The referenced screenshot was unavailable in that earlier turn. The
Owner-specified input was tested in the follow-up above.

Root cause: `ThreeTraditionReportPage` previously received only agreements and
rendered the same generic theme label for every participating lens, discarding
each adapter's evidence. The comparator also joined broad signal-family themes
that did not always mean the same thing. The new reading model keeps ranked
observations for each lens, renders distinct Thai evidence from Thai Mirror
content titles, BaZi day master/element facts, and Western Sun/Moon/Rising
facts, and shows nonmatching traditions separately. Exact theme matches are
eligible only with nonempty evidence and confidence at least `0.6`. Only the
explicitly reviewed `independent`/`leadership` pair may form a near-match;
`supportive`, `loyal`, and `independent_connection` do not form one relationship
agreement. Year-animal bridge signals below `0.6` remain visible as secondary
Chinese observations but cannot establish a point of agreement. Western
dominant element/modality is emitted only with a unique count of at least two
among the Big Three. No date or event claim is added.

Synthetic example for Owner copy review (not the missing screenshot case):

> **ความมั่นคง — สอดคล้องกัน 2 ศาสตร์ (จีนและตะวันตก)**
>
> จีน: พบประเด็นการให้ความสำคัญกับความมั่นคงจากธาตุเด่นของดวงจีนเป็นดิน
>
> ตะวันตก: พบประเด็นการให้ความสำคัญกับความมั่นคงจากลัคนาอยู่ราศีพฤษภ
>
> ไทย: ไม่มีหลักฐานที่หนักพอให้นับร่วมในประเด็นนี้; แสดงข้อสังเกตไทยอื่นแยกด้านล่าง
>
> เวลาเลือกงานหรือแผนชีวิต ลองดูว่าความมั่นคงมีน้ำหนักเพียงใด

This is a reflective reading grounded in two separate facts, not a prediction
or a claim that Thai agrees. The old generic Chinese/Western duplicate is gone.

Local Backend full suite **54/54 PASS**; Thai/Chinese/Western and overall
Flutter regressions **48/48 PASS**; focused mobile/report tests **14/14 PASS**;
changed-file analyzer **0 issues**. Two synthetic birth sets via loopback-only
Backend produced **4** and **1** supported common topics; the second has only
one supported common topic, so the UI adds evidence-backed lens observations
instead of fabricating more agreements. Local mobile selection-to-report took
**1,602 ms**. The local loopback release Web build (not deployable as-is) contains
loopback API, both `/v1/calculate-*` paths, no Production API URL, SHA-256
`E0DA2AB4509C9D966A24BD390DC9872585463450D4F142D7C3D070637BC504F1`.

The already deployed calculation-only Preview Backend was not changed. The
loopback Web build must not be deployed. Public endpoint abuse protection,
rate limiting, and Owner wording review remain open. Production/Firestore and
PR Draft status were not changed.

A second release build configured for the existing isolated Preview Backend
succeeded from the rebased PR source. It contains both calculate paths,
no loopback or Firestore endpoint, and only a negative Production URL guard;
`main.dart.js` SHA-256 is `E69C3D57A4DB379BED6668EC6359EE5027FFD7DF8AF0252396FD288FFBC2441F`.
Only Hosting Preview channel `pr-149-overall-safe` was updated, with
`--no-authorized-domains`; it expires `2026-10-01T09:45:43Z`. The hosted
index/bootstrap cache pins and downloaded JS hash equal the local build. The
`live` Hosting release time did not change. Mobile Chrome at 390×844 showed
four supported two-tradition cards, distinct Chinese/Western evidence, and
separate Thai/Chinese/Western observations; scroll width was 390 px. A repeat
click-to-heading measurement was **2,147 ms**. Network capture after the click
had exactly two POSTs to Preview Backend, both 200, and no Auth, Firestore, or
Production API request. The earlier screenshot was unavailable; the Owner-specified input has
now been tested above. The branch push succeeded with existing credentials.

## Earlier isolated Hosted Preview QA

Status (2026-09-24): **Draft PR #149 OPEN; isolated Backend and safe Hosting
Preview deployed; earlier anonymous browser selector-to-report QA PASS; no
Production deployment or merge**. The
five previously affected Production documents were restored and verified before
this change. Historical branch validation passed in
[GitHub Actions run #35824575799](https://github.com/notekmitl/knowme/actions/runs/35824575799)
at commit `c33160d4bf01bd2f0a870d2c50925d700645f8b0`: focused tests,
analyzer, release Web build, PDF dependencies, and the complete Flutter suite.
The local Flutter SDK is available for this revision. The isolated Preview
implementation commit `05a2af4ab04ff988039131cde66040a200c022aa` also passed the focused tests,
analyzer, release Web build, PDF dependency setup, and complete Flutter suite in
[GitHub Actions run #35963786418](https://github.com/notekmitl/knowme/actions/runs/35963786418).
No related test failure required a code change.

## 2026-09-24 mobile Hosted Preview follow-up and old-channel closure

- In a fresh mobile Chrome context at **390×844**, Bangkok timezone and no
  saved session, the flow opened the new Hosted Preview, filled synthetic
  known-time birth data, selected **ดูดวงรวม**, and reached the report. Click to
  report heading took **4,799 ms** on the first run and **795/793 ms** on two
  fresh-context runs after the old channel was closed. These are browser
  measurements, including sequential Backend calculation requests; the first
  run may include a Cloud Run cold start.
- The selector showed all four choices in order (Thai, Chinese, Western,
  Overall) and the correct birth summary. Visual review of the report at the
  top and bottom found readable Thai text, three- and two-tradition cards,
  source labels, and the no-age-range disclosure. No text was clipped or
  overlapped. Both document and body scroll width were **390 px** at a 390 px
  viewport. Owner wording acceptance is still pending.
- Each accepted mobile run made exactly two POSTs, `/v1/calculate-bazi` and
  `/v1/calculate-chart`, to the separate Backend Preview. Both returned
  **HTTP 200**. Captured requests contained **zero** Firebase Auth, Firestore,
  Production API, or other mutating requests; page and console errors were
  zero. Screenshots, the latest full request list, and the validation summary are in ignored
  `.preview-qa/mobile-390x844/`; the repeatable check is
  `tool/pr149_preview_mobile_flow.cjs`.
- Deleted only Hosting channel `pr-149-overall-v1` after confirming it was the
  historical Production-API bundle. A fresh channel listing contains
  `pr-149-overall-safe` and `live`, with the old channel absent. The old URL
  now returns **HTTP 404**; the new `/beta/thai` returns **HTTP 200** and passed
  the full mobile selector-to-report flow again after deletion.

Owner wording review link:
`https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app/beta/thai`
(previously scheduled to expire `2026-10-01T06:06:12Z` before this update).

## 2026-09-24 isolated hosted Preview QA

- Backend: new Cloud Run service `knowme-overall-pr149-preview`, revision
  `knowme-overall-pr149-preview-00001-gfn`, at
  `https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app`. Its runtime
  identity is the new
  `knowme-pr149-overall-preview@knowme-app-694e1.iam.gserviceaccount.com`.
  Project IAM inspection found **zero role bindings** for that identity and no
  parent organization/folder. It has no Production Firestore permission. Its
  staged source and container include only the calculation app and BaZi/Western
  engines, with no Firebase/Firestore library, save module, Firebase Auth
  initialization, or saved-chart route. Cloud Build
  `7827ecc3-97e1-43b3-be4f-bc6571ebb54e` passed the import and route gate.
  The service has `min-instances=0`, `max-instances=2`, and a 60-second timeout.
- Backend live checks with synthetic birth data: both anonymous calculation
  POSTs returned `200`, with no `saved_paths`; `/v1/generate-bazi` returned
  `404`; `uid` and `profile` on calculation requests returned `422`. CORS
  accepted only the new Hosting Preview origin; Production Hosting and an
  unrelated origin returned `400` without an allow-origin header.
- Hosting Preview: new seven-day channel `pr-149-overall-safe` at
  `https://knowme-app-694e1--pr-149-overall-safe-vbx6de6a.web.app`, expiring
  `2026-10-01T06:06:12Z` before this update. It was built from this PR checkout with
  `KNOWME_OVERALL_PREVIEW=true`, the new Backend URL, and the Evidence Badge
  flag off. This build skips Firebase initialization and the landing page's
  participant-count Firestore read. The release bundle is 6,910,773 bytes,
  SHA-256
  `6E5393809982E1D3BA4C177896FBCD78DF997DCFC87FFDB0969B9117AA3B9962`;
  the downloaded hosted bundle matched that hash exactly. It contains the
  Preview Backend URL and both `/v1/calculate-*` paths, but no Production API
  URL, loopback API URL, or `firestore.googleapis.com` string. Entrypoint cache
  pin: `6e5393809982`.
- Fresh headless Chrome context (1280×800, Bangkok timezone, no saved session)
  opened `/beta/thai`, entered synthetic known-time data, reached the selector,
  clicked **ดูดวงรวม**, and displayed the combined report in **843 ms** and
  **860 ms** on two runs. The report included both three-tradition and
  two-tradition agreements. Network capture saw exactly two calculation POSTs
  to the Preview Backend and zero Auth, Firestore, Production API, or other
  mutating requests; page errors were zero. Local screenshots and the network
  record are in ignored `.preview-qa/`; the repeatable browser check is
  `tool/pr149_preview_flow.cjs`. No Firebase Auth account or Firestore document
  was created for this QA.
- The first Preview build briefly made a Firestore **read** for the landing
  participant count. It made no write, but was replaced immediately. The final
  hosted bundle and both accepted Chrome runs have zero Auth/Firestore traffic.
  Production Cloud Run remains on `knowme-astrology-api-00014-j2z`; Production
  Hosting, Firestore rules/data, Auth configuration, Functions, and Storage were
  not deployed or changed. PR #149 stays Draft.

This is a time-limited public QA service. Before wider exposure, add a rate
limit and abuse controls. The old `pr-149-overall-v1` channel was deleted on
2026-09-24. The exact temporary CORS origin on the Production Backend remains
for a separate reviewed removal revision.

## Reader path

`/beta/thai` → birth form → select **โหราศาสตร์โดยรวม**. The option requires a
known birth time and resolved province because Western V2 needs both. The overall
action now calls `/v1/calculate-bazi` and `/v1/calculate-chart` sequentially.
These new routes accept birth calculation fields only, require no Firebase Auth,
and return charts without calling the Firestore save services. The client sends
no UID, token, name, or profile field. Thai Beta runs its existing local
analysis. The report is composed only when all three return valid results.
The Chinese and Western single-system actions retain their existing signed-in
save flow; their behavior was not changed in this repair.

## Comparison rule

- Use the existing Thai Mirror, BaZi and Western natal theme adapters and their
  registered, nonempty engine evidence. No alteration to the three calculators,
  the readers, Firestore rules, Auth, or the legacy Fusion snapshot format.
- Group one result per lens and theme. Show exact matching themes only when at
  least two *different* traditions have nonempty evidence with confidence at
  least `0.6`. The only reviewed near-match is `independent`/`leadership`,
  described narrowly as self-direction. Rank three-lens agreements before
  two-lens agreements; never promote an unrelated third lens.
- Do not merge a growth-area warning into a positive signal (for example,
  `overthinking` with `analytical`). Do not assert dates or age ranges because
  the available natal outputs do not contain comparable timing evidence across
  all three systems. A zero-agreement chart has an explicit empty state.
- Display each contributing tradition's distinct engine facts on its card and
  the remaining traditions' observations in a clearly separate section. The
  result is calculated in memory and is not written as a new user document.
- Pass the actual submit instant to the Thai analysis runner, which converts it
  to Bangkok civil time once. The existing single-Thai choice now does the same;
  it avoids a second conversion on a device outside the Bangkok time zone.

## Known boundaries and verification

The combined action calls two anonymous, calculation-only endpoints in sequence.
It does not read or write saved charts. A failure in any source does not show a
partial combined report. The existing single-system routes remain independent.
The calculation endpoints are public, so rate limiting and abuse protection
must be reviewed before they are exposed beyond an isolated QA backend.

## 2026-09-24 root-cause repair and isolated verification

The prior selector called `resolveUser` for Overall, then reused
`ThaiBetaAstrologyHandoff.prepare`. That handoff sent the Firebase ID token and
canonical profile to `/v1/generate-bazi` and `/v1/generate-chart`. Both Backend
routes saved the profile, chart, and result mirror to Firestore under that UID.
Because the old Hosting Preview was built with the Production Cloud Run URL,
the silent existing browser session led to the five Production overwrites that
were subsequently restored. The in-memory combined report itself made no write;
its source-generation path did.

The repair adds dedicated calculation-only routes that reuse the existing BaZi
and Western builders. The Overall selector now uses an anonymous handoff and
never resolves a Firebase user. The Backend request models reject `uid` and
`profile`; the response has no `saved_paths`. Authenticated save routes and the
Thai engine are retained. No Firestore rules or schema changed.

Local checks using synthetic birth data: Backend full suite **54/54 PASS**,
including real HTTP calculation responses, no-save guards, rejection of UID and
profile, and continued 401 protection on save routes. Flutter focused feature
and three-system regressions **42/42 PASS**. Scoped analyzer **PASS (0 issues)**.
A mobile-size (390×844) Flutter selection-to-report test called a loopback
Backend started with lifespan off,
so Firebase Admin and Firestore were never initialized. Both HTTP calculations
returned 200 and the full report appeared in **1,608 ms**. This was a local
widget/runtime test, not a live Chrome or Hosted Preview timing measurement.
An isolated release Web build succeeded; its bundle contains the loopback API
URL and both calculation paths, and does not contain the Production API URL.

Before this follow-up, the old Hosted Preview served its authenticated bundle and
Production API. A read-only download on 2026-09-24 matched the old bundle
SHA-256
`8479C6E1A9112F20914280D5834C9001308F0116545BBCEC366FF3638437AFBA`:
it contains the Production API and `/v1/generate-*` paths but neither
`/v1/calculate-*` path. It does **not** contain this repair and must not be
used to claim anonymous Overall QA. The new isolated Preview described above
supersedes this historical blocker. The temporary exact Preview CORS entry remains live on
the Production Backend and still needs a separately reviewed removal revision.

Focused tests cover three matching lenses, exact plus similar themes, source
deduplication, empty evidence, growth-area exclusion, real Thai engine output,
the selector's known/unknown time and failure paths, single Bangkok conversion,
and mobile/desktop widget layouts. The draft workflow uses Flutter 3.41.1,
`TZ=Asia/Bangkok`, Poppler and Python `pypdf`, focused Flutter tests, the analyzer,
a release Web build, and the complete Flutter suite. This matches the timezone and PDF
dependencies used by the repository's earlier successful Flutter workflow.

The first full-suite attempt (run #35822200056) passed focused tests and
analyzer, then reported seven failures: four Bangkok civil-time assertions,
two missing-Poppler PDF gates, and one runtime evidence comparison affected by
the time value. The failing test files and Thai runner were unchanged from
`main`. Run #35823155332 passed focused tests, analyzer and Web build; installing
Poppler removed one missing-tool failure, while the real PDF parity script
then exposed its additional `pypdf` dependency. The final candidate workflow
includes both PDF dependencies and Bangkok time. Run #35824575799
completed successfully with all tests passing.

The historical validation described here preceded the anonymous repair.
The isolated hosted browser QA passed as recorded above. Owner review of the
combined Thai wording remains open.

## Historical Hosting Preview verification (invalid QA)

The former seven-day Preview channel `pr-149-overall-v1` served
`https://knowme-app-694e1--pr-149-overall-v1-nr8oa6e0.web.app`; it was
deleted on 2026-09-24 and now returns HTTP 404. Its release Web build was from
application source `d56946d`, used the configured Production Cloud Run API,
passed the official
bundle validator and four explicit localhost/loopback guards, and has cache pin
`d56946d`. `main.dart.js` is 8,557,552 bytes with SHA-256
`8479C6E1A9112F20914280D5834C9001308F0116545BBCEC366FF3638437AFBA`.

Backend commit `2edf7a9` adds only the exact Preview URL to the explicit
production-origin list in `backend/app/main.py`; no wildcard is present.
Backend full tests pass `51/51`, the endpoint verifier passes `5/5`, and local
plus live CORS matrices accept both Production origins and the exact Preview
origin while rejecting an unrelated origin with `HTTP 400` and no allow-origin
header. Cloud Run revision `knowme-astrology-api-00014-j2z` receives 100%
traffic with the same CPU, memory, concurrency, timeout, instance bounds, CPU
allocation, startup boost, and environment as rollback revision
`knowme-astrology-api-00013-zc8`. The deploy took `224.895 s`. Production
Hosting, Firestore rules, Auth configuration, Functions, Storage, indexes, and
the PR merge state were not changed.

Real Chrome at mobile width reconfirmed the selector order: Thai, Chinese BaZi,
Western, then **โหราศาสตร์โดยรวม**. The synthetic known-time form reached a
combined report after the CORS repair, but this is not accepted QA: the browser
silently reused a non-QA Firebase session. The flow updated exactly five
pre-existing documents (canonical profile, two natal charts, and their two
result mirrors). It did not create a Fusion result document. Testing was paused
immediately after ownership was identified, and no corrective write or delete
has been performed.

A read-only historical `batchGet` recovered all five documents at
`2026-09-23T10:27:18.000000Z` (`17:27:18.000000 Asia/Bangkok`), before the
observed writes at `10:27:18.244907Z` through `10:27:19.514069Z`. The local-only
snapshot contains current and historical copies for all five paths and has
SHA-256 `423B6CCCDE6CB00C3A1FB15643A3F18CED80684609F54A56FD7F8B318E8B5D68`.
No UID or profile value is stored in this repository. PITR is disabled, no
managed backup exists, and no backup schedule exists; recovery used the
standard one-hour version-retention window.

The Unicode-safe restore validated the original snapshot SHA-256, `3,430` JSON
keys (`80` non-ASCII and no literal `??`), duplicate-key absence at every level,
Firestore value unions/types, and lossless snapshot/request round-trip. Each of
the five outgoing field maps matched its before-write source. A fresh live guard
then matched current `updateTime` and canonical field hash `5/5`.

One atomic commit restored all five complete historical field maps with no
`updateMask` and a `currentDocument.updateTime` precondition per write. Commit
time was `2026-09-24T03:37:55.719177Z` (`10:37:55.719177 Asia/Bangkok`). The
single readback passed `5/5`: fields and Firestore types equal the before-write
snapshot, all original `createTime` values are unchanged, and new `updateTime`
values equal their atomic write results. No other document or Firebase resource
was touched, and no personal value or UID is stored in this repository.

Local feature-focused tests pass 14/14 for consensus, ordering, known/unknown
time, sign-in cancellation, safe engine order, and mobile/desktop layouts.
The additional date-aware file retains the known Windows local-time mismatch
(three `+07:00` assertion failures); the pinned Ubuntu workflow above passes it
and the complete suite. This historical Preview QA remains **PAUSED/INVALID**;
the repaired anonymous flow later passed on the separate Preview above.

Owner authorized the branch push and opening a Draft PR. GitHub branch
`codex/three-tradition-overall-v1` and PR #149 exist. No Ready, merge, or
Production Hosting deploy has been performed. The isolated hosted QA path is
ready and the old Preview channel is closed. Remove the exact temporary
Preview origin in a separately reviewed Production Backend revision and rerun
the CORS matrix when that change is authorized.
