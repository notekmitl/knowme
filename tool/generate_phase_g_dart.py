#!/usr/bin/env python3
"""Generate Phase G Dart test fixtures from JSON outputs."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ATOMIC_SRC = ROOT / "tool/output/phase_g_atomic_units.json"
REF_SRC = ROOT / "tool/output/phase_g_reference_cells.json"
ATOMIC_OUT = ROOT / "test/validation/thai/generated/phase_g_lookup_atomic_units.dart"
REF_OUT = ROOT / "test/validation/thai/generated/phase_g_reference_table_cells.dart"

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


def gen_atomic() -> None:
    units = json.loads(ATOMIC_SRC.read_text(encoding="utf-8"))
    lines = [
        "// Generated for Phase G lookup tables (atomic). Do not hand-edit.",
        "import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';",
        "import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';",
        "",
        "List<AtomicKnowledgeUnit> phaseGLookupAtomicUnits({",
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
        "    String? locator,",
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
        lines.append("        domain: KnowledgeDomain.lookupTables,")
        lines.append("        strength: AtomicStrength.none,")
        if u.get("condition"):
            lines.append(f"        condition: '{esc(u['condition'])}',")
        if u.get("locator"):
            lines.append(f"        locator: '{esc(u['locator'])}',")
        ctx_type = u.get("context_type")
        if ctx_type:
            lines.append(f"        contextType: {CTX[ctx_type]},")
            lines.append(f"        contextValue: '{esc(u['context_value'])}',")
        lines.append(f"        page: '{u['page']}',")
        lines.append("      ),")
    lines.append("    ];")
    lines.append("")
    ATOMIC_OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {len(units)} atomic units to {ATOMIC_OUT}")


def gen_ref() -> None:
    cells = json.loads(REF_SRC.read_text(encoding="utf-8"))
    lines = [
        "// Generated for Phase G lookup tables (reference cells). Do not hand-edit.",
        "import 'package:knowme/features/astrology/thai/knowledge/canon/reference/canon_reference_table_cell.dart';",
        "import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';",
        "",
        "List<CanonReferenceTableCell> phaseGReferenceTableCells() => [",
    ]
    for c in cells:
        lines.append("  CanonReferenceTableCell(")
        lines.append(f"    id: '{esc(c['id'])}',")
        lines.append(f"    tableId: '{esc(c['tableId'])}',")
        lines.append(f"    tableTitle: '{esc(c['tableTitle'])}',")
        lines.append(f"    rowKey: '{esc(c['rowKey'])}',")
        lines.append(f"    columnKey: '{esc(c['columnKey'])}',")
        lines.append(f"    cellValue: '{esc(c['cellValue'])}',")
        lines.append("    evidence: AtomicEvidenceRef(")
        lines.append("      bookId: 'mahabhut',")
        lines.append(f"      page: '{c['page']}',")
        lines.append(f"      locator: '{esc(c['tableTitle'])}',")
        lines.append("    ),")
        lines.append("  ),")
    lines.append("];")
    lines.append("")
    REF_OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {len(cells)} reference cells to {REF_OUT}")


def main() -> None:
    gen_atomic()
    gen_ref()


if __name__ == "__main__":
    main()
