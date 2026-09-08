# Actual 00:35 — past-period equivalence

**PASS for source-period applicability; NOT a transfer of Candidate0011 wording acceptance.**

00:03 and 00:35 share context `mahabhut2537.rem0.saturday`, Thai astrological date `1982-06-05`, weekday 7, and the same three completed period rows. Ascendant degrees differ (9.396069063125992 vs 19.313708418191027), but inspected past selector rows have no ascendant/time-dependent field.

The 00:03 reader plan uses its accepted golden override. That fixture-specific reader wording is deliberately excluded. The shared Mahabhut context/period rows and resolved source bindings—not the golden decisions—are equivalent.

| Claim | Owner | Section | Scope | Domain | Horizon | Direction | Classification |
|---|---|---|---|---|---|---|---|
| selector.mahabhut2537.rem0.saturday.saturn.0_10 | past-selector | 0-10 | 0-10 | boriwan | past-life-period | dueng_tok | SOURCE_PERIOD_EQUIVALENT |
| selector.mahabhut2537.rem0.saturday.jupiter.11_29 | past-selector | 11-29 | 11-29 | ayu | past-life-period | dueng_khuen | SOURCE_PERIOD_EQUIVALENT |
| selector.mahabhut2537.rem0.saturday.rahu.30_41 | past-selector | 30-41 | 30-41 | det | past-life-period | dueng_khuen | SOURCE_PERIOD_EQUIVALENT |

## Source bindings

### 0-10

- Selector: selector.mahabhut2537.rem0.saturday.saturn.0_10 — resolved and equal
- Sources: source.T0003-SRC-0-10-FAMILY-CONSTRAINT (resolved); canon.mahabhut.p28.saturn_owns_family (resolved)
- Time/ascendant-dependent keys: 0

### 11-29

- Selector: selector.mahabhut2537.rem0.saturday.jupiter.11_29 — resolved and equal
- Sources: source.T0003-SRC-11-62-RISING-BLOCK (resolved); canon.mahabhut.p220.jupiter_owns_learning (resolved); canon.mahabhut.p220.jupiter_owns_career (resolved)
- Time/ascendant-dependent keys: 0

### 30-41

- Selector: selector.mahabhut2537.rem0.saturday.rahu.30_41 — resolved and equal
- Sources: source.T0003-SRC-11-62-RISING-BLOCK (resolved); source.T0003-SRC-30-41-PLACEMENT (resolved); canon.mahabhut.p39.det_owns_career (resolved)
- Time/ascendant-dependent keys: 0

## Negative controls

- wrong Thai astrological day/context: REJECTED
- wrong period selector: REJECTED
- time/ascendant-dependent component introduced: REJECTED
