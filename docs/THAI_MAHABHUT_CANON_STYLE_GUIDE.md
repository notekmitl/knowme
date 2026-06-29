# Thai Astrology — Canon Style Guide (Mahabhut)

Standards for extracting "หลักมหาภูต" so the whole book is consistent. This guide
governs **how to record** what the book says — it never licenses adding meaning
the book does not state. When the book is silent, leave the field empty.

Status: **CURRENT** · Decision Log **D-055**, **D-057**, **D-058** · paired with
`THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST.md` and the ingestion toolchain.

> **Atomic Knowledge (V2, D-058):** the canonical object is now the
> `AtomicKnowledgeUnit` — **one atomic fact** (`subject --relation--> object`,
> + condition/effect/strength/confidence/evidence), not a "Statement". Extract
> *entities, relationships, conditions, effects, exceptions* — never paragraphs,
> summaries, interpretation or prediction. A paragraph with N ideas becomes N
> units. See `THAI_CANON_ATOMIC_KNOWLEDGE_V2.md`.
>
> **Canonical Ontology (V3, D-059):** subjects, objects, domains and relationships
> MUST come from the **Canonical Ontology Layer** (`canon/ontology/`). Identify
> entities by their stable id (`planet.jupiter`, `domain.finance`,
> `relationship.owns`) — never by display text — and resolve surface forms via
> alias resolution (unknown/ambiguous stays unresolved; never guess). No package
> may invent entity or relationship names. See `THAI_CANON_ONTOLOGY_V3.md`.

> Golden rule: **extract knowledge, cite by reference**. Record the book's
> *concepts, relationships, logic and rules* as structured knowledge — **never
> store copyrighted paragraph text** in the canon. No interpretation, no internet,
> no memory-sourced content, no guessing. Every unit traces to book › chapter ›
> section › page.

## 0 · Provenance & copyright (D-057)

The book is a **Canon Reference**, not a corpus to copy. Therefore:

- The promoted unit `statement` is the **structured knowledge** the reviewer
  authored from the source — *not* the book's paragraph. The verbatim paragraph
  may live only in the local working candidate file as reading material; it is
  never promoted to `canon_database.knowme.json`.
- **Provenance is by reference**: `page` (+ `chapter`/`section`) is required for
  approval. A verbatim `quote` is **not** required and, if used at all, must be a
  short locator (a term or table label), never a paragraph.
- Narrative is always **generated from the knowledge layer**; never hardcode book
  paragraphs into narratives.

---

## 1 · ID naming

Deterministic, lowercase, hyphenated; never reuse an id for different content.

- Book: the `sourceId` registered in `canon_sources.json` — `mahabhut`.
- Chapter: `mahabhut-chNN` (`mahabhut-ch01`). Two-digit, ordered.
- Section: `mahabhut-chNN-sNN`.
- Candidate / unit: `mahabhut-cNNNN` (4-digit running number from extraction).
- Evidence: `<unitId>-e`. Cross-reference: `<unitId>-xNN`. Example unit:
  `<unitId>-exNN` (auto-generated on promotion — do not hand-edit).

If two paragraphs state the **same** rule, give them **one** id (do not create a
second) — the Consistency Checker flags duplicate-id violations.

## 2 · Concept naming

- `subject` = a stable machine key (snake/lower, ASCII where practical), e.g.
  `venus`, `saturn`, `lagna`, `bhava_7`.
- `title` = the book's own Thai term for that concept (e.g. `ดาวศุกร์`).
- One `subject` ⇒ exactly one `title`. Do not mix `ศุกร์`/`ดาวศุกร์` for the same
  subject — the Consistency Checker flags `concept_naming`.

## 3 · Rule naming

- `type: rule`. `subject` identifies what the rule is about (e.g.
  `venus->saturn`). `statement` is the rule expressed as **structured knowledge**
  faithful to the book — not the copied paragraph.
- `value` holds the normalised outcome only when the book states one
  (`friend` / `enemy` / `neutral` / a number). Otherwise leave empty.
- Every rule should link to the concept(s)/formula it depends on via a
  cross-reference (otherwise it is flagged as an orphan rule).

## 4 · Formula naming

- `type: formula`. `subject` = the formula's name/scope. `statement` = the
  formula's logic/structure (the symbolic form, not surrounding prose). Put the
  normalised form in `value` when the book prints it.
- Never create the same formula twice — reuse the id and cross-reference it.

## 5 · Writing Meaning

- `type: meaning`. Record the book's stated meaning as structured knowledge in
  `statement` (faithful, not a copied paragraph).
- No synthesis across passages. One meaning unit per stated meaning.

## 6 · Writing Interpretation

- `type: interpretation`. Use only when the book itself interprets (e.g. "this
  indicates…"). Capture the interpretation faithfully as structured knowledge;
  cite the page by reference.
- Link interpretations to the formula/rule they interpret
  (`formulaToInterpretation`).

## 7 · Writing Exception

- `type: exception`, or record on the parent unit's `exceptions` list when the
  book frames it as an exception to a specific rule.
- Capture the condition exactly. Cross-reference the rule it modifies.

## 8 · Writing Cross References

Create a cross-reference whenever the book ties two units together. Pick the
narrowest matching type:

| Type | From → To |
| --- | --- |
| `ruleToRule` | rule → rule |
| `conceptToConcept` | concept → concept |
| `conceptToFormula` | concept → formula |
| `formulaToInterpretation` | formula → interpretation |
| `chapterToChapter` | structural link |
| `exampleOf` | example → its parent (auto on promotion) |
| `seeAlso` / `refines` / `dependsOn` / `contradicts` | general links |

Cross-reference targets must exist (in this batch or already in the Canon
Database) — broken targets are validation errors.

## 9 · Conditions, examples, notes

- `conditions`: verbatim pre-conditions the book attaches to a unit.
- `examples`: the book's worked examples (promoted to `example` units linked by
  `exampleOf`).
- `extractionNotes`: record book problems (duplicate text, archaic spelling,
  hard tables, ambiguity) here — **never** edit the source to "fix" them.

## 10 · Confidence

Set `confidence` from how the book states it (definitive vs. qualified). When in
doubt leave it `none`; confidence never substitutes for a citation.

---

These standards are enforced mechanically where possible by the Validation
Engine, Review Assistant, Coverage Analysis and Consistency Checker, and
reviewed by a human against `THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST.md` before a
unit becomes Canon Approved.
