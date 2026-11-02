# PR #149 artwork paint diagnosis (synthetic trial data)

Application commit `7cd80f065997cc980f68d09217e0f02721dab41e` changes only
the presentation of decorative trial artwork. The starting branch was clean at
`0b858dfa5dd75c13a6c5b6cefb364fbb4a78bb08`. The previously completed
three visual changes were retained.

## Confirmed before the fix

- A newly opened ChatGPT in-app tab and a new ordinary Chrome tab displayed
  the landing art. The reported earlier blank in-app tab was not reproduced in
  that new tab. [In-app screenshot](iab-new-tab-visible.jpg). This does not
  invalidate the earlier observation.
- Fresh Chrome 156 contexts with `--disable-gpu --disable-webgl` reproduced a
  blank landing banner and blank Overall, Thai, Chinese and Western art at
  both 390×844 and 1280×800. The console reported `Falling back to CPU-only
  rendering. Reason: webGLVersion is -1`. Ordinary Chrome contexts painted
  the same artwork.
- Every trial art response was HTTP 200 with `image/webp` from the existing
  Hosting Preview. A separate browser `Image.decode()` succeeded for
  `overall.webp` at 1024×1536. Replacing the image response with PNG bytes of
  the *same artwork inside the disposable CPU test context* still left the
  banner blank. The experiment does not support a WebP-only explanation.
- In the 390 px landing screenshot, the artwork rectangle
  `(20,210)–(370,460)` had RGB standard deviation `(0,0,0)` in the CPU case,
  versus `(67.68,49.47,37.86)` in ordinary Chrome. This measures painted
  pixels, in addition to response and decode status.

| Before-fix comparison | CPU fallback | Ordinary Chrome |
| --- | --- | --- |
| Landing 390 px | [blank banner](before-cpu-landing-390.png) | [painted banner](before-chrome-landing-390.png) |
| Overall 390 px | [blank hero](before-cpu-overall-390.png) | [prior hosted normal view](../pr149-integrated-visual/hosted-overall-390.png) |

## Scoped repair and local regression

`TrialArtworkBanner` and `TrialIllustratedHero` now use Flutter's
`Image.network` with `WebHtmlElementStrategy.prefer` on web, resolving the
same-origin bundled asset through a browser image element. Non-web still uses
`Image.asset`. The artwork remains pointer-ignored and decorative. No
calculation, reading text, evidence rule, flow, Backend, Auth or Firestore code
changed. The guarded isolated trial build stayed plugin-free and embedded only
the Backend Preview URL.

The isolated build painted all five trial surfaces (landing and four readers)
at 390×844 and 1280×800 in fresh ordinary Chrome and CPU/WebGL-disabled
contexts. The CPU landing rectangle measured RGB standard deviation
`(64.43,45.36,33.36)` at 390 px and `(66.96,49.67,37.09)` at 1280 px.
Each known-time journey sent exactly two successful calculation POSTs to the
separate Backend Preview; reader switches, back navigation and disclosures
sent no more. Unknown-time journeys sent zero POSTs and stopped on the form.
Every journey recorded zero forbidden Auth/Firestore/Production requests,
other writes, failed requests, app errors and horizontal overflow. Focused
Flutter trial, Overall, Thai, BaZi and Western tests passed.

| Reader | Fixed CPU 390 px | Fixed CPU 1280 px |
| --- | --- | --- |
| Landing | [view](local-fixed-cpu-landing-390.png) | [view](local-fixed-cpu-landing-1280.png) |
| Overall | [view](local-fixed-cpu-overall-390.png) | [view](local-fixed-cpu-overall-1280.png) |
| Thai | [view](local-fixed-cpu-thai-390.png) | [view](local-fixed-cpu-thai-1280.png) |
| Chinese | [view](local-fixed-cpu-chinese-390.png) | [view](local-fixed-cpu-chinese-1280.png) |
| Western | [view](local-fixed-cpu-western-390.png) | [view](local-fixed-cpu-western-1280.png) |

The [synthetic browser journey harness](journey.py) supports `--hosted` or
`--build PATH`, `--width 390|1280`, `--case a|b|unknown`, `--mode chrome|cpu`
and a required `--out PATH`. It records requests before initial load and
checks calculator counts and privacy. Its `cpu_png` mode substitutes identical
art as PNG only inside the test browser, with no Hosting mutation.
[Sanitized diagnostic signals](diagnosis-summary.json) omit the synthetic
birth inputs, POST payloads and reading text.

## CI and Hosted Preview

Required CI run [41272194209](https://github.com/notekmitl/knowme/actions/runs/41272194209)
passed `backend-validation`, `isolated-trial-build` and `flutter-validation`,
including the full Flutter suite, for application SHA `7cd80f0`.
The exact guarded build version `pr149-7cd80f0` was deployed only to the
existing Hosting Preview channel `pr-149-overall-safe` with
`--no-authorized-domains`. [Before/after channel state](hosting-state.json)
shows Preview version `618a0d087d43aa9b` became `a10df6e87fc5e43f`, while
Production `live` remained release `1790074568414000` / version
`d32e72678324e634` and the Preview URL suffix stayed `c41ic92g`.
The channel expires **8 Nov 2026 11:26:08 Asia/Bangkok**. Hosted
[index/bootstrap/main JS hashes](hosted-hashes.json) matched the guarded
build byte for byte.

Fresh Hosted 390×844 and 1280×800 journeys in ordinary Chrome and
CPU/WebGL-disabled Chrome each reached Overall, Thai, Chinese and Western and
returned to Overall. All four art files responded HTTP 200 with `image/webp`.
Landing and Overall painted in both rendering modes at both sizes. The image
region measured RGB standard deviation `(64.43,45.36,33.36)` at 390 px and
`(66.96,49.67,37.09)` at 1280 px in hosted CPU fallback. Reader screenshots
below show the four painted traditions at both sizes. Known-time journeys sent
exactly two successful calculator POSTs to the separate Backend Preview, with
no extra POST on switching or disclosure. Unknown-time journeys at both sizes
stopped with [an explanation](hosted-unknown-time-390.png) and zero POSTs.
Every run found zero Auth/Firestore/Production API requests, other writes,
failed requests, app errors and horizontal overflow.

| Hosted CPU fallback | 390×844 | 1280×800 |
| --- | --- | --- |
| Landing | [view](hosted-fixed-cpu-landing-390.png) | [view](hosted-fixed-cpu-landing-1280.png) |
| Overall | [view](hosted-fixed-cpu-overall-390.png) | [view](hosted-fixed-cpu-overall-1280.png) |
| Thai | [view](hosted-fixed-cpu-thai-390.png) | [view](hosted-fixed-cpu-thai-1280.png) |
| Chinese | [view](hosted-fixed-cpu-chinese-390.png) | [view](hosted-fixed-cpu-chinese-1280.png) |
| Western | [view](hosted-fixed-cpu-western-390.png) | [view](hosted-fixed-cpu-western-1280.png) |

Ordinary Chrome also painted the [390 px landing](hosted-fixed-chrome-landing-390.png)
and [1280 px Overall layout](hosted-fixed-chrome-overall-1280.png).
The [refreshed ChatGPT in-app browser](iab-hosted-fixed.jpg) requested
`flutter_bootstrap.js?v=pr149-7cd80f0` and painted the landing artwork.

## Limits and unresolved observation

The controlled CPU/WebGL-disabled failure is reproducible, but the earlier
ChatGPT inspection tab was not retained for instrumentation. We cannot prove
its blank art had precisely the same mechanism. Browser `Image.decode()`
proves the browser can decode the file; it does not prove CanvasKit painted it.
The separate PNG substitution rules out a WebP-only cause in the tested
browser configuration. Owner review of the running UI remains pending.

One first hosted CPU mobile capture at about 550 ms after switching to Thai
and Chinese still showed [blank Thai art](hosted-first-cpu-thai-390-early-blank.png)
and [blank Chinese art](hosted-first-cpu-chinese-390-early-blank.png). Its trace
recorded HTTP 200 by the end of the journey, not at the moment of capture.
Three independent fresh CPU mobile repeats painted both arts at the immediate
capture and again 2.2 seconds later; their pixel measurements are in the
[sanitized diagnostic summary](diagnosis-summary.json). This single early
capture is retained as a limitation. It does not establish a persistent
failure after load, and we have not attributed it to a specific timing cause.
No further app change was justified by the current evidence. The art
presentation fix is pending Owner review of the running UI; no UI approval is
claimed.
