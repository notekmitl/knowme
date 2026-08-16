# Clock A/B/C matrix

## Clock A — frozen acceptance

- `startedAt`: `2026-08-07T00:00:00`
- explicit `asOf`: `2026-08-07T00:00:00` Asia/Bangkok civil
- owner-known canonical hash: `08F446D1B72A10F985B80C34702785A4DE61AB96DE5DC01374837876D32396E3`
- current period: age 42–62, Venus / happiness and relationships
- next period: age 63–68, Sun / recognition
- result: exact accepted R7.1 Web/PDF output

## Clock B — narrowest evidenced Production interval

An exact application session timestamp was not persisted in the release evidence. The narrowest defensible interval is:

- earliest UTC: `2026-08-16T09:15:15.572116Z`
- latest UTC: `2026-08-16T09:19:44.4545351Z`
- Asia/Bangkok: `2026-08-16T16:15:15.572116` through `16:19:44.4545351`
- sources: Production verification timestamp and original Downloads PDF NTFS creation time

Every sampled explicit `asOf` in this interval retained the same periods, material, accepted phrases and canonical hash as Clock A. Neither rollback Production mismatch phrase appeared. This disproves `asOf` as the root cause.

## Clock C — controlled boundaries

- Before/after Bangkok midnight conversion: `2026-08-16T16:59:59.999Z → 2026-08-16 23:59:59.999`; `2026-08-16T17:00:00Z → 2026-08-17 00:00:00`.
- Form opened before midnight and submitted after midnight: captured `startedAt` stays before midnight; stored `asOf` is the post-midnight Bangkok submit instant.
- Different `startedAt` with the same explicit `asOf`: identical report hash and canonical text.
- Same `startedAt` across a birthday boundary with different explicit `asOf`: normalized birth and lagna remain stable; current age and explainable date-aware report material change.
- Daily scan `2026-08-06` through `2026-08-17` for the Owner fixture: same life period and canonical output, as expected because no relevant boundary is crossed.

Raw structured results are in `clock-abc-pre-repair.json`, `clock-abc-pre-repair-test-result.txt`, `live-asof-contract-test-result.txt` and `date-aware-contract-test-result.txt`.
