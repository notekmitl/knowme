# Thai Beta Full Report Export

**Status:** ACTIVE  
**Date:** July 2026  
**Commit:** Thai Beta Full Report Export  

---

## Why GoFullPage was abandoned

Flutter Web keeps report content inside engine host nodes (`flt-glass-pane` /
`flutter-view`). Even after syncing `documentElement` / `body` scroll heights,
browser full-page extensions (GoFullPage) still often capture only the first
viewport or produce inflated white space. Capture mode + host height sync remain
useful for debugging, but they are **not** a reliable user-facing export path.

---

## Export method chosen

**Option A — PDF from structured report data** (primary)

- Service: `ThaiBetaReportPdfExporter`
- Document builder: `ThaiBetaReportExportDocument.fromAnalysis(...)`
- Source: existing `ThaiMirrorConsumerViewState` (+ optional LEVEL 1 badge labels)
- Fonts: Noto Sans Thai via `PdfGoogleFonts` (`printing` package)
- Download: browser blob download on web (`downloadBytesAsFile`)

**Option B — Print-friendly page** (fallback)

- Page: `ThaiBetaExportPrintPage`
- Used when PDF generation or download fails
- User can Ctrl+P / Save as PDF in the browser

PNG long-capture is **not** implemented (canvas / memory risk).

---

## Export button / route

| Surface | Behavior |
|---------|----------|
| `/beta/thai/capture` | Shows **ดาวน์โหลดรายงานเต็ม** |
| `/beta/thai?screenshot=1` (screenshot mode report) | Same button |
| Normal `/beta/thai` report | **No** export button |
| `ThaiMirrorResultPage` public | **No** export button |
| Home / Daily Mirror | **No** export button |

Filename: `knowme-thai-report.pdf`

### Export button placement

On capture / screenshot mode, chrome is **pinned above the report** in the first
viewport (not inside the long scroll body):

1. Banner: **Thai Beta Capture Mode Active** (capture route only)
2. Primary: **ดาวน์โหลดรายงานเต็ม** (full-width filled button)
3. Secondary: **เปิดหน้าพิมพ์ / Save as PDF**
4. Then the long report content

Visibility is driven only by `screenshotMode` / capture route — **not** by
evidence badge feature flags, admin, or invited-beta audience.

---

## What is included

Copied from existing consumer report fields only:

1. Hero / identity summary  
2. Birth-data confidence  
3. Signature insight  
4. Strengths / cautions / advice  
5. Life dashboard  
6. Life timeline periods (consumer copy)  
7. Future prediction windows (consumer copy already on report)  
8. Narrative sections  
9. Reflection summary + closing message  
10. Source transparency + disclaimers  
11. LEVEL 1 public badge labels **only if** already allowed on the beta report  

---

## What is excluded / forbidden

Export safety scrub (`ThaiBetaReportExportSafety`) strips or rejects:

- raw Canon unit ids (`unit.…`)
- ontology ids
- remedy / แก้เคล็ด
- Taksa / ทักษา
- Khumsap / คุ้มทรัพย์
- ดวงขึ้น / ดวงตก
- source prose / unauthorized LEVEL 2 page refs
- analytics / tracking payloads

No new prediction text is generated. Engine / Canon / Mirror copy are unchanged.

---

## How to use

1. Open `https://knowme-app-694e1.web.app/beta/thai/capture` (login if required).  
2. Confirm **Thai Beta Capture Mode Active**.  
3. Click **ดาวน์โหลดรายงานเต็ม**.  
4. Browser downloads `knowme-thai-report.pdf`.  
5. If download fails, print page opens → use browser **Print → Save as PDF**.

---

## Tests

```bash
flutter test test/validation/thai_beta/thai_beta_report_export_test.dart
flutter test test/validation/thai_beta/ test/validation/thai/
```

Coverage includes: button visibility, forbidden-content scrub, existing-copy usage,
print fallback chrome, **real PDF exporter path regression** (`ThaiBetaReportPdfExporter.build`
plainText assertions), public fingerprint suite.

---

## Known limitations

- PDF font load uses Google Fonts network fetch at generate time (first export may
  need connectivity).
- Print fallback depends on browser print dialog.
- Export is **beta/internal capture surfaces only** — not a public product feature yet.
- GoFullPage is not supported as the export path.

---

## PDF polish

Draft PR #86 Round 4 treats pre-domain horizon summaries as independent PDF
semantic units. They are never prepended to the first domain. Disclaimer and
omission heading/lead/first-body groups render atomically, while domain units
retain continuation context after page breaks.

Export formatting is cleaned in `ThaiBetaReportExportPolish` + PDF layout.

| Issue | Fix |
|-------|-----|
| `ช่วงก่อนหน้า: ช่วงก่อนหน้า: …` | Neighbour labels already include prefix — collapse duplicates |
| `เหลืออีกประมาณ 0 ปี / 0 เดือน` | Rewrite to “กำลังอยู่ช่วงปลายของจังหวะนี้”; omit zero remaining |
| UI ellipsis truncations (`…`) | Prefer `expandedBody`; drop mid-word truncated UI fragments |
| `ดี(ผ่าน…)` spacing | Normalize spaces around `()` and `•` |
| Duplicate headings / keyword echo | Drop bare/`คำสำคัญ:` line when planetLine already ends with `• keyword` |
| Dense layout | Larger section gaps, timeline cards, disclaimer box, page numbers |

### Real PDF exporter path

Download button path:

`ThaiBetaReportExportButton._exportPdf`
→ `ThaiBetaReportExportDocument.fromAnalysis` (polish)
→ `ThaiBetaReportPdfExporter.build` / `buildBytes` (**polishForPdf again**)
→ `downloadBytesAsFile`

Regression tests assert on `ThaiBetaPdfRenderResult.plainText` — the exact Unicode
strings written into PDF widgets (custom font embedding prevents reliable Thai
extraction from raw PDF bytes).

### Known fixed copy issues

- Duplicate neighbour prefix
- Zero-year / zero-month remaining copy
- Truncated dashboard / card ellipsis fragments in export
- Missing space before parentheses
- Keyword heading echoes after `•`

### What PDF is for

PDF is the **primary** way for beta testers to save/share the full Thai report.
It packages **existing consumer report text** only — not a new prediction engine.

### Why GoFullPage is no longer the primary path

Flutter Web host/canvas scrolling does not reliably produce a clean full-page
browser capture. Capture mode remains for debugging; **ดาวน์โหลดรายงานเต็ม** is
the supported export path.

---

## Real-user session analysis (export source)

`/beta/thai/capture` exports **only** `ThaiBetaCurrentAnalysis.current`.

| Event | Export state |
|-------|----------------|
| Start new analysis (`ThaiBetaInputPage`) | `clear()` immediately |
| Analysis succeeds | `set(analysis)` stores it |
| Analysis fails | `set(failed)` clears — **no stale prior success** |
| No current success | Capture shows **ยังไม่มีรายงานสำหรับส่งออก** |
| `/beta/thai/capture-qa` | Separate QA sample route (labeled); never used as capture fallback |

---

**Report content / engine / Canon / badge policy unchanged — export packaging + presentation polish only.**
## Active Round 9 Fix Set 03 export contract

Product Acceptance passed as `PRODUCT_ACCEPTANCE_PASS — ROUND 9 FIX SET 03` on 2026-08-10. The owner reviewed 34/34 final PDF renders and both Web screenshots. Web and PDF export the same Claim, Risk, Decision Impact, Action, and separate uncertainty-disclosure values from the shared presentation model. PDF code never reconstructs predictive fields or parses audit fingerprints.

Disclosure is rendered as `ข้อจำกัดของคำอ่าน` after the four predictive fields and is excluded from cross-mode semantic comparison. Decision Impact and Action come from the same typed `ForecastDecisionPlan`; the exporter renders their composed strings without rebuilding or inferring intent. Unknown-time Action independently requires a real-result checkpoint.

Fix Set 03 makes ISO date tokens atomic while retaining ASCII hyphens and recognizes `โชคลาภ` as a separate domain heading. The acceptance screenshot harness loads Material Icons and suppresses its debug banner. Acceptance audits hash the final PDFs before checking semantic coherence and all 34 renders. The failed R2 visual log is not carried forward: a new full-resolution review covered every final page and both final screenshots. Historical inspection of the rejected 126/124-page candidate covered Known pages 1–40 only; the remaining 210 pages were waived, not passed. Page counts, hashes, and manual-upload status are authoritative in `TASK_RESULT.md`.

Rounds 5–7 export notes are historical and superseded by this contract.

## Production download verification — 2026-08-10

Production `https://knowme-app-694e1.web.app` served cache pin `a516d57`. Known-time 10:00 and Unknown-time analyses started at `/beta/thai`; the export action at the bottom of each result navigated inside the same SPA session to Capture Mode, preserving `ThaiBetaCurrentAnalysis.current`. The real download button was then clicked. Direct `/capture` navigation was not used.

- Known: `knowme-thai-report (15).pdf`; 59,590 bytes; 17 pages; SHA-256 `7A88C0BDF46FC4297FBFE28F6DAC4444725E0B56D8D5F165D1D6AFF298A58915`.
- Unknown: `knowme-thai-report (16).pdf`; 59,563 bytes; 17 pages; SHA-256 `6F3E995942314F01E7FB79A5FC27A979C73BFA9734CA40C91AA3288273218A40`.

Both Production files parsed and rendered on every page. Visual review found no true blank page, clipping, overflow, footer overlap, debug/sample/test marker, or Markdown leakage. ISO dates remained atomic and `โชคลาภ` remained a separate card from `สุขภาพ`. Known retained time-qualified Lagna/house facts; Unknown omitted their values and included explicit fail-closed reasons. The export document does not render submitted name fields; birth date and analysis mode matched the live fixtures. Runtime hashes are independent of the accepted Product Acceptance artifact hashes.

## Thai Report Reading Flow and Friendly Voice V1 — active draft

Status: `PENDING PRODUCT ACCEPTANCE`. This amendment keeps the real PDF exporter and the same `ThaiBetaAnalysis`; it changes presentation order and consumer wording only.

The PDF now follows the reader-facing sequence used by Web: Core interpretation and life domains first; then life map, past, present, 12-month outlook, next life period, and long-term outlook; then `รายงานนี้ดูจากอะไร`, source transparency, disclaimers, and explicit omissions. Thai astrological-day detail and chart structure remain present but no longer open the report. Natural field labels replace academic UI/PDF labels while typed Claim/Risk/Decision Impact/Action data remains unchanged.

Validation for this draft must include exact Web/PDF semantic parity, Known/Unknown behavior, ISO token atomicity, fortune/health ownership, full PDF raster review, desktop/mobile screenshots, and a separate hashed acceptance packet. Do not merge or deploy before Owner Product Acceptance.
