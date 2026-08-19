# Revision 3 blocker — Owner Known PDF page 1 clipping

Historical status at stop time: **BLOCKED — mandatory PDF visual gate appeared to fail.** Current status: **RESOLVED BY BYTE-IDENTITY PROOF; final technical gates passed; Owner copy/visual Approved.**

Manual inspection of the final Revision 3 renders found that the `owner-known-0035` first page is not a complete page in either PDF path. Both renders begin at the heading `งานจะไปต่อได้ เมื่อข้อตกลงยังชัดและทำได้จริง`; the KnowMe report header, birth-chart introduction, and earlier opening copy are absent above it. This is present in each final page PNG itself, so it is not caused by contact-sheet scaling.

| Render | Dimensions | SHA-256 | Result |
|---|---:|---|---|
| `renders/revision-3/browser-print-owner-known-0035/page-1.png` | 909×1287 | `7C0BE83B8085A76BFE8B2E4178E59B0797E14D4AE3F524873A8CAE7F1FD5A91A` | FAIL — top content clipped/missing |
| `renders/revision-3/dedicated-report-owner-known-0035/page-1.png` | 910×1287 | `D5BC91F9ED2AC9684B9D1A5AF79748A01F00CE5384D4043C491A189BD0DE62B0` | FAIL — top content clipped/missing |

Control pages are complete:

| Render | Dimensions | SHA-256 | Result |
|---|---:|---|---|
| `renders/revision-3/browser-print-comparison-known-khon-kaen/page-1.png` | 909×1287 | `255AD176E0F66FD08512F17D7A81D98BB63D9D3446FD5EA13635C38D9BE830D1` | complete |
| `renders/revision-3/dedicated-report-comparison-known-khon-kaen/page-1.png` | 910×1287 | `1DFAF11372249F48F73398C3A66F99A317B26992B701BD06FF33F7B62FD6BDE4` | complete |

Required repair scope for a later authorized task: diagnose the shared `owner-known-0035` pagination/content-flow path and regenerate both PDF variants plus all dependent renders/contact sheets. Re-run semantic inventory and the PDF visual gate before resuming the remaining Final Gate. Do not hide the defect by removing copy, changing canonical/expected output, shrinking text below the design minimum, or accepting a partial first page.

At this historical checkpoint PR #100 remained Open, Draft and unmerged at `21fbcd51d16d5a289d215791780c95a1b0db389a`. The Owner subsequently Approved the Revision 3/4 copy and visual scope at `2026-08-19T08:52:49Z`. Production remains V1.5 Hosting version `5f98dfffef913e38`. Deploy and Firebase mutation are not authorized.

## 2026-08-19 correction after byte-identity investigation

The blocker above is preserved as the contemporaneous reason work stopped, but its statement that both PDF files were clipped is corrected: the PDF bytes and the PNG bytes were not clipped. A direct Poppler rerender of the browser PDF to a globally unique basename produced a byte-identical PNG (46,201 bytes; SHA-256 `7C0BE83B8085A76BFE8B2E4178E59B0797E14D4AE3F524873A8CAE7F1FD5A91A`) that visibly contains the complete header and introduction. PDF text extraction and glyph geometry independently confirm that the browser and dedicated page-one content lies inside their page boxes.

The false visual result came from the evidence-display path reusing the basename `page-1.png` across every PDF directory, allowing the preview cache to associate the requested path with another page image. Resolution therefore binds every final render filename to its source PDF stem and validates the source PDF text, coordinates, page box, raster bounds, and hash. Full evidence and Final Gate status are recorded in `revision-3-pdf-page-one-repair.md`; this historical blocker is not deleted or rewritten as if the observation never occurred.
