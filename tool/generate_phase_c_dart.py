#!/usr/bin/env python3
"""Generate phase_c_taksa_units.dart from phase_c_taksa_units.json."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "tool/output/phase_c_taksa_units.json"
OUT = ROOT / "test/validation/thai/generated/phase_c_taksa_units.dart"

CTX = {
    "archetype_chart": "AtomicContextType.archetypeChart",
    "life_period": "AtomicContextType.lifePeriod",
    "other": "AtomicContextType.other",
    None: None,
}


def main() -> None:
    units = json.loads(SRC.read_text(encoding="utf-8"))
    lines = [
        "// Generated for Phase C Taksa production. Do not hand-edit.",
        "import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';",
        "import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';",
        "",
        "List<AtomicKnowledgeUnit> phaseCTaksaUnits({",
        "  required AtomicKnowledgeUnit Function({",
        "    required String id,",
        "    required String subject,",
        "    AtomicEntityKind subjectKind,",
        "    required AtomicRelation relation,",
        "    required String object,",
        "    AtomicEntityKind objectKind,",
        "    AtomicContextType? contextType,",
        "    String? contextValue,",
        "    required String page,",
        "  }) unit,",
        "}) =>",
        "    [",
    ]
    for u in units:
        subj_kind = "planet" if u["subject"].startswith("planet.") else "other"
        obj_kind = u.get("objectKind", "other")
        ctx_type = u.get("context_type")
        ctx_val = u.get("context_value")
        lines.append("      unit(")
        lines.append(f"        id: '{u['id']}',")
        lines.append(f"        subject: '{u['subject']}',")
        lines.append(f"        subjectKind: AtomicEntityKind.{subj_kind},")
        rel = u["relation"]
        rel_enum = {
            "located_in": "AtomicRelation.locatedIn",
            "owns": "AtomicRelation.owns",
            "relates_to": "AtomicRelation.relatesTo",
        }[rel]
        lines.append(f"        relation: {rel_enum},")
        lines.append(f"        object: '{u['object']}',")
        lines.append(f"        objectKind: AtomicEntityKind.{obj_kind},")
        if ctx_type:
            lines.append(f"        contextType: {CTX[ctx_type]},")
            lines.append(f"        contextValue: '{ctx_val}',")
        lines.append(f"        page: '{u['page']}',")
        lines.append("      ),")
    lines.append("    ];")
    lines.append("")
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {len(units)} units to {OUT}")


if __name__ == "__main__":
    main()
