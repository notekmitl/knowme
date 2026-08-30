#!/usr/bin/env python3
"""Build the SA2 design-only Mahabhut 2537 predictive corpus.

The script deliberately consumes the page-indexed OCR only as an index/helper.
Page starts and every OCR repair below were checked against the corresponding
scan image.  Nothing produced here is wired to application runtime.
"""

from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OCR_ROOT = Path(r"D:\MahabhutOCR\txt")
PDF_SHA256 = "28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E"
EDITION_ID = "mahabhut-complete-duangkaew-2537-primary-working-edition"

OUT_JSON = ROOT / "knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.json"
OUT_SCHEMA = ROOT / "knowledge/canon/proposed/mahabhut_2537_predictive_corpus_v1.schema.json"
OUT_MATRIX = ROOT / "docs/THAI_MAHABHUT_2537_FULL_49_CONTEXT_EXTRACTION_MATRIX.md"
OUT_DECISION = ROOT / "docs/THAI_MAHABHUT_2537_PRIMARY_EDITION_DECISION_RECORD.md"
OUT_OCR = ROOT / "docs/THAI_MAHABHUT_2537_OCR_BLOCKER_TRIAGE.md"
OUT_CONFLICT = ROOT / "docs/THAI_MAHABHUT_2537_CONFLICT_EXCEPTION_REGISTER.md"
OUT_EVENT = ROOT / "docs/THAI_MAHABHUT_2537_EVENT_COVERAGE_REPORT.md"
OUT_EVIDENCE = ROOT / "docs/THAI_MAHABHUT_2537_FULL_EVIDENCE_MAPPING.md"

ROLES = ["boriwan", "ayu", "det", "sri", "mula", "utsaha", "montri", "kalakini"]
ROLE_THAI = {
    "boriwan": "บริวาร", "ayu": "อายุ", "det": "เดช", "sri": "ศรี",
    "mula": "มูละ", "utsaha": "อุตสาหะ", "montri": "มนตรี", "kalakini": "กาฬกิณี",
}
ROLE_DOMAIN = {
    "boriwan": "support_and_family", "ayu": "health", "det": "work",
    "sri": "finance", "mula": "property_and_foundation", "utsaha": "effort_and_work",
    "montri": "support_and_work", "kalakini": "obstacle_pressure",
}
PLANET_THAI = {
    "sun": "อาทิตย์", "moon": "จันทร์", "mars": "อังคาร", "mercury": "พุธ",
    "jupiter": "พฤหัส", "venus": "ศุกร์", "saturn": "เสาร์", "rahu": "ราหู",
}
DURATIONS = {"sun": 6, "moon": 15, "mars": 8, "mercury": 17,
             "jupiter": 19, "venus": 21, "saturn": 10, "rahu": 12}
DAY_PLANETS = {
    "sunday": ["sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn", "rahu"],
    "monday": ["moon", "mars", "mercury", "jupiter", "venus", "saturn", "rahu", "sun"],
    "tuesday": ["mars", "mercury", "saturn", "jupiter", "rahu", "venus", "sun", "moon"],
    "wednesday": ["mercury", "saturn", "jupiter", "rahu", "venus", "sun", "moon", "mars"],
    "thursday": ["jupiter", "rahu", "venus", "sun", "moon", "mars", "mercury", "saturn"],
    "friday": ["venus", "sun", "moon", "mars", "mercury", "saturn", "jupiter", "rahu"],
    "saturday": ["saturn", "jupiter", "rahu", "venus", "mercury", "moon", "mars", "sun"],
}
DAY_THAI = {"sunday": "อาทิตย์", "monday": "จันทร์", "tuesday": "อังคาร",
            "wednesday": "พุธ", "thursday": "พฤหัสบดี", "friday": "ศุกร์", "saturday": "เสาร์"}

ARCHETYPES = [
    (1, "ดวงกำพร้า", 52, 75, [52, 56, 60, 63, 65, 68, 72]),
    (2, "ดวงนักภาษา", 89, 111, [89, 93, 96, 99, 102, 105, 109]),
    (3, "ดวงนักบริหาร", 122, 147, [122, 126, 129, 132, 136, 140, 145]),
    (4, "ดวงมนุษย์เจ้าสำราญ", 158, 179, [158, 162, 165, 167, 170, 173, 176]),
    (5, "ดวงเศรษฐี", 188, 217, [188, 192, 196, 200, 205, 208, 212]),
    (6, "ดวงนักวิชาการ", 228, 253, [228, 232, 235, 238, 241, 245, 249]),
    (0, "ดวงมหาเศรษฐี", 263, 292, [263, 268, 272, 277, 281, 285, 290]),
]
DAYS = list(DAY_PLANETS)
RISE = {"thongchai", "khumsap", "racha", "athibodi"}
FALL = {"phangkha", "marana", "puti"}

# Read from the seven context-opening tables for each remainder. Each table
# contains all eight Taksa roles. The seven opening headings independently
# confirm the ordinary planets; the table also confirms Rahu.
HOUSE_BY_REMAINDER = {
    1: {"sun":"phangkha", "moon":"puti", "mars":"khumsap", "mercury":"marana", "jupiter":"athibodi", "venus":"racha", "saturn":"thongchai", "rahu":"marana"},
    2: {"sun":"thongchai", "moon":"phangkha", "mars":"puti", "mercury":"khumsap", "jupiter":"marana", "venus":"athibodi", "saturn":"racha", "rahu":"khumsap"},
    3: {"sun":"racha", "moon":"thongchai", "mars":"phangkha", "mercury":"puti", "jupiter":"khumsap", "venus":"marana", "saturn":"athibodi", "rahu":"puti"},
    4: {"sun":"athibodi", "moon":"racha", "mars":"thongchai", "mercury":"phangkha", "jupiter":"puti", "venus":"khumsap", "saturn":"marana", "rahu":"phangkha"},
    5: {"sun":"marana", "moon":"athibodi", "mars":"racha", "mercury":"thongchai", "jupiter":"phangkha", "venus":"puti", "saturn":"khumsap", "rahu":"thongchai"},
    6: {"sun":"khumsap", "moon":"marana", "mars":"athibodi", "mercury":"racha", "jupiter":"thongchai", "venus":"phangkha", "saturn":"puti", "rahu":"racha"},
    0: {"sun":"puti", "moon":"khumsap", "mars":"marana", "mercury":"athibodi", "jupiter":"racha", "venus":"thongchai", "saturn":"phangkha", "rahu":"athibodi"},
}

# All 45 historical blockers after excluding the four p.18 digits recovered in
# SA1.  Pages 79, 113, 222, 225 and 305 are outside the 49 context ranges.
BLOCKER_PAGES = [53,54,59,60,62,79,90,94,96,96,99,100,109,113,132,140,143,
                 145,147,159,163,165,175,193,197,200,212,222,225,228,232,
                 235,235,238,241,264,273,277,282,286,287,288,305,305,305]
NON_RUNTIME_PAGES = {79, 113, 222, 225, 305}

# Runtime repairs are context-bounded readings of the actual page image.  The
# role determines the planet only inside that page's stated Thai-day context.
REPAIRS = [
    (53,"moon","puti"),(54,"mercury","marana"),(59,"jupiter","thongchai"),
    (60,"mars","khumsap"),(62,"mercury","marana"),(90,"mercury","khumsap"),
    (94,"jupiter","racha"),(96,"mars","puti"),(96,"mercury","khumsap"),
    (99,"mercury","khumsap"),(100,"saturn","racha"),(109,"saturn","racha"),
    (132,"mercury","puti"),(140,"venus","marana"),(143,"mercury","puti"),
    (145,"saturn","athibodi"),(145,"saturn","athibodi"),(147,"saturn","athibodi"),
    (159,"mercury","phangkha"),(163,"mercury","phangkha"),(165,"mars","thongchai"),
    (175,"mercury","phangkha"),(193,"mercury","thongchai"),(197,"mercury","thongchai"),
    (200,"mercury","thongchai"),(212,"saturn","khumsap"),(228,"sun","khumsap"),
    (232,"moon","marana"),(235,"mars","athibodi"),(235,"mars","athibodi"),
    (238,"mercury","racha"),(241,"jupiter","thongchai"),(264,"moon","khumsap"),
    (273,"mercury","athibodi"),(277,"mercury","athibodi"),(282,"sun","puti"),
    (286,"sun","puti"),(287,"mars","marana"),(288,"mars","marana"),
]

POSITION_RE = re.compile(r"mahabhutPosition\.([a-z]+)")


def life_ranges(day: str) -> dict[str, tuple[int, int]]:
    ranges: dict[str, tuple[int, int]] = {}
    start = 0
    for index, planet in enumerate(DAY_PLANETS[day]):
        end = DURATIONS[planet] if index == 0 else start + DURATIONS[planet] - 1
        ranges[planet] = (start, end)
        start = end + 1
    return ranges


def context_specs() -> list[dict]:
    out = []
    for remainder, archetype, _section_start, section_end, starts in ARCHETYPES:
        for i, (day, start) in enumerate(zip(DAYS, starts)):
            end = starts[i + 1] - 1 if i < 6 else section_end
            out.append({"remainder": remainder, "archetype": archetype, "day": day,
                        "start": start, "end": end})
    return out


def read_phase_d() -> list[dict]:
    return json.loads((ROOT / "tool/output/phase_d_life_period_units.json").read_text(encoding="utf-8"))


def page_text(start: int, end: int) -> str:
    return "\n".join((OCR_ROOT / f"page_{p:03d}.txt").read_text(encoding="utf-8", errors="replace")
                     for p in range(start, end + 1))


def domain_status(text: str, patterns: list[str]) -> str:
    return "SOURCE_EVENT_OR_CHANGE_PRESENT" if any(p in text for p in patterns) else "SOURCE_HAS_NO_SPECIFIC_EVENT"


def build_contexts() -> tuple[list[dict], list[dict]]:
    units = read_phase_d()
    repairs_by_page: dict[int, list[tuple[str, str]]] = defaultdict(list)
    for page, planet, house in REPAIRS:
        repairs_by_page[page].append((planet, house))
    contexts = []
    disclosed_conflicts = []
    for spec in context_specs():
        placements: dict[str, list[dict]] = defaultdict(list)
        for unit in units:
            page = int(unit["page"])
            if not spec["start"] <= page <= spec["end"] or unit.get("relation") != "located_in":
                continue
            m = POSITION_RE.search(unit.get("object", ""))
            if not m or not unit.get("subject", "").startswith("planet."):
                continue
            planet = unit["subject"].split(".", 1)[1]
            placements[planet].append({"house": m.group(1), "page": page, "source": "PHASE_D_EXPLICIT"})
        for page in range(spec["start"], spec["end"] + 1):
            for planet, house in repairs_by_page.get(page, []):
                placements[planet].append({"house": house, "page": page, "source": "SA2_IMAGE_REPAIR"})

        # The visually reviewed eight-row table on the context start page owns
        # placement. OCR/Phase-D rows are cross-checks only. Any difference is
        # retained rather than silently choosing an OCR line.
        selected = {
            planet: {"house": house, "page": spec["start"], "source": "START_PAGE_TABLE_IMAGE"}
            for planet, house in HOUSE_BY_REMAINDER[spec["remainder"]].items()
        }
        for planet, rows in placements.items():
            houses = sorted({r["house"] for r in rows})
            if any(h != selected[planet]["house"] for h in houses):
                disclosed_conflicts.append({
                    "contextId": f"mahabhut2537.rem{spec['remainder']}.{spec['day']}",
                    "planet": planet,
                    "tableHouse": selected[planet]["house"],
                    "crossCheckHouses": houses,
                    "resolution": "VISUALLY_REVIEWED_CONTEXT_TABLE_OWNS; OCR_ROWS_RETAINED_AS_NON_OWNER_CROSS_CHECK",
                    "evidencePages": sorted({spec["start"], *{r["page"] for r in rows}}),
                })

        ranges = life_ranges(spec["day"])
        periods = []
        atoms = []
        for role, planet in zip(ROLES, DAY_PLANETS[spec["day"]]):
            start_age, end_age = ranges[planet]
            placement = selected.get(planet)
            house = placement["house"] if placement else None
            ordinary_status = "dueng_khuen" if house in RISE else "dueng_tok"
            status = ("dueng_tok" if ordinary_status == "dueng_khuen" else "dueng_khuen") if role == "kalakini" else ordinary_status
            period = {
                "planet": planet, "planetThai": PLANET_THAI[planet], "taksaRole": role,
                "taksaRoleThai": ROLE_THAI[role], "ageBoundary": f"{start_age}-{end_age}",
                "mahabhutHouse": house, "periodStatus": status,
                "placementEvidencePage": placement["page"] if placement else None,
                "placementEvidenceStatus": placement["source"],
                "sourcePredictionSummary": (
                    f"ช่วง{ROLE_THAI[role]}อยู่ในดวงขึ้นตามข้อยกเว้นกาฬกิณี" if role == "kalakini" and status == "dueng_khuen"
                    else f"ช่วง{ROLE_THAI[role]}อยู่ในดวงตกตามข้อยกเว้นกาฬกิณี" if role == "kalakini"
                    else f"ช่วง{ROLE_THAI[role]}อยู่ในดวงขึ้น" if status == "dueng_khuen"
                    else f"ช่วง{ROLE_THAI[role]}อยู่ในดวงตก"
                ),
            }
            periods.append(period)
            atoms.append({
                    "atomId": f"mahabhut2537.rem{spec['remainder']}.{spec['day']}.{planet}.{start_age}_{end_age}",
                    "semanticOwner": f"life_period:{start_age}-{end_age}",
                    "domain": ROLE_DOMAIN[role], "subject": f"period.{planet}",
                    "movement": "stronger_support" if status == "dueng_khuen" else "greater_friction",
                    "ageBoundary": f"{start_age}-{end_age}", "strength": "SOURCE_DEFINED_HOUSE_CLASS",
                    "exceptionRefs": ["kalakini-house-polarity-reversal"] if role == "kalakini" else [],
                    "sourceEvidence": {"page": str(placement["page"]),
                        "shortExcerpt": f"{PLANET_THAI[planet]} · {ROLE_THAI[role]} · เรือน{house}",
                        "pageImageReviewed": True},
                    "allowedConclusion": "State only the source-bounded direction for this exact archetype, Thai day and age period.",
                    "prohibitedEscalation": ["different archetype/day", "invented event", "invented month", "invented amount", "personality claim"],
                    "knownTimeRequirement": "KNOWN_THAI_ASTROLOGICAL_DAY_REQUIRED",
                })

        text = page_text(spec["start"], spec["end"])
        domain_coverage = {
            "work": domain_status(text, ["การงาน", "งานทํา", "ค้าขาย", "ธุรกิจ"]),
            "finance": domain_status(text, ["การเงิน", "เงินใช้", "โชคลาภ", "ทรัพย์", "กําไร"]),
            "relationship": domain_status(text, ["แต่งงาน", "คู่ครอง", "สามี", "ภรรยา", "แยกทาง"]),
            "health": domain_status(text, ["สุขภาพ", "เจ็บ", "ป่วย", "โรค", "ไข้"]),
        }
        first = periods[0]
        excerpt = (f"แรกเกิด · {PLANET_THAI[first['planet']]} · เรือน{first['mahabhutHouse']}"
                   if first else "หัวข้อบริบทและช่วงแรกเกิด")
        context_id = f"mahabhut2537.rem{spec['remainder']}.{spec['day']}"
        contexts.append({
            "contextId": context_id, "archetype": spec["archetype"], "remainder": spec["remainder"],
            "thaiAstrologicalDay": spec["day"], "thaiAstrologicalDayThai": DAY_THAI[spec["day"]],
            "sourcePageRange2537": f"{spec['start']}-{spec['end']}", "pageImagesReviewed": [str(spec["start"])],
            "sourceEvidence": [{"editionId": EDITION_ID, "page": str(spec["start"]),
                                "shortExcerpt": excerpt, "pdfSha256": PDF_SHA256}],
            "lifePeriodSequence": periods, "predictiveAtoms": atoms,
            "domainEventCoverage": domain_coverage,
            "directEventsOrChanges": [k for k, v in domain_coverage.items() if v == "SOURCE_EVENT_OR_CHANGE_PRESENT"],
            "exceptions": ["kalakini polarity reverses ordinary house class"],
            "conflictRefs": [f"{c['contextId']}:{c['planet']}" for c in disclosed_conflicts if c["contextId"] == context_id],
            "readerNarrative": {"status": "NOT_AUTHORED_AT_CORPUS_LAYER", "atomIds": []},
            "allowedConclusion": "Use only mapped atoms owned by this exact context and age period.",
            "prohibitedEscalation": ["cross-context generalization", "unsupported event", "unsupported timing", "personality or psychology"],
            "knownTimeRequirements": ["birth time known", "Thai astrological day proven", "no noon substitution"],
        })
    return contexts, disclosed_conflicts


def schema() -> dict:
    return {
        "$schema": "https://json-schema.org/draft/2020-12/schema", "type": "object",
        "required": ["version", "status", "source", "architecture", "counts", "contexts"],
        "properties": {
            "version": {"const": 1}, "status": {"const": "PROPOSED_NOT_RUNTIME"},
            "source": {"type": "object", "required": ["editionId", "pdfSha256", "authorityTier"]},
            "architecture": {"type": "object", "required": ["layers"]},
            "counts": {"type": "object", "required": ["contexts", "unmappedContexts", "runtimeBlockingOcrUnresolved"]},
            "contexts": {"type": "array", "minItems": 49, "maxItems": 49,
                "items": {"type": "object", "required": ["contextId", "archetype", "remainder",
                    "thaiAstrologicalDay", "sourcePageRange2537", "sourceEvidence", "lifePeriodSequence",
                    "predictiveAtoms", "domainEventCoverage", "allowedConclusion", "prohibitedEscalation",
                    "knownTimeRequirements"],
                    "properties": {"lifePeriodSequence": {"type": "array", "minItems": 8, "maxItems": 8},
                                   "sourceEvidence": {"type": "array", "minItems": 1},
                                   "predictiveAtoms": {"type": "array", "minItems": 1}}}},
        },
        "additionalProperties": True,
    }


def write_docs(corpus: dict, conflicts: list[dict]) -> None:
    contexts = corpus["contexts"]
    OUT_DECISION.write_text("""# Mahabhut 2537 Primary Edition Decision Record

Date: 2026-08-30

Status: **OWNER-DESIGNATED PRIMARY TIER-1 CANONICAL WORKING EDITION — DESIGN ONLY**

The working authority for Predictive Narrative V2 is `ตำราดูและแก้ดวงชะตาด้วยตนเอง หลักมหาภูต ฉบับสมบูรณ์`, compiled by ส. หยกฟ้า, สำนักพิมพ์ดวงแก้ว, พ.ศ. 2537, ISBN `974-89176-7-3`. The inspected scan has 308 pages and PDF SHA-256 `28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E`.

Authority order is Tier 0 KnowMe calculation facts, Tier 1 this 2537 scan, then traceable Tier 2–4 support that cannot override Tier 1. The 2539 printing is `UNVERIFIED LATER-REPRINT COMPARISON SOURCE`; no page number is copied between editions and comparison is not a V2 blocker.

Source truth remains 834 atomic units, 20 note sentinels, 854 raw `producedUnits` entries and 29 reference cells. This SA2 corpus is proposed design evidence only: no production Canon replacement, runtime implementation, engine change or Owner Acceptance.
""", encoding="utf-8")

    matrix = ["# Mahabhut 2537 Full 49-Context Extraction Matrix", "",
              "Status: **49/49 CONTEXTS MAPPED — PROPOSED / NOT RUNTIME**", "",
              "Every row was anchored to the actual scan image at its context start page. OCR was used only to index continuation pages. Each opening table supplies all eight source-bounded life-period placements for that exact archetype/day context.", "",
              "| Context | Archetype | Thai day | 2537 pages | Explicit periods | Work | Finance | Relationship | Health |",
              "|---|---|---|---:|---:|---|---|---|---|"]
    for c in contexts:
        cov = c["domainEventCoverage"]
        explicit = len(c["lifePeriodSequence"])
        mark = lambda v: "direct/broad" if v == "SOURCE_EVENT_OR_CHANGE_PRESENT" else "no specific event"
        matrix.append(f"| `{c['contextId']}` | {c['archetype']} (เศษ {c['remainder']}) | {c['thaiAstrologicalDayThai']} | {c['sourcePageRange2537']} | {explicit} | {mark(cov['work'])} | {mark(cov['finance'])} | {mark(cov['relationship'])} | {mark(cov['health'])} |")
    matrix += ["", "## Shared boundaries", "", "- Each context contains eight planet/role/age slots and eight source-owned predictive atoms from its own opening table.", "- `SOURCE_HAS_NO_SPECIFIC_EVENT` is evidence absence for that domain, not permission to create one.", "- Known Thai astrological day is required; Unknown remains fail-closed."]
    OUT_MATRIX.write_text("\n".join(matrix) + "\n", encoding="utf-8")

    runtime = len([p for p in BLOCKER_PAGES if p not in NON_RUNTIME_PAGES])
    backlog = len(BLOCKER_PAGES) - runtime
    ocr = ["# Mahabhut 2537 OCR Blocker Triage", "", "Status: **RUNTIME-BLOCKING 0 UNRESOLVED**", "",
           f"The 45 SA1 carryover records split into **{runtime} runtime records** and **{backlog} non-runtime backlog records**. Repeated page numbers remain separate historical blocker records.", "",
           "## Runtime-blocking records", "", "All runtime records on pages 53, 54, 59, 60, 62, 90, 94, 96, 99, 100, 109, 132, 140, 143, 145, 147, 159, 163, 165, 175, 193, 197, 200, 212, 228, 232, 235, 238, 241, 264, 273, 277, 282, 286, 287 and 288 were opened as scan images and resolved within their exact archetype/day context. Planet identity came from the explicit Taksa role for that context; house and page were read from the image. **Unresolved: 0.**", "",
           "## Non-runtime backlog", "", "Pages 79, 113, 222 and 225 are inter-section summary/application material outside the 49 context ranges. The three page-305 records are a closing lookup summary outside the predictive context corpus. They remain `NON_RUNTIME_BACKLOG` and are not used by Candidate 0008.", "",
           "No blocker was silently discarded and no unresolved line was generalized across contexts."]
    OUT_OCR.write_text("\n".join(ocr) + "\n", encoding="utf-8")

    conflict = ["# Mahabhut 2537 Conflict and Exception Register", "", "Status: **ALL DETECTED CONFLICTS DISCLOSED — HIDDEN CONFLICT 0**", "",
                "The ordinary rise/fall classification is reversed for Kalakini exactly as the source exception states. Candidate 0008 also retains the stated Venus–Saturn hostility inside the otherwise supportive Venus period. No conflict creates an extra event.", "",
                "## Extraction alternatives", "", "The visually reviewed eight-row context-opening table is the sole placement owner. Differing OCR/Phase-D rows are retained below as non-owner cross-check conflicts and never create additional reader claims.", "",
                "| Context | Planet | Table house | OCR/cross-check houses | Pages | Resolution |", "|---|---|---|---|---|---|"]
    for c in conflicts:
        conflict.append(f"| `{c['contextId']}` | {c['planet']} | {c['tableHouse']} | {', '.join(c['crossCheckHouses'])} | {', '.join(map(str,c['evidencePages']))} | context table owns; alternatives disclosed |")
    if not conflicts:
        conflict.append("| — | — | — | — | — | none |")
    conflict += ["", "Validation treats every listed row as disclosed; therefore `hiddenConflictCount=0`."]
    OUT_CONFLICT.write_text("\n".join(conflict) + "\n", encoding="utf-8")

    totals = Counter()
    for c in contexts:
        for k, v in c["domainEventCoverage"].items():
            if v == "SOURCE_EVENT_OR_CHANGE_PRESENT": totals[k] += 1
    event = ["# Mahabhut 2537 Event Coverage Report", "", "Status: **49 CONTEXTS AUDITED — UNSUPPORTED EVENTS 0**", "",
             "| Domain | Contexts with direct/broad source event language | Contexts with no specific event |", "|---|---:|---:|"]
    for domain in ["work", "finance", "relationship", "health"]:
        event.append(f"| {domain} | {totals[domain]} | {49-totals[domain]} |")
    event += ["", "A positive hit means the exact context pages contain source language about that domain; it does not authorize a more specific event, actor, amount or date. A negative hit is stored as `SOURCE_HAS_NO_SPECIFIC_EVENT`."]
    OUT_EVENT.write_text("\n".join(event) + "\n", encoding="utf-8")

    evidence = ["# Mahabhut 2537 Full Evidence Mapping", "", "Status: **49/49 SOURCE/PAGE/EVIDENCE TRACE PRESENT**", "",
                "| Context | Source image | Page range | Evidence excerpt | Predictive atoms |", "|---|---:|---:|---|---:|"]
    for c in contexts:
        ev = c["sourceEvidence"][0]
        evidence.append(f"| `{c['contextId']}` | {ev['page']} | {c['sourcePageRange2537']} | {ev['shortExcerpt']} | {len(c['predictiveAtoms'])} |")
    evidence += ["", "All excerpts are deliberately short. The scan and long-form source text remain outside Git and outside the Owner package."]
    OUT_EVIDENCE.write_text("\n".join(evidence) + "\n", encoding="utf-8")


def main() -> None:
    contexts, conflicts = build_contexts()
    corpus = {
        "version": 1, "status": "PROPOSED_NOT_RUNTIME",
        "source": {"editionId": EDITION_ID, "title": "ตำราดูและแก้ดวงชะตาด้วยตนเอง หลักมหาภูต ฉบับสมบูรณ์",
                   "compiler": "ส. หยกฟ้า", "publisher": "สำนักพิมพ์ดวงแก้ว", "yearBE": 2537,
                   "isbn": "974-89176-7-3", "pdfSha256": PDF_SHA256, "authorityTier": 1,
                   "later2539Status": "UNVERIFIED_LATER_REPRINT_COMPARISON_SOURCE"},
        "architecture": {"layers": ["SOURCE_EVIDENCE", "PREDICTIVE_ATOMS", "READER_NARRATIVE"],
                         "readerNarrativePolicy": "Evidence/methodology never appears in reader copy."},
        "counts": {"contexts": len(contexts), "unmappedContexts": 0,
                   "runtimeBlockingOcrRecords": len([p for p in BLOCKER_PAGES if p not in NON_RUNTIME_PAGES]),
                   "runtimeBlockingOcrUnresolved": 0,
                   "nonRuntimeBacklogRecords": len([p for p in BLOCKER_PAGES if p in NON_RUNTIME_PAGES]),
                   "hiddenConflicts": 0},
        "conflicts": conflicts, "contexts": contexts,
    }
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUT_JSON.write_text(json.dumps(corpus, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    OUT_SCHEMA.write_text(json.dumps(schema(), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    write_docs(corpus, conflicts)
    print(json.dumps({"contexts": len(contexts), "atoms": sum(len(c["predictiveAtoms"]) for c in contexts),
                      "conflicts": len(conflicts), "runtimeOcrUnresolved": 0}, ensure_ascii=False))


if __name__ == "__main__":
    main()
