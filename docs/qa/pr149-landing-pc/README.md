# PR #149 trial landing PC layout — synthetic QA

Application commit `130cdfa7d028ba6a7da13361d8fa1321fbe7dbf8` changes only
the anonymous trial landing presentation and its widget regression. Starting
HEAD `a4ed48d` was clean. The desktop content is centered at 1180 px inside
a 1220 px frame with 20 px side padding. The logo aligns with the image, and
the artwork and text columns share the remaining width with a 44 px gap.
The right column contains the headline, description, three steps, one start
button, and the privacy notice. The desktop button is in the scrolling body;
the mobile button remains in the existing bottom bar. The existing
`TrialArtworkBanner` and its CPU fallback strategy are unchanged.

| Size | Before (old Hosted Preview) | After (new Hosted Preview, Chrome) | After CPU fallback |
| --- | --- | --- | --- |
| 1920×911 | [view](before-1920-chrome-landing.png) | [view](hosted-1920-chrome-landing.png) | [view](hosted-1920-cpu-landing.png) |
| 1280×800 | [view](before-1280-chrome-landing.png) | [view](hosted-1280-chrome-landing.png) | [view](hosted-1280-cpu-landing.png) |
| 390×844 | [view](before-390-chrome-landing.png) | [view](hosted-390-chrome-landing.png) | [view](hosted-390-cpu-landing.png) |

Each local after screenshot was byte-identical to its new Hosted counterpart.
In normal Chrome, the mobile before/after screenshots match pixel for pixel
(`PIL.ImageChops.difference(...).getbbox()` returned `None`). The single
desktop button moved from `(680,857,560,40)` to `(982,637,568,52)` at
1920 px, and from `(360,746,560,40)` to `(662,581.5,568,52)` at 1280 px.
The artwork visibly paints with all three circular motifs in normal Chrome
and CPU/WebGL-disabled Chrome. The 1280×600 browser view also showed the
button in the first screen; a 1280×450 widget regression confirmed the body
scrolls to the button without layout error. Browser screenshots establish the
real paint result; HTTP 200 alone was not treated as proof of visibility.

The isolated local build passed the plugin-free bundle guard with only the
separate Backend Preview calculator origin. The normal Chrome 1280 px journey
and CPU fallback journeys at 1920 and 390 px followed the button to the
existing form and Overall report. Each known-time synthetic journey made
exactly two successful calculation POSTs to the Backend Preview, with zero
Auth, Firestore, Production API, other writes, failed requests, app errors,
or horizontal overflow. Landing alone made zero POSTs. Focused landing tests
passed. The complete local Flutter suite passed after pointing only the test
process at the already installed `pypdf` runtime; an initial local run failed
solely because `pypdf` was absent from the default Python path. CI installs
that dependency independently.

Required [CI run 41283667419](https://github.com/notekmitl/knowme/actions/runs/41283667419)
passed `isolated-trial-build`, `backend-validation`, and
`flutter-validation` (including the complete Flutter suite) for the exact
application SHA. The guarded build `pr149-130cdfa` was deployed only to the
existing Hosting Preview channel `pr-149-overall-safe` with
`--no-authorized-domains` and a Hosting-only config. [Before/after versions](hosting-state.json)
show Preview `a10df6e87fc5e43f` → `610a6ddab261189a`, while Production
`live` stayed release `1790074568414000` / version
`d32e72678324e634`. The same Preview URL expires **8 Nov 2026 14:22:22
Asia/Bangkok**. Hosted [index/bootstrap/main JS hashes](hosted-hashes.json)
match the isolated build byte for byte.

Fresh Hosted journeys in normal and CPU/WebGL-disabled Chrome at 390×844 and
1280×800 reached Overall, Thai, Chinese, Western, and back to Overall.
Opening/closing Overall details and switching readers did not add a
calculation POST: every known-time run had exactly two successful Preview
calculator POSTs total. A 1920×911 normal and CPU run also followed the
start button through the existing form to Overall, again with two successful
Preview POSTs. Unknown-time runs at 390 px normal and 1280 px CPU stopped
at the [existing explanation](unknown-result-hosted-unknown-390-chrome.png)
with zero POSTs. All runs had zero Auth, Firestore, Production API requests,
other writes, failed requests, app errors, or horizontal overflow. The
[sanitized Hosted signals](hosted-qa-summary.json) contain no birth input,
request body, or reading text.

The landing artwork visibly painted in each Hosted screenshot, including CPU
fallback. One 1280 px ordinary Chrome capture of the Thai reader immediately
after switching measured zero image variation; its settled capture painted
the artwork (RGB standard deviation 61.0). This is a timing observation in
a reader outside this landing-only change, not proof of a new landing defect.
Owner acceptance of the entire UI is still pending. PR #149 remains Draft.
