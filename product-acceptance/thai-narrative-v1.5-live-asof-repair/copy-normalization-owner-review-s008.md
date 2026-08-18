# S008 copy-normalization Owner-review packet

Status: **superseded by the Owner-authorized copy semantic safety repair**. This packet preserves the pre-repair 93-profile/112-field finding; those broad reader-visible changes are not accepted product behavior and are absent from the final pipeline output.

Final disposition: all 300 fresh outputs match the accepted baseline with reader-visible delta 0, omission 0, addition 0 and prediction-to-advice transformation 0. The Owner did not approve these 112 changes; instead, the implementation was repaired at the semantic-source boundary and the two stale expectations that required broad normalization were replaced with a stronger behavioral contract. PR #95 may move to Ready for review only after all final gates, commit and push complete. This is not merge or deployment authorization.

## Exact scope

- 93/300 profiles; 112 `summary` fields.
- Known-time fields: 81; Unknown-time fields: 31.
- Section: `lifeTimeline.periods`; every row records profile, period index, before/after copy, engine-fact identity, life-period identity and exact period scores.
- Complete 112-row ledger: `copy-normalization-owner-review-ledger-s008.json`.

## Before / after contract

- Before: `ต่อไปมีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก`
- After: `ช่วงนี้ชวนให้เปิดรับโอกาสผ่านงานหรือเครือข่าย แล้วดูจากผลที่เกิดขึ้นจริงว่าอะไรควรทำต่อ`
- Historical reason for review: the prior implementation used broad post-composition normalization to force accepted `owner-unknown` wording. The final repair produces that cautious wording at the semantic source and removes the broad reader-visible transformation.

## Representative rows

| Profile | Mode | Section / period | Field | Before | After |
|---|---|---|---|---|---|
| S004 | known | lifeTimeline.periods / 4 | summary | ต่อไปมีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก | ช่วงนี้ชวนให้เปิดรับโอกาสผ่านงานหรือเครือข่าย แล้วดูจากผลที่เกิดขึ้นจริงว่าอะไรควรทำต่อ |
| S011 | unknown | lifeTimeline.periods / 3 | summary | ต่อไปมีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก | ช่วงนี้ชวนให้เปิดรับโอกาสผ่านงานหรือเครือข่าย แล้วดูจากผลที่เกิดขึ้นจริงว่าอะไรควรทำต่อ |

## Editorial review

- Grammar: the after-copy is a complete Thai sentence with an explicit action and evidence-check clause.
- Naturalness: `ช่วงนี้ชวนให้...` is less deterministic than `มีโอกาสใหม่เข้ามา` and reads as guidance rather than a guaranteed event.
- Repetition: normalization collapses two equivalent opportunity phrasings to one cautious form; the 300-profile audit reports 300/300 unique reports and narratives with no within-report collapse.
- Facts and advice: profile facts, houses, life periods, period scores and advice are untouched. Only `lifeTimeline.periods[*].summary` rows listed in the ledger change.
- Cross-runtime proof: VM/Chrome copy-impact mismatch is 0, alongside profile, structured, period-score, report-hash, canonical-text, narrative and omission mismatch 0.

Decision log: the Owner authorized replacement of only the two stale test expectations that required this broad normalization. The Owner did not accept the enumerated 112 reader-visible changes. Final automated evidence proves those changes no longer occur. No merge or deployment is authorized by this packet.
