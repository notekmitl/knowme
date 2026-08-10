# Task: Thai Report Reading Flow and Friendly Voice V1

Owner feedback after the completed Round 9 release requires a new Product Narrative and Information Architecture pass for the Thai Beta Web/PDF report. This task does not change astrology calculations, Canon, factual provenance, ascendant/houses, timeline boundaries, beta policy, Auth, or Production.

## Delivery contract

- Baseline: `c34a1c088b555160707577308c281570b570752a` (`origin/main`).
- Branch: `agent/thai-report-reading-flow-v1`.
- Reader-facing interpretation leads; calculation method and chart structure move to final collapsed transparency controls.
- Web and PDF consume the same `ThaiBetaAnalysis`, core reading, timeline, and forecast state.
- Thai voice is warm, direct, plain, and uses `คุณ`; typed Risk → Decision Impact → Action semantics remain intact.
- Known-time facts remain unchanged; Unknown-time remains fail-closed.
- Round 9 is retained as completed historical evidence. Existing `product-acceptance/` is not changed.
- Final state for this task: `PENDING PRODUCT ACCEPTANCE`. Do not merge or deploy.

## Acceptance

- New reader-facing order is enforced for Web and PDF.
- `หลักการนับวันทางโหราศาสตร์ไทย` and `โครงสร้างดวงหลัก` are absent from the opening flow and available only near the end.
- Forecast fields use natural labels without weakening typed semantic ownership.
- Focused, full, analyzer, screenshot/golden, PDF raster, documentation, secret/PII, PreCommit, and PostCommit gates pass.
- A separate Known/Unknown acceptance packet is generated, hashed, rendered, visually reviewed, and copied to the Windows delivery location.
- Push a non-force branch and open a Draft PR. Do not merge or deploy.
