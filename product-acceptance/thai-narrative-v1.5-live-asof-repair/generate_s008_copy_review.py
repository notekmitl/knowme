from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "cross-runtime-300-vm-run-1-s008-final.json"
LEDGER = ROOT / "copy-normalization-owner-review-ledger-s008.json"
PACKET = ROOT / "copy-normalization-owner-review-s008.md"


manifest = json.loads(SOURCE.read_text(encoding="utf-8"))
rows: list[dict[str, object]] = []
for case in manifest["cases"]:
    for impact in case["copyNormalizationImpact"]:
        period_index = impact["periodIndex"]
        rows.append(
            {
                "profileId": case["caseId"],
                "birthTimeMode": case["birthTimeMode"],
                "section": "lifeTimeline.periods",
                "periodIndex": period_index,
                "field": impact["field"],
                "before": impact["before"],
                "after": impact["after"],
                "structuredSource": {
                    "profileEngineFactSignature": case["profileEngineFactSignature"],
                    "lifePeriodSignature": case["lifePeriodSignature"],
                    "periodScoreSignature": case["periodScoreSignature"],
                    "periodScores": case["periodScores"][period_index],
                },
            }
        )

profiles = sorted({row["profileId"] for row in rows})
known = [row for row in rows if row["birthTimeMode"] == "known"]
unknown = [row for row in rows if row["birthTimeMode"] == "unknown"]
assert len(profiles) == 93
assert len(rows) == 112
assert {row["field"] for row in rows} == {"summary"}
assert known and unknown

ledger = {
    "schema": "knowme-v15-s008-copy-normalization-owner-review-v1",
    "sourceManifest": SOURCE.name,
    "profileCount": len(profiles),
    "fieldCount": len(rows),
    "fieldNames": ["summary"],
    "knownFieldCount": len(known),
    "unknownFieldCount": len(unknown),
    "rows": rows,
}
LEDGER.write_text(
    json.dumps(ledger, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
    newline="\n",
)

representatives = [known[0], unknown[0]]
lines = [
    "# S008 copy-normalization Owner-review packet",
    "",
    "Status: **technical parity verified; reader-visible copy remains pending Owner review; PR #95 stays Draft**.",
    "",
    "## Exact scope",
    "",
    f"- {len(profiles)}/300 profiles; {len(rows)} `summary` fields.",
    f"- Known-time fields: {len(known)}; Unknown-time fields: {len(unknown)}.",
    "- Section: `lifeTimeline.periods`; every row records profile, period index, before/after copy, engine-fact identity, life-period identity and exact period scores.",
    "- Complete 112-row ledger: `copy-normalization-owner-review-ledger-s008.json`.",
    "",
    "## Before / after contract",
    "",
    "- Before: `ต่อไปมีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก`",
    "- After: `ช่วงนี้ชวนให้เปิดรับโอกาสผ่านงานหรือเครือข่าย แล้วดูจากผลที่เกิดขึ้นจริงว่าอะไรควรทำต่อ`",
    "- Reason retained: disabling the normalization changes the frozen accepted `owner-unknown` fixture. The cautious after-copy preserves the accepted R7.1 wording while avoiding a deterministic cross-runtime copy split.",
    "",
    "## Representative rows",
    "",
    "| Profile | Mode | Section / period | Field | Before | After |",
    "|---|---|---|---|---|---|",
]
for row in representatives:
    lines.append(
        f"| {row['profileId']} | {row['birthTimeMode']} | {row['section']} / {row['periodIndex']} | "
        f"{row['field']} | {row['before']} | {row['after']} |"
    )
lines += [
    "",
    "## Editorial review",
    "",
    "- Grammar: the after-copy is a complete Thai sentence with an explicit action and evidence-check clause.",
    "- Naturalness: `ช่วงนี้ชวนให้...` is less deterministic than `มีโอกาสใหม่เข้ามา` and reads as guidance rather than a guaranteed event.",
    "- Repetition: normalization collapses two equivalent opportunity phrasings to one cautious form; the 300-profile audit reports 300/300 unique reports and narratives with no within-report collapse.",
    "- Facts and advice: profile facts, houses, life periods, period scores and advice are untouched. Only `lifeTimeline.periods[*].summary` rows listed in the ledger change.",
    "- Cross-runtime proof: VM/Chrome copy-impact mismatch is 0, alongside profile, structured, period-score, report-hash, canonical-text, narrative and omission mismatch 0.",
    "",
    "Owner decision requested: accept or reject only this enumerated 112-field copy normalization. No merge or deployment is authorized by this packet.",
    "",
]
PACKET.write_text("\n".join(lines), encoding="utf-8", newline="\n")

print(
    json.dumps(
        {
            "profiles": len(profiles),
            "fields": len(rows),
            "knownFields": len(known),
            "unknownFields": len(unknown),
            "ledger": LEDGER.name,
            "packet": PACKET.name,
        },
        ensure_ascii=False,
    )
)
