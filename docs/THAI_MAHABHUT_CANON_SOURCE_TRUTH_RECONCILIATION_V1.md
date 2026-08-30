# Thai Mahabhut Canon Source Truth Reconciliation V1

Date: 2026-08-30

Status: **RECONCILED — EXTRACTED EDITION AND OWNER AUTHORITY EDITION KEPT DISTINCT**

## Authoritative current truth

The raw `producedUnits` array has 854 elements, but it does **not** contain 854
atomic units. It contains 834 objects with an `id` and 20 `$note` sentinels.
The separate `producedReferenceTableCells` array contains 29 cells. The frozen
production truth is therefore **834 atomic units + 29 reference-table cells**.
The top comment's 834 is correct; treating the raw array length as an atomic
count was the reconciliation error.

| Tree / commit | Atomic units | Note sentinels | Raw array | Reference cells |
|---|---:|---:|---:|---:|
| Phase F `fb09e228` | 770 | 18 | 788 | 0 |
| Phase G / freeze tree `f97e6247` | 825 | 19 | 844 | 29 |
| Post-Freeze Patch 001 `3b3df361` | 826 | 19 | 845 | 29 |
| Post-Freeze Patch 002 `1d49ca5a` and current PR start | 834 | 20 | 854 | 29 |

The historical Final Audit and Freeze documents state 825 atomic + 28
reference cells. Their atomic count matches the Phase G tree; their reference
count is one lower than the JSON actually committed by Phase G. Those records
remain immutable history. This document records the live-file correction
without rewriting frozen evidence.

## Working source availability

The configured local source root contains:

- `book.pdf`: 308 pages, 407,303,373 bytes
- 308 page PNGs
- 308 page-indexed OCR text files
- SHA-256 of the PDF:
  `28D74F5D7258A00EFA4967186B15ED97174E173AB12BD4DF9FBED66BD3EA890E`
- PDF page index = page-image index = OCR filename index = existing Canon
  `sourcePage`

The full scan, page set and OCR remain outside Git and outside Owner packages.
Only short necessary excerpts and extracted structures may be committed.

## Edition identity and non-equivalence gate

Visual inspection of the local scan's title and copyright pages establishes:

- title: `ตำราดูและแก้ดวงชะตาด้วยตนเอง หลักมหาภูต ฉบับสมบูรณ์`
- compiler: `ส. หยกฟ้า`
- local extraction scan year: พ.ศ. 2537
- publisher/imprint: สำนักพิมพ์ดวงแก้ว
- printer: บริษัท สหธรรมิก จำกัด
- ISBN printed in the scan: `974-89176-7-3`

The Owner-designated authority identity is the later 2539 reprint / printing 3.
[Google Books](https://books.google.com/books/about/%E0%B8%AB%E0%B8%A5%E0%B8%B1%E0%B8%81%E0%B8%A1%E0%B8%AB%E0%B8%B2%E0%B8%A0%E0%B8%B9%E0%B8%95_%E0%B8%89%E0%B8%9A%E0%B8%B1.html?id=QRMdMwEACAAJ)
records a 1996 reprint and ISBN `9748917673`; a
[second-hand bibliographic listing](https://megabooks4u.lnwshop.com/product/45582/%E0%B8%AB%E0%B8%A5%E0%B8%B1%E0%B8%81%E0%B8%A1%E0%B8%AB%E0%B8%B2%E0%B8%A0%E0%B8%B9%E0%B8%95%E0%B8%B4-%E0%B8%89%E0%B8%9A%E0%B8%B1%E0%B8%9A%E0%B8%AA%E0%B8%A1%E0%B8%9A%E0%B8%B9%E0%B8%A3%E0%B8%93%E0%B9%8C-%E0%B8%AA-%E0%B8%AB%E0%B8%A2%E0%B8%81%E0%B8%9F%E0%B9%89%E0%B8%B2-%E0%B8%AB%E0%B8%99%E0%B8%B1%E0%B8%87%E0%B8%AA%E0%B8%B7%E0%B8%AD%E0%B8%9A%E0%B9%89%E0%B8%B2%E0%B8%99-%E0%B8%A1%E0%B8%B7%E0%B8%AD%E0%B8%AA%E0%B8%AD%E0%B8%87-%E0%B8%AA%E0%B8%A0%E0%B8%B2%E0%B8%9E85-95-%E0%B8%AA%E0%B8%B1%E0%B8%99%E0%B8%9B%E0%B8%81%E0%B8%A1%E0%B8%B5%E0%B8%A3%E0%B8%AD%E0%B8%A2%E0%B9%81%E0%B8%AB%E0%B8%A7%E0%B9%88%E0%B8%87-%E0%B8%81%E0%B8%A3%E0%B8%B0%E0%B8%94%E0%B8%B2%E0%B8%A9%E0%B9%80%E0%B8%81%E0%B9%88%E0%B8%B2)
labels it printing 3 / 2539. Access date for both: 2026-08-30.

The 2539 source pages were not available for direct comparison. Same title,
ISBN and 308-page extent are not sufficient proof of page identity. Therefore:

- every new extraction in SA1 is explicitly scoped to
  `mahabhut-complete-duangkaew-2537-scan`;
- no 2537 page number is attributed to the 2539 reprint;
- promotion to the Owner-designated 2539 authority corpus requires a page map
  or direct edition comparison.

## Stale fields corrected

| File / field | Previous state | Corrected state |
|---|---|---|
| `canon_sources.json` note | content not extracted | frozen 834 + 29; edition mapping pending |
| `mahabhut.manifest.json` | null bibliography, `not_started` | scanned identity, hash, counts, `completed` |
| `library.manifest.json` | `notStarted`, zeros | `completed`, `canonApproved`, 834 + 29 |
| source README | source absent / extraction not begun | source available outside repo / frozen extraction complete |
| library-manifest test | expected `notStarted` | expected `completed` |

No production unit, reference cell, frozen audit, Freeze record or
`product-acceptance/` file was edited.

## Still unverified

- direct page equivalence between the 2537 extraction scan and 2539 reprint;
- a library record explicitly stating printing number 3 (Google Books says
  reprint, while the printing number is currently supported by a bookseller);
- backfilled chapter/section membership for the legacy manifest;
- human review of the proposed Canon V2 predictive-rule corpus.
