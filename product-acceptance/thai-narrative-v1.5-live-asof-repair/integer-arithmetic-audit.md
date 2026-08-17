# Integer arithmetic audit

## Findings and repair

The initial stable-string replacement was not sufficient. Reader-visible seed expressions still contained wide XOR and multiplication whose semantics differ when compiled to JavaScript. In particular, a stable hash multiplied by `2654435761` can exceed JavaScript's safe-integer range before later XOR/modulo operations.

The repair makes the intended domains explicit:

- 32-bit FNV and stable-hash operations wrap and mask at 32 bits.
- Reader-visible wide XOR uses `BigInt`, then verifies the result remains within the exact 53-bit selection range.
- `left ^ (value * multiplier)`, absolute value and modulo are performed exactly with `BigInt` for period score nuance.
- Accumulated Mirror and Thai Beta seeds use exact helpers instead of relying on dart2js bitwise coercion.
- Evidence ordering uses an explicit compatibility insertion order so accepted VM ordering is reproduced deterministically rather than depending on runtime sort behavior for the short list.

## Verification

The shared arithmetic vectors include signed/unsigned boundaries, overflow products, negative minimum 32-bit input, XOR, multi-value XOR, multiply, seed accumulation and final modulo. All vector values and all stable string/multiple-string vectors are identical in Dart VM and compiled JavaScript/Chrome.

The repeated 300-profile results also prove arithmetic determinism within each runtime: VM run 1 equals VM run 2 and Chrome run 1 equals Chrome run 2 across profile, structured, period score, report, canonical, narrative, omission and copy-normalization fields.

## Remaining blocker

Arithmetic used by the stable-hash/selection layer is no longer the mismatch. S008 differs one ULP in the upstream floating-point `siderealAscendantDeg`, so the serialized report snapshot and downstream report-hash-derived narrative seed differ. That engine/runtime floating-point contract needs a separately authorized repair; expected-output updates or post-hoc copy replacement were not used.
