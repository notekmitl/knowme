# S008 copy-normalization Owner-review packet

Status: **technical parity verified; reader-visible copy remains pending Owner review; PR #95 stays Draft**.

## Exact scope

- 93/300 profiles; 112 `summary` fields.
- Known-time fields: 81; Unknown-time fields: 31.
- Section: `lifeTimeline.periods`; every row records profile, period index, before/after copy, engine-fact identity, life-period identity and exact period scores.
- Complete 112-row ledger: `copy-normalization-owner-review-ledger-s008.json`.

## Before / after contract

- Before: `ต่อไปมีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก`
- After: `ช่วงนี้ชวนให้เปิดรับโอกาสผ่านงานหรือเครือข่าย แล้วดูจากผลที่เกิดขึ้นจริงว่าอะไรควรทำต่อ`
- Reason retained: disabling the normalization changes the frozen accepted `owner-unknown` fixture. The cautious after-copy preserves the accepted R7.1 wording while avoiding a deterministic cross-runtime copy split.

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

Owner decision requested: accept or reject only this enumerated 112-field copy normalization. No merge or deployment is authorized by this packet.
