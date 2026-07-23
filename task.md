# Task: Fix Life Map Mahabhut all-unknown (missing Canon index)

## Goal
Wire Frozen Canon `repository.index` into Production / Thai Beta / QA Life Map presenters so Mahabhut positions resolve via existing resolvers instead of returning unknown for all 8 periods.

## Non-goals
- Do not invent placement tables or formulas
- Do not modify Frozen Canon, Mahabhut formula, or Public Evidence Badge
- Do not guess positions when Canon is ambiguous/conflicted

## Acceptance
- Consumer path receives real canonIndex
- Fixture with confirmable placements shows real Thai names
- Not all 8 periods unknown when Canon confirms
- Ambiguous/source conflict stay unknown
- Beta / Mirror / QA agree
- Gate + focused tests pass
