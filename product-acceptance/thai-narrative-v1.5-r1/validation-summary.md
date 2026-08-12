# Validation summary

- Focused narrative/core/PDF/300-profile suite: PASS, 261 tests.
- 300 synthetic reports: 300 unique, deterministic; 225 Known / 75 Unknown;
  20 representative real PDFs preserve Web semantic parity.
- Scoped analyzer (three implementation files): PASS, no issues.
- Repository analyzer: 299 pre-existing findings; no scoped findings.
- Complete repository test run: 2,864 passed / 39 failed. The failures are
  repository-wide pre-existing/baseline tests outside the V1.5 focused scope;
  focused affected suites pass. This baseline is reported, not hidden.
- Known/Unknown/comparison PDF geometry and manual contact-sheet inspection:
  PASS; no clipping, overlap, blank/footer-only or out-of-bounds page observed.
- Repetition audit: PASS. Confirmed phrases 3/2/2 -> 1/1/1; hedges per 100
  words 8.42 -> 6.37; exact duplicate narrative sentences: 0.
- Web/PDF canonical text: byte-equal for all four generated fixtures.
- Product Acceptance: PENDING OWNER ACCEPTANCE.
