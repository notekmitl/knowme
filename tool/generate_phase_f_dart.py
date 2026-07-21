#!/usr/bin/env python3
"""Generate phase_f_remedy_units.dart from phase_f_remedy_units.json."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "tool/output/phase_f_remedy_units.json"
OUT = ROOT / "test/validation/thai/generated/phase_f_remedy_units.dart"

CTX = {
    "archetype_chart": "AtomicContextType.archetypeChart",
    "life_period": "AtomicContextType.lifePeriod",
    "other": "AtomicContextType.other",
    None: None,
}

REL = {
    "located_in": "AtomicRelation.locatedIn",
    "owns": "AtomicRelation.owns",
    "relates_to": "AtomicRelation.relatesTo",
    "produces": "AtomicRelation.produces",
    "opposes": "AtomicRelation.opposes",
    "supports": "AtomicRelation.supports",
    "requires": "AtomicRelation.requires",
}


def esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "\\'")


def main() -> None:
    units = json.loads(SRC.read_text(encoding="utf-8"))
    lines = [
        "// Generated for Phase F remedies. Do not hand-edit.",
        "import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';",
        "import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';",
        "",
        "List<AtomicKnowledgeUnit> phaseFRemedyUnits({",
        "  required AtomicKnowledgeUnit Function({",
        "    required String id,",
        "    required String subject,",
        "    AtomicEntityKind subjectKind,",
        "    required AtomicRelation relation,",
        "    required String object,",
        "    AtomicEntityKind objectKind,",
        "    AtomicContextType? contextType,",
        "    String? contextValue,",
        "    KnowledgeDomain domain,",
        "    AtomicStrength strength,",
        "    String? condition,",
        "    required String page,",
        "  }) unit,",
        "}) =>",
        "    [",
    ]
    for u in units:
        lines.append("      unit(")
        lines.append(f"        id: '{esc(u['id'])}',")
        lines.append(f"        subject: '{esc(u['subject'])}',")
        lines.append(f"        subjectKind: AtomicEntityKind.{u.get('subjectKind', 'other')},")
        lines.append(f"        relation: {REL[u['relation']]},")
        lines.append(f"        object: '{esc(u['object'])}',")
        lines.append(f"        objectKind: AtomicEntityKind.{u.get('objectKind', 'other')},")
        lines.append("        domain: KnowledgeDomain.remedies,")
        lines.append("        strength: AtomicStrength.none,")
        if u.get("condition"):
            lines.append(f"        condition: '{esc(u['condition'])}',")
        ctx_type = u.get("context_type")
        if ctx_type:
            lines.append(f"        contextType: {CTX[ctx_type]},")
            lines.append(f"        contextValue: '{esc(u['context_value'])}',")
        lines.append(f"        page: '{u['page']}',")
        lines.append("      ),")
    lines.append("    ];")
    lines.append("")
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {len(units)} units to {OUT}")


if __name__ == "__main__":
    main()
