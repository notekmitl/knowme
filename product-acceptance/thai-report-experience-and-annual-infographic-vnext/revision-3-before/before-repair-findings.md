# Revision 3 before-repair findings

Source: immutable Revision 2 PNG bytes under `generated-artifacts/revision-2/`. Measurements are pixel coordinates on the exact 1080×1920 files, using the navy canvas color as the background boundary.

## Byte-level visual reproduction

| Fixture | First/last painted y | Ornament bounds `(l,t,r,b)` | Opportunity top | Empty vertical runs around ornament |
|---|---:|---:|---:|---:|
| Known | 49 / 1880 | 191,1067,888,1182 | 1485 | 303 px before + 302 px after |
| Unknown | 49 / 1880 | 191,1065,888,1181 | 1482 | 300 px before + 300 px after |
| Longest Known | 49 / 1880 | 191,1052,888,1167 | 1455 | 287 px before + 287 px after |
| Longest Unknown | 49 / 1880 | 191,1079,888,1194 | 1446 | 251 px before + 251 px after |
| Longest opportunity/caution | 49 / 1880 | 191,1079,888,1194 | 1446 | 251 px before + 251 px after |
| Thai multiline | 49 / 1880 | 191,1091,888,1206 | 1482 | 275 px before + 275 px after |

All six exact PNG byte payloads contain the title glyphs at y=49–103. The reported missing-title view can be reproduced only through a tall-image preview surface that crops the displayed top/bottom; a Chrome screenshot was proven pixel-identical to the source PNG. The artifact bytes themselves do not omit the title. Revision 3 still replaces the flexible two-`Spacer` composition so preview/capture surfaces cannot depend on a large vertically centered middle region.

## Confirmed visual defects

- Two flex spacers place 502–606 empty pixels around a 697×116 px ellipse/rosette. The ellipse reads like a placeholder or chart boundary despite `monthlyTimelineAvailable = false`.
- Primary content is concentrated in the top ~40% and bottom ~23% of the canvas, leaving the middle visually unfinished.
- The ornament painter uses two long ellipse arcs, visually closer to a data frame than a clearly decorative Thai motif.
- The disclaimer ends at y=1880 (40 px from the bottom). It remains inside the canvas, but the bottom group has little breathing room compared with the oversized middle gap.
- Known and Unknown share the same widget hierarchy, but longer Unknown copy creates denser cards while the middle gap remains large instead of redistributing space.

## Confirmed copy defects

- Unknown categories repeat `ควรดูผลที่เกิดซ้ำก่อนตัดสินใจ` in all four domains.
- Multiple categories repeat `และเผื่อแรงไว้ในช่วงเปลี่ยนผ่าน` even though it is report-level annual guidance.
- Themes repeatedly use abstract phrases such as `ให้ใช้ขอบเขตหน้าที่ที่เปลี่ยนไปเป็นสัญญาณ` and `พฤติกรรมหลังข้อตกลงเริ่มชัด`.
- Unknown closing advice contains constructions such as `ใช้ความถนัดในการสร้างฐานทีละขั้นกับข้อมูลที่เกิดซ้ำจริง` and `พฤติกรรมที่ทำตามคำตกลงจะยืนยันได้`.
- Revision 2 corpus still contains repeated general caveats inside individual category cards, making the four domains sound system-generated even though their domain-specific claims differ.

## Repair boundary

Revision 3 will change only the opt-in reader-copy projection, shared infographic layout/tests, and new evidence. Accepted default/canonical R7.1 text and frozen R1–R7.1 artifacts remain immutable. No monthly engine or inferred month data will be added.
