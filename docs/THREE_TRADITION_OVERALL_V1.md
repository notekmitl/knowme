# Overall astrology from three traditions — V1 working branch

Status: **Draft PR #149 OPEN; Flutter verification unavailable in this
workspace; not released**. Application tree:
`58083dfacc85122b0a19a53e534778d020ab02fe`.

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

## Known boundaries and verification

The combined action calls two authenticated generation endpoints in sequence,
so total latency may exceed the accepted per-reader five-second target. It
does not read old saved charts, which avoids mixing a previous birth profile
with the newly submitted form. A failure in any source does not show a partial
combined report; an earlier successful endpoint may still have persisted its
individual chart. Old single-system routes remain independent.

Focused tests added for three matching lenses, exact plus similar themes,
source deduplication, empty evidence, growth-area exclusion, and the selector's
known/unknown time and failure paths. **These tests have not been run here:**
Flutter and Dart SDK binaries are absent, and the SDK artifact host is
unreachable from this environment. `git diff --check` is the only executed
local gate. Flutter focused tests, analyzer, Web build, actual three-chart QA,
mobile layout, authenticated latency, and Owner wording acceptance remain open.

Owner authorized the branch push and opening a Draft PR. GitHub branch
`codex/three-tradition-overall-v1` and PR #149 exist; the application tree
matches the local implementation byte for byte. No Ready, merge, Backend
deploy, Hosting deploy, or Production verification has been performed.
