# PR #149 — integrated reader hero comparison

Application commit: `e8bcfa72ffc292964f40e1df1de0465db1070960`.
CI run `41201507946` passed all three required checks. Captures are from
Hosting Preview version `618a0d087d43aa9b`, expiring 7 Nov 2026 19:40:50
Asia/Bangkok; only the 320 px screenshot is from the identical isolated build.
The approved boards are visual references. Their text, chart placements and
numbers are illustrative, so the running trial renders calculated data and
existing reading strings instead. The captures below use synthetic inputs.

| View | Approved direction | Before this pass | New Hosted Preview |
| --- | --- | --- | --- |
| Overall 390×844 | [mobile board](../pr149-approved-visual/reference-mobile.png) | [old](../pr149-approved-visual/mobile-overall.png) | [current](hosted-overall-390.png) |
| Overall 1280×800 | [desktop board](../pr149-approved-visual/reference-desktop.png) | [old](../pr149-approved-visual/desktop-overall.png) | [current](hosted-overall-1280.png) |
| Overall expanded 1280×800 | — | [old](../pr149-approved-visual/desktop-overall-expanded.png) | [current](hosted-overall-expanded-1280.png) |
| Chinese 390×844 | [mobile board](../pr149-approved-visual/reference-mobile.png) | [old](../pr149-approved-visual/mobile-chinese.png) | [current](hosted-chinese-390.png) |
| Chinese 1280×800 | [desktop board](../pr149-approved-visual/reference-desktop.png) | [old](../pr149-approved-visual/desktop-chinese.png) | [current](hosted-chinese-1280.png) |
| Western 390×844 | [mobile board](../pr149-approved-visual/reference-mobile.png) | [old](../pr149-approved-visual/mobile-western.png) | [current](hosted-western-390.png) |
| Western 1280×800 | [desktop board](../pr149-approved-visual/reference-desktop.png) | [old](../pr149-approved-visual/desktop-western.png) | [current](hosted-western-1280.png) |
| Thai deep reading 390×844 | [mobile board](../pr149-approved-visual/reference-mobile.png) | [old](../pr149-approved-visual/mobile-thai-full.png) | [current](hosted-thai-deep-390.png) |
| Thai deep reading 1280×800 | [desktop board](../pr149-approved-visual/reference-desktop.png) | [old](../pr149-approved-visual/desktop-thai-full.png) | [current](hosted-thai-deep-1280.png) |
| Overall 320 px | — | — | [local narrow check](local-overall-320.png) |

The Overall artwork and three calculated lens facts now occupy one surface.
At desktop width, four collapsed life cards form a 2×2 grid; opening a card
grows it vertically and preserves every character of the existing reading.
The Chinese day master and four pillars sit in the same illustrated panel;
element counts remain available in its disclosure. The Western Big 3, overview
and calculated element proportions share one illustrated surface. Thai deep
report section cards and the nested 12-month infographic tiles use jade and
gold only in the anonymous trial. The
standalone Thai report is unchanged.

The references contain ornate chart wheels and bespoke illustrated icons that
are not calculated chart renderers. The implementation keeps the generated
artwork decorative and uses native text/icons for computed facts. Chinese and
Western desktop reports retain their linear article reading below the hero;
they do not copy the boards' 2×2 topic tiles. At 320 px, the Overall title
wraps and some short lens fact chips use ellipsis; the full calculated details
remain in the individual lenses. Owner review of the running UI is pending.

See [Hosted QA summary](hosted-qa-summary.json), [asset hashes](hosted-hashes.json),
and [Hosting before/after versions](hosting-state.json),
and sanitized network traces for [mobile known time](network-hosted-a-390.json),
[desktop known time](network-hosted-b-1280.json),
[mobile unknown time](network-hosted-unknown-390.json), and
[desktop unknown time](network-hosted-unknown-1280.json). Traces omit birth
inputs and reading text. No actual personal data was used.
