# PR #89 V1.2 Root-Cause Record

Recorded before V1.2 implementation on August 11, 2026.

## Owner decision

V1.1 was rejected as `REJECTED — NARRATIVE REMAINS FORMULAIC AND PDF PAGINATION IS VISIBLY BROKEN`. Product Acceptance remains pending. PR #89 must remain open and Draft; merge and deployment are prohibited.

## Formulaic narrative

V1.1 removed four visible field labels but `_naturalForecastBody` still concatenated the same semantic sequence for every domain: timed claim, decision impact, horizon bridge, risk signal, action, risk fallback, and optional transition reserve. `_naturalActionForPlan` also appended a risk response and the same transition-reserve family to otherwise distinct actions. Exact complete sentences differed because domain and horizon words changed, while internal clauses and sentence skeletons remained shared.

The V1.1 audit split only on newlines and terminal punctuation, normalized complete sentences, and compared exact keys. It did not segment Thai clauses, normalize domain/horizon substitutions, compare sentence skeletons, count transition families, or limit semantic fragments per paragraph. It therefore returned zero although the acceptance output contained meaningful internal repetition.

Past-period output carried summary, change, and advice fields for every period even when evidence did not support three distinct personal statements. Generic life-stage phrases consequently appeared in more than one period.

## Pagination

`_semanticBlocks` correctly separated the section preamble from each domain, but the PDF renderer treated every block as a new atomic pagination unit. For every block after the first it unconditionally generated `${section.title} (ต่อ)`, even when the block remained on the same page. It repeated the same continuation heading again for every bounded paragraph after the first. The regression test explicitly expected a continuation heading before work, finance, relationship, and health, preserving the defect.

V1.2 must render the parent section heading once, keep each domain heading with its opening body, and never use block index as a proxy for a page transition. A continuation heading is optional and will be omitted unless the renderer can prove a real page transition.

## Invalid V1.1 visual-review conclusion

The previous review checked raster legibility, clipping, blank pages, overflow, and footer collisions, but did not record page-level first heading, last visible line, or continuation-heading counts. It also lacked an explicit rejection rule for repeated headings or component-like fragmentation. This allowed pages 6–8 to be marked visually legible while still being editorially broken.

V1.2 review must inspect every rendered page at full resolution, record those page-level fields, count continuation headings, and reject any page that resembles the V1.1 pages 6–8 pattern.

