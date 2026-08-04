# Thai Mirror Golden Baseline Repair V1

**Status:** Baseline regenerated; PreCommit Gate passed  
**Base:** `fdf2cb3ccdbdacb8cd33bd0c41e6ff1fe35fe2d8` (`origin/main`)  
**Toolchain:** Flutter 3.41.1 / Dart 3.11.0

## Purpose

Restore the Thai Mirror QA screenshot regression as an enforceable Local Gate.
The checked-in PNG baselines predated the current rendering of unchanged
`main`: all 24 profile/viewport cases failed before this repair, primarily
because timeline image dimensions changed and some section pixels no longer
matched.

## Scope boundary

Only existing files under
`test/validation/thai_mirror_qa_harness/screenshots/*.png` may be regenerated.
No production source, comparator, tolerance, test, Gate script, Engine, Canon,
Birth Normalization, or Thai Beta Past-to-Future Narrative V3 code is changed.
Failure artifacts, build output, and contact sheets are not repository assets.

## Acceptance evidence

- Two consecutive non-update screenshot regression passes.
- Identical SHA-256 manifests for the accepted PNG set across both passes.
- Desktop, Tablet, and Mobile contact-sheet review.
- Story-coverage and focused consumer UI test passes.
- Flutter analyze, Local Gate PreCommit, and Local Gate PostCommit passes.

This repair accepts deterministic rendering of unchanged `main`; it does not
introduce or approve a production UI change.

The separate legacy golden at `test/goldens/thai_mirror_consumer_page.png` is
not part of this harness or repair. Its unchanged-main comparison remains the
previously recorded 32.63% / 305,379-pixel mismatch; neither that baseline nor
its test is modified here.

## Verified baseline result

- 51 existing QA harness PNGs changed.
- Screenshot regression passed at least three consecutive non-update runs.
- Accepted-set manifest SHA-256:
  `67912832186cd29134c2e25c8864434677af7b9e58be27331328fb4cd96d7714`.
- Desktop, Tablet, and Mobile contact sheets were stored outside the repository
  and reviewed: all six story sections are present for profiles A-H with no
  clipping, overlap, overflow, blank card, or missing layout block observed.
- Story coverage passed for profiles A-H.
- Gate self-test passed 9/9; scoped required PreCommit Gate passed, including
  analyze (no fatal errors), focused tests, and full scoped suite.
