# PR #89 V1.3 Root-Cause Record

> Superseded delivery status (2026-08-11): V1.4 completion is authorized under the Owner-approved baseline-delta gate. Candidate-r2 remains negative evidence with 9 substantive violations; candidate-r5 remains diagnostic only. Fresh candidate-r6 passes the corrected audit with zero substantive violations. Product Acceptance remains pending, and all V1–V1.3 packets remain immutable.

Recorded before V1.3 implementation on August 11, 2026.

## Owner decision and verified packet

V1.2 was rejected as `REJECTED — CROSS-FIXTURE NARRATIVE DUPLICATION, UNKNOWN-TIME CONTRADICTION, AND PDF LAYOUT DEFECT REMAIN`. The inspected ZIP was `C:\Users\USER\Downloads\thai-report-natural-narrative-v1-2-fa2664f.zip`, SHA-256 `8EA21BB2AEB98BBD36DDE28B8F958E4693A58F0C49A03D72C7D7B49249BEC673`. Product Acceptance remains pending; PR #89 stays open and Draft.

## Known page 6 limitation-card geometry

The disclaimer path used a one-column `pw.Table` without `columnWidths`. Unlike `_atomicPaginationUnit`, that table had no `pw.FlexColumnWidth`, so its cell used intrinsic width. `width: double.infinity` inside the cell could not establish page width because the parent table had already chosen an intrinsic column width. The Known first disclaimer was short enough for the border to collapse to the left while following disclaimer text continued as unboxed siblings. Unknown happened to look full-width because its first paragraph was longer; it did not use a safer layout contract.

The V1.2 review opened the PNG but recorded only first heading, last line, continuation count, clipping, and glyph status. It did not record each component's border bounds or whether associated text stayed inside the border. The malformed component was therefore legible but wrongly marked passed. V1.3 must use the same full-width atomic wrapper for every disclaimer and record component geometry per page.

## Cross-fixture collapse

`ForecastMaterialFingerprint` carried horizon, domain, band, risk, availability, and transition state, but reader-facing `_forecastClaim` accepted only `sourceBody` and `windowIndex`. The source body came from the same score-band template for Known and Unknown, so `evidenceAvailability` affected the action only; the semantic forecast remained identical. Direct comparison of the actual V1.2 canonical corpora found 14 identical long reader-facing lines, including the three Owner-identified 12-month domain predictions and the closing recommendation.

The V1.2 audit evaluated each report separately. It did not compare Known against Unknown or allocate one evidence key to one horizon, so cross-fixture and cross-horizon semantic reuse could pass with zero within-body duplicate clauses.

## Repeated horizons and past periods

The forecast composer reused the upstream score-band claim in every horizon and differentiated it with timing prefixes/actions. In Known work, the 12-month and next-period sections therefore repeated the same movement/role/visibility claim.

`_differentiateTimelineDomains` deduplicated life-domain bodies but copied `period.summary` and `period.whatChanges` unchanged. The PDF's `_concisePeriodSection` selected those untouched fields, which allowed the same relationship/selection statements to appear in ages 11–29 and 30–41 even though domain-body deduplication had succeeded.

## Unknown displayed-versus-omitted contradiction

The core reading correctly omitted house-based work, money, relationship, and wellbeing readings when time was absent. Separately, the timeline prediction layer emitted no-Lagna material based on time-independent period scores. The omitted-topic list used the unqualified topic labels `การงาน`, `การเงิน`, `ความรักและความสัมพันธ์`, and `สุขภาพและพลังชีวิต`, making a house-based omission read as if the entire topic had been omitted. The display and availability decisions were semantically separate but their reader-facing labels collapsed them into a contradiction.

V1.3 keeps the existing fail-closed contract: no Lagna/house claim is introduced. It qualifies omissions as `...จากลัคนาและเรือน`, labels no-time forecasts as timeline-only observation, and uses one availability decision in model metadata, prose, Web/PDF output, and omission wording.
