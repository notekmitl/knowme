# Date-aware release verification contract

## Frozen acceptance gate

Run all five accepted fixtures with explicit Bangkok civil `asOf = 2026-08-07`.

- Web and PDF canonical text must match accepted R7.1 exactly 5/5.
- R1–R7.1 ZIP/PDF/text/render identities remain immutable.
- Owner Known remains Aquarius 19°19′; regression 00:03 remains Aquarius 9°24′.
- Unknown remains fail-closed and claim traceability remains 170/170.

## Live Production gate

1. Capture the submission's resolved `asOf` once.
2. Use the exact source/build, Canon and assets being released.
3. Generate a deterministic local oracle with the same input and explicit same `asOf`.
4. Compare Production Web/PDF canonical text, structured facts, page count and visual output to that same-`asOf` oracle.
5. Compare the live report with frozen acceptance only for invariants: engine facts, omission/fail-closed rules, schema/section responsibilities, safety/reader-quality rules and immutable identities.

Do not compare a live-date PDF or live canonical text exactly to a frozen-date PDF when their `asOf` values differ. Do not use PDF binary hash as the canonical content comparison.

This branch supplies a verified local contract only. It is not merged or deployed; Production remains V1.4.
