# R1 focused failure index

The immutable historical log `r1-focused-failing-historical.log` is copied byte-for-byte from the rejected R1 packet. Its exact focused command ended at 253 passed / 8 failed with `Some tests failed`.

1. Four-domain contract: each prediction horizon omitted three of work, money, love and health.
2. Future UI: the collapsed future surface could not show all four intended domains.
3. Current versus 12-month comparison: missing domain lists caused a `RangeError`.
4. Deterministic repetition audit: missing domain lists caused a second `RangeError`.
5. Cross-horizon gate: the removed field caused a null-check failure.
6. Readability: one deterministic report exceeded the accepted paragraph-length gate.
7. Known/Unknown sensitivity: reduced future material missed the existing 240-character threshold.
8. Synthetic cross-mode sensitivity: the removed field caused a null-check failure.

The later `r1-command-reproduction.log` is retained separately and ends at 261/0. It proves the R1 package summary referenced a later successful rerun while packaging the earlier failed log. It does not replace or erase the eight historical failures above.
