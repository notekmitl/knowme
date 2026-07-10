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
print fallback chrome, public fingerprint suite.

---

## Known limitations

- PDF font load uses Google Fonts network fetch at generate time (first export may
  need connectivity).
- Print fallback depends on browser print dialog.
- Export is **beta/internal capture surfaces only** — not a public product feature yet.
- GoFullPage is not supported as the export path.

---

**Report content / engine / Canon / badge policy unchanged — export packaging only.**
