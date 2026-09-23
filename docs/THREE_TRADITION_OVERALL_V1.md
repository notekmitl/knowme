# Overall astrology from three traditions — V1 working branch

Status: **Draft PR #149 OPEN; not released**. Branch validation passed in
[GitHub Actions run #35824575799](https://github.com/notekmitl/knowme/actions/runs/35824575799)
at commit `c33160d4bf01bd2f0a870d2c50925d700645f8b0`: focused tests,
analyzer, release Web build, PDF dependencies, and the complete Flutter suite.
Flutter/Dart SDKs remain unavailable in the local workspace.

## Reader path

`/beta/thai` → birth form → select **โหราศาสตร์โดยรวม**. The option requires a
known birth time and resolved province because Western V2 needs both. It uses
the existing sign-in gate for the two authenticated backend calculations.
BaZi and Western are generated sequentially through their existing authenticated
endpoints using the same normalized profile; Thai Beta runs its existing local
analysis. The report is composed only when all three return valid results.

## Comparison rule

- Use the existing Thai Mirror, BaZi and Western natal theme adapters and their
  registered, nonempty engine evidence. No alteration to the three calculators,
  the readers, Firestore rules, Auth, or the legacy Fusion snapshot format.
- Group one result per lens and theme. Show exact matching themes, or compatible
  themes mapped to the same existing Fusion signal, only when at least two
  *different* traditions support the result. A third compatible lens joins the
  same card. Rank three-lens agreements before two-lens agreements.
- Do not merge a growth-area warning into a positive signal (for example,
  `overthinking` with `analytical`). Do not assert dates or age ranges because
  the available natal outputs do not contain comparable timing evidence across
  all three systems. A zero-agreement chart has an explicit empty state.
- Display the contributing traditions and their distinct meanings on each card.
  The result is calculated in memory and is not written as a new user document.
- Pass the actual submit instant to the Thai analysis runner, which converts it
  to Bangkok civil time once. The existing single-Thai choice now does the same;
  it avoids a second conversion on a device outside the Bangkok time zone.

## Known boundaries and verification

The combined action calls two authenticated generation endpoints in sequence,
so total latency may exceed the accepted per-reader five-second target. It
does not read old saved charts, which avoids mixing a previous birth profile
with the newly submitted form. A failure in any source does not show a partial
combined report; an earlier successful endpoint may still have persisted its
individual chart. Old single-system routes remain independent.

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

Authenticated three-chart browser QA, real endpoint latency, visual review of
the combined Thai wording, and Owner acceptance are still required before
Ready, Merge, or deployment.

Owner authorized the branch push and opening a Draft PR. GitHub branch
`codex/three-tradition-overall-v1` and PR #149 exist. No Ready, merge, Backend
deploy, Hosting deploy, or Production verification has been performed.
