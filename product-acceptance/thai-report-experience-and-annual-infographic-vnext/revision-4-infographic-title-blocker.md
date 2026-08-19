# Revision 4 infographic title integrity — root-cause and gate record

Status: **Technical verification passed; Owner copy/visual Approved; Final Merge Gate pending; PR #100 Draft; not deployed.**

## Owner observation and byte-level finding

Owner visual inspection rejected Revision 3 after at least `unknown`, `stress-unknown-longest`, and `stress-opportunity-caution-longest` appeared without `ดวงชะตาปี 2569`. That observation is preserved. Direct PNG hashing and raster inspection proves the stored files did not lose the title: Revision 3 and freshly generated Revision 4 are byte-identical for all 15 PNGs, including the three reported files. Their SHA-256 values are respectively `E5FB1E493C1F74E0F4B76E92504A102BA1D248A3F87B626DC6CFCB6227846FA8`, `B5E98C7C79667C7AFD174113A89ABFFD3B35552DC9272BE3945F8A9D08B53A48`, and `ABFA660523D7EA271B5A2C969BB471A981E6DDA4036A23613AAC41DAA5C2F5E5` in both revisions.

The first divergence is after final file identity: the evidence viewer can render the same bytes differently when previews collide. A SHA-bound copy and an identity-labelled contact sheet show the title while a direct preview of byte-identical content can omit it. This reproduces the display defect without attributing it incorrectly to the model, widget, layout, `RepaintBoundary`, font loading, capture timing, generator, or stored PNG.

## Production/capture path proof

1. `ThaiBetaAnnualInfographicData.title` derives `ดวงชะตาปี 2569/2570` from Bangkok-civil `asOf`.
2. `ThaiBetaAnnualInfographicPanel` binds one title widget and one semantics value.
3. Normal, compact and stress fixtures share that widget; no fixture override omits the title.
4. Title bounds are inside the 1080×1920 canvas and top safe area; no negative translation is used.
5. The same `RepaintBoundary` is settled after fonts load and captured twice; both captures are byte-identical.
6. Every fixture has a unique output path and input-identity sidecar; the aggregate gate rejects basename collisions, swaps and stale hashes.
7. The standalone validator reopens final PNG bytes and requires painted title pixels plus a title-region hash different from a navy background control.
8. Contact sheets add Revision, fixture ID and source filename so review no longer depends on ambiguous preview identities.

No application implementation, accepted copy, astrology logic, canonical text, golden, PDF pagination logic or monthly data was changed for Revision 4.

## Complete 15-fixture final-file audit

| Fixture | Final path | SHA-256 | Pixels | Expected title | Widget | Bounds | Raster title | First divergence |
|---|---|---|---:|---|---:|---|---|---|
| `known` | `generated-artifacts/revision-4/annual-infographic-known.png` | `026445FFB0BC5EBF1445C90C8E7A4F7F9FF77B7B4B31565A58D1E4D406CC5E04` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `unknown` | `generated-artifacts/revision-4/annual-infographic-unknown.png` | `E5FB1E493C1F74E0F4B76E92504A102BA1D248A3F87B626DC6CFCB6227846FA8` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `owner-known-0035` | `generated-artifacts/revision-4/annual-infographic-owner-known-0035.png` | `DC58DD52F60CA16480D2AD783DF9114181453106AC930EF7D16EFCFDF5A796E6` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `owner-unknown` | `generated-artifacts/revision-4/annual-infographic-owner-unknown.png` | `B9E8A8EC0EE4E8D840BE8D5E06026CC5AD295E72CC40527121DA32C11C508115` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `regression-known-0003` | `generated-artifacts/revision-4/annual-infographic-regression-known-0003.png` | `DC58DD52F60CA16480D2AD783DF9114181453106AC930EF7D16EFCFDF5A796E6` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `comparison-known-bangkok` | `generated-artifacts/revision-4/annual-infographic-comparison-known-bangkok.png` | `F09B1B17A497694F596B2C67DAD31A06470281E979F5A4A74C4516883B3CCBD8` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `comparison-known-khon-kaen` | `generated-artifacts/revision-4/annual-infographic-comparison-known-khon-kaen.png` | `EA42A1C990BA97D15A10ECE2D2F49BB458509B9DF67D171AD663D91AA93ABB1C` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `stress-known-longest` | `generated-artifacts/revision-4/annual-infographic-stress-known-longest.png` | `9FC63C0E3C6AC4BB40070BEC931BFA7C63815BDCBA7D8E00F77D7DDC43D1E37C` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `stress-unknown-longest` | `generated-artifacts/revision-4/annual-infographic-stress-unknown-longest.png` | `B5E98C7C79667C7AFD174113A89ABFFD3B35552DC9272BE3945F8A9D08B53A48` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `stress-opportunity-caution-longest` | `generated-artifacts/revision-4/annual-infographic-stress-opportunity-caution-longest.png` | `ABFA660523D7EA271B5A2C969BB471A981E6DDA4036A23613AAC41DAA5C2F5E5` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `stress-disclaimer-longest` | `generated-artifacts/revision-4/annual-infographic-stress-disclaimer-longest.png` | `01081DCDF0D8E953ADEEA4E37D4C41642941016061E03F11602C306AD20176E7` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `stress-thai-multiline` | `generated-artifacts/revision-4/annual-infographic-stress-thai-multiline.png` | `C448E80680703E79C8DAD817B1E98B5459EC9F6987DBFAF0321E83235309423E` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `stress-regression-1972` | `generated-artifacts/revision-4/annual-infographic-stress-regression-1972.png` | `9F743CBAFA28C70F73B425FC39CDC9E20622ABE4645494745A3B0147A7300110` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `year-boundary-2569` | `generated-artifacts/revision-4/annual-infographic-year-boundary-2569.png` | `DC58DD52F60CA16480D2AD783DF9114181453106AC930EF7D16EFCFDF5A796E6` | 1080×1920 | ดวงชะตาปี 2569 | 1 | 138,39–1032,129 | yes; 8,457 pixels | preview only |
| `year-boundary-2570` | `generated-artifacts/revision-4/annual-infographic-year-boundary-2570.png` | `4F1A6F983D7CE81E69B8C360460F516E0B9D2AC537083A573E6AA9768B0B071F` | 1080×1920 | ดวงชะตาปี 2570 | 1 | 138,39–1032,129 | yes; 8,186 pixels | preview only |

## Gate result

Generator and standalone validator pass 15/15 with missing 0, mismatch 0, unlisted 0, duplicate paths 0 and title-raster failures 0. Negative tests reject omitted title, off-canvas title, fixture/output swaps, stale hashes and duplicate basename/cache identities. Manual review used original-resolution SHA-bound copies plus five identity-labelled sheets; no clipping, overflow, overlap, fake monthly visualization, birth details or placeholder data graphics were found.

Owner decision is **Approved** for 60/60 grouped rules, 4,407/4,407 ledger fields, 15/15 infographics and 14/14 PDFs / 105/105 pages. Approval is bound to evidence HEAD `87bd8d466d5ed657667c6ab2c21871d4ffd2ab5d` and manifest `A03C979B8FA9F1BAFA85993371C17E19475DD2DE0927840CCD87002BC203BC78`. `monthlyTimelineAvailable=false`. Keep PR #100 Draft until the Final Merge Gate passes; do not Deploy or mutate Firebase.
