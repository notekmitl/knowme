# Candidate 0029 Runtime Revision 7 — supported-input completeness matrix

**PASS FOR THE SUPPORTED THAI INPUT DOMAIN — READY FOR OWNER TESTING ONLY — OPEN + DRAFT — NOT OWNER-ACCEPTED — NOT READY FOR REVIEW — NOT MERGED — NOT DEPLOYED**

Date: 2026-09-11

Runtime: Flutter 3.41.1 / Dart 3.11.0

Environment: `CI=true`, analytics suppressed, `TZ=Asia/Bangkok`

## What this validation proves

The new matrix validates completeness over the input domain exposed by the Thai report flow. It separates the inexpensive normalization Cartesian product from the more expensive analysis, prediction-plan and reader-document layers.

| Layer | Coverage | Result |
| --- | --- | ---: |
| Birth normalization | 7 civil weekdays × 1,440 clock minutes × 77 selectable Thai provinces | 776,160/776,160 PASS |
| Known-time analysis and prediction plan | Every minute, every province, every civil and astrological weekday, all form gender values, all lagna/context/period classes | 1,909/1,909 PASS |
| Full reader document | One document per province plus one document per reachable predictive context | 126/126 PASS |
| Unknown-time fail-closed | 7 civil weekdays × 77 selectable Thai provinces | 539/539 PASS |

The normalization matrix reached all 77 supported provinces, all 24 hours and every minute, both sides of local sunrise, all seven civil weekdays and all seven resulting astrological weekdays. It observed 187,042 before-sunrise cases and 589,118 at-or-after-sunrise cases. Every case preserved its exact clock value, resolved the province coordinates, supplied sunrise data and selected the correct astrological date.

The Known-time matrix reached all five form gender representations (`ชาย`, `หญิง`, `อื่น ๆ`, `ไม่ระบุ`, and null), all 12 lagna values, all 49 reachable predictive contexts and all 392 context/age/planet period rows. Every period resolver was checked at both inclusive boundaries; every row was also run through a real analysis at its end age. All 1,440 clock minutes produced a complete evidence-bound prediction plan.

Every rendered reader document retained the requested structure: exactly one past chapter; no `อายุ 0–…`; a governing planet in each life-period heading; one current section with exactly six continuous paragraphs and no domain subheadings; partnered and single relationship wording for adults; two `เด่นเรื่อง` phrases in the rolling 12-month prediction; seven facts-only main-chart rows; and `ข้อจำกัด` as the absolute final section after `ที่มาของผลวิเคราะห์`. Empty titles, empty paragraphs, unresolved placeholders, missing semantic owners, unsupported claims, omitted claims, fixture leakage, binding errors and baseline fallback all remained 0.

All 539 Unknown-time combinations completed analysis but stayed explicitly fail-closed: no time-dependent prediction claims, no Known-to-Unknown leakage and no infographic. The reader receives an explicit omission explanation.

## Defects found and fixed by the matrix

1. The generalized path outside the Candidate 0029 reference profile still had legacy reader wording: a zero-based past range, an age-led rather than present-tense current introduction, adult relationship copy that did not explicitly address both partnered and single readers, and a rolling section without the requested `เด่นเรื่อง` language. The generalized runtime now applies the accepted structure to every supported context.
2. A terminal age period could suppress the entire prediction plan because the runtime required a future life-period window even when no later catalog period legitimately existed. The runtime now emits every applicable current, past, rolling-12-month, advice and disclosure claim and omits only the nonexistent next-life-period claim. It does not invent a future period.
3. Two regression assertions still expected the retired generalized heading `แนวโน้ม 12 เดือนข้างหน้า`. They now assert the current reader-section heading `คำทำนาย 12 เดือนข้างหน้า`; the infographic's independently versioned title remains unchanged.

## Automated gates

| Gate | Result |
| --- | ---: |
| Completeness matrix | 3/3 PASS |
| Focused runtime/export/PDF/completeness gate | 84/84 PASS |
| Updated heading regressions | 13/13 PASS |
| OR5 evidence projection | 5/5 PASS |
| Node foundation and signature | 9/9 PASS |
| Candidate 0024–0029 validators | PASS |
| Full Flutter suite | 3,029/3,029 PASS |
| Changed-scope analyzer | 0 issues |
| Repository analyzer policy | exit 0; 297 historical warning/info diagnostics |

## Boundary of the claim

This is exhaustive for the selectable Thai place domain (77 provinces) at minute resolution and uses equivalence-class coverage for the expensive full-document layer. It is not a claim that every possible worldwide coordinate or every free-text place has been rendered, and it does not establish astrological predictive accuracy. It establishes that supported inputs normalize correctly and that the report emits all applicable, evidence-bound sections without structural omissions.

Candidate 0029 still has no Owner-accepted exact golden. This PASS authorizes Owner testing only. It does not authorize Ready for Review, merge, Firebase deployment, Production access or any Production mutation. `product-acceptance/` is unchanged.
