# Overall astrology from three traditions — V1 working branch

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

Acceptance: no sign-in dialog or Auth/Firestore/Production API request from
the trial path; zero writes; two calculation POSTs to the isolated Preview
Backend; mobile 390×844 from input to four report screens without overflow;
unchanged result content and evidence threshold. Current Hosted Preview is
the older build and is **not** proof of this new flow. Validate tests and CI,
then refresh the isolated Hosting Preview before Owner review. PR remains
Draft, with no Production deployment or merge authorized by this change.
