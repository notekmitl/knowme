#!/usr/bin/env python3
"""Report-level Thai narrative repetition audit for V1.5 acceptance."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import Counter
from difflib import SequenceMatcher
from pathlib import Path

HEDGES = ("มัก", "อาจ", "ลอง", "ควร", "มีโอกาส", "หาก")
DISTINCTIVE = (
    "วินัย ความต่อเนื่อง และการสร้างฐานทีละขั้น",
    "การแบกภาระนานเกินไปโดยไม่ปรับวิธี",
    "การวางระบบที่ทำซ้ำได้",
)


def normalize(value: str) -> str:
    return re.sub(r"[^ก-๙a-z0-9]+", "", value.lower())


def sentences(text: str) -> list[str]:
    return [
        value.strip()
        for value in re.split(r"[\n.!?]+", text)
        if len(normalize(value)) >= 24
    ]


def audit(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    items = sentences(text)
    counts = Counter(normalize(item) for item in items)
    duplicates = [key for key, count in counts.items() if count > 1]
    overlaps = []
    for left in range(len(items)):
        for right in range(left + 1, len(items)):
            a, b = normalize(items[left]), normalize(items[right])
            if a == b or min(len(a), len(b)) < 40:
                continue
            ratio = SequenceMatcher(None, a, b).ratio()
            if ratio >= 0.82:
                overlaps.append({"left": left, "right": right, "ratio": round(ratio, 3)})
    word_count = len(re.findall(r"\S+", text))
    hedge_counts = {word: text.count(word) for word in HEDGES}
    return {
        "path": path.name,
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest().upper(),
        "sentences": len(items),
        "exact_duplicate_sentence_groups": len(duplicates),
        "high_overlap_pairs": len(overlaps),
        "high_overlap_examples": overlaps[:20],
        "distinctive_phrase_counts": {phrase: text.count(phrase) for phrase in DISTINCTIVE},
        "hedge_counts": hedge_counts,
        "hedge_total": sum(hedge_counts.values()),
        "word_count": word_count,
        "hedges_per_100_words": round(sum(hedge_counts.values()) * 100 / max(word_count, 1), 2),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = {"baseline": audit(args.baseline), "candidate": audit(args.candidate)}
    candidate = result["candidate"]
    result["result"] = "PASS" if (
        candidate["exact_duplicate_sentence_groups"] == 0
        and max(candidate["distinctive_phrase_counts"].values()) <= 1
        and candidate["hedges_per_100_words"] < result["baseline"]["hedges_per_100_words"]
    ) else "FAIL"
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["result"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
